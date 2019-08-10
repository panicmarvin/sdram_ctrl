module  sdram_init(
        // system signals
        input                   sclk                    ,
        input                   s_rst_n                 ,
        // others
        output  reg     [ 3:0]  cmd_reg                 ,
        output  wire    [12:0]  sdram_addr              ,
        output  wire            flag_init_end
);

//================================================================\
// ========= Define Parameter and Internal Signals ==========
//================================================================/
localparam      DELAY_200US     =       10000                   ;
//SDRAM Command
localparam      NOP             =       4'b0111                 ;
localparam      PREA             =      4'b0010                 ;
localparam      AREF            =       4'b0001                 ;
localparam      MSET            =       4'b0000                 ;

reg     [13:0]                  cnt_200us                       ;
wire                            flag_200us                      ;
reg     [ 6:0]                  cmd_cnt                         ;
//==========================================================================
// ****************     Main    Code    **************
//==========================================================================
//cnt_200us
always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                cnt_200us       <=      'd0;
        else if(flag_200us == 1'b0)
                cnt_200us       <=      cnt_200us + 1'b1;
end

always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                cmd_cnt <=      'd0;
        else if(flag_200us == 1'b1 && flag_init_end == 1'b0)
                cmd_cnt <=      cmd_cnt + 1'b1;
end

//cmd_reg
always  @(posedge sclk or negedge s_rst_n) begin 
        if(s_rst_n == 1'b0)
                cmd_reg <=      NOP;
        else if(flag_200us == 1'b1)
                case(cmd_cnt)
                        0:       cmd_reg <=      PREA;
                        1:       cmd_reg <=      AREF;
                        5:       cmd_reg <=      AREF;
                        9:       cmd_reg <=      AREF;
                        13:      cmd_reg <=     AREF;
                        17:      cmd_reg <=     AREF;
                        21:      cmd_reg <=     AREF;
                        25:      cmd_reg <=     AREF;
                        29:      cmd_reg <=     AREF;
                        33:      cmd_reg <=     MSET;
                        default:cmd_reg <=      NOP;                        
                endcase
end

assign  flag_init_end   =       (cmd_cnt >= 'd35) ? 1'b1 : 1'b0;
assign  sdram_addr      =       (cmd_reg == MSET) ? 13'b0_0000_0011_0010 : 13'b0_0100_0000_0000;
assign  flag_200us      =       (cnt_200us >= DELAY_200US) ? 1'b1 : 1'b0;

endmodule