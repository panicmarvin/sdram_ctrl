`timescale 1ns/1ps
module tb_uart_tx;
reg clk ;         
reg rst_n ;       
wire rs232_tx   ;  
reg rfifo_empty  ;
wire rfifo_rd_en  ;
reg [7:0] rfifo_rd_data;
wire data_vld;


initial begin
clk=1;
forever #5 clk=~clk;
end
initial begin
rst_n  =0;
rfifo_empty=1;
#20
rst_n	=1;
#10
@(posedge clk)
rfifo_empty=0;
wait(rfifo_rd_en);
@(posedge clk)
@(posedge clk)
rfifo_rd_data=8'h55;

wait(rfifo_rd_en);
@(posedge clk)
@(posedge clk)
rfifo_rd_data=8'haa;

wait(rfifo_rd_en);
@(posedge clk)
@(posedge clk)
rfifo_rd_data=8'h10;
end
 
uart_tx top(
.clk               (clk          )     ,
.rst_n             (rst_n        )     ,
.rs232_tx          (rs232_tx     )     ,
.rfifo_empty       (rfifo_empty  )     ,
.rfifo_rd_en       (rfifo_rd_en  )     ,
.rfifo_rd_data     (rfifo_rd_data)     ,
.data_vld(data_vld)
);
endmodule
