`timescale 1ns/1ps
module tb_sdram_aref;
reg clk  ;       
reg s_rst_n    ;  
reg ref_en     ;  
wire ref_req      ;
wire flag_ref_end ;
wire [3:0] aref_cmd     ;
wire [12:0] sdram_addr   ;
reg flag_init_end;





initial begin
clk=1;
forever #10 clk=~clk;
end

initial begin
s_rst_n  =0;
ref_en = 0;
flag_init_end = 0;

#30
@(posedge clk)
s_rst_n  =1;
#10
@(posedge clk)
flag_init_end=1;
wait(ref_req);
@(posedge clk)
ref_en=1;
wait(flag_ref_end) ref_en=0;

wait(ref_req);
@(posedge clk)
ref_en=1;
wait(flag_ref_end) ref_en=0;

wait(ref_req);
@(posedge clk)
ref_en=1;
wait(flag_ref_end) ref_en=0;

#200

$stop;
end
 
 
sdram_aref top(
.sclk            (clk         )       ,
.s_rst_n         (s_rst_n      )       ,
.ref_en          (ref_en       )       ,
.ref_req         (ref_req      )       ,
.flag_ref_end    (flag_ref_end )       ,
.aref_cmd        (aref_cmd     )       ,
.sdram_addr      (sdram_addr   )       ,
.flag_init_end   (flag_init_end)       
);
endmodule
