`timescale 1ns/1ps
module tb_sdram_write;
reg clk    ;       
reg s_rst_n      ;  
reg wr_en          ;
wire wr_req         ;
wire flag_wr_end    ;
reg ref_req        ;
reg wr_trig      ;  
wire [3:0] wr_cmd      ;   
wire [12:0] wr_addr        ;
wire [1:0] bank_addr      ;
wire [15:0] wr_data        ;
wire wfifo_rd_en    ;
reg [15:0] wfifo_rd_data	;
reg wfifo_deepth_eight	;




initial begin
clk=1;
forever #5 clk=~clk;
end

initial begin
s_rst_n  =0;
wfifo_deepth_eight=0;
wr_trig=0;
wr_en=0;
ref_req=0;
#20
s_rst_n	=1;
#10
gendata1();
#100
gendata2();
#100
gendata3();
#200
$stop;
end
 
task	gendata1;
begin
	@(posedge clk)
	wr_trig=1;
	@(posedge clk)
	wr_trig=0;
	wait(wr_req);
	@(posedge clk)
	@(posedge clk)
	wr_en=1;

	wait(wfifo_rd_en);
	@(posedge clk)
	@(posedge clk)
	wfifo_rd_data=16'h0f10;
	@(posedge clk)
	wfifo_rd_data=16'h0f55;
	@(posedge clk)
	wfifo_rd_data=16'h0faa;
	@(posedge clk)
	wfifo_rd_data=16'h0f01;

	wait(flag_wr_end);
	wr_en=0;
end
endtask

task	gendata2;
begin
	@(posedge clk)
	wfifo_deepth_eight=1;
	@(posedge clk)
	wfifo_deepth_eight=0;
	wait(wr_req);
	@(posedge clk)
	@(posedge clk)
	wr_en=1;

	wait(wfifo_rd_en);
	@(posedge clk)
	@(posedge clk)
	wfifo_rd_data=16'h0f10;
	@(posedge clk)
	wfifo_rd_data=16'h0f55;
	@(posedge clk)
	wfifo_rd_data=16'h0faa;
	@(posedge clk)
	wfifo_rd_data=16'h0f01;

	wait(flag_wr_end);
	wr_en=0;
end
endtask

task	gendata3;
begin
	@(posedge clk)
	wfifo_deepth_eight=1;
	wait(wr_req);
	@(posedge clk)
	@(posedge clk)
	wr_en=1;

	wait(wfifo_rd_en);
	@(posedge clk)
	@(posedge clk)
	wfifo_rd_data=16'h0f10;
	@(posedge clk)
	wfifo_rd_data=16'h0f55;
	//ref_req=1;
	@(posedge clk)
	wfifo_rd_data=16'h0faa;
	@(posedge clk)
	wfifo_rd_data=16'h0f01;
	wait(wr_addr=='d511) $stop;
	wait(flag_wr_end);
	wr_en=0;
end
endtask
 
sdram_write top(
.sclk             (clk           )     ,
.s_rst_n          (s_rst_n        )     ,
.wr_en            (wr_en          )     ,
.wr_req           (wr_req         )     ,
.flag_wr_end      (flag_wr_end    )     ,
.ref_req          (ref_req        )     ,
.wr_trig          (wr_trig        )     ,
.wr_cmd           (wr_cmd         )     ,
.wr_addr          (wr_addr        )     ,
.bank_addr        (bank_addr      )     ,
.wr_data          (wr_data        )     ,
.wfifo_rd_en      (wfifo_rd_en    )     ,
.wfifo_rd_data	  (wfifo_rd_data	)	 ,
.wfifo_deepth_eight  (wfifo_deepth_eight)
);
endmodule
