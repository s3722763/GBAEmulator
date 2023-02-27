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
# https://github.com/camstutz/vivado-workflow/blob/master/scripts/full_implementation.tcl
proc add_ip_files {} {
    set files {}
    lappend files {*}[FindFiles "./ip" "*.xci"]

    foreach file $files {
        read_ip $file
    }

    foreach ip [get_ips] {
        set ip_filename [get_property IP_FILE $ip]
        set ip_dcp [file rootname $ip_filename]
        append ip_dcp ".dcp"
        set ip_xml [file rootname $ip_filename]
        append ip_xml ".xml"

        if {([file exists $ip_dcp] == 0) || [expr {[file mtime $ip_filename ] > [file mtime $ip_dcp ]}]} {
            reset_target all $ip
            
            file delete $ip_xml

            generate_target all $ip
            set_property generate_synth_checkpoint true [get_files $ip_filename]
            synth_ip $ip
        }
    }

    generate_target all [get_ips]
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

proc run_impl {FPGA_PART TOP_MODULE_NAME PROJECT_NAME PROBE_FILE BOARD_PART} {
    set_part $FPGA_PART
    set_property TARGET_LANGUAGE Verilog [current_project]
    set_property BOARD_PART $BOARD_PART [current_project]
    set_property DEFAULT_LIB word [current_project]

    add_sv_files
    add_ip_files
    add_constraint_files

}

proc run_synth {FPGA_PART TOP_MODULE_NAME PROJECT_NAME PROBE_FILE BOARD_PART} {
    set_part $FPGA_PART
    set_property TARGET_LANGUAGE Verilog [current_project]
    set_property BOARD_PART $BOARD_PART [current_project]
    set_property DEFAULT_LIB word [current_project]

    add_sv_files
    add_ip_files
    add_constraint_files
    synthesise_design $FPGA_PART $TOP_MODULE_NAME $PROJECT_NAME
}
