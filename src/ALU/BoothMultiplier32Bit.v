module Multiplier32Bit (
	input[31:0] multiplicand,
	input[31:0] multiplier,
	input clk,
	input enable,
	input reset_n,
	output[31:0] aBus
);
	// TODO: Set flags
	wire[63:0] first, second;
	
	assign first = { { 32{multiplicand[31] } }, multiplicand };
	assign second = { { 32{multiplier[31] } }, multiplier };
	
	wire[63:0] resultFull;
	reg[31:0] resultHold;
	reg outputResult;
	reg validOutput;
	reg[2:0] delayCounter;
	
	assign resultFull = first * second;
	// Determine delay
	
	always @(posedge clk) begin
		if (enable) begin
			resultHold <= resultFull[31:0];
			outputResult <= 0;
		end else if (delayCounter == 1) begin
			resultHold <= resultFull[31:0];
			outputResult <= 1;
		end else if (delayCounter == ~0) begin
			// Overflow meaning delay has overflowed
			resultHold <= 0;
			outputResult <= 0;
		end else begin
			resultHold <= resultHold;
			outputResult <= 0;
		end
	end
	
	always @(posedge clk, negedge reset_n) begin
		if (reset_n == 0) begin
			validOutput <= 0;
		end else begin
			if (validOutput == 0 && enable == 1) begin
				validOutput <= 1'b1;
			end else if (validOutput == 1 && delayCounter == 0) begin 
				validOutput <= 1'b0;
			end else begin
				validOutput <= validOutput;
			end
		end
	end
	
	// Work out cycle delay
	always @(posedge clk) begin
		if (enable) begin
			// Need to set the 
			if (multiplier[31:8] == 0 || multiplier[31:8] == ~0) begin
				delayCounter <= 1;
			end else if (multiplier[31:16] == 0 || multiplier[31:16] == ~0) begin
				delayCounter <= 2;
			end else if (multiplier[31:24] == 0 || multiplier[31:24] == ~0) begin
				delayCounter <= 3;
			end else begin
				delayCounter <= 4;
			end 
		end else begin
			delayCounter <= delayCounter - 1;
		end
	end
	
	assign aBus = outputResult ? (delayCounter == 0 ? resultHold : 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz) 
										: 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
endmodule
