module ROM 
#(
	parameter rom_file = ""
)
(
	input          CLK,
	input          RST_N,
	
	input  [22: 0] RADDR,
	output [31: 0] DO
);

// synopsys translate_off
`define SIM
// synopsys translate_on
	
`ifdef SIM

	reg [31:0] MEM [(8*1024*1024)/4];
	initial begin
		$readmemh(rom_file, MEM);
	end
	
	assign DO = MEM[RADDR[22:2]];

`else
	
	

	
	
`endif

endmodule
