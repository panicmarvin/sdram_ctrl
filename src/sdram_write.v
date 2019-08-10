module  sdram_write(
        // system signals
        input                   sclk                    ,
        input                   s_rst_n                 ,
        // Communicate with TOP
        input                   wr_en                   ,
        output  wire            wr_req                  ,
        output  reg             flag_wr_end             ,
        // Others
        input                   ref_req                 ,
        input                   wr_trig                 ,
        // write interfaces
        output  reg     [ 3:0]  wr_cmd                  ,
        output  reg     [12:0]  wr_addr                 ,
        output  wire    [ 1:0]  bank_addr               ,
        output  wire    [15:0]  wr_data                 ,
        // WFIFO Interfaces
        output  wire             wfifo_rd_en            ,
        input           [ 15:0]  wfifo_rd_data			,
		input					 wfifo_deepth_eight	//深度大于8则读出四次，8*8bit=4*16bit
);

//===================================================================\
// ********* Define Parameter and Internal Signals *********
//===================================================================/
// Define State
localparam      S_IDLE          =       5'b0_0001               ;
localparam      S_REQ           =       5'b0_0010               ;
localparam      S_ACT           =       5'b0_0100               ;
localparam      S_WR            =       5'b0_1000               ;
localparam      S_PRE           =       5'b1_0000               ;
// SDRAM Command
localparam      CMD_NOP         =       4'b0111                 ;
localparam      CMD_PRE         =       4'b0010                 ;
localparam      CMD_AREF        =       4'b0001                 ;
localparam      CMD_ACT         =       4'b0011                 ;
localparam      CMD_WR          =       4'b0100                 ;//A10=0

localparam		ACT_NUM			=		3;
localparam		BURST_NUM		=		3;
localparam		PRE_NUM			=		3;

localparam		ROW_NUM			=		8*1024-1;
localparam		COL_NUM			=		1024-1;

reg     [ 4:0]                  state,next_state                           ;
//-----------------------------------------------------------------
wire                             flag_act_end                    ;
wire                             flag_pre_end                    ;
wire                             sd_row_end                      ;
reg     [ 1:0]                  burst_cnt                       ; 
reg     [ 1:0]                  burst_cnt_t                     ;
reg     [ 1:0]                  burst_cnt_tt                     ;
 
wire                             wr_data_end                     ;
//-----------------------------------------------------------------
reg     [ 3:0]                  act_cnt                         ;
reg     [ 3:0]                  break_cnt                       ;
reg     [ 7:0]                  col_cnt                         ;
//-----------------------------------------------------------------
reg     [12:0]                  row_addr                        ;
wire    [ 9:0]                  col_addr                        ;

reg	  [15:0]				    reg_data_out					;
wire							wr_flag							;

//==========================================================================
// ****************     Main    Code    **************
//==========================================================================

//-------------------------  STATE ------------------------------------------
assign	wr_flag	=	wr_trig == 1'b1||wfifo_deepth_eight == 1'b1;
always  @(*) begin
        if(s_rst_n == 1'b0)
                next_state   <=      S_IDLE;
        else case(state)
                S_IDLE:
                        if(wr_flag)
                                next_state   =      S_REQ;
                        else
                                next_state   =      S_IDLE;
                S_REQ:
                        if(wr_en == 1'b1)
                                next_state   =      S_ACT;
                        else
                                next_state   =      S_REQ;
                S_ACT:
                        if(flag_act_end == 1'b1)
                                next_state   =      S_WR;
                        else 
                                next_state   =      S_ACT;
                S_WR:
                        if(ref_req == 1'b1 && wr_data_end == 1)
                                next_state   =      S_PRE;
                        else if(wr_data_end == 1 || sd_row_end == 1'b1)
                                next_state   =      S_PRE;
						else
								next_state   =      S_WR;
                S_PRE:
				//PRE到ACTIVE最小延时
                        if(flag_pre_end == 1'b1 && ref_req == 1'b1 && wr_flag == 1'b1)
                                next_state   =      S_REQ;
                        else if(flag_pre_end == 1'b1 && wr_flag == 1'b1)
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
                flag_wr_end     <=      1'b0;
        else if((state==S_PRE && ref_req == 1'b1)||(state==S_PRE && !wr_flag == 1'b1))
                flag_wr_end     <=      1'b1;
        else
                flag_wr_end     <=      1'b0;
end

// burst_cnt
always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                burst_cnt       <=      'd0;
        else if(burst_cnt == BURST_NUM)
				burst_cnt       <=      'd0;
		else if(state == S_WR)
                burst_cnt       <=      burst_cnt + 1'b1;
        else
                burst_cnt       <=      'd0;
end
always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0) begin
                burst_cnt_t 	<=      'd0;
				burst_cnt_tt	<=		'd0;
		end
        else begin
                burst_cnt_t 	<=      burst_cnt;
				burst_cnt_tt 	<=      burst_cnt_t;
		end
end

// wr_cmd
always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                wr_cmd  <=      CMD_NOP;
        else case(state)
                S_ACT:  
                        if(act_cnt == 'd0)
                                wr_cmd  <=      CMD_ACT;
                        else 
                                wr_cmd  <=      CMD_NOP;
                S_WR:
                        if(burst_cnt_t == 'd1)
                                wr_cmd  <=      CMD_WR;
                        else
                                wr_cmd  <=      CMD_NOP;
                S_PRE:
                        if(break_cnt == 'd0)
                                wr_cmd  <=      CMD_PRE;
                        else
                                wr_cmd  <=      CMD_NOP;
                default:
                        wr_cmd  <=      CMD_NOP;
        endcase
end

// wr_addr
always  @(posedge sclk or negedge s_rst_n) begin
        case(state)
                S_ACT:
                        if(act_cnt == 'd0)
                                wr_addr <=      row_addr;
                        else
                                wr_addr <=      'd0;
                S_WR:   wr_addr <=      {3'b000, col_addr};
                S_PRE:  if(break_cnt == 'd0)
                                wr_addr <=      {13'b0_0100_0000_0000};
                        else
                                wr_addr <=      'd0;
                default:
                        wr_addr <=      'd0;
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
        else if(wr_data_end)
                col_cnt <=      col_cnt + 1'b1;
end

always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                row_addr        <=      'd0;
        else if(sd_row_end == 1'b1)
                row_addr        <=      row_addr + 1'b1;
end
assign	sd_row_end	=	col_addr == COL_NUM;
assign	wr_data_end	=	burst_cnt_tt	==	BURST_NUM;

assign  col_addr        =       {col_cnt, burst_cnt_tt};
assign  bank_addr       =       2'b00;
assign  wr_req          =       state==S_REQ;
assign  wfifo_rd_en     =       state==S_WR && burst_cnt_tt<=1;

always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                reg_data_out        <=      'd0;
        else
                reg_data_out        <=      wfifo_rd_data;
end

assign  wr_data         =       reg_data_out;

endmodule