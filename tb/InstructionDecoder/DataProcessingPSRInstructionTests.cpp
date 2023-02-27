//
// Created by daniel on 2/5/23.
//
#include "InstructionDecoderTypes.h"
#include "../common.cpp"
#include <VInstructionDecoder.h>
#include <array>

void reset_model(VerilatorInfo<VInstructionDecoder> &info) {
    auto &model = info.model;

    model->clk = 0;
    model->instruction = 0;
    model->reset = 1;

    cycle<VInstructionDecoder>(info);

    model->reset = 0;
    cycle<VInstructionDecoder>(info);
}

std::unique_ptr<VInstructionDecoder> create_test_model() {
    auto model = std::make_unique<VInstructionDecoder>();

    model->instruction = 0;
    model->clk = 0;
    model->reset = 0;
    model->alu_op = 0;
    model->offset_type = 0;
    model->rn = 0;
    model->rd = 0;
    model->source_psr = 0;
    model->set_cond = 0;
    model->operand_2_shift_imm = 0;
    model->shift_reg_imm = 0;
    model->shift_type = 0;
    model->rs = 0;
    model->rm = 0;
    model->imm = 0;

    model->reset = 1;
    model->clk = 1;
    model->eval();
    model->clk = 0;
    model->eval();
    model->reset = 0;
    model->clk = 1;
    model->eval();
    model->clk = 0;
    model->eval();

    return std::move(model);
}

void compare_models(VInstructionDecoder &expected, VInstructionDecoder &actual) {
    REQUIRE(expected.instruction == actual.instruction);
    REQUIRE(expected.clk == actual.clk);
    REQUIRE(expected.reset == actual.reset);
    REQUIRE(expected.alu_op == actual.alu_op);
    REQUIRE(expected.offset_type == actual.offset_type);
    REQUIRE(expected.rn == actual.rn);
    REQUIRE(expected.rd == actual.rd);
    REQUIRE(expected.source_psr == actual.source_psr);
    REQUIRE(expected.set_cond == actual.set_cond);
    REQUIRE(expected.operand_2_shift_imm == actual.operand_2_shift_imm);
    REQUIRE(expected.shift_reg_imm == actual.shift_reg_imm);
    REQUIRE(expected.shift_type == actual.shift_type);
    REQUIRE(expected.rs == actual.rs);
    REQUIRE(expected.rm == actual.rm);
    REQUIRE(expected.imm == actual.imm);
}

void check_instruction_decoded(VInstructionDecoder& decoder, DataProcessing_Instruction& instruction) {
    // Follows same logic as creating the binary representation of the instruction
    REQUIRE(decoder.alu_op == instruction.data_op);
    REQUIRE(decoder.condition == instruction.condition);
    REQUIRE(decoder.rn == instruction.rn);
    REQUIRE(decoder.rd == instruction.rd);

    if (instruction.immediate_operand == DataProcessingPSR::OffsetType::Immediate) {
        /*REQUIRE(decoder.rotate == )
         *
         */
        REQUIRE(decoder.imm == instruction.imm);
    } else {
        // Offset type is register
        if (instruction.operand_2_shift_imm == DataProcessingPSR::Op2ShiftType::Op2_Immediate) {
            REQUIRE(decoder.shift_reg_imm == instruction.shift_amount);
        } else {
            // Shift register
            REQUIRE(decoder.rs == instruction.shift_register);
        }

        REQUIRE(decoder.operand_2_shift_imm == instruction.operand_2_shift_imm);
        REQUIRE(decoder.shift_type == instruction.shift_type);
        REQUIRE(decoder.rm == instruction.rm);
    }
}

TEST_CASE("OpcodeChange", "DataProcessingPSRInstructionTest") {
    auto info = setupContext<VInstructionDecoder>("ID_DPPSR_OpcodeChange");

    DataProcessing_Instruction instruction{};

    const std::vector<DataProcessingPSR::Op> ALU_OPCODES = {
            DataProcessingPSR::Op::AND,
            DataProcessingPSR::Op::EOR,
            DataProcessingPSR::Op::SUB,
            DataProcessingPSR::Op::RSB,
            DataProcessingPSR::Op::ADD,
            DataProcessingPSR::Op::ADC,
            DataProcessingPSR::Op::SBC,
            DataProcessingPSR::Op::RSC,
            DataProcessingPSR::Op::TST,
            DataProcessingPSR::Op::TEQ,
            DataProcessingPSR::Op::CMP,
            DataProcessingPSR::Op::CMN,
            DataProcessingPSR::Op::ORR,
            DataProcessingPSR::Op::MOV,
            DataProcessingPSR::Op::BIC,
            DataProcessingPSR::Op::MVN
    };

    reset_model(info);

    for (auto &opcode: ALU_OPCODES) {
        instruction.data_op = opcode;

        uint32_t binary_rep = instruction.to_binary();
        info.model->instruction = binary_rep;
        cycle<VInstructionDecoder>(info);
        check_instruction_decoded(*info.model, instruction);
    }
}

TEST_CASE("TestHardcodedInstructions", "DataProcessingPSRInstructionTest") {
    auto info = setupContext<VInstructionDecoder>("ID_DPPSR_OpcodeChange");
    reset_model(info);

    DataProcessing_Instruction movene_instruction{};
    movene_instruction.data_op = DataProcessingPSR::Op::MOV;
    movene_instruction.rn = 1;
    movene_instruction.rd = 2;

    movene_instruction.condition = Condition::Op::NotEqual;

    uint32_t binary_instruction = movene_instruction.to_binary();
    info.model->instruction = binary_instruction;
    cycle<VInstructionDecoder>(info);
    check_instruction_decoded(*info.model, movene_instruction);

    DataProcessing_Instruction add_instruction{};
    add_instruction.condition = Condition::Op::Always;
    add_instruction.rn = 1;
    add_instruction.rd = 2;
    add_instruction.rm = 3;
}

TEST_CASE("TestHardcored", "DataProcessingPSRInstructionTest") {
    auto context = setupContext<VInstructionDecoder>("ID_DPPSR_HardcodeOps");
    reset_model(context);

    // Essentially the same as instruction to binary test but actually executes though device
    DataProcessing_Instruction instruction{};
    instruction.data_op = DataProcessingPSR::Op::ADD;

    uint32_t binary = instruction.to_binary();
    context.model->instruction = binary;
    cycle<VInstructionDecoder>(context);
    check_instruction_decoded(*context.model, instruction);

    instruction.condition = Condition::Equal;
    binary = instruction.to_binary();
    context.model->instruction = binary;
    cycle<VInstructionDecoder>(context);
    check_instruction_decoded(*context.model, instruction);

    DataProcessing_Instruction add_test_instruction{};
    add_test_instruction.data_op = DataProcessingPSR::Op::ADD;
    add_test_instruction.rn = 2;
    add_test_instruction.rd = 1;
    add_test_instruction.rm = 3;
    binary = add_test_instruction.to_binary();
    context.model->instruction = binary;
    cycle<VInstructionDecoder>(context);
    check_instruction_decoded(*context.model, add_test_instruction);

    DataProcessing_Instruction add_imm{};
    add_imm.data_op = DataProcessingPSR::Op::ADD;
    add_imm.condition = Condition::Op::Always;
    add_imm.rn = 2;
    add_imm.rd = 1;
    add_imm.imm = 4;
    add_imm.immediate_operand = DataProcessingPSR::OffsetType::Immediate;
    binary = add_imm.to_binary();
    context.model->instruction = binary;
    cycle<VInstructionDecoder>(context);
    check_instruction_decoded(*context.model, add_imm);

    DataProcessing_Instruction bic_imm{};
    bic_imm.condition = Condition::Op::GreaterEqual;
    bic_imm.data_op = DataProcessingPSR::Op::BIC;
    bic_imm.rd = 5;
    bic_imm.rn = 10;
    bic_imm.imm = 0xF;
    bic_imm.immediate_operand = DataProcessingPSR::OffsetType::Immediate;
    bic_imm.rotate = 6;
    binary = bic_imm.to_binary();
    context.model->instruction = binary;
    cycle<VInstructionDecoder>(context);
    check_instruction_decoded(*context.model, bic_imm);

    bic_imm.imm = 0;
    bic_imm.rotate = 0;
    binary = bic_imm.to_binary();
    context.model->instruction = binary;
    cycle<VInstructionDecoder>(context);
    check_instruction_decoded(*context.model, bic_imm);

    DataProcessing_Instruction sub_instruction{};
    sub_instruction.data_op = DataProcessingPSR::Op::SUB;
    sub_instruction.condition = Condition::Op::Always;
    sub_instruction.rd = 4;
    sub_instruction.rn = 5;
    sub_instruction.rm = 7;
    sub_instruction.shift_register = 2;
    sub_instruction.shift_type = DataProcessingPSR::ShiftType::LogicalRight;
    sub_instruction.operand_2_shift_imm = DataProcessingPSR::Op2ShiftType::Op2_Register;

    binary = sub_instruction.to_binary();
    context.model->instruction = binary;
    cycle<VInstructionDecoder>(context);
    check_instruction_decoded(*context.model, sub_instruction);
}

TEST_CASE("TestInstructionToBinary", "TestFrameworkDataInstruction") {
    DataProcessing_Instruction instruction{};
    instruction.data_op = DataProcessingPSR::Op::ADD;

    uint32_t binary = instruction.to_binary();
    REQUIRE(binary == 0xE0800000);

    instruction.condition = Condition::Equal;
    binary = instruction.to_binary();
    REQUIRE(binary == 0x00800000);

    DataProcessing_Instruction add_test_instruction{};
    add_test_instruction.data_op = DataProcessingPSR::Op::ADD;
    add_test_instruction.rn = 2;
    add_test_instruction.rd = 1;
    add_test_instruction.rm = 3;
    binary = add_test_instruction.to_binary();
    REQUIRE(binary == 0xE0821003);

    DataProcessing_Instruction add_imm{};
    add_imm.data_op = DataProcessingPSR::Op::ADD;
    add_imm.condition = Condition::Op::Always;
    add_imm.rn = 2;
    add_imm.rd = 1;
    add_imm.imm = 4;
    add_imm.immediate_operand = DataProcessingPSR::OffsetType::Immediate;
    binary = add_imm.to_binary();
    REQUIRE(binary == 0xE2821004);

    DataProcessing_Instruction bic_imm{};
    bic_imm.condition = Condition::Op::GreaterEqual;
    bic_imm.data_op = DataProcessingPSR::Op::BIC;
    bic_imm.rd = 5;
    bic_imm.rn = 10;
    bic_imm.imm = 0xF;
    bic_imm.immediate_operand = DataProcessingPSR::OffsetType::Immediate;
    bic_imm.rotate = 6;
    binary = bic_imm.to_binary();
    REQUIRE(binary == 0xA3CA560F);

    bic_imm.imm = 0;
    bic_imm.rotate = 0;
    binary = bic_imm.to_binary();
    REQUIRE(binary == 0xA3CA5000);

    DataProcessing_Instruction sub_instruction{};
    sub_instruction.data_op = DataProcessingPSR::Op::SUB;
    sub_instruction.condition = Condition::Op::Always;
    sub_instruction.rd = 4;
    sub_instruction.rn = 5;
    sub_instruction.rm = 7;
    sub_instruction.shift_register = 2;
    sub_instruction.shift_type = DataProcessingPSR::ShiftType::LogicalRight;
    sub_instruction.operand_2_shift_imm = DataProcessingPSR::Op2ShiftType::Op2_Register;

    binary = sub_instruction.to_binary();
    REQUIRE(binary == 0xE0454237);
}