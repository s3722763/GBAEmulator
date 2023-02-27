`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.07.2022 21:45:57
// Design Name: 
// Module Name: BranchHandler
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


// Should reside 
module BranchHandler (
    input overflow_flag,
    input carry_flag,
    input zero_flag,
    input negative_flag,
    input[3:0] op_condition_flag,
    
    output var should_branch
);
    always_comb begin
        case(op_condition_flag)
            // Equal
            4'b0000: should_branch = zero_flag == 1;
            // Not Equal
            4'b0001: should_branch = zero_flag == 0;
            // Unsigned Higher or Same
            4'b0010: should_branch = carry_flag == 1;
            // Unsigned Lower
            4'b0011: should_branch = carry_flag == 0;
            // Negative
            4'b0100: should_branch = negative_flag == 1;
            // Positive or Zero
            4'b0101: should_branch = negative_flag == 0;
            // Overflow
            4'b0110: should_branch = overflow_flag == 1;
            // No Overflow
            4'b0111: should_branch = overflow_flag == 0;
            // Unsigned Higher
            4'b1000: should_branch = carry_flag == 1 && zero_flag == 0;
            // Unsigned Lower or Same
            4'b1001: should_branch = carry_flag == 0 || zero_flag == 1;
            // Greater or Equal
            4'b1010: should_branch = negative_flag == overflow_flag;
            // Less than
            4'b1011: should_branch = negative_flag != overflow_flag;
            // Greater Than
            4'b1100: should_branch = zero_flag == 0 && (negative_flag == overflow_flag);
            // Less Than or Equal
            4'b1101: should_branch = zero_flag == 1 || (negative_flag != overflow_flag);
            // Always
            4'b1110: should_branch = 1;
            // Reserved
            4'b1111: should_branch = 0;
        endcase      
    end
endmodule
