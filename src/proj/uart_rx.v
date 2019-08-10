module  uart_rx(
        // system signals
        input                   clk                    ,
        input                   rst_n                 ,
        // UART Interface
        input                   rs232_rx                ,
        // WFIFO
        output 	reg         [ 7:0]  rx_data           ,
		output	reg				rx_data_vld			
);
//====================================================================\
// ********** Define Parameter and Internal Signals *************
//====================================================================/
localparam      BAUD_END        =       434                    ;
localparam      BAUD_M          =       BAUD_END/2 - 1          ;
localparam      BIT_END         =       9                       ;

reg                             rx_r1                           ;
reg                             rx_r2                           ;
reg                             rx_r3                           ;
reg                             rx_flag                         ;
reg     [12:0]                  baud_cnt                        ;
wire                            bit_flag                        ;
reg     [ 3:0]                  bit_cnt                         ;

wire                            rx_neg_flag                          ;
//=================================================================================
// ***************      Main    Code    ****************
//=================================================================================
assign  rx_neg_flag  =       ~rx_r2 & rx_r3;

always  @(posedge clk) begin
        rx_r1   <=      rs232_rx;
        rx_r2   <=      rx_r1;
        rx_r3   <=      rx_r2;
end

always  @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0)
                rx_flag <=      1'b0;
        else if(rx_neg_flag == 1'b1)
                rx_flag <=      1'b1;
        else if(bit_cnt == 'd0 && baud_cnt == BAUD_END-10)
                rx_flag <=      1'b0;
end

always  @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0)
                baud_cnt        <=      'd0;
        else if(baud_cnt == BAUD_END)
                baud_cnt        <=      'd0;
        else if(rx_flag == 1'b1)
                baud_cnt        <=      baud_cnt + 1'b1;
        else
                baud_cnt        <=      'd0;
end

assign bit_flag	=	baud_cnt == BAUD_M?1'b1:1'b0;

always  @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0)
                bit_cnt <=      'd0;
        else if(bit_flag == 1'b1 && bit_cnt == BIT_END) 
                bit_cnt <=      'd0;
        else if(bit_flag == 1'b1)
                bit_cnt <=      bit_cnt + 1'b1;
end


always  @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0)
                rx_data <=      'd0;
        else if(bit_flag == 1'b1 && bit_cnt >= 'd1)
                rx_data <=      {rx_r2, rx_data[7:1]};
end

always  @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0)
                rx_data_vld <=      1'b0;
        else if(bit_cnt == 8 && bit_flag == 1'b1)
                rx_data_vld <=      1'b1;
        else
                rx_data_vld <=      1'b0;
end

endmodule