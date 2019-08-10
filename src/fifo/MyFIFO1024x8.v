module MyFIFO1024x8 #(
     parameter Wdata_Width = 16,
	 parameter Rdata_Width = 8,
     parameter Raddr_Width = 10,
	 parameter Waddr_Width = 9
         )
    (
	input								WClk, 
	input								RClk,
	input								Rst_n,
	input	[Wdata_Width - 1 : 0] 		Din,
	output	[Rdata_Width - 1 : 0] 		Dout,
	input								Wen,
	input								Ren,
	output								Empty,
	output								Full
);
	
wire	RAM_We;
wire	[Waddr_Width - 1 : 0] RAM_Waddr;
wire	[Raddr_Width - 1 : 0] RAM_Raddr;


MyFIFO_Ctrl U_MyFIFO_Ctrl (
	.WClk       (WClk),     
	//.WClkEn     (WClkEn),   
	.RClk       (RClk),     
	//.RClkEn     (RClkEn),   
	.Rst_n        (Rst_n),     
	.Wen        (Wen),      
	.Ren        (Ren),      
	.Empty      (Empty),    
	.Full       (Full),   
	                      
	.RAM_We     (RAM_We),   
	.RAM_Waddr  (RAM_Waddr),
	.RAM_Raddr  (RAM_Raddr)
);

bram_1024x8	U_bram_1024x8 (
	.data      ( Din ),
	.rdaddress ( RAM_Raddr ),
	.rdclock   ( RClk ),
	.wraddress ( RAM_Waddr ),
	.wrclock   ( WClk ),
	.wren      ( Wen && !Full),
	.rden      ( Ren && !Empty),
	.q         ( Dout )
	);
endmodule


