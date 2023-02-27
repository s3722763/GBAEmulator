find_package(verilator HINTS $ENV{VERILATOR_ROOT} ${VERILATOR_ROOT})
if (NOT verilator_FOUND)
    message(FATAL_ERROR "Verilator was not found. Either install it, or set the VERILATOR_ROOT environment variable")
endif()

find_package(Catch2 3 REQUIRED)

add_library(InstructionDecoder InstructionDecoderTest.cpp DataProcessingPSRInstructionTests.cpp InstructionDecoderTypes.cpp)

target_link_libraries(InstructionDecoder PRIVATE Catch2::Catch2)

# Add the Verilated circuit to the target
verilate(InstructionDecoder COVERAGE TRACE
         VERILATOR_ARGS -f ../input.vc -x-assign fast
         SOURCES ../../src/InstructionDecoder/InstructionDecoder.sv)

verilate(InstructionDecoder COVERAGE TRACE
        VERILATOR_ARGS -f ../input.vc -x-assign fast
        SOURCES ../../src/InstructionDecoder/DataProcessingPSRInstructionDecoder.sv)

verilate(InstructionDecoder COVERAGE TRACE
        VERILATOR_ARGS -f ../input.vc -x-assign fast
        SOURCES ../../src/InstructionDecoder/ConditionDecoder.sv)
