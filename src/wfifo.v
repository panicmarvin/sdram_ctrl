module wfifo(
		rst_n		,
		fifo_wr_clk	,
		fifo_wr_en	,
		fifo_full	,
		fifo_wr_data,
		
		fifo_rd_clk	,
		fifo_rd_en	,
		fifo_rd_data,
		fifo_empty	,
		wfifo_deepth_eight
		
//		fifo_wr_err,
//		fifo_rd_err
		
	);
 
		input rst_n			;
		input fifo_wr_en	;
		input	[7:0]	fifo_wr_data;
		input fifo_rd_en	;
		input fifo_rd_clk;
		input fifo_wr_clk;
		output  fifo_full	;
		output [15:0]	fifo_rd_data;
		output  fifo_empty	;
		output	wfifo_deepth_eight;
		
//		output reg fifo_wr_err;
//		output reg fifo_rd_err;
		
		reg	[9:0]  rdaddress; //RAM地址为9位地址 扩展一位用于同步
		reg	[10:0]  wraddress;
		
		wire	wr_ram,rd_ram;
	
		wire	[10:0]	gray_rdaddress;
		wire	[10:0]	gray_wraddress;
		
		/*同步寄存器*/
		reg	[10:0] sync_w2r_r1,sync_w2r_r2;
		reg	[10:0] sync_r2w_r1,sync_r2w_r2;
		
		assign	wfifo_deepth_eight	=	0;
		
		/*二进制转化为格雷码计数器*/
		assign gray_rdaddress = ({rdaddress,1'b0} >>1) ^ {rdaddress,1'b0};//(({1'b0,rdaddress[9:1]}) ^ rdaddress);
		
		/*另一种写法，二进制转化为格雷码计数器*/
		assign gray_wraddress = (({1'b0,wraddress[10:1]}) ^ wraddress);
		
		assign fifo_empty = (gray_rdaddress == sync_w2r_r2);
		
		assign fifo_full = (gray_wraddress == {~sync_r2w_r2[10:9],sync_r2w_r2[8:0]});
		
		assign wr_ram = (~fifo_full && fifo_wr_en);
		assign rd_ram = (~fifo_empty && fifo_rd_en);
		
		ram_1024x8_w	ram_1024_8_w_inst (
		.data ( fifo_wr_data ),
		.rdaddress ( rdaddress[8:0] ),
		.rdclock ( fifo_rd_clk ),
		.rden ( rd_ram ),
		.wraddress ( wraddress[9:0] ),
		.wrclock ( fifo_wr_clk ),
		.wren ( wr_ram ),
		.q ( fifo_rd_data )
		);	
			
		/*读数据地址生成*/
		always@(posedge fifo_rd_clk or negedge rst_n)
		if(!rst_n)
			rdaddress <= 10'b0;
		else if(fifo_rd_en && ~fifo_empty)begin
			rdaddress <= rdaddress + 1'b1;
		end
		
		/*写数据地址生成*/
		always@(posedge fifo_wr_clk or negedge rst_n)
		if(!rst_n)
			wraddress <= 11'b0;
		else if(fifo_wr_en && ~fifo_full)begin
			wraddress <= wraddress + 1'b1;
		end
		
		/*同步读地址到写时钟域*/
		always@(posedge fifo_wr_clk or negedge rst_n)
		if(!rst_n)begin
			sync_r2w_r1 <= 11'd0;
			sync_r2w_r2 <= 11'd0;
		end else begin
			sync_r2w_r1 <= gray_rdaddress;
			sync_r2w_r2 <= sync_r2w_r1;		
		end
 
		/*同步写地址到读时钟域, 同步以后 存在延迟两个节拍*/
		always@(posedge fifo_rd_clk or negedge rst_n)
		if(!rst_n)begin
			sync_w2r_r1 <= 11'd0;
			sync_w2r_r2 <= 11'd0;
		end else begin
			sync_w2r_r1 <= gray_wraddress ;
			sync_w2r_r2 <= sync_w2r_r1;		
		end
		
endmodule