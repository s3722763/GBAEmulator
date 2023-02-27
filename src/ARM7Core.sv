`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.06.2022 11:56:53
// Design Name: 
// Module Name: ARM7Core
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


module ARM7Core(
    input CLK,
    input reset_n,
    output var[31:0] address,
    input[31:0] data,
    output var[31:0] aluBusOut
);
    var[31:0] instructionRegister;
    var[31:0] addressRegister;

    // Buses
    var[31:0] aluBus, aBus, bBus, pcBus, incrementBus, aluBBusInput;
    var[3:0] aluOp;
    var[3:0] op_condition_flag;

    InstructionDecoder instructionDecoder(
        .clk(CLK),
        .instruction(instructionRegister),
        .aluOp(aluOp),
        .op_condition_flag(op_condition_flag)
    );

    ALU alu(
        .clk(CLK),
        .aBus(aBus),
        .aluBus(aluBus),
        .aluOp(aluOp),
        .barrelOutput(aluBBusInput)
    );

    Multiplier32Bit multiplier (
        
    );
    
    var carry_flag, overflow_flag, negative_flag, zero_flag;

    RegisterFile registerFile(
        .clk(CLK),
        .alu_bus(aluBus),
        .pc_bus(pcBus),
        .a_bus(aBus),
        .b_bus(bBus),
        .carry_flag(carry_flag),
        .negative_flag(negative_flag),
        .overflow_flag(overflow_flag),
        .zero_flag(zero_flag)
    );
    
    BranchHandler branchHandler (
        .carry_flag(carry_flag),
        .negative_flag(negative_flag),
        .overflow_flag(overflow_flag),
        .zero_flag(zero_flag),
        .op_condition_flag(op_condition_flag)
    );
    
    BarrelShifter barrelShifter (
        .clk(CLK),
        .b_bus(bBus),
        .alu_input(aluBBusInput)
    );

    always @(posedge CLK) begin
        instructionRegister = data;
    end

    always @(posedge CLK or negedge reset_n) begin
        if (reset_n == 0) begin
            // ROM entry point is 0x08000000
            addressRegister = 0;
        end else begin
            // Each address contains 16 bits
            addressRegister = addressRegister + 2;
        end
    end
    
    assign aluBusOut = aluBus;
endmodule
