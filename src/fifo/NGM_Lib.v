module Norm2Gray #(parameter Data_Width = 8) (
	input 	[Data_Width - 1 : 0] Din,
	output	[Data_Width - 1 : 0] Dout
);

assign	Dout = Din ^ {1'b0, Din[Data_Width - 1 : 1]};

endmodule		

module Gray2Norm #(parameter Data_Width = 8) (
	input 	[Data_Width - 1 : 0] Din,
	output	reg	[Data_Width - 1 : 0] Dout
);
integer	i, j;
reg 	Tmp;
always @(*)
	begin
		for (i = Data_Width - 1; i >= 0; i = i - 1)
		begin
			Tmp = 1'b0;
			begin
				for (j = Data_Width - 1; j >= i; j = j - 1)
					Tmp = Tmp ^ Din[j];
			end
			Dout[i] = Tmp;
		end
	end

endmodule	
