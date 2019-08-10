`timescale 1ns/1ps
module tb_rfifo;
reg			rst_n				;
reg			fifo_wr_clk	        ;
reg			fifo_wr_en	        ;
wire			fifo_full	    ;
reg		[15:0]	fifo_wr_data    ;

reg			fifo_rd_clk	        ;
reg			fifo_rd_en	        ;
wire		[7:0]	fifo_rd_data    ;
wire 		fifo_empty        ;

localparam	WR_CLK	=	5;
localparam	RD_CLK	=	6.75;
initial begin
	fifo_wr_clk=0;

	forever #WR_CLK fifo_wr_clk=~fifo_wr_clk;
end
initial begin
	fifo_rd_clk=0;

	forever #RD_CLK fifo_rd_clk=~fifo_rd_clk;
end
	integer i;
initial begin
	rst_n=0;
	fifo_wr_en=0;
	fifo_rd_en=0;
	fifo_wr_data=16'h0000;
	
	#20
	rst_n=1;
	begin:wr_cnt
		for(i=0;i<=600;i=i+1)
		begin
			@(negedge fifo_wr_clk)
			fifo_wr_data=16'h0f00+i;
			fifo_wr_en=1;
		end
	end
	begin:wr_cnt1
		for(i=0;i<=600;i=i+1)
		begin
			@(negedge fifo_wr_clk)
			fifo_wr_data=16'h0f00+i;
			fifo_wr_en=1;
		end
	end
	#10	

	begin:rd_cnt
		for(i=0;i<=140;i=i+1)
		begin
			@(negedge fifo_rd_clk)
			fifo_wr_en=0;
			fifo_rd_en=1;
		end
	end
	
	#10
	begin:wr1_cnt
		for(i=0;i<=100;i=i+1)
		begin
			@(negedge fifo_wr_clk)
			fifo_wr_data=i;
			fifo_wr_en=1;
		end
	end
	#100
	$stop;
end

	rfifo	inst(
		.rst_n			(rst_n		),
		.fifo_wr_clk		(fifo_wr_clk	),
		.fifo_wr_en		(fifo_wr_en	),
		.fifo_full		(fifo_full	),
		.fifo_wr_data	(fifo_wr_data),
		.fifo_rd_clk		(fifo_rd_clk	),
		.fifo_rd_en		(fifo_rd_en	),
		.fifo_rd_data	(fifo_rd_data),
		.fifo_empty	(fifo_empty)
		
	);
endmodule