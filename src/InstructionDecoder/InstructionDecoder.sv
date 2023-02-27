`include "../Utilities/InstructionTypes.sv"

import Condition::Condition_Value;
import AluOpcode::AluOpcode_Value;
import OffsetType::OffsetType_Value;
import SourcePSR::SourcePSR_Value;
import ShiftType::ShiftType_Value;
import Op2ShiftType::Op2ShiftType_Value;

module InstructionDecoder (
    input clk,
    input reset,
    input[31:0] instruction,
    // Flag conditions
    // ALU control lines
    output AluOpcode_Value alu_op,
    output OffsetType_Value offset_type,
    output var[3:0] rn,
    output var[3:0] rd,
    output SourcePSR_Value source_psr,
    output var set_cond,
    output Op2ShiftType_Value operand_2_shift_imm,
    output var[4:0] shift_reg_imm,
    output ShiftType_Value shift_type,
    output var[3:0] rs,
    output var[3:0] rm,
    output var[7:0] imm,
     output var[3:0] rotate_amount,
    // Branch control lines
    
    output Condition_Value condition
);
    // Instructions not included
    // HINT (ARM11)
    // UMAAL (ARM11)
    // MulHalfARM9 (ARM9)

    reg dataProcessingOrPSRInstruction, multiplyInstruction, multiplyLongInstruction, singleDataSwapInstruction, branchExchangeInstruction, halfwordDataTransferRegisterInstruction, halfwordDataTransferImmInstruction;
    always_comb begin
        dataProcessingOrPSRInstruction = 0;
        multiplyInstruction = 0;
        multiplyLongInstruction = 0;
        branchExchangeInstruction = 0;
        singleDataSwapInstruction = 0;
        halfwordDataTransferRegisterInstruction = 0;
        halfwordDataTransferImmInstruction = 0;

        if (instruction[27:26] == 2'b00) begin
            if ((instruction[25:22] == 4'b0000) && (instruction[7:4] == 4'b1001)) begin
                // Multiply instruction
                multiplyInstruction = 1'b1;
            end else if ((instruction[25:23] == 3'b001) && (instruction[7:4] == 4'b1001)) begin
                // Multiply long instruction
                multiplyLongInstruction = 1'b1;
            end else if (instruction[27:4] == 24'b000100101111111111110001) begin
                // Branch and exchange instruction 
                branchExchangeInstruction = 1'b1;
            end else if ((instruction[25:23] == 3'b010) && (instruction[21:20] == 2'b00) && (instruction[11:4] == 8'b00001001)) begin
                // Single data swap instruction
                singleDataSwapInstruction = 1'b1;
            end else if ((instruction[22] == 1'b0) && (instruction[11:7] == 5'b00001) && (instruction[4] == 1'b1)) begin
                // Halfword data transfer instruction with register offset
                halfwordDataTransferRegisterInstruction = 1'b1;
            end else if ((instruction[22] == 1'b1) && (instruction[7] == 1'b1) && (instruction[4] == 1'b1)) begin
                // Halfword data transfer instruction with immediate offset
                halfwordDataTransferImmInstruction = 1'b1;
            end else begin
                // Data processing / PSR transfer instruction
                dataProcessingOrPSRInstruction = 1'b1;
            end
        end
    end

    DataProcessingPSRInstructionDecoder dataProcessingPSRInstructionDecoder(
        .clk(clk),
        .reset(reset),
        .instruction(instruction),
        .alu_op(alu_op),
        .offset_type(offset_type),
        .rn(rn),
        .rd(rd),
        .source_psr(source_psr),
        .set_cond(set_cond),
        .operand_2_shift_imm(operand_2_shift_imm),
        .shift_reg_imm(shift_reg_imm),
        .shift_type(shift_type),
        .rs(rs),
        .rm(rm),
        .imm(imm),
        .rotate_amount(rotate_amount)
    );

    ConditionDecoder conditionDecoder(
        .clk(clk),
        .reset(reset),
        .cond_encoded(instruction[31:28]),
        .cond_decoded(condition)
    );

endmodule
