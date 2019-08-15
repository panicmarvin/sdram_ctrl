module  uart_tx(
        // system signals
        input                   clk                    ,
        input                   rst_n                 ,
        // UART Interface
        output                  rs232_tx                ,
        // RFIFO
        input                   rfifo_empty             ,
        output  reg             rfifo_rd_en             ,
        input           [ 7:0]  rfifo_rd_data           ,
		output	reg				data_vld
);
//====================================================================\
// ********** Define Parameter and Internal Signals *************
//====================================================================/
localparam      BAUD_END        =       434                    ;
localparam      BAUD_M          =       BAUD_END/2 - 1          ;
localparam      BIT_END         =       9                       ;

localparam		IDLE			=		3'b001;
localparam		START			=		3'b010;
localparam		TRANS			=		3'b100;
reg     [2:0] 					nx_state,cu_state;
reg                       		tx_trig_r, tx_trig_r1           ;
reg     [ 7:0]                  tx_data_r, tx_data_r1           ;
reg     [12:0]                  baud_cnt                        ;
wire                            bit_flag                        ;
reg     [ 3:0]                  bit_cnt                         ;
wire                            tx_trig                         ;
//baud_cnt
always  @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0)
                baud_cnt        <=      'd0;
        else if(baud_cnt == BAUD_END)
                baud_cnt        <=      'd0;
        else if(cu_state==TRANS)
                baud_cnt        <=      baud_cnt + 1'b1;
        else
                baud_cnt        <=      'd0;
end
// bit_flag
assign bit_flag=baud_cnt==BAUD_END?1'b1:1'b0;
//bit_cnt
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
                rfifo_rd_en     <=      1'b0;
        else if(rfifo_empty == 1'b0 && cu_state == IDLE && rfifo_rd_en==1'b0)
                rfifo_rd_en     <=      1'b1;
        else
                rfifo_rd_en     <=      1'b0;
end
assign	tx_trig = rfifo_rd_en;
always  @(posedge clk) begin
        tx_trig_r        <=      tx_trig;
		tx_trig_r1       <=      tx_trig_r;
end
always  @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0)
                tx_data_r      <=      'd1;
        else if(tx_trig_r1)
				tx_data_r		<=	 rfifo_rd_data ;
		else if(cu_state==TRANS&&bit_flag==1'b1&&bit_cnt>=1)
				tx_data_r		<=	{1'b1,tx_data_r[7:1]};
end

always  @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0)
                cu_state     <=      IDLE;
        else 
				cu_state     <=      nx_state;
end
always  @(*) begin
        if(rst_n == 1'b0)
                nx_state     =      IDLE;
        else
				case(cu_state)
					IDLE:
							if(tx_trig)
								nx_state	=	START;
							else
								nx_state	=	IDLE;
					START:
							if(tx_trig_r1)
								nx_state	=	TRANS;
							else
								nx_state	=	START;
					TRANS:
							if(bit_flag&&bit_cnt==BIT_END)
								nx_state	=	IDLE;
							else
								nx_state	=	TRANS;
				default:nx_state=IDLE;
				endcase
		end


assign 				rs232_tx = cu_state==TRANS?(bit_cnt==0?1'b0:tx_data_r[0]):1'b1;
always  @(posedge clk) begin
        data_vld       <=      tx_trig_r;
end
endmodule