//
// Created by daniel on 2/5/23.
//

#ifndef VERILATORTEST_INSTRUCTIONDECODERTYPES_H
#define VERILATORTEST_INSTRUCTIONDECODERTYPES_H

#include <cstdint>

// TODO: Are bits set
// TODO: Implement more enums for flags
// TODO: Check immediate flag for instructions

uint32_t big_endian_to_little(uint32_t original);

namespace ProgramStatus {
    enum FlagMask {
        Negative = 1 << 31,
        Zero = 1 << 30,
        Carry = 1 << 29,
        Overflow = 1 << 28,
        IRQDisable = 1 << 7,
        FIQDisable = 1 << 6,
        StateBit = 1 << 5,
        ModeBits = (1 << 4) | (1 << 3) | (1 << 2) | (1 << 1) | (1 << 0)
    };

    enum Mode {
        User = 0b10000,
        FIQ = 0b1001,
        IRQ = 0b10010,
        Supervisor = 0b10011,
        Undefined = 0b11011,
        System = 0b11111
    };
}

namespace Condition {
    enum Op {
        Equal = 0b0000,
        NotEqual = 0b0001,
        UnsignedHigherSame = 0b0010,
        UnsignedLower = 0b0011,
        Negative = 0b0100,
        PositiveZero = 0b0101,
        Overflow = 0b0110,
        NoOverflow = 0b0111,
        UnsignedHigher = 0b1000,
        UnsignedLowerSame = 0b1001,
        GreaterEqual = 0b1010,
        LessThan = 0b1011,
        GreaterThan = 0b1100,
        LessThanEqual = 0b1101,
        Always = 0b1110,
        // Used for coprocessor operation sometimes
        Undefined = 0b1111
    };

    enum SetConditionFlags {
        DontSet = 0,
        Set = 1
    };
}

namespace DataProcessingPSR {
    enum Op {
        AND = 0b0000,
        EOR = 0b0001,
        SUB = 0b0010,
        RSB = 0b0011,
        ADD = 0b0100,
        ADC = 0b0101,
        SBC = 0b0110,
        RSC = 0b0111,
        TST = 0b1000,
        TEQ = 0b1001,
        CMP = 0b1010,
        CMN = 0b1011,
        ORR = 0b1100,
        MOV = 0b1101,
        BIC = 0b1110,
        MVN = 0b1111
    };

    enum ShiftType {
        LogicalLeft = 0b00,
        LogicalRight = 0b01,
        ArithmeticRight = 0b10,
        RotateRight = 0b11
    };

    enum SourcePSR {
        CPSR = 0,
        SPSR = 1
    };

    enum OffsetType {
        Immediate = 1,
        Register = 0
    };

    enum Op2ShiftType {
        Op2_Immediate = 0,
        Op2_Register = 1
    };
}

namespace Multiply {
    enum SignOfOp {
        Unsigned = 0,
        Signed = 1
    };

    enum Accumulate {
        MultiplyOnly = 0,
        MultiplyAccumulate = 1
    };
}

namespace StorageOperations {
    enum LoadStore {
        Store = 0,
        Load = 1
    };

    enum ByteWord {
        Word = 0,
        Byte = 1
    };

    enum IncrementType {
        Post = 0,
        Pre = 1
    };

    enum LoadPSRForceUser {
        No,
        Yes
    };

    enum ShouldWriteBack {
        NoWriteBack = 0,
        WriteBack = 1
    };

    enum UpDown {
        Down = 0,
        Up = 1
    };
}

namespace Branch {
    enum Link {
        Branch = 0,
        BranchLink = 1
    };
}

struct BranchExchange_Instruction {
    Condition::Op condition = Condition::Op::Always;
    std::size_t rn = 0;

    std::uint32_t to_binary();
};

struct BranchLink_Instruction {
    Condition::Op condition = Condition::Op::Always;
    Branch::Link link = Branch::Link::Branch;
    std::size_t offset = 0;

    std::uint32_t to_binary();
};

struct DataProcessing_Instruction {
    Condition::Op condition = Condition::Op::Always;
    DataProcessingPSR::OffsetType immediate_operand = DataProcessingPSR::OffsetType::Register;
    DataProcessingPSR::Op data_op = DataProcessingPSR::Op::AND;
    std::size_t rn = 0;
    std::size_t rd = 0;
    Condition::SetConditionFlags set_cond = Condition::SetConditionFlags::DontSet;
    // Not explicity stated in documentation but bit 4 signifies if immediate or register used for shift amount
    DataProcessingPSR::Op2ShiftType operand_2_shift_imm = DataProcessingPSR::Op2ShiftType::Op2_Immediate;
    // Immediate Operand = 0
    std::size_t shift_amount = 0;
    std::size_t shift_register = 0;
    std::size_t rm = 0;
    DataProcessingPSR::ShiftType shift_type = DataProcessingPSR::LogicalLeft;
    // Immediate Operand = 1
    std::size_t rotate = 0;
    std::size_t imm = 0;

    std::uint32_t to_binary();
};

struct PSR_Instruction {
    enum Type {
        PSRToRegister = 0,
        RegisterToPSR = 1,
        TransferContentsOrImmToFlagOnly = 2
    };

    enum ImmediateOrRegister {
        ImmediateSource = 0,
        RegisterSource = 1
    };

    Condition::Op condition = Condition::Op::Always;
    DataProcessingPSR::SourcePSR destination_psr = DataProcessingPSR::SourcePSR::CPSR;
    std::size_t rd = 0;
    std::size_t rm = 0;
    std::size_t imm = 0;
    std::size_t rotate = 0;
    std::size_t immediate_operand = 0;
    PSR_Instruction::Type type = PSR_Instruction::Type::PSRToRegister;
    PSR_Instruction::ImmediateOrRegister source = PSR_Instruction::ImmediateOrRegister::ImmediateSource;

    std::uint32_t to_binary();
};

struct Multiply_Instruction {
    Condition::Op condition = Condition::Op::Always;
    Multiply::Accumulate accumulate = Multiply::Accumulate::MultiplyOnly;
    Condition::SetConditionFlags set_cond = Condition::SetConditionFlags::DontSet;
    std::size_t rd = 0;
    std::size_t rn = 0;
    std::size_t rs = 0;
    std::size_t rm = 0;

    std::uint32_t to_binary();
};

struct MultiplyLong_Instruction {
    Condition::Op condition = Condition::Op::Always;
    Multiply::SignOfOp signed_op = Multiply::Unsigned;
    Multiply::Accumulate accumulate = Multiply::Accumulate::MultiplyOnly;
    Condition::SetConditionFlags set_cond = Condition::SetConditionFlags::DontSet;
    std::size_t rd_hi = 0;
    std::size_t rd_lo = 0;
    std::size_t rs = 0;
    std::size_t rm = 0;

    std::uint32_t to_binary();
};

struct SingleDataTransfer_Instruction {
    Condition::Op condition = Condition::Op::Always;
    DataProcessingPSR::OffsetType immediate = DataProcessingPSR::OffsetType::Immediate;
    StorageOperations::IncrementType increment_type = StorageOperations::IncrementType::Post;
    StorageOperations::UpDown up_down = StorageOperations::UpDown::Down;
    StorageOperations::ByteWord byte_word = StorageOperations::ByteWord::Word;
    StorageOperations::ShouldWriteBack write_back = StorageOperations::ShouldWriteBack::NoWriteBack;
    StorageOperations::LoadStore load_store = StorageOperations::LoadStore::Store;
    std::size_t rn = 0;
    std::size_t rd = 0;
    // Immediate = 0
    std::size_t immediate_offset = 0;
    // Immediate = 1
    std::size_t shift = 0;
    std::size_t rm = 0;

    std::uint32_t to_binary();
};

struct HalfwordSignedDataTransfer_Instruction {
    enum SH {
        SWP = 0b00,
        UnsignedHalfwords = 0b01,
        SignedByte = 0b10,
        SignedHalfwords = 0b11
    };

    Condition::Op condition = Condition::Op::Always;
    StorageOperations::IncrementType increment_type = StorageOperations::IncrementType::Post;
    StorageOperations::UpDown up_down = StorageOperations::UpDown::Down;
    StorageOperations::ShouldWriteBack write_back = StorageOperations::ShouldWriteBack::NoWriteBack;
    StorageOperations::LoadStore load_store = StorageOperations::LoadStore::Store;
    std::size_t rn = 0;
    std::size_t rd = 0;
    SH sh = SH::SWP;
    std::size_t rm = 0;
    std::size_t high_nibble_offset = 0;
    std::size_t low_nibble_offset = 0;
    DataProcessingPSR::OffsetType imm_reg_offset = DataProcessingPSR::OffsetType::Register;

    std::uint32_t to_binary();
};

struct BlockDataTransfer_Instruction {
    Condition::Op condition = Condition::Op::Always;
    StorageOperations::IncrementType increment_type = StorageOperations::IncrementType::Post;
    StorageOperations::UpDown up_down = StorageOperations::UpDown::Down;
    StorageOperations::LoadPSRForceUser load_psr_force_user_mode =  StorageOperations::LoadPSRForceUser::No;
    StorageOperations::ShouldWriteBack write_back = StorageOperations::ShouldWriteBack::NoWriteBack;
    StorageOperations::LoadStore load_store = StorageOperations::LoadStore::Store;
    std::size_t rn = 0;
    std::size_t register_list = 0;

    std::uint32_t to_binary();
};

struct SingleDataSwap_Instruction {
    Condition::Op condition = Condition::Op::Always;
    StorageOperations::ByteWord byte_word = StorageOperations::ByteWord::Word;
    std::size_t rn = 0;
    std::size_t rd = 0;
    std::size_t rm = 0;

    std::uint32_t to_binary();
};

struct SoftwareInterrupt_Instruction {
    Condition::Op condition = Condition::Op::Always;

    std::uint32_t to_binary();
};

struct CoprocessorDataOperations_Instruction {
    Condition::Op condition = Condition::Op::Always;
    std::size_t cp_opc = 0;
    std::size_t co_rn = 0;
    std::size_t co_rd = 0;
    std::size_t cp_number = 0;
    std::size_t co_info = 0;
    std::size_t co_crm = 0;

    std::uint32_t to_binary();
};

struct CoprocessorDataTransfer_Instruction {
    Condition::Op condition = Condition::Op::Always;
    StorageOperations::IncrementType increment_type = StorageOperations::IncrementType::Post;
    StorageOperations::UpDown up_down = StorageOperations::UpDown::Down;
    std::size_t transfer_length = 0;
    StorageOperations::ShouldWriteBack write_back = StorageOperations::ShouldWriteBack::NoWriteBack;
    StorageOperations::LoadStore load_store = StorageOperations::LoadStore::Store;
    std::size_t rn = 0;
    std::size_t co_rd = 0;
    std::size_t cp_number = 0;
    std::size_t offset = 0;

    std::uint32_t to_binary();
};

struct CoprocessorRegisterTransfers_Instruction {
    Condition::Op condition = Condition::Op::Always;
    std::size_t co_op_mode = 0;
    std::size_t load_store = 0;
    std::size_t co_rn = 0;
    std::size_t rd = 0;
    std::size_t cp_number = 0;
    std::size_t co_info = 0;
    std::size_t co_rm = 0;

    std::uint32_t to_binary();
};

struct UndefinedInstruction_Instruction {
    Condition::Op condition = Condition::Op::Always;

    std::uint32_t to_binary();
};

#endif //VERILATORTEST_INSTRUCTIONDECODERTYPES_H
