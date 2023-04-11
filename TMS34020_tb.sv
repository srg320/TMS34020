module TMS34020_tb;

	bit         CLK;
	bit         RST_N;
	
	bit [31: 3] C_A;
	bit [31: 0] C_DI;
	
	bit [31: 0] LA;
	bit [31: 0] LDI;
	bit [31: 0] LDO;
	bit [ 3: 0] CAS_N;
	bit         WE_N;
	bit         QE_N;
	bit         ALTCH_N;
	bit         LRDY;
	
	bit [31: 0] ROM_DO;
	bit [31: 0] RAM_A;
	bit [31: 0] RAM_DO;
	bit [ 7: 0] NVRAM_DO;
	bit [ 3: 0] RAM_WE;
	 
	//clock generation
	always #5 CLK = ~CLK;
	 
	//reset Generation
	initial begin
	  RST_N = 0;
	  #6 RST_N = 1;
	end
	
	bit CE_F,CE_R;
	always @(posedge CLK or negedge RST_N) begin
		if (!RST_N) begin
			CE_F <= 0;
			CE_R <= 0;
		end
		else begin
			CE_F <= ~CE_F;
			CE_R <= CE_F;
		end
	end
	
	
	TMS34020	core
	(
		.CLK(CLK),
		.RST_N(RST_N),
		.EN(1),
		
		.CE_F(CE_F),
		.CE_R(CE_R),
		.VCE_R(CE_R),
		
		.RES_N(1),
		.NMI_N(1),
		.LINT1_N(1),
		.LINT2_N(1),
		
		.LA(LA),
		.CAS_N(CAS_N),
		.LDI(LDI),
		.LDO(LDO),
		.WE_N(WE_N),
		.QE_N(QE_N),
		.ALTCH_N(ALTCH_N),
		.LRDY(LRDY)
	);
	
	
	
	
//	ROM #(.rom_file("btc0.txt")) rom(CLK, RST_N, C_A[25:3], C_DI);
	
	wire ROM_SEL = LA >= 32'hF0000000 && LA <= 32'hFFFFFFFF;
	ROM #(.rom_file("btc0.txt")) rom2(CLK, RST_N,LA[25:3], ROM_DO);
	
	wire RAM_SEL = LA <= 32'h003FFFFF;
	RAM #(.rom_file("")) ram(CLK, RST_N, LA[21:3], LDO, {4{RAM_SEL}} & ~CAS_N & ~{4{WE_N}}, LA[21:3], RAM_DO);
	
	wire NVRAM_SEL = LA >= 32'h60000000 && LA <= 32'h6FFFFFFF;
	NVRAM #(.save_file("")) nvram(CLK, RST_N, LA[19:5], LDO[7:0], NVRAM_SEL & ~CAS_N[0] & ~WE_N, LA[19:5], NVRAM_DO);
	
	
	always @(negedge CLK or negedge RST_N) begin
		bit OLD;
		
		if (!RST_N) begin
			LRDY <= 1;
		end
		else if (CE_F) begin
			OLD <= WE_N && QE_N;
			
			LRDY <= 1;
			if ((ROM_SEL || RAM_SEL) && LA[3:0] != 4'b1001 && (!WE_N || !QE_N) && OLD) begin
				LRDY <= 0;
			end
		end
	end
	
	wire MISC_SEL = LA >= 32'h20000000 && LA <= 32'h200007FF;
	bit [15: 0] SPR_SCALE;
	bit [15: 0] SPR_CONTROL;
	bit [15: 0] DISP_CONTROL;
	bit [15: 0] SCROLL0,SCROLL1;
	bit [15: 0] MISC_CONTROL;
	bit [ 7: 0] Z80_DIN;
	bit [ 7: 0] Z80_DOUT;
	always @(posedge CLK or negedge RST_N) begin
		bit Z80_DOUT_READ;
		
		if (!RST_N) begin
			SPR_SCALE <= '0;
			SPR_CONTROL <= '0;
			DISP_CONTROL <= '0;
			SCROLL0 <= '0;
			SCROLL1 <= '0;
			MISC_CONTROL <= '0;
			Z80_DIN <= '0;
			Z80_DOUT <= 8'h54;
			Z80_DOUT_READ <= 0;
		end
		else if (CE_R) begin
			if (MISC_SEL && !WE_N) begin
				case ({LA[11:5],5'b00000})
					12'h000: SPR_SCALE <= LDO[15:0];//
					12'h100: SPR_CONTROL <= LDO[15:0];//
					12'h180: DISP_CONTROL <= LDO[15:0];//
					12'h200: SCROLL0 <= LDO[15:0];//
					12'h280: SCROLL1 <= LDO[15:0];//
					12'h300: ;//tlc34076
					12'h380: Z80_DIN <= LDO[7:0];//Z80IO
					12'h400: MISC_CONTROL <= LDO[15:0];//
					default: ;
				endcase
				
				
			end
			
			if (MISC_SEL && {LA[11:5],5'b00000} == 12'h380 && !QE_N) begin
				Z80_DOUT_READ <= 1;
			end
			if (Z80_DOUT_READ && QE_N) begin
				if (Z80_DOUT == 8'h54) Z80_DOUT <= 8'h6F;
				else if (Z80_DOUT == 8'h6F) Z80_DOUT <= 8'h61;
				else if (Z80_DOUT == 8'h61) Z80_DOUT <= 8'h64;
				
				Z80_DOUT_READ <= 0;
			end
			
			if (!MISC_CONTROL[3]) begin
				Z80_DOUT <= 8'h54;
				Z80_DOUT_READ <= 0;
			end
		end
	end

	bit [ 7: 0] MISC_DO;
	always_comb begin
		case ({LA[11:5],5'b00000})
			12'h000: MISC_DO = 8'hFF;//P1
			12'h080: MISC_DO = 8'hFF;//P2
			12'h100: MISC_DO = 8'hFF;//P3
			12'h180: MISC_DO = 8'hFF;//UNK
			12'h200: MISC_DO = 8'h03;//Z80STAT
			12'h280: MISC_DO = 8'h7F;//SW1
			12'h380: MISC_DO = Z80_DOUT;//Z80IO
			default: MISC_DO = 8'hFF;
		endcase
	end
	
	assign LDI = RAM_SEL   ? RAM_DO :
	             MISC_SEL  ? {24'h000000,MISC_DO} :
	             NVRAM_SEL ? {24'h000000,8'hFF  } :
					 ROM_SEL   ? ROM_DO : 32'h00000000;

	//RW,0x00000000-0x003fffff ram
	//R, 0x20000000-0x2000007f P1
	//R, 0x20000080-0x200000ff P2
	//R, 0x20000100-0x2000017f P3
	//R, 0x20000180-0x200001ff UNK
	//R, 0x20000200-0x2000027f SPECIAL
	//R, 0x20000280-0x200002ff SW1
	//W, 0x20000000-0x200000ff sprite_scale
	//W, 0x20000100-0x2000017f sprite_control
	//W, 0x20000180-0x200001ff display_control
	//W, 0x20000200-0x2000027f scroll0
	//W, 0x20000280-0x200002ff scroll1
	//RW,0x20000300-0x2000037f tlc34076
	//RW,0x20000380-0x200003ff main_sound
	//W, 0x20000400-0x2000047f misc_control
	//0x40000000-0x4000001f watchdog? 
	//RW,0x60000000-0x6003ffff nvram
	//RW,0xa0000000-0xa03fffff vram_fg_display
	//RW,0xa4000000-0xa43fffff vram_fg_draw
	//RW,0xa8000000-0xa87fffff vram_fg_data
	//0xa8800000-0xa8ffffff 
	//RW,0xb0000000-0xb03fffff vram_bg0
	//RW,0xb4000000-0xb43fffff vram_bg1
	//R, 0xfc000000-0xffffffff rom
	
endmodule
