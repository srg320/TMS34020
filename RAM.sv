module RAM 
#(
	parameter rom_file = ""
)
(
	input          CLK,
	input          RST_N,
	
	input  [18: 0] WADDR,
	input  [31: 0] DI,
	input  [ 3: 0] WE,
	
	input  [18: 0] RADDR,
	output [31: 0] DO
);

// synopsys translate_off
`define SIM2
// synopsys translate_on
	
`ifdef SIM
	
	reg [31:0] MEM [(512*1024)/4];
		
	bit [13:2] ADDR;
	always @(posedge CLK or negedge RST_N) begin
		if (!RST_N) begin
			ADDR <= '0;
		end
		else begin
			ADDR <= RADDR;
			if (WE) begin
				MEM[{WADDR[9:3],1'b0}] <= DI[31:0];
				MEM[{WADDR[9:3],1'b1}] <= DI[63:32];
			end
		end
	end
		
	assign DO = {MEM[{RADDR[9:3],1'b1}],MEM[{RADDR[9:3],1'b0}]};
	
	
`elsif SIM2

	reg [31:0] MEM [(512*1024)/4];
	initial begin
		$readmemh(rom_file, MEM);
	end
		
	always @(posedge CLK or negedge RST_N) begin
		if (!RST_N) begin

		end
		else begin
			if (WE[3]) MEM[WADDR[18:2]][31:24] <= DI[31:24];
			if (WE[2]) MEM[WADDR[18:2]][23:16] <= DI[23:16];
			if (WE[1]) MEM[WADDR[18:2]][15: 8] <= DI[15: 8];
			if (WE[0]) MEM[WADDR[18:2]][ 7: 0] <= DI[ 7: 0];
		end
	end
	
	assign DO = MEM[RADDR[18:2]];

`else
	
	

	
	
`endif

endmodule
