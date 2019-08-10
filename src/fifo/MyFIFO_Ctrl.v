module MyFIFO_Ctrl #(
    
     parameter Full_Limit = 1020,
     parameter Empty_Limit = 4,
     parameter Wdata_Width = 16,
	 parameter Rdata_Width = 8,
     parameter Raddr_Width = 10,
	 parameter Waddr_Width = 9

)
(
	//input	WClk, WClkEn, 
	//input	RClk, RClkEn, Rst_n,
	input	WClk, 
	input	RClk, Rst_n, //modified by wuq 0708
	input	Wen, Ren,
	output	reg	Empty, Full,
	output	RAM_We,
	output	reg	[Waddr_Width - 1 : 0] RAM_Waddr,
    output	reg	[Raddr_Width - 1 : 0] RAM_Raddr	

);

assign RAM_We = Wen ;


// write addr on wclk
always @(posedge WClk or negedge Rst_n)
begin
		if (!Rst_n)
			RAM_Waddr <= 0;
		else if(Wen==1'b1 && Full==1'b0)  
		    RAM_Waddr<=RAM_Waddr + 1'b1;
end	

// write addr's binary to grey logic circuit
wire	[Waddr_Width - 1 : 0] RAM_Waddr_Gray_Wire;

Norm2Gray U1_Norm2Gray (
	.Din			(RAM_Waddr),
	.Dout			(RAM_Waddr_Gray_Wire)
);

defparam U1_Norm2Gray.Data_Width = Waddr_Width;

// RAM_Waddr_Gray_Wire to flip_flop output on wclk
reg		[Waddr_Width - 1 : 0] RAM_Waddr_Gray;

always @(posedge WClk or negedge Rst_n)
begin	
		if (!Rst_n)
			RAM_Waddr_Gray <= 0;
		else
			RAM_Waddr_Gray <= RAM_Waddr_Gray_Wire;
end
	
// read addr on rclk
always @(posedge RClk or negedge Rst_n)
begin
		if (!Rst_n)
			RAM_Raddr <= 0;
		else if(Ren==1'b1 && Empty==1'b0) 
			RAM_Raddr <= RAM_Raddr + 1'b1;
end

// read addr' binary to gray circuit 

defparam U2_Norm2Gray.Data_Width = Raddr_Width;
	
wire	[Raddr_Width - 1 : 0] RAM_Raddr_Gray_Wire;


Norm2Gray U2_Norm2Gray (
	.Din			(RAM_Raddr),
	.Dout			(RAM_Raddr_Gray_Wire)
);
	
//  RAM_Raddr_Gray_Wire 's flip flop output on rclk	
reg		[Raddr_Width - 1 : 0] RAM_Raddr_Gray;
		
always @(posedge RClk or negedge Rst_n)
begin	
		if (!Rst_n)
			RAM_Raddr_Gray <= 0;
		else
			RAM_Raddr_Gray <= RAM_Raddr_Gray_Wire; 
end	

// ram read addr (gray) to sync by wclk 
reg		[Raddr_Width - 1 : 0] RAM_Raddr_Gray_OnWClk_P, RAM_Raddr_Gray_OnWClk, RAM_Raddr_OnWClk;

always @(posedge WClk or negedge Rst_n)
begin
	  if (!Rst_n) //modified by wuq 20150707
		begin
			RAM_Raddr_Gray_OnWClk_P <= 0;
			RAM_Raddr_Gray_OnWClk <= 0;
		end
		else 
		begin
			RAM_Raddr_Gray_OnWClk_P <= RAM_Raddr_Gray;
			RAM_Raddr_Gray_OnWClk <= RAM_Raddr_Gray_OnWClk_P;
		end
end

// read (grey) addr on wclk to gray to binary logic circuit
wire	[Raddr_Width - 1 : 0] RAM_Raddr_OnWClk_Wire;

Gray2Norm U1_Gray2Norm (
	.Din			(RAM_Raddr_Gray_OnWClk),
	.Dout			(RAM_Raddr_OnWClk_Wire)
);
defparam U1_Gray2Norm.Data_Width = Raddr_Width;

// RAM_Raddr_OnWClk_Wire to flip-flop output on wlk
always @(posedge WClk or negedge Rst_n)
begin			
		if (!Rst_n)
			RAM_Raddr_OnWClk <= 0;
		else
			RAM_Raddr_OnWClk <= RAM_Raddr_OnWClk_Wire; 
end


// write full circuit 
 wire [9:0]  diff_waddr_onwclk;
 assign      diff_waddr_onwclk = {RAM_Waddr,1'b0} - RAM_Raddr_OnWClk;
			
always @(posedge WClk or negedge Rst_n)
begin			
		if (!Rst_n)
			Full <= 1'b0;
		else  
			begin
			if (diff_waddr_onwclk >= Full_Limit)
	  		  Full <= 1'b1;
			else
			  Full <= 1'b0;	
			end						
		
end

// write addr (grey) to sync by rclk
reg		[Waddr_Width - 1 : 0] RAM_Waddr_Gray_OnRClk_P, RAM_Waddr_Gray_OnRClk, RAM_Waddr_OnRClk;

always @(posedge RClk or negedge Rst_n)
begin
	  if (!Rst_n) // modified by wuq 150707
		begin
			RAM_Waddr_Gray_OnRClk_P <= 0;
			RAM_Waddr_Gray_OnRClk <= 0;
		end
		else
		begin
			RAM_Waddr_Gray_OnRClk_P <= RAM_Waddr_Gray;
		    RAM_Waddr_Gray_OnRClk <= RAM_Waddr_Gray_OnRClk_P;
		end
end

//write addr (grey) on wclk to gray to binary logic circuit
wire	[Waddr_Width - 1 : 0] RAM_Waddr_OnRClk_Wire;

Gray2Norm U2_Gray2Norm (
	.Din			(RAM_Waddr_Gray_OnRClk),
	.Dout			(RAM_Waddr_OnRClk_Wire)
);

defparam U2_Gray2Norm.Data_Width = Waddr_Width;


// RAM_Waddr_OnRClk_Wire  to flip-flop on rclk
always @(posedge RClk or negedge Rst_n)
begin			
		if (!Rst_n)
			RAM_Waddr_OnRClk <= 0;
		else
			RAM_Waddr_OnRClk <= RAM_Waddr_OnRClk_Wire;
end			


// read empty circuit
 wire [9:0]  diff_raddr_onrclk;
 assign      diff_raddr_onrclk = {RAM_Waddr_OnRClk,1'b0} - RAM_Raddr; 

always @(posedge RClk or negedge Rst_n)
begin				
		if (!Rst_n)
			Empty <= 1'b1;
		else  
			begin
				if(diff_raddr_onrclk <= Empty_Limit)
                    Empty <= 1'b1;
				else
                    Empty <= 1'b0;				
			end
end

endmodule

