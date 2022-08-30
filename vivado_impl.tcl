proc ::FindFiles {base_dir pattern} {
    set dirs [glob -nocomplain -type d [file join $base_dir * ]]
    set files {}

    foreach dir $dirs {
        lappend files {*}[FindFiles $dir $pattern]
    }

    lappend files {*}[glob -nocomplain -type f [file join $base_dir $pattern]]
    return $files
}

proc add_sv_files {} {
    set files {}
    lappend files {*}[FindFiles "./src" "*.sv"]

    foreach file $files {
        read_verilog $file
    }
}

proc add_constraint_files {} {
    set files {}
    lappend files {*}[FindFiles "./constraints" "*.xdc"]

    foreach file $files {
        read_xdc $file
    }
}

proc synthesise_design {FPGA_PART TOP_MODULE_NAME PROJECT_NAME} {
    synth_design -part $FPGA_PART -top $TOP_MODULE_NAME
    report_timing_summary -file ./reports/${PROJECT_NAME}_post_synth_tim.rpt
    report_utilization -file ./reports/${PROJECT_NAME}_post_synth_util.rpt
    write_checkpoint -force -file post_synth_checkpoint
}

proc implement_design {PROJECT_NAME} {
    opt_design
    write_checkpoint -force -file opt_design_checkpoint
    place_design
    write_checkpoint -force -file place_design_checkpoint
    phys_opt_design
    write_checkpoint -force -file phys_opt_design_checkpoint
    route_design
    write_checkpoint -force -file route_design_checkpoint
    
    report_timing_summary -file ./reports/${PROJECT_NAME}_post_impl_tim.rpt
	report_utilization -file ./reports/${PROJECT_NAME}_post_impl_util.rpt
	report_route_status -file  ./reports/${PROJECT_NAME}_post_impl_route_util.rpt
	report_io -file ./reports/${PROJECT_NAME}_post_impl_io.rpt
	report_power -file ./reports/${PROJECT_NAME}_post_impl_power.rpt
}

proc generate_bitstream {PROBE_FILE PROJECT_NAME} {
    write_debug_probes -force ${PROBE_FILE}
    write_bitstream -force ${PROJECT_NAME}
}

proc run_impl {FPGA_PART TOP_MODULE_NAME PROJECT_NAME PROBE_FILE} {
    add_sv_files
    add_constraint_files
    synthesise_design $FPGA_PART $TOP_MODULE_NAME $PROJECT_NAME
    implement_design $PROJECT_NAME
    generate_bitstream $PROBE_FILE $PROJECT_NAME
}

