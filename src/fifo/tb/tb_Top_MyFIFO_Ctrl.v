/*****************************************************************************
--tb_Top_MyFIFO_Ctrl.v
-- 
-- Created:  04/15/2012 liyu
-- This file provides stimulated signal for Top_MyFIFO_Ctrl
--
-- Revised:  none
-- *****************************************************************************/
`timescale 1ns / 100ps 
module tb_Top_MyFIFO_Ctrl;
	reg		Wclk;
	reg		Rclk;	
	reg 	Rst_n;
	reg     Wen;
	reg     Ren;
	reg  [15:0]   Din;
	wire [7:0]   Dout;
	wire    Empty;
	wire    Full;

	
	parameter 	WCLK_CYCLE = 6.25;		// 80Mhz
	parameter 	RCLK_CYCLE = 5;			// 100Mhz

	always 	#WCLK_CYCLE Wclk = ~Wclk;
	
	always 	#RCLK_CYCLE Rclk = ~Rclk;
	
	initial
		begin
			Wclk = 0;
			Rclk = 0;
			Wen = 0;
			Ren = 0;
			Rst_n = 0;
			Din=0;
			#100 Rst_n = 0;
			#200 Rst_n = 1;
			#100 
			@(posedge Wclk)
			Din = 16'h0a0f;
			Wen = 1;
			
			#80000 
			Wen = 0;
			Ren = 1;
			#80000 
			$stop;
		end
		
		
	

MyFIFO1024x8  U_MyFIFO1024x8 (
		.WClk			(Wclk), 
		//.WClkEn			(1'b1), 
		.RClk			(Rclk), 
		//.RClkEn			(1'b1), 
		.Rst_n			(Rst_n),
		.Din			(Din),
		.Dout			(Dout),
		.Wen			(Wen), 
		.Ren			(Ren),
		.Empty			(Empty), 
		.Full           (Full)
			);
 			
endmodule
