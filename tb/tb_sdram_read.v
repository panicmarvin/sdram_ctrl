`timescale 1ns/1ps
module tb_sdram_rd;
reg clk    ;      
reg s_rst_n       ;
reg rd_en         ;
wire rd_req        ;
wire flag_rd_end   ;
reg ref_req       ;
reg rd_trig       ;
wire [3:0] rd_cmd      ;  
wire [12:0] rd_addr       ;
wire [1:0] bank_addr     ;
reg [15:0] rd_data       ;
wire rfifo_wr_en   ;
wire [15:0] rfifo_wr_data	;
reg rfifo_full    ;






initial begin
clk=1;
forever #10 clk=~clk;
end

initial begin
s_rst_n  =0;
rfifo_full=0;
rd_trig=0;
rd_en=0;
ref_req=0;
rd_data=0;
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
	rd_trig=1;
	@(posedge clk)
	rd_trig=0;
	wait(rd_req);
	@(posedge clk)
	@(posedge clk)
	rd_en=1;

	wait(rd_cmd==4'b0101);
	@(negedge clk)
	
	@(negedge clk)
	@(negedge clk)
	@(negedge clk)
	rd_data=16'h0f10;
	@(negedge clk)
	rd_data=16'h0f55;
	@(negedge clk)
	rd_data=16'h0faa;
	@(negedge clk)
	rd_data=16'h0f01;

	wait(flag_rd_end);
	rd_en=0;
end
endtask

task	gendata2;
begin
	@(posedge clk)
	rfifo_full=1;
	@(posedge clk)
	rd_trig=1;
	@(posedge clk)
	rd_trig=0;
	//wait(rd_req);
	@(posedge clk)
	@(posedge clk)
	//rd_en=1;

	//wait(rd_cmd==4'b0101);
	@(negedge clk)
	
	@(negedge clk)
	@(negedge clk)
	@(negedge clk)
	rd_data=16'h0f10;
	@(negedge clk)
	rd_data=16'h0f55;
	@(negedge clk)
	rd_data=16'h0faa;
	@(negedge clk)
	rd_data=16'h0f01;

	//wait(flag_rd_end);
	rd_en=0;
end
endtask

task	gendata3;
begin
	@(posedge clk)
	rfifo_full=0;
	@(posedge clk)
	rd_trig=1;
	@(posedge clk)
	rd_trig=0;
	wait(rd_req);
	@(posedge clk)
	@(posedge clk)
	rd_en=1;

	wait(rd_cmd==4'b0101);
	@(negedge clk)
	
	@(negedge clk)
	@(negedge clk)
	@(negedge clk)
	rd_data=16'h0f10;
	@(negedge clk)
	rd_data=16'h0f55;
	@(posedge clk)
	ref_req=1;
	@(negedge clk)
	rd_data=16'h0faa;
	@(negedge clk)
	rd_data=16'h0f01;

	wait(flag_rd_end) rd_en=0;
	
end
endtask
 
sdram_read  top(
.sclk                 (clk         )  ,
.s_rst_n              (s_rst_n      )  ,
.rd_en                (rd_en        )  ,
.rd_req               (rd_req       )  ,
.flag_rd_end          (flag_rd_end  )  ,
.ref_req              (ref_req      )  ,
.rd_trig              (rd_trig      )  ,
.rd_cmd               (rd_cmd       )  ,
.rd_addr              (rd_addr      )  ,
.bank_addr            (bank_addr    )  ,
.rd_data              (rd_data      )  ,
.rfifo_wr_en          (rfifo_wr_en  )  ,
.rfifo_wr_data		  (rfifo_wr_data) ,
.rfifo_full           (rfifo_full)
);
endmodule
