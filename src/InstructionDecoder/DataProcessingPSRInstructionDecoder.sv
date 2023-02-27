`include "../Utilities/InstructionTypes.sv"

import AluOpcode::AluOpcode_Value;
import OffsetType::OffsetType_Value;
import SourcePSR::SourcePSR_Value;
import ShiftType::ShiftType_Value;
import Op2ShiftType::Op2ShiftType_Value;

module DataProcessingPSRInstructionDecoder (
    input[31:0] instruction,
    input clk,
    input reset,
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
    output var[3:0] rotate_amount
);
    // TODO: Implement PSR instruction decoding

    always_ff @(posedge clk or posedge reset) begin
        offset_type = OffsetType::Register;

        if (reset == 1'b1)begin
            offset_type = OffsetType::Register;
        end else begin
            if (reset != 1'b1) begin
                if (instruction[25] == 1'b1) begin
                    offset_type = OffsetType::Immediate;
                end else begin
                    offset_type = OffsetType::Register;
                end
            end
        end
    end

    always_ff @(posedge clk or posedge reset) begin
        alu_op = AluOpcode::AND;

        if (reset == 1'b1) begin
            alu_op = AluOpcode::AND;
        end else begin
            case(instruction[24:21])
            4'h0: begin
                alu_op = AluOpcode::AND;
            end
            4'h1: begin
                alu_op = AluOpcode::EOR;
            end
            4'h2: begin
                alu_op = AluOpcode::SUB;
            end
            4'h3: begin
                alu_op = AluOpcode::RSB;
            end
            4'h4: begin
                alu_op = AluOpcode::ADD;
            end
            4'h5: begin
                alu_op = AluOpcode::ADC;
            end
            4'h6: begin
                alu_op = AluOpcode::SBC;
            end
            4'h7: begin
                alu_op = AluOpcode::RSC;
            end
            4'h8: begin
                alu_op = AluOpcode::TST;
            end
            4'h9: begin
                alu_op = AluOpcode::TEQ;
            end
            4'hA: begin
                alu_op = AluOpcode::CMP;
            end
            4'hB: begin
                alu_op = AluOpcode::CMN;
            end
            4'hC: begin
                alu_op = AluOpcode::ORR;
            end
            4'hD: begin
                alu_op = AluOpcode::MOV;
            end
            4'hE: begin
                alu_op = AluOpcode::BIC;
            end
            4'hF: begin
                alu_op = AluOpcode::MVN;
            end
            endcase
        end
    end

    always_ff @(posedge clk or posedge reset) begin
        set_cond = 1'b0;

        if (reset == 1'b1) begin
            set_cond = 1'b0;
        end else begin
            set_cond = instruction[20];
        end
    end

    always_ff @(posedge clk or posedge reset) begin
        rn = 0;

        if (reset == 1'b1) begin
            rn = 0;
        end else begin
            rn = instruction[19:16];
        end
    end

    always_ff @(posedge clk or posedge reset) begin
        rd = 0;

        if (reset == 1'b1) begin
            rd = 0;
        end else begin
            rd = instruction[15:12];
        end
    end

    // Operand 2 decoding
    always_ff @(posedge clk or posedge reset) begin
        shift_reg_imm = 0;
        operand_2_shift_imm = Op2ShiftType::Immediate;
        rs = 0;
        shift_type = ShiftType::LogicalLeft;
        rotate_amount = 0;
        imm = 0;
        rm = 0;
        if (reset == 1'b1) begin
            shift_reg_imm = 0;
            rs = 0;
            shift_type = ShiftType::LogicalLeft;
            rotate_amount = 0;
            operand_2_shift_imm = Op2ShiftType::Immediate;
            imm = 0;
            rm = 0;
        end else begin
            if (instruction[25] == 1'b0) begin
                // Operand 2 is a register
                if (instruction[4] == 0) begin
                    shift_reg_imm = instruction[11:7];
                    operand_2_shift_imm = Op2ShiftType::Immediate;
                end else if (instruction[7] == 0 && instruction[4] == 1) begin
                    rs = instruction[11:8];
                    operand_2_shift_imm = Op2ShiftType::Register;
                end

                case(instruction[6:5])
                2'h0: shift_type = ShiftType::LogicalLeft;
                2'h1: shift_type = ShiftType::LogicalRight;
                2'h2: shift_type = ShiftType::ArithmeticRight;
                2'h3: shift_type = ShiftType::RotateRight;
                endcase

                rm = instruction[3:0];
                
            end else begin
                // Operand 2 is an immediate value
                rotate_amount = instruction[11:8];
                imm = instruction[7:0];
                operand_2_shift_imm = Op2ShiftType::Immediate;
            end        
        end
    end
endmodule
