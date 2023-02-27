//
// Created by daniel on 2/6/23.
//
#include "InstructionDecoderTypes.h"

std::uint32_t SingleDataTransfer_Instruction::to_binary() {
    uint32_t instruction_binary = 0;
    instruction_binary |= this->condition << 28;

    instruction_binary |= 0b01 << 26;
    instruction_binary |= this->immediate << 25;
    instruction_binary |= this->increment_type << 24;
    instruction_binary |= this->up_down << 23;
    instruction_binary |= this->byte_word << 22;
    instruction_binary |= this->write_back << 21;
    instruction_binary |= this->load_store << 20;
    instruction_binary |= this->rn << 16;
    instruction_binary |= this->rd << 12;

    if (this->immediate == DataProcessingPSR::OffsetType::Immediate) {
        instruction_binary |= this->immediate_offset;
    } else {
        // Register with shift
        instruction_binary |= this->shift << 4;
        instruction_binary |= this->rm;
    }

    return instruction_binary;
}

std::uint32_t MultiplyLong_Instruction::to_binary() {
    uint32_t instruction_binary = 0;
    instruction_binary |= this->condition << 28;

    instruction_binary |= 0b00001;
    instruction_binary |= this->signed_op << 22;
    instruction_binary |= this->accumulate << 21;
    instruction_binary |= this->set_cond << 20;
    instruction_binary |= this->rd_hi << 16;
    instruction_binary |= this->rd_lo << 12;
    instruction_binary |= this->rs << 8;
    instruction_binary |= 0b1001;
    instruction_binary |= this->rm;

    return instruction_binary;
}

std::uint32_t Multiply_Instruction::to_binary() {
    uint32_t instruction_binary = 0;
    instruction_binary |= this->condition << 28;

    instruction_binary |= 0b000000;
    instruction_binary |= this->accumulate << 21;
    instruction_binary |= this->set_cond << 20;
    instruction_binary |= this->rd << 16;
    instruction_binary |= this->rn << 12;
    instruction_binary |= this->rs << 8;
    instruction_binary |= 0b1001;
    instruction_binary |= this->rm;

    return instruction_binary;
}

std::uint32_t PSR_Instruction::to_binary() {
    uint32_t instruction_binary = 0;
    instruction_binary |= this->condition << 28;
    // Both destination and source, depends on instruction
    instruction_binary |= this->destination_psr << 22;

    if (this->type == PSR_Instruction::Type::PSRToRegister) {
        instruction_binary |= 0b00010 << 23;
        instruction_binary |= 0b001111 << 16;
        instruction_binary |= 0b000000000000;
        instruction_binary |= this->rd << 12;
    } else if (this->type == PSR_Instruction::Type::RegisterToPSR) {
        instruction_binary |= 0b00010 << 23;
        instruction_binary |= 0b1010011111 << 12;
        instruction_binary |= 0b00000000;
        instruction_binary |= this->rm;
    } else {
        // Only transfer to psr flags
        instruction_binary |= 0b00 << 26;
        instruction_binary |= immediate_operand << 25;
        instruction_binary |= 0b10 << 23;
        instruction_binary |= 0b1010001111 << 12;

        // TODO: Make enum
        if (this->immediate_operand == 0) {
            instruction_binary |= 0b00000000;
            instruction_binary |= rm;
        } else {
            instruction_binary |= this->rotate << 8;
            instruction_binary |= this->imm;
        }
    }

    return instruction_binary;
}

std::uint32_t DataProcessing_Instruction::to_binary() {
    uint32_t instruction_binary = 0;
    instruction_binary |= this->condition << 28;

    instruction_binary |= this->immediate_operand << 25;
    instruction_binary |= this->data_op << 21;
    instruction_binary |= this->set_cond << 20;
    instruction_binary |= this->rn << 16;
    instruction_binary |= this->rd << 12;

    if (this->immediate_operand == DataProcessingPSR::OffsetType::Immediate) {
        instruction_binary |= this->rotate << 8;
        instruction_binary |= this->imm;
    } else {
        // Register
        if (this->operand_2_shift_imm == DataProcessingPSR::Op2ShiftType::Op2_Immediate) {
            instruction_binary |= this->shift_amount << 7;
        } else {
            // Shift Register
            instruction_binary |= this->shift_register << 8;
            instruction_binary |= 1 << 4;
        }
        instruction_binary |= this->operand_2_shift_imm << 4;
        instruction_binary |= this->shift_type << 5;
        instruction_binary |= this->rm;
    }

    return instruction_binary;
}

std::uint32_t BranchLink_Instruction::to_binary() {
    uint32_t instruction_binary = 0;
    instruction_binary |= this->condition << 28;

    instruction_binary |= this->link << 24;
    instruction_binary |= offset & 0xFFFFFF;

    return instruction_binary;
}

std::uint32_t BranchExchange_Instruction::to_binary() {
    uint32_t instruction_binary = 0;
    instruction_binary |= this->condition << 28;

    instruction_binary |= this->rn & 0b1111;

    return instruction_binary;
}

std::uint32_t HalfwordSignedDataTransfer_Instruction::to_binary() {
    uint32_t instruction_binary = 0;
    instruction_binary |= this->condition << 28;

    instruction_binary |= 0b000 << 25;
    instruction_binary |= this->increment_type << 24;
    instruction_binary |= this->up_down << 23;
    instruction_binary |= this->write_back << 21;
    instruction_binary |= this->load_store << 20;
    instruction_binary |= this->rn << 16;
    instruction_binary |= this->rd << 12;
    instruction_binary |= 0b1 << 7;
    instruction_binary |= this->sh << 5;
    instruction_binary |= 0b1 << 4;

    if (this->imm_reg_offset == DataProcessingPSR::OffsetType::Register) {
        instruction_binary |= this->rm;
    } else {
        // Immediate offset
        instruction_binary |= 0b1 << 22;
        instruction_binary |= high_nibble_offset << 8;
        instruction_binary |= low_nibble_offset;
    }

    return instruction_binary;
}

std::uint32_t BlockDataTransfer_Instruction::to_binary() {
    uint32_t instruction_binary = 0;
    instruction_binary |= this->condition << 28;

    instruction_binary |= this->increment_type << 24;
    instruction_binary |= this->up_down << 23;
    instruction_binary |= this->load_psr_force_user_mode << 22;
    instruction_binary |= this->write_back << 21;
    instruction_binary |= this->load_store << 20;

    instruction_binary |= this->rn << 16;
    instruction_binary |= this->register_list;

    return instruction_binary;
}

std::uint32_t SingleDataSwap_Instruction::to_binary() {
    uint32_t instruction_binary = 0;
    instruction_binary |= this->condition << 28;

    instruction_binary |= this->byte_word << 22;
    instruction_binary |= this->rn << 16;
    instruction_binary |= this->rd << 12;
    instruction_binary |= 0b1011 << 4;
    instruction_binary |= this->rm;

    return instruction_binary;
}

std::uint32_t SoftwareInterrupt_Instruction::to_binary() {
    uint32_t instruction_binary = 0;
    instruction_binary |= this->condition << 28;

    instruction_binary|= 0b1111 << 24;

    return instruction_binary;
}

std::uint32_t CoprocessorDataOperations_Instruction::to_binary() {
    uint32_t instruction_binary = 0;
    instruction_binary |= this->condition << 28;

    return instruction_binary;
}

std::uint32_t CoprocessorDataTransfer_Instruction::to_binary() {
    uint32_t instruction_binary = 0;
    instruction_binary |= this->condition << 28;

    return instruction_binary;
}

std::uint32_t CoprocessorRegisterTransfers_Instruction::to_binary() {
    uint32_t instruction_binary = 0;
    instruction_binary |= this->condition << 28;

    return instruction_binary;
}

std::uint32_t UndefinedInstruction_Instruction::to_binary() {
    uint32_t instruction_binary = 0;
    instruction_binary |= this->condition << 28;

    return instruction_binary;
}