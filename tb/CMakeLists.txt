cmake_minimum_required(VERSION 3.8)
project(VerilatorTest)
set(CMAKE_CXX_STANDARD 20)

find_package(verilator HINTS $ENV{VERILATOR_ROOT} ${VERILATOR_ROOT})
if (NOT verilator_FOUND)
  message(FATAL_ERROR "Verilator was not found. Either install it, or set the VERILATOR_ROOT environment variable")
endif()

find_package(Catch2 3 REQUIRED)

# add_subdirectory(ALU)
add_subdirectory(InstructionDecoder)

add_executable(VerilatorTest test.cpp)

target_link_libraries(VerilatorTest Catch2::Catch2 InstructionDecoder)