`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.07.2022 15:27:38
// Design Name: 
// Module Name: RegisterBank
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

module RegisterFile(
    input clk,
    input reset_n,
    input read_from_gpr_to_a_bus_input,
    input read_from_gpr_to_b_bus_input,
    input[4:0] a_bus_read_register_input,
    input[4:0] b_bus_read_register_input,

    // Bus connections
    input[31:0] alu_bus,
    input[31:0] increment_bus,

    output var[31:0] a_bus,
    output var[31:0] b_bus,
    output var[31:0] pc_bus,

    // Conditions
    output var overflow_flag, 
    output var carry_flag, 
    output var zero_flag, 
    output var negative_flag,

    // Control lines
    input write_to_gpr,
    input[3:0] register_to_write_to,
    output var update_address_register
);
    // GPR registers
    var[31:0] general_purpose_registers[14:0];
    var[31:0] cspr;
    // Banked registers - Always exist, have to be in a specific mode to access
    var[31:0] fiq_registers[4:0];
    var[31:0] supervisor_registers[1:0];
    var[31:0] abort_registers[1:0] ;
    var[31:0] irq_registers[1:0];
    var[31:0] undefined_registers[1:0];
    // Saved Program Status Registers. Used to save SPSR for the new mod. Going to FIQ mode from system mode (normal) has
    // the CPSR saved in the SPSR_fiq register
    var[31:0] saved_process_status_registers[4:0];

    // CSPR flags
    var[4:0] mode_bits;
    var state_bit, fiq_disable_flag, irq_disable_flag;

    assign mode_bits = cspr[4:0];
    assign state_bit = cspr[5];
    assign fiq_disable_flag = cspr[6];
    assign irq_disable_flag = cspr[7];
    assign overflow_flag = cspr[28];
    assign carry_flag = cspr[29];
    assign zero_flag = cspr[30];
    assign negative_flag = cspr[31];
    
    // Decode Mode
    var user_mode, fiq_mode, irq_mode, supervisor_mode, abort_mode, undefined_mode, system_mode;
    assign user_mode = mode_bits == 5'b10000 ? 1 : 0;
    assign fiq_mode = mode_bits == 5'b10001 ? 1 : 0;
    assign irq_mode = mode_bits == 5'b10010 ? 1 : 0;
    assign abort_mode = mode_bits == 5'b10111 ? 1 : 0;
    assign undefined_mode = mode_bits == 5'b11011 ? 1 : 0;
    assign system_mode = mode_bits == 5'b11111 ? 1 : 0;
    // Processor operating mode ARM or Thunb

    // Writing to GPR
    // First 8 registers always handled in the same way. r8-r12 are handled mostly the same except for
    // FIQ. r13 & r14 handled differently in every mode. r15(PC) always handled the same.
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin: apply_gpr_values
            if (i >= 0 && i < 8) begin
                always_ff @(posedge clk) begin
                    if (register_to_write_to == i && write_to_gpr == 1'b1) begin
                        general_purpose_registers[i] = alu_bus;
                    end
                end
            end else if (i >= 8 && i < 14) begin
                always_ff @(posedge clk) begin
                    if (register_to_write_to == i && write_to_gpr == 1'b1) begin
                        if (fiq_mode == 1'b1) begin
                            fiq_registers[i - 8] = alu_bus;
                        end else begin
                            general_purpose_registers[i] = alu_bus;
                        end
                    end
                end
            end else begin
                always_ff @(posedge clk) begin
                    if (register_to_write_to == i && write_to_gpr == 1'b1) begin
                        if (fiq_mode == 1'b1) begin
                            fiq_registers[i - 14] = alu_bus;
                        end else if (supervisor_mode == 1'b1) begin
                            supervisor_registers[i - 14] = alu_bus;
                        end else if (abort_mode == 1'b1) begin
                            abort_registers[i - 14] = alu_bus;
                        end else if (irq_mode == 1'b1) begin
                            irq_registers[i - 14] = alu_bus;
                        end else if (undefined_mode == 1'b1) begin
                            undefined_registers[i - 14] = alu_bus;
                        end
                    end
                end
            end
        end
    endgenerate

    // Reading from GPR
    var read_from_gpr_to_a_bus;
    var read_from_gpr_to_b_bus;
    var[4:0] a_bus_read_register;
    var[4:0] b_bus_read_register;

    always @(posedge clk) begin
        read_from_gpr_to_a_bus = read_from_gpr_to_a_bus_input;
        read_from_gpr_to_b_bus = read_from_gpr_to_b_bus_input;
        a_bus_read_register = a_bus_read_register_input;
        b_bus_read_register = b_bus_read_register_input;
    end

    // Read to A Bus
    integer index;
    generate
        always_comb begin
            a_bus = 0;

            for (index = 0; index < 15; index = index + 1) begin: gpr_to_a_bus
                if (index >= 0 && index < 8) begin

                    if (a_bus_read_register == index && read_from_gpr_to_a_bus == 1'b1) begin
                        a_bus = general_purpose_registers[index];
                    end

                end else if (index >= 8 && index < 13) begin

                    if (a_bus_read_register == index && read_from_gpr_to_a_bus == 1'b1) begin
                        if (fiq_mode == 1'b1) begin
                            a_bus = fiq_registers[index - 8];
                        end else begin
                            a_bus = general_purpose_registers[index];
                        end
                    end

                end else begin

                    if (a_bus_read_register == index && read_from_gpr_to_a_bus == 1'b1) begin
                        if (fiq_mode == 1'b1) begin
                            a_bus = fiq_registers[index - 14];
                        end else if (supervisor_mode == 1'b1) begin
                            a_bus = supervisor_registers[index - 14];
                        end else if (abort_mode == 1'b1) begin
                            a_bus = abort_registers[index - 14];
                        end else if (irq_mode == 1'b1) begin
                            a_bus = irq_registers[index - 14];
                        end else if (undefined_mode == 1'b1) begin
                            a_bus = undefined_registers[index - 14];
                        end
                    end

                end
            end
        end
    endgenerate

    // Read to B Bus
    generate
        always_comb begin
            b_bus = 0;

            for (index = 0; index < 15; index = index + 1) begin: gpr_to_b_bus
                if (index >= 0 && index < 8) begin
                    if (b_bus_read_register == index && read_from_gpr_to_b_bus == 1'b1) begin
                        b_bus = general_purpose_registers[index];
                    end
                end else if (index >= 8 && index < 13) begin
                    if (b_bus_read_register == index && read_from_gpr_to_b_bus == 1'b1) begin
                        if (fiq_mode == 1'b1) begin
                            b_bus = fiq_registers[index - 8];
                        end else begin
                            b_bus = general_purpose_registers[index];
                        end
                    end
                end else begin
                    if (b_bus_read_register == index && read_from_gpr_to_b_bus == 1'b1) begin
                        if (fiq_mode == 1'b1) begin
                            b_bus = fiq_registers[index - 14];
                        end else if (supervisor_mode == 1'b1) begin
                            b_bus = supervisor_registers[index - 14];
                        end else if (abort_mode == 1'b1) begin
                            b_bus = abort_registers[index - 14];
                        end else if (irq_mode == 1'b1) begin
                            b_bus = irq_registers[index - 14];
                        end else if (undefined_mode == 1'b1) begin
                            b_bus = undefined_registers[index - 14];
                        end
                    end
                end
            end
        end
    endgenerate
    
    // PC (r15) Read and Write
    // TODO: Handle branch instructions
    always_ff @(posedge clk) begin
        if (register_to_write_to == 15) begin
            general_purpose_registers[15] = alu_bus;
        end else begin
            general_purpose_registers[15] = increment_bus;
        end
    end
    
    assign pc_bus = general_purpose_registers[15];
endmodule