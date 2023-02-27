module AddModuleALU(
	input[31:0] firstInput,
	input[31:0] secondInput,
	output[31:0] result,
	input carryFlag,
	input countCarry,
	output newCarryFlag,
	output newOverflowFlag
);
	wire[31:0] tempResult;
	assign tempResult = firstInput + secondInput;
	assign result = countCarry ? tempResult + carryFlag : tempResult;
	
	// Taken from AVR ISA for equation
	assign newCarryFlag = (firstInput[31] & secondInput[31]) | (secondInput[31] & ~result[31]) | (firstInput[31] & ~result[31]);
	assign newOverflowFlag = (firstInput[31] & secondInput[31] & ~result[31]) | (~firstInput[31] & ~secondInput[31] & result[31]);
	
endmodule
