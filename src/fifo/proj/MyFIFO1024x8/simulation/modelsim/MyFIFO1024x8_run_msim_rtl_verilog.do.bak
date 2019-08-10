transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/xuboy/Desktop/sdram/src/fifo {C:/Users/xuboy/Desktop/sdram/src/fifo/NGM_Lib.v}
vlog -vlog01compat -work work +incdir+C:/Users/xuboy/Desktop/sdram/src/fifo {C:/Users/xuboy/Desktop/sdram/src/fifo/MyFIFO1024x8.v}
vlog -vlog01compat -work work +incdir+C:/Users/xuboy/Desktop/sdram/src/fifo {C:/Users/xuboy/Desktop/sdram/src/fifo/MyFIFO_Ctrl.v}
vlog -vlog01compat -work work +incdir+C:/Users/xuboy/Desktop/sdram/src/fifo/proj/MyFIFO1024x8 {C:/Users/xuboy/Desktop/sdram/src/fifo/proj/MyFIFO1024x8/bram_1024x8.v}

vlog -vlog01compat -work work +incdir+C:/Users/xuboy/Desktop/sdram/src/fifo/proj/MyFIFO1024x8/../../tb {C:/Users/xuboy/Desktop/sdram/src/fifo/proj/MyFIFO1024x8/../../tb/tb_Top_MyFIFO_Ctrl.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  tb_Top_MyFIFO_Ctrl

add wave *
view structure
view signals
run -all
