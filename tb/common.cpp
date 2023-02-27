// DESCRIPTION: Verilator: Verilog example module
//
// This file ONLY is placed under the Creative Commons Public Domain, for
// any use, without warranty, 2017 by Wilson Snyder.
// SPDX-License-Identifier: CC0-1.0
//======================================================================

// For std::unique_ptr
#include <memory>
#include <string_view>

// Include common routines
#include <verilated.h>
#include <verilated_vcd_c.h>

// Include model header, generated from Verilating "top.v"
#include "catch2/catch_test_macros.hpp"

// Legacy function required only so linking works on Cygwin and MSVC++
double sc_time_stamp() { return 0; }

template<typename T>
struct VerilatorInfo {
    std::unique_ptr<VerilatedContext> context;
    std::unique_ptr<T> model;
    std::unique_ptr<VerilatedVcdC> trace;

    vluint64_t sim_time = 0;
};

template<typename T>
VerilatorInfo<T> setupContext(std::string_view trace_name) {
    // This is a more complicated example, please also see the simpler examples/make_hello_c.

    // Create logs/ directory in case we have traces to put under it
    Verilated::mkdir("logs");

    std::unique_ptr<VerilatedContext> context = std::make_unique<VerilatedContext>();
    context->debug(0);
    context->randReset(2);
    context->traceEverOn(true);
    std::unique_ptr<T> top = std::make_unique<T>(context.get(), "TOP");

    std::unique_ptr<VerilatedVcdC> trace = std::make_unique<VerilatedVcdC>();

    top->trace(trace.get(), 99);
    std::string trace_filename = std::string(trace_name) + ".vcd";

    trace->open(trace_filename.data());

    VerilatorInfo<T> info = {0};
    info.context = std::move(context);
    info.model = std::move(top);
    info.trace = std::move(trace);

    return info;
}


template<typename T>
void cycle(VerilatorInfo<T>& info) {
    info.context->timeInc(1); 
    info.model->clk = 0;
    info.model->eval();
    info.trace->dump(info.sim_time);
    info.sim_time += 1;

    info.context->timeInc(1); 
    info.model->clk = 1;
    info.model->eval();
    info.trace->dump(info.sim_time);
    info.sim_time += 1;
}