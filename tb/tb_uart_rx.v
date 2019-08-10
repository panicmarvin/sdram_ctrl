`timescale 1ns/1ps
module tb_uart_rx;
reg clk  ;      
reg rst_n      ;
reg rs232_rx   ;
reg wfifo_full ;
wire [7:0] rx_data    ;
wire rx_data_vld;

wire full;

initial begin
clk=1;
forever #10 clk=~clk;
end
initial begin
rst_n  =0;
rs232_rx =  1;
wfifo_full=1;
#20
rst_n	=1;
#10
gendata(8'haa);
#1000
gendata(8'h10);

end
 
mux41 top(
.clk          (clk         )         ,
.rst_n        (rst_n       )        ,
.rs232_rx     (rs232_rx    )          ,
.wfifo_full   (wfifo_full  )         ,
.rx_data      (rx_data     )    ,
.rx_data_vld  (rx_data_vld)	,
.full				(full)
);

task gendata;
integer i;
input [7:0]	a;
for (i=0;i<=9;i=i+1) 
	repeat(434) begin
	@(posedge clk)
	if(i==0)
		rs232_rx=1'b0;
	else if(i==9)
		rs232_rx=1'b1;
	else
		rs232_rx=a[i-1];
end

endtask
endmodule
