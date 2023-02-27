module SubtractModuleALU (
	input[31:0] firstInput,
	input[31:0] secondInput,
	output[31:0] result,
	input carryFlag,
	input countCarry,
	input reverseInputs,
	output newCarryFlag,
	output newOverflowFlag
);
	// Instruction can have these reversed
	wire[31:0] actualFirstInput, actualSecondInput, tempResult;
	assign actualFirstInput = reverseInputs ? secondInput : firstInput;
	assign actualSecondInput = reverseInputs ? firstInput : secondInput;
	assign tempResult = actualFirstInput - actualSecondInput;
	
	assign result = countCarry ? tempResult + carryFlag - 1 : tempResult;
	
	// TODO: Verify these work
	assign newCarryFlag = (actualFirstInput[31] & ~actualSecondInput[31] & ~result[31]) | (~actualFirstInput[31] & actualSecondInput[31] & result[31]);
	assign newOverflowFlag = (~actualFirstInput[31] & actualSecondInput[31]) | (actualSecondInput[31] & result[31]) | (result[31] & ~actualSecondInput[31]);										
endmodule
