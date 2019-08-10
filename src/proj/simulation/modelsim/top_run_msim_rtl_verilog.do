transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/xuboy/Desktop/sdram/src/proj {C:/Users/xuboy/Desktop/sdram/src/proj/wfifo.v}
vlog -vlog01compat -work work +incdir+C:/Users/xuboy/Desktop/sdram/src/proj {C:/Users/xuboy/Desktop/sdram/src/proj/uart_tx.v}
vlog -vlog01compat -work work +incdir+C:/Users/xuboy/Desktop/sdram/src/proj {C:/Users/xuboy/Desktop/sdram/src/proj/uart_rx.v}
vlog -vlog01compat -work work +incdir+C:/Users/xuboy/Desktop/sdram/src/proj {C:/Users/xuboy/Desktop/sdram/src/proj/top.v}
vlog -vlog01compat -work work +incdir+C:/Users/xuboy/Desktop/sdram/src/proj {C:/Users/xuboy/Desktop/sdram/src/proj/sdram_write.v}
vlog -vlog01compat -work work +incdir+C:/Users/xuboy/Desktop/sdram/src/proj {C:/Users/xuboy/Desktop/sdram/src/proj/sdram_top.v}
vlog -vlog01compat -work work +incdir+C:/Users/xuboy/Desktop/sdram/src/proj {C:/Users/xuboy/Desktop/sdram/src/proj/sdram_read.v}
vlog -vlog01compat -work work +incdir+C:/Users/xuboy/Desktop/sdram/src/proj {C:/Users/xuboy/Desktop/sdram/src/proj/sdram_init.v}
vlog -vlog01compat -work work +incdir+C:/Users/xuboy/Desktop/sdram/src/proj {C:/Users/xuboy/Desktop/sdram/src/proj/sdram_aref.v}
vlog -vlog01compat -work work +incdir+C:/Users/xuboy/Desktop/sdram/src/proj {C:/Users/xuboy/Desktop/sdram/src/proj/rfifo.v}
vlog -vlog01compat -work work +incdir+C:/Users/xuboy/Desktop/sdram/src/proj {C:/Users/xuboy/Desktop/sdram/src/proj/cmd_decode.v}
vlog -vlog01compat -work work +incdir+C:/Users/xuboy/Desktop/sdram/src/proj {C:/Users/xuboy/Desktop/sdram/src/proj/ram_1024x8_w.v}
vlog -vlog01compat -work work +incdir+C:/Users/xuboy/Desktop/sdram/src/proj {C:/Users/xuboy/Desktop/sdram/src/proj/ram_1024x8_r.v}
vlog -vlog01compat -work work +incdir+C:/Users/xuboy/Desktop/sdram/src/proj {C:/Users/xuboy/Desktop/sdram/src/proj/sdram_model_plus.v}
vlog -vlog01compat -work work +incdir+C:/Users/xuboy/Desktop/sdram/src/proj {C:/Users/xuboy/Desktop/sdram/src/proj/tb_top.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  tb_top

add wave *
view structure
view signals
run -all