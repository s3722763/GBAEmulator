module ALU (
	input[31:0] aBus,
	input[31:0] barrelOutput,
	
	input clk,
	//input opAnd, opEor, opSub, opRsb, opAdd, opAdc, opSbc, opRsc, opTst, opTeq, opCmp, opCmn, opOrr, opMov, opBic, opMvn,
	input[3:0] aluOp,
	input updateFlags,
	input carryFlag, zeroFlag, overflowFlag, negativeFlag,
	
	output newCarryFlag, newZeroFlag, newOverflowFlag, newNegativeFlag,
	output[31:0] aluBus
);
    // Decode aluOp
    var opAnd, opEor, opSub, opRsb, opAdd, opAdc, opSbc, opRsc, opTst, opTeq, opCmp, opCmn, opOrr, opMov, opBic, opMvn;
    always @(posedge clk) begin
        opAnd = 1'b0;
        opEor = 1'b0;
        opSub = 1'b0;
        opRsb = 1'b0;
        opAdd = 1'b0;
        opAdc = 1'b0;
        opSbc = 1'b0;
        opRsc = 1'b0;
        opTst = 1'b0;
        opTeq = 1'b0;
        opCmp = 1'b0;
        opCmn = 1'b0;
        opOrr = 1'b0;
        opMov = 1'b0;
        opBic = 1'b0;
        opMvn = 1'b0;

        case(aluOp)
            4'b0000: begin
                opAnd = 1'b1;
            end
            4'b0001: begin
                opEor = 1'b1;
            end
            4'b0010: begin
                opSub = 1'b1;
            end
            4'b0011: begin
                opRsb = 1'b1;
            end
            4'b0100: begin
                opAdd = 1'b1;
            end
            4'b0101: begin
                opAdc = 1'b1;
            end
            4'b0110: begin
                opSbc = 1'b1;
            end
            4'b0111: begin
                opRsc = 1'b1;
            end
            4'b1000: begin
                opTst = 1'b1;
            end
            4'b1001: begin
                opTeq = 1'b1;
            end
            4'b1010: begin
                opCmp = 1'b1;
            end
            4'b1011: begin
                opCmn = 1'b1;
            end
            4'b1100: begin
                opOrr = 1'b1;
            end
            4'b1101: begin
                opMov = 1'b1;
            end
            4'b1110: begin
                opBic = 1'b1;
            end
            4'b1111: begin
                opMvn = 1'b1;
            end
        endcase
    end

	wire[31:0] outputValue;
	wire canOutput;
	
	assign canOutput = opAnd | opEor | opSub | opRsb | opAdd | opAdc | opSbc | opRsc | opTst | opTeq | opCmp | opCmn | opOrr | opMov | opBic | opMvn;
	assign aluBus = canOutput ? outputValue : 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
	
	// Determine if carry flag should be considered
	wire considerCarryFlag;
	assign considerCarryFlag = opAdc | opSbc | opRsc;

	// ADD module for ADD, ADC and CMN
	wire[31:0] addModuleResult;
	wire addModuleNewCarryFlag, addModuleNewOverflowFlag;
	
	AddModuleALU addModuleAlu(
		.firstInput(aBus),
		.secondInput(barrelOutput),
		.result(addModuleResult),
		.carryFlag(carryFlag),
		.countCarry(considerCarryFlag),
		.newCarryFlag(addModuleNewCarryFlag),
		.newOverflowFlag(addModuleNewOverflowFlag)
	);
	
	// SUB, RSB, SBC, RSC and CMP
	wire[31:0] subtractModuleResult;
	wire subtractModuleNewCarryFlag, subtractModuleNewOverflowFlag;
	wire reverseInputs;
	
	assign reverseInputs = opRsb | opRsc;
	
	SubtractModuleALU subtractModuleAlu(
		.firstInput(aBus),
		.secondInput(barrelOutput),
		.result(subtractModuleResult),
		.carryFlag(carryFlag),
		.countCarry(considerCarryFlag),
		.reverseInputs(reverseInputs),
		.newCarryFlag(subtractModuleNewCarryFlag),
		.newOverflowFlag(subtractModuleNewOverflowFlag)
	);
	
	// AND and TST
	wire[31:0] andResult;
	assign andResult = aBus & barrelOutput;
	
	// EOR and Teq
	wire[31:0] eorResult;
	assign eorResult = aBus ^ barrelOutput;
	
	// Orr
	wire[31:0] orrResult;
	assign orrResult = aBus | barrelOutput;
	
	// MOV
	wire[31:0] movResult;
	assign movResult = barrelOutput;
	
	// BIC
	wire[31:0] bicResult;
	assign bicResult = aBus & (~barrelOutput);
	
	// MVN
	wire[31:0] mvnResult;
	assign mvnResult = ~barrelOutput;
	
	// Assign output value
	assign outputValue = opAdd ? addModuleResult :
								opAdc ? addModuleResult :
								opCmn ? addModuleResult :
								opSbc ? subtractModuleResult :
								opRsc ? subtractModuleResult :
								opRsb ? subtractModuleResult :
								opSub ? subtractModuleResult :
								opCmp ? subtractModuleResult :
								opAnd ? andResult :
								opTst ? andResult :
								opEor ? eorResult :
								opTeq ? eorResult :
								opOrr ? orrResult :
								opMov ? movResult :
								opBic ? bicResult :
								opMvn ? mvnResult :
								32'h0;
	
	assign newCarryFlag = updateFlags ? (opAdd ? addModuleNewCarryFlag :
													 opAdc ? addModuleNewCarryFlag :
													 opCmn ? addModuleNewCarryFlag :
													 opSbc ? subtractModuleNewCarryFlag :
													 opRsc ? subtractModuleNewCarryFlag :
													 opRsb ? subtractModuleNewCarryFlag :
													 opSub ? subtractModuleNewCarryFlag :
													 opCmp ? subtractModuleNewCarryFlag :
													 1'b0)
												 : carryFlag;
								 
	assign newZeroFlag = updateFlags ? outputValue == 0 : zeroFlag;
	
	assign newOverflowFlag = updateFlags ? (opAdd ? addModuleNewOverflowFlag :
														 opAdc ? addModuleNewOverflowFlag :
														 opCmn ? addModuleNewOverflowFlag :
														 opSbc ? subtractModuleNewOverflowFlag :
														 opRsc ? subtractModuleNewOverflowFlag :
														 opRsb ? subtractModuleNewOverflowFlag :
														 opSub ? subtractModuleNewOverflowFlag :
														 opCmp ? subtractModuleNewOverflowFlag :
														 1'b0)
													 : overflowFlag;
													 
	assign newNegativeFlag = updateFlags ? outputValue[31] == 1 : negativeFlag;
	
endmodule
