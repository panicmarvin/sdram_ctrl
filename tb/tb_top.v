`timescale      1ns/1ns

module  tb_top;

reg             sclk;
reg             s_rst_n;

//----------------------------------------------------------
wire            sdram_clk;
wire            sdram_cke;
wire            sdram_cs_n;
wire            sdram_cas_n;
wire            sdram_ras_n;
wire            sdram_we_n;
wire    [ 1:0]  sdram_bank;
wire    [12:0]  sdram_addr;
wire    [ 1:0]  sdram_dqm;
wire    [15:0]  sdram_dq;


reg             rs232_rx;
wire			rs232_tx;



initial begin
s_rst_n  =0;
rs232_rx =  1;
#20
s_rst_n	=1;
#20

wait(top_inst.sdram_top_inst.flag_init_end);
#1000
gendata(8'h55);
#20
gendata(8'h12);
#20
gendata(8'h0F);
#20
gendata(8'h34);
#20
gendata(8'h0F);
#20
gendata(8'h56);
#20
gendata(8'hFF);
#20
gendata(8'h78);
#20
gendata(8'h0F);
#1000
gendata(8'haa);
#1000
$stop;
end

task gendata;
	integer i;
	input [7:0]	a;
begin
	for (i=0;i<=10;i=i+1) 
		repeat(434) begin
		@(posedge sclk)
		if(i==0)
			rs232_rx=1'b0;
		else if(i>=9)
			rs232_rx=1'b1;
		else
			rs232_rx=a[i-1];
	end
	rs232_rx=1'b1;
end
endtask




initial begin
sclk=1;
forever #10 sclk=~sclk;
end

defparam        sdram_model_plus_inst.addr_bits =       13;
defparam        sdram_model_plus_inst.data_bits =       16;
defparam        sdram_model_plus_inst.col_bits  =       10;
defparam        sdram_model_plus_inst.mem_sizes =       1048576*1-1;            // 1M




top             top_inst(
        // system signals
        .sclk                    (sclk                  ),
        .s_rst_n                 (s_rst_n               ),
        // UART Interface
        .rs232_rx                (rs232_rx              ),
        .rs232_tx                (rs232_tx				),
        // SDRAM Interfaces
        .sdram_clk               (sdram_clk             ),
        .sdram_cke               (sdram_cke             ),
        .sdram_cs_n              (sdram_cs_n            ),
        .sdram_cas_n             (sdram_cas_n           ),
        .sdram_ras_n             (sdram_ras_n           ),
        .sdram_we_n              (sdram_we_n            ),
        .sdram_bank              (sdram_bank            ),
        .sdram_addr              (sdram_addr            ),
        .sdram_dqm               (sdram_dqm             ),
        .sdram_dq                (sdram_dq              )
);

sdram_model_plus sdram_model_plus_inst(
        .Dq                     (sdram_dq               ), 
        .Addr                   (sdram_addr             ), 
        .Ba                     (sdram_bank             ), 
        .Clk                    (sdram_clk              ), 
        .Cke                    (sdram_cke              ), 
        .Cs_n                   (sdram_cs_n             ), 
        .Ras_n                  (sdram_ras_n            ), 
        .Cas_n                  (sdram_cas_n            ), 
        .We_n                   (sdram_we_n             ), 
        .Dqm                    (sdram_dqm              ),
        .Debug                  (1'b1                   )
);


endmodule