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

run_implementation: generate_synthesis_tcl_script generate_implementation_tcl_script generate_bitstream_tcl_script
	vivado -mode batch -source vivado_script.tcl

generate_synthesis_tcl_script:
# Clear file if it exists
	echo "" > vivado_script.tcl

# Read design file
	for file in $(SOURCES); do \
		echo "read_verilog $$file" >> vivado_script.tcl; \
	done

# Read constraint files
	for file in $(CONSTRAINTS); do \
		echo "read_xdc $$file" >> vivado_script.tcl; \
	done

# Generate Ip
	echo "generate_target all [get_ips]" >> vivado_script.tcl

	echo "synth_design -part $(FPGA_PART) -top $(TOP_MODULE_NAME)" >> vivado_script.tcl
	echo "report_timing_summary -file ./reports/$(PROJECT_NAME)_post_synth_tim.rpt" >> vivado_script.tcl
	echo "report_utilization -file ./reports/$(PROJECT_NAME)_post_synth_util.rpt" >> vivado_script.tcl
	echo "write_checkpoint -force -file post_synth_checkpoint" >> vivado_script.tcl
	
generate_implementation_tcl_script:
	echo opt_design >> vivado_script.tcl
	echo "write_checkpoint -force -file opt_design_checkpoint" >> vivado_script.tcl

	echo place_design >> vivado_script.tcl
	echo phys_opt_design >> vivado_script.tcl 
	echo route_design >> vivado_script.tcl

	echo "report_timing_summary -file ./reports/$(PROJECT_NAME)_post_impl_tim.rpt" >> vivado_script.tcl
	echo "report_utilization -file ./reports/$(PROJECT_NAME)_post_impl_util.rpt" >> vivado_script.tcl
	echo "report_route_status -file  ./reports/$(PROJECT_NAME)_post_impl_route_util.rpt" >> vivado_script.tcl
	echo "report_io -file ./reports/$(PROJECT_NAME)_post_impl_io.rpt" >> vivado_script.tcl
	echo "report_power -file ./reports/$(PROJECT_NAME)_post_impl_power.rpt" >> vivado_script.tcl
	echo "write_checkpoint -force -file post_impl_checkpoint" >> vivado_script.tcl

generate_bitstream_tcl_script:
	echo "write_debug_probes -force $(PROBE_FILE)" >> vivado_script.tcl
	echo "write_bitstream -force $(PROGRAM_FILE)" >> vivado_script.tcl

hardware_manager:
	echo "start_gui" > hardware_manager.tcl
	echo "open_hw_manager" >> hardware_manager.tcl
	vivado -mode batch -source hardware_manager.tcl 

upload:
	echo "open_hw_manager" > upload.tcl
	echo "connect_hw_server -allow_non_jtag" >> upload.tcl
	echo "open_hw_target" >> upload.tcl
	echo "current_hw_device [get_hw_devices $(FPGA_PART_FOR_UPLOAD)]" >> upload.tcl
	echo "refresh_hw_device -update_hw_probes false [lindex [get_hw_devices $(FPGA_PART_FOR_UPLOAD)] 0]" >> upload.tcl
	echo "set_property PROBES.FILE {${PROBE_FILE}} [get_hw_devices ${FPGA_PART_FOR_UPLOAD}]" >> upload.tcl
	echo "set_property FULL_PROBES.FILE {${FULL_PROBE_FILE}} [get_hw_devices ${FPGA_PART_FOR_UPLOAD}]" >> upload.tcl
	echo "set_property PROGRAM.FILE {${PROGRAM_FILE}} [get_hw_devices ${FPGA_PART_FOR_UPLOAD}]" >> upload.tcl
	echo "program_hw_device [lindex [get_hw_devices ${FPGA_PART_FOR_UPLOAD}] 0]" >> upload.tcl
	echo "refresh_hw_device -update_hw_probes false [lindex [get_hw_devices $(FPGA_PART_FOR_UPLOAD)] 0]" >> upload.tcl

	vivado -mode batch -source upload.tcl 