rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

PROJECT_NAME := Test
SOURCES := $(call rwildcard,src,*.sv)
CONSTRAINTS := $(call rwildcard,constraints,*.xdc)
TB_SOURCE := tb/Testbench.sv
TB_CPP_SOURCES = $(call rwildcard,tb,*.cpp)
FPGA_PART := "xc7a100tcsg324-1"
FPGA_PART_FOR_UPLOAD := "xc7a100t_0"
VERILATOR_BIN := verilator_bin
TOP_MODULE_NAME := Top
PROBE_FILE := "${PROJECT_NAME}.ltx"
FULL_PROBE_FILE := "" 
PROGRAM_FILE := "${PROJECT_NAME}.bit"

generate:
	$(VERILATOR_BIN) -cc -Wall --top-module Testbench $(SOURCES) $(TB_SOURCE)

build:
	$(VERILATOR_BIN) -cc -Wall --exe --build --top-module Testbench $(SOURCES) $(TB_SOURCE) $(TB_CPP_SOURCES)

run_tests:
# To do parallel tests, look at sharding (catch2)
	./obj_dir/VTestbench

clean:
	rm -r obj_dir

# https://docs.xilinx.com/r/en-US/ug892-vivado-design-flows-overview/Using-Non-Project-Mode-Tcl-Commands

impl:
	echo "source vivado_impl.tcl" > impl.tcl
	echo "run_impl $(FPGA_PART) $(TOP_MODULE_NAME) $(PROJECT_NAME) $(PROBE_FILE)" >> impl.tcl
	vivado -mode batch -source impl.tcl

upload:
	echo "source upload.tcl" > up.tcl
	echo "upload_to_fpga $(FPGA_PART_FOR_UPLOAD) $(PROBE_FILE) $(PROGRAM_FILE)" >> up.tcl
	vivado -mode batch -source up.tcl

hardware_manager:
	echo "source hardware_manager.tcl" > hwm.tcl
	echo "open_hardware_manager" >> hwm.tcl
	vivado -mode batch -source hwm.tcl