module  top(
        // system signals
        input                   sclk                    ,
        input                   s_rst_n                 ,
        // UART Interface
        input                   rs232_rx                ,
        output  wire            rs232_tx                ,
        // SDRAM Interfaces
        output  wire            sdram_clk               ,
        output  wire            sdram_cke               ,
        output  wire            sdram_cs_n              ,
        output  wire            sdram_cas_n             ,
        output  wire            sdram_ras_n             ,
        output  wire            sdram_we_n              ,
        output  wire    [ 1:0]  sdram_bank              ,
        output  wire    [12:0]  sdram_addr              ,
        output  wire    [ 1:0]  sdram_dqm               ,
        inout           [15:0]  sdram_dq                
);

//====================================================================\
// ********** Define Parameter and Internal Signals *************
//====================================================================/
wire    [ 7:0]                  rx_data                         ;
wire							tx_data_vld						;
wire                            rx_data_vld                     ;

wire                            sdram_wr_trig                   ;
wire                            sdram_rd_trig                   ;
wire                            wfifo_wr_en                     ;
wire    [ 7:0]                  wfifo_data                      ;
wire                            wfifo_rd_en                     ;
wire    [15:0]                  wfifo_rd_data                   ;
wire                            wfifo_empty                     ;
wire                            wfifo_full                      ;

wire    [15:0]                  rfifo_wr_data                   ;
wire                            rfifo_wr_en                     ;
wire    [ 7:0]                  rfifo_rd_data                   ;
wire                            rfifo_rd_en                     ;
wire                            rfifo_empty                     ;
wire                            rfifo_full                      ;

wire							wfifo_deepth_eight				;
//=================================================================================
// ***************      Main    Code    ****************
//=================================================================================
uart_rx         uart_rx_inst(
        // system signals
        .clk                    (sclk                  ),
        .rst_n                  (s_rst_n               ),
        // UART Interface        
        .rs232_rx               (rs232_rx              ),
        // others                
        .rx_data                (rx_data               ),
        .rx_data_vld            (rx_data_vld       )
);
//------------------------------------------------------------------------
uart_tx         uart_tx_inst(
        // system signals
        .clk                    (sclk                  ),
        .rst_n                  (s_rst_n               ),
        // UART Interface
        .rs232_tx               (rs232_tx              ),
        //
        .rfifo_empty            (rfifo_empty           ),
        .rfifo_rd_en            (rfifo_rd_en           ),
        .rfifo_rd_data          (rfifo_rd_data         ),
        .data_vld			    (tx_data_vld)
);

cmd_decode      cmd_decode_inst(
        // system signals
        .clk                    (sclk                  ),
        .rst_n                  (s_rst_n               ),
        // From UART_RX module   
        .uart_data_vld               (rx_data_vld               ),
        .uart_data               (rx_data               ),
        // Others  
        .wfifo_full              (wfifo_full            ),		  
        .wr_trig                 (sdram_wr_trig         ),
        .rd_trig                 (sdram_rd_trig         ),
        .wfifo_wr_en             (wfifo_wr_en           ),
        .wfifo_data              (wfifo_data            )
);

wfifo	wfifo_inst(
	.rst_n			(s_rst_n		),
	.fifo_wr_clk	(sclk	),
	.fifo_wr_en		(wfifo_wr_en	),
	.fifo_full		(wfifo_full	),
	.fifo_wr_data	(wfifo_data),
	.fifo_rd_clk	(sclk	),
	.fifo_rd_en		(wfifo_rd_en	),
	.fifo_rd_data	(wfifo_rd_data),
	.fifo_empty	    (wfifo_empty),
	.wfifo_deepth_eight (wfifo_deepth_eight)
	
);

rfifo	rfifo_inst(
	.rst_n			(s_rst_n		),
	.fifo_wr_clk	(sclk	),
	.fifo_wr_en		(rfifo_wr_en	),
	.fifo_full		(rfifo_full	),
	.fifo_wr_data	(rfifo_wr_data),
	.fifo_rd_clk	(sclk	),
	.fifo_rd_en		(rfifo_rd_en	),
	.fifo_rd_data	(rfifo_rd_data),
	.fifo_empty	    (rfifo_empty)
	
);

//------------------------------------------------------------------------
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
		.wfifo_deepth_eight		 (wfifo_deepth_eight    ),
		.rfifo_full				 (rfifo_full   			)
);

endmodule