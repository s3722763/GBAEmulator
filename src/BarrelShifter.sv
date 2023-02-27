`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.07.2022 19:19:41
// Design Name: 
// Module Name: BarrelShifter
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


module BarrelShifter(
    input clk,

    input[31:0] b_bus,
    input[1:0] shift_type,
    input[4:0] shift_amount_imm,
    input[7:0] shift_amount_reg,
    input reg_shift,
    
    output var[31:0] alu_input
);  
    var[31:0] register_shift_output, imm_shift_output;
    
    // If the register input use used, an additional clock cycle is 
    always_ff @(posedge clk) begin
        case (shift_type)
         2'b00: begin
            // Logical Left
            register_shift_output = b_bus << shift_amount_reg;
         end
         2'b01: begin
            // Logical Right
            register_shift_output = b_bus >> shift_amount_reg;
         end
         2'b10: begin
            // Arithmetic Right
            register_shift_output = b_bus >>> shift_amount_reg;
         end
         2'b11: begin
            // Rotate Right - This is a circular shift (https://en.wikipedia.org/wiki/Bitwise_operation#Circular_shift)
            register_shift_output = (b_bus << shift_amount_reg) | (b_bus >> (32 - shift_amount_reg));
         end
        endcase
    end
    
    always_comb begin
        case (shift_type)
         2'b00: begin
            // Logical Left
            imm_shift_output = b_bus << shift_amount_imm;
         end
         2'b01: begin
            // Logical Right
            imm_shift_output = b_bus >> shift_amount_imm;
         end
         2'b10: begin
            // Arithmetic Right
            imm_shift_output = b_bus >>> shift_amount_imm;
         end
         2'b11: begin
            // Rotate Right - This is a circular shift (https://en.wikipedia.org/wiki/Bitwise_operation#Circular_shift)
            imm_shift_output = (b_bus << shift_amount_imm) | (b_bus >> (32 - shift_amount_imm));
         end
        endcase
    end
    
    // TODO: Add cycle delay for register use
    always_comb begin
        if (reg_shift == 1'b1) begin
            alu_input = register_shift_output;
        end else begin
            alu_input = imm_shift_output;
        end
    end

endmodule
