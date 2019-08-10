module  sdram_read(
        // system signals
        input                   sclk                    ,
        input                   s_rst_n                 ,
        // Communicate with TOP
        input                   rd_en                   ,
        output  wire            rd_req                  ,
        output  reg             flag_rd_end             ,
        // Others
        input                   ref_req                 ,
        input                   rd_trig                 ,
        // write interfaces
        output  reg     [ 3:0]  rd_cmd                  ,
        output  reg     [12:0]  rd_addr                 ,
        output  wire    [ 1:0]  bank_addr               ,
        input   wire    [15:0]  rd_data                 ,
        // WFIFO Interfaces
        output  wire             rfifo_wr_en            ,
        output           [ 15:0]  rfifo_wr_data			,
		input					 rfifo_full
);

//===================================================================\
// ********* Define Parameter and Internal Signals *********
//===================================================================/
// Define State
localparam      S_IDLE          =       5'b0_0001               ;
localparam      S_REQ           =       5'b0_0010               ;
localparam      S_ACT           =       5'b0_0100               ;
localparam      S_RD            =       5'b0_1000               ;
localparam      S_PRE           =       5'b1_0000               ;
// SDRAM Command
localparam      CMD_NOP         =       4'b0111                 ;
localparam      CMD_PRE         =       4'b0010                 ;
localparam      CMD_AREF        =       4'b0001                 ;
localparam      CMD_ACT         =       4'b0011                 ;
localparam      CMD_RD          =       4'b0101                 ;//A10=0

localparam		ACT_NUM			=		3;
localparam		BURST_NUM		=		3;
localparam		PRE_NUM			=		3;
localparam		LATENCY			=		3;

localparam		ROW_NUM			=		8*1024-1;
localparam		COL_NUM			=		1024-1;

reg     [ 4:0]                  state,next_state                ;
//-----------------------------------------------------------------
wire							rd_flag							;
wire                            flag_act_end                    ;
wire                            flag_pre_end                    ;
wire                            sd_row_end                      ;
reg     [ 1:0]                  burst_cnt                       ; 
 
wire                             rd_data_end                     ;
//-----------------------------------------------------------------
reg     [ 3:0]                  act_cnt                         ;
reg     [ 3:0]                  break_cnt                       ;
reg     [ 7:0]                  col_cnt                         ;
//-----------------------------------------------------------------
reg     [12:0]                  row_addr                        ;
wire    [ 9:0]                  col_addr                        ;

wire								int_rfifo_wr_en					;
reg           [LATENCY+1:0]  		dly_wr_fifo_en            ;
reg           [ 15:0]  				neg_dly_rfifo_wr_data,dly_rfifo_wr_data			;
//==========================================================================
// ****************     Main    Code    **************
//==========================================================================

//-------------------------  STATE ------------------------------------------
assign	rd_flag	=	rd_trig == 1'b1&&~rfifo_full;
always  @(*) begin
        if(s_rst_n == 1'b0)
                next_state   <=      S_IDLE;
        else case(state)
                S_IDLE:
                        if(rd_flag)
                                next_state   =      S_REQ;
                        else
                                next_state   =      S_IDLE;
                S_REQ:
                        if(rd_en == 1'b1)
                                next_state   =      S_ACT;
                        else
                                next_state   =      S_REQ;
                S_ACT:
                        if(flag_act_end == 1'b1)
                                next_state   =      S_RD;
                        else 
                                next_state   =      S_ACT;
                S_RD:
                        if(ref_req == 1'b1 && rd_data_end == 1)
                                next_state   =      S_PRE;
                        else if(rd_data_end == 1 || sd_row_end == 1'b1)
                                next_state   =      S_PRE;
						else
								next_state   =      S_RD;
                S_PRE:
				//PRE到ACTIVE最小延时
                        if(flag_pre_end == 1'b1 && ref_req == 1'b1 && rd_flag == 1'b1)
                                next_state   =      S_REQ;
                        else if(flag_pre_end == 1'b1 && rd_flag == 1'b1)
                                next_state   =      S_ACT;
                        else if(flag_pre_end == 1'b1)
                                next_state   =      S_IDLE;
						else
								next_state   =      S_PRE;
                default:
                        next_state   <=      S_IDLE;
        endcase
end
always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                state <=      S_IDLE;
        else 
                state <=      next_state;
end

always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                flag_rd_end     <=      1'b0;
        else if((state==S_PRE && ref_req == 1'b1)||(state==S_PRE && !rd_flag == 1'b1))
                flag_rd_end     <=      1'b1;
        else
                flag_rd_end     <=      1'b0;
end

// burst_cnt
always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                burst_cnt       <=      'd0;
        else if(burst_cnt == BURST_NUM)
				burst_cnt       <=      'd0;
		else if(state == S_RD)
                burst_cnt       <=      burst_cnt + 1'b1;
        else
                burst_cnt       <=      'd0;
end

// rd_cmd
always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                rd_cmd  <=      CMD_NOP;
        else case(state)
                S_ACT:  
                        if(act_cnt == 'd0)
                                rd_cmd  <=      CMD_ACT;
                        else 
                                rd_cmd  <=      CMD_NOP;
                S_RD:
                        if(burst_cnt == 'd0)
                                rd_cmd  <=      CMD_RD;
                        else
                                rd_cmd  <=      CMD_NOP;
                S_PRE:
                        if(break_cnt == 'd0)
                                rd_cmd  <=      CMD_PRE;
                        else
                                rd_cmd  <=      CMD_NOP;
                default:
                        rd_cmd  <=      CMD_NOP;
        endcase
end

// rd_addr
always  @(posedge sclk or negedge s_rst_n) begin
        case(state)
                S_ACT:
                        if(act_cnt == 'd0)
                                rd_addr <=      row_addr;
                        else
                                rd_addr <=      'd0;
                S_RD:   rd_addr <=      {3'b000, col_addr};
                S_PRE:  if(break_cnt == 'd0)
                                rd_addr <=      {13'b0_0100_0000_0000};
                        else
                                rd_addr <=      'd0;
                default:
                        rd_addr <=      'd0;
        endcase
end
//-------------------------------------------------------------------
assign		flag_act_end	=	act_cnt == ACT_NUM;
assign		flag_pre_end	=	break_cnt == PRE_NUM;
// act_cnt
always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                act_cnt <=      'd0;
		  else if(act_cnt == ACT_NUM)
				act_cnt <=			'd0;
        else if(state == S_ACT)
                act_cnt <=      act_cnt + 1'b1;
        else
                act_cnt <=      'd0;
end
// break_cnt
always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                break_cnt <=      'd0;
		  else if(break_cnt == PRE_NUM)
				break_cnt <=			'd0;
        else if(state == S_PRE)
                break_cnt <=      break_cnt + 1'b1;
        else
                break_cnt <=      'd0;
end

// col_cnt
always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                col_cnt <=      'd0;
        else if(col_addr == COL_NUM)
                col_cnt <=      'd0;
        else if(rd_data_end)
                col_cnt <=      col_cnt + 1'b1;
end

always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                row_addr        <=      'd0;
        else if(sd_row_end == 1'b1)
                row_addr        <=      row_addr + 1'b1;
end

assign  int_rfifo_wr_en     =       state==S_RD;
always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                dly_wr_fifo_en        <=      'd0;
        else
                dly_wr_fifo_en        <=      {dly_wr_fifo_en[LATENCY:0],int_rfifo_wr_en};
end

//数据只在sdram的第三个正边沿有效，也就是负边沿，那就接着打拍
always  @(negedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                neg_dly_rfifo_wr_data        <=      'd0;
        else
                neg_dly_rfifo_wr_data        <=      rd_data;
end
always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                dly_rfifo_wr_data        <=      'd0;
        else
                dly_rfifo_wr_data        <=      neg_dly_rfifo_wr_data;
end

assign	sd_row_end	=	col_addr == COL_NUM;
assign	rd_data_end	=	burst_cnt	==	BURST_NUM;

assign  col_addr        =       {col_cnt, burst_cnt};
assign  bank_addr       =       2'b00;
assign  rd_req          =       state==S_REQ;
assign  rfifo_wr_en     =       dly_wr_fifo_en[LATENCY+1];
assign  rfifo_wr_data   =   	dly_rfifo_wr_data;
endmodule