proc upload_to_fpga {FPGA_PART_FOR_UPLOAD PROBE_FILE PROGRAM_FILE} {
    open_hw_manager
    connect_hw_server -allow_non_jtag
    open_hw_target
    current_hw_device [get_hw_devices ${FPGA_PART_FOR_UPLOAD}]
    refresh_hw_device -update_hw_probes false [lindex [get_hw_devices ${FPGA_PART_FOR_UPLOAD}] 0]
    set_property PROBES.FILE ${PROBE_FILE} [get_hw_devices ${FPGA_PART_FOR_UPLOAD}] 
    # set_property FULL_PROBES.FILE ${FULL_PROBE_FILE} [get_hw_devices ${FPGA_PART_FOR_UPLOAD}]
    set_property PROGRAM.FILE ${PROGRAM_FILE} [get_hw_devices ${FPGA_PART_FOR_UPLOAD}]
    program_hw_device [lindex [get_hw_devices ${FPGA_PART_FOR_UPLOAD}] 0]
    refresh_hw_device -update_hw_probes false [lindex [get_hw_devices ${FPGA_PART_FOR_UPLOAD}] 0]
}