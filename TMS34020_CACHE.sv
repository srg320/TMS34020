module TMS34020_CACHE
 (
	input              CLK,
	input              RST_N,
	input              EN,
	
	input              CE_F,
	input              CE_R,
	
	input              RES_N,
	input              RST_EXEC,
	
	input      [31: 0] CACHE_DATA,
	input              CACHE_WR,
	
	input      [31: 0] PC,
	output     [31: 0] CACHE_Q,
	output             CACHE_MISS,
	output reg         CACHE_WAIT
);
	
	bit  [31: 0] SSA[4];
	bit  [ 7: 0] P[4];
	bit  [ 1: 0] LRU_STACK[4];
	bit          SEG_MISS;
	bit          SUBSEG_MISS;
	bit  [ 1: 0] SEG;
	wire [ 2: 0] SUBSEG = PC[9:7];
	always_comb begin
		bit [ 1: 0] S;
		
		SEG_MISS <= 0;
		if (SSA[0][31:10] == PC[31:10]) begin
			S = 2'd0;
		end else if (SSA[1][31:10] == PC[31:10]) begin
			S = 2'd1;
		end else if (SSA[2][31:10] == PC[31:10]) begin
			S = 2'd2;
		end else if (SSA[3][31:10] == PC[31:10]) begin
			S = 2'd3;
		end else begin
			S = LRU_STACK[3];
			SEG_MISS <= 1;
		end
		SEG <= S;
		SUBSEG_MISS <= ~P[S][SUBSEG];
	end
	
	bit  [ 6: 0] RAM_WADDR;
	always @(posedge CLK or negedge RST_N) begin		
		bit  [ 1: 0] LWORD_POS;
		
		if (!RST_N) begin
			SSA <= '{4{'0}};
			P <= '{4{'0}};
			LRU_STACK <= '{2'd0,2'd1,2'd2,2'd3};
			LWORD_POS <= '0;
		end
		else if (EN && CE_F) begin
			CACHE_WAIT <= (SEG_MISS || SUBSEG_MISS) && !RST_EXEC;
		end
		else if (EN && CE_R) begin
			if (CACHE_WR) begin
				LWORD_POS <= LWORD_POS + 2'd1;
				if (LWORD_POS == 2'd3) begin
					if (SEG_MISS)
						P[SEG] <= '0;
					SSA[SEG] <= PC;
					P[SEG][SUBSEG] <= 1;
					if (SEG == LRU_STACK[1] || SEG == LRU_STACK[2] || SEG == LRU_STACK[3]) begin
						LRU_STACK[0] <= SEG;
						LRU_STACK[1] <= LRU_STACK[0];
					end
					if (SEG == LRU_STACK[2] || SEG == LRU_STACK[3]) begin
						LRU_STACK[2] <= LRU_STACK[1];
					end
					if (SEG == LRU_STACK[3]) begin
						LRU_STACK[3] <= LRU_STACK[2];
					end
				end
				RAM_WADDR <= {SEG,SUBSEG,PC[6:5]+LWORD_POS};
			end
		end
	end
	assign CACHE_MISS = (SEG_MISS || SUBSEG_MISS) && !RST_EXEC;
	
	wire [ 6: 0] RAM_RADDR = {SEG,PC[9:5]};
	TMS34020_CACHE_RAM CACHE_RAM (
		.CLK(CLK),
		
		.WADDR(RAM_WADDR),
		.DATA(CACHE_DATA),
		.WREN(CACHE_WR && CE_F),
		
		.RADDR(RAM_RADDR),
		.Q(CACHE_Q)
	);
	
endmodule
