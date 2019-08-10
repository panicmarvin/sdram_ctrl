`timescale      1ns/1ps

module  tb_sdram_top;

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
reg				wfifo_deepth_eight;
reg				rfifo_full;

//----------------------------------------------------------
reg				sdram_wr_trig;
reg				sdram_rd_trig;
wire			wfifo_rd_en;
wire			rfifo_wr_en;
reg		[15:0]		wfifo_rd_data;
wire	[15:0]		rfifo_wr_data;

initial begin
	s_rst_n  =0;
	wfifo_deepth_eight=0;
	sdram_wr_trig=0;
	sdram_rd_trig=0;
	rfifo_full=0;
	wfifo_rd_data=0;
	#20
	s_rst_n	=1;

	wait(sdram_top_inst.flag_init_end);
	#100
	//repeat(260) begin
	repeat(660) begin
	#100
	gendata1();
	end
	#100
	readdata1();
	#200
	$stop;
end

task	gendata1;
begin
	@(posedge sclk)
	sdram_wr_trig=1;
	@(posedge sclk)
	sdram_wr_trig=0;

	wait(wfifo_rd_en);
	@(posedge sclk)
	@(posedge sclk)
	wfifo_rd_data=16'h0f10;
	@(posedge sclk)
	wfifo_rd_data=16'h0f55;
	@(posedge sclk)
	wfifo_rd_data=16'h0faa;
	@(posedge sclk)
	wfifo_rd_data=16'h0f01;
end
endtask

task	readdata1;
begin
	@(posedge sclk)
	sdram_rd_trig=1;
	@(posedge sclk)
	sdram_rd_trig=0;
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

sdram_top       sdram_top_inst(
        // system signals
        .sclk                    (sclk                  ),
        .s_rst_n                 (s_rst_n               ),
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
        .sdram_dq                (sdram_dq              ),
        // Others
        .wr_trig                 (sdram_wr_trig         ),
        .rd_trig                 (sdram_rd_trig         ),
        // FIFO Signals
        .wfifo_rd_en             (wfifo_rd_en           ),
        .wfifo_rd_data           (wfifo_rd_data         ),
        .rfifo_wr_data           (rfifo_wr_data         ),
        .rfifo_wr_en             (rfifo_wr_en           ),
		.wfifo_deepth_eight      (wfifo_deepth_eight       ),
		.rfifo_full              (rfifo_full            )
);
endmodule