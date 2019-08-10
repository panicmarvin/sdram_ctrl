transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/xuboy/Desktop/sdram/src/wfifo {C:/Users/xuboy/Desktop/sdram/src/wfifo/wfifo.v}
vlog -vlog01compat -work work +incdir+C:/Users/xuboy/Desktop/sdram/src/wfifo/proj {C:/Users/xuboy/Desktop/sdram/src/wfifo/proj/ram_1024x8_w.v}

vlog -vlog01compat -work work +incdir+C:/Users/xuboy/Desktop/sdram/src/wfifo/proj/.. {C:/Users/xuboy/Desktop/sdram/src/wfifo/proj/../tb_wfifo.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  tb_wfifo

add wave *
view structure
view signals
run -all
