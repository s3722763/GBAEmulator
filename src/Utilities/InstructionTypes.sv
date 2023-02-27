`ifndef INSTRUCTION_TYPES_PACKAGE
`define INSTRUCTION_TYPES_PACKAGE

package Condition;
    typedef enum bit[3:0] { 
        Equal = 0,
        NotEqual = 1,
        UnsignedHigherSame = 2,
        UnsignedLower = 3,
        Negative = 4,
        PositiveZero = 5,
        Overflow = 6,
        NoOverflow = 7,
        UnsignedHigher = 8,
        UnsignedLowerSame = 9,
        GreaterEqual = 10,
        LessThan = 11,
        GreaterThan = 12,
        LessThanEqual = 13,
        Always = 14,
        Undefined = 15
    } Condition_Value;
endpackage

package OffsetType;
    typedef enum bit {
        Immediate = 1,
        Register = 0
    } OffsetType_Value;
endpackage

package AluOpcode;
    typedef enum bit[3:0] {
        AND = 0,
        EOR = 1,
        SUB = 2,
        RSB = 3,
        ADD = 4,
        ADC = 5,
        SBC = 6,
        RSC = 7,
        TST = 8,
        TEQ = 9,
        CMP = 10,
        CMN = 11,
        ORR = 12,
        MOV = 13,
        BIC = 14,
        MVN = 15
    } AluOpcode_Value;
endpackage

package ShiftType;
    typedef enum bit[1:0] {
        LogicalLeft = 0,
        LogicalRight = 1,
        ArithmeticRight = 2,
        RotateRight = 3
    } ShiftType_Value;
endpackage

package SourcePSR;
    typedef enum bit {
        CPSR = 0,
        SPSR = 1
    } SourcePSR_Value;
endpackage

package Op2ShiftType;
    typedef enum bit {
        Immediate = 0,
        Register = 1
    } Op2ShiftType_Value;
endpackage

`endif // INSTRUCTION_TYPES_PACKAGE
