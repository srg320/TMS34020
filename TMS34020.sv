/*
Not implemented:
- big endian mode
- host interface and host interrupt
- 16 bit bus size
- interrupt during graphic instruction execition (IX flag)
- window mode 1,2 and window interrupt
- horizontal/vertical direction
- pixel processing operation
- extern sync for video interface
- instructions:
  - EMU,IDLE,BLMOVE,CEXEC,CMOVxx,RETM,SWAPF
  - VBLT,VLCOL,VFILL
  - CLIP,PFILL,TFILL,FLINE,FPIXEQ,FPIXNE,LINIT,DRAV
  - PIXBLT L,M,L
  - PIXBLT XY,L
  - PIXBLT XY,XY
*/

module TMS34020
 (
	input              CLK,
	input              RST_N,
	input              EN,
	
	input              CE_F,
	input              CE_R,
	
	input              RES_N,
	input              NMI_N,
	input              LINT1_N,
	input              LINT2_N,
	
	output     [31: 0] LA,
	input      [31: 0] LDI,
	output     [31: 0] LDO,
	output             RAS_N,
	output     [ 3: 0] CAS_N,
	output             WE_N,
	output             QE_N,
	output             ALTCH_N,
	input              LRDY,
	
	input              VCE_R,
	output             HS_N,
	output             VS_N,
	output             HBL_N,
	output             VBL_N
	
`ifdef DEBUG
	,
	output reg [25: 3] DBG_PC,
	output reg [31: 0] DBG_ALU_R,
	output reg         DBG_ALU_C,
	output reg         DBG_ALU_Z,
	output reg         DBG_ALU_N,
	output reg         DBG_ALU_V,
	output reg [31: 0] DBG_PIX_WMASK,
	output reg [31: 0] DBG_PIX_PAT,
	output reg         DBG_UNUSED,
	output reg         DBG_UNUSED_PC,
	output reg [31: 0] DBG_SAVE_PC,
	output reg [15: 0] DBG_DI_FLAG,
	output     [31: 0] DBG_TEMP
`endif
);
	 
	 import TMS34020_PKG::*;
	 
	//MC
	bit  [31: 0] MC_ADDR;
	bit  [31: 0] MC_DIN;
	bit  [31: 0] MC_DOUT;
	bit          MC_WAIT;
	bit          MC_CACHE_WR;
	
	bit  [31: 0] DBUS_A;
	bit  [31: 0] DBUS_DI;
	bit  [31: 0] DBUS_DO;
	bit          DBUS_RAS;
	bit          DBUS_WE;
	bit          DBUS_RD;
	bit  [ 3: 0] DBUS_BE;
	bit  [ 3: 0] DBUS_CODE;
	bit          DBUS_RDY;
	
	//IO
	IOReg_t      IO_REGS;
	bit  [31: 0] IO_DO;
	bit  [31: 0] SCRREF_ADDR;
	bit          SCRREF_RUN;
	bit          INT1_REQ;
	bit          INT2_REQ;
	bit          HI_REQ;
	bit          DI_REQ;
	bit          WV_REQ;
	
	//IE
	bit  [31: 0] PC;
	ST_t         ST;
	bit  [ 4: 0] RF_WA_N;
	bit  [31: 0] RF_WA_D;
	bit          RF_WA_WE;
	bit  [ 4: 0] RF_WB_N;
	bit  [31: 0] RF_WB_D;
	bit          RF_WB_WE;
	bit  [ 4: 0] RF_RA_N;
	bit  [ 4: 0] RF_RB_N;
	bit  [31: 0] RF_RA_Q;
	bit  [31: 0] RF_RB_Q;
	
	bit  [15: 0] IC;
	bit  [31: 0] IW;
	bit          RST_EXEC;
	DecInstr_t   DECI;
	bit  [ 4: 0] STATE;
	bit  [ 5: 0] FS;
	bit          FE;
	bit          DS_Z;
	bit  [31: 0] ALU_A,ALU_B;
	bit  [63: 0] MD_ACC;
	bit  [63: 0] MD_SHIFT;
	bit  [31: 0] MD_Q;
	bit          DIV_V;
	bit  [31: 0] ALU_R;
	bit          ALU_C,ALU_V,ALU_Z,ALU_N;
	bit  [ 3: 0] ALU_XY_CC;
	bit          MD_COND;
	bit          MD_NEG;
	bit          J_COND;
	bit          DS_COND;
	bit          MM_COND;
	bit          RP_COND;
	bit  [ 5: 0] PSIZE;
	bit  [15: 0] CONVDP;
	bit  [15: 0] CONVSP;
	bit  [15: 0] CONVMP;
	bit  [31: 0] PIXALU_R;
	XY_t         PIX_POS;
	XY_t         PIX_DYDX;
	bit  [ 3: 0] PIX_WINCC;
	bit  [31: 0] PIX_DOFFS;
	bit  [31: 0] PIX_SOFFS;
	bit  [31: 0] PIX_MOFFS;
	bit  [ 5: 0] PIXBLT_PPW;
	bit  [15: 0] PIXBLT_X;
	bit  [31: 0] PIX_BIT;
	bit  [31: 0] PIX_PAT;
	bit          PIX_XEND;
	bit          PIX_YEND;
	bit          PIX_BL;
	bit  [31: 0] PIX_WMASK;
	bit          PIX_WE;
	bit          LINE_GZ;
	bit          LINE_COND;
	bit  [31: 0] WSTART;
	bit  [31: 0] WEND;
	bit  [31: 0] COLOR0;
	bit  [31: 0] COLOR1;
	bit  [31: 0] PATTERN;
	
	//Cache
	bit  [31: 0] CACHE_Q;
	bit          CACHE_MISS;
	bit          CACHE_WAIT;
	TMS34020_CACHE CACHE
	(
		.CLK(CLK),
		.RST_N(RST_N),
		.EN(EN),
		
		.CE_F(CE_F),
		.CE_R(CE_R),
		
		.RES_N(RES_N),
		.RST_EXEC(RST_EXEC),
		
		.CACHE_DATA(DBUS_DI),
		.CACHE_WR(MC_CACHE_WR),
		
		.PC(PC),
		.CACHE_Q(CACHE_Q),
		.CACHE_MISS(CACHE_MISS),
		.CACHE_WAIT(CACHE_WAIT)
	);
	
	
	TMS34020_ID ID (
		.CLK(CLK),
		.RST_N(RST_N),
		.EN(EN),
		
		.CE_F(CE_F),
		.CE_R(CE_R),
		
		.IC(IC),
		.STATE(STATE),
		.MD_COND(MD_COND),
		.MD_NEG(MD_NEG),
		.DIV_V(DIV_V),
		.J_COND(J_COND),
		.DS_COND(DS_COND),
		.MM_COND(MM_COND),
		.FE0(ST.FE0),
		.FE1(ST.FE1),
		.RP_COND(RP_COND),
		.LINE_GZ(LINE_GZ),
		.LINE_COND(LINE_COND),
		.PIX_XEND(PIX_XEND),
		.PIX_YEND(PIX_YEND),
		.PIX_WINEN(&IO_REGS.CONTROL.W),
		.PIX_WINCC(PIX_WINCC),
		.PIX_BL(PIX_BL),
		.PIX_WE(PIX_WE),
		
		.DECI(DECI)
	);
	
	bit  [ 1: 0] WORD_MASK;
	wire IW_WAIT = DECI.IWL[1] && PC[4];
	wire INT_REQ = (DI_REQ || HI_REQ || WV_REQ || INT1_REQ || INT2_REQ) && ST.IE;
	
	always @(posedge CLK or negedge RST_N) begin		
		bit [31: 0] PC_NEXT;
		bit         STATE_DONE;
		
		if (!RST_N) begin
			PC <= 32'hFFFFFFFF;
			IC <= 16'h0900;
			IW <= '0;
			RST_EXEC <= 1;
			STATE <= '0;
			WORD_MASK <= '0;
		end
		else if (EN && CE_R) begin
			if (!MC_WAIT && !CACHE_WAIT) begin
				if (INT_REQ && DECI.LST) begin
					IC <= 16'h090A;
					STATE <= 5'd0;
				end else if (!DECI.IWL) begin
					STATE <= DECI.NST;
					if (DECI.LST) begin
						IC <= !PC[4] ? CACHE_Q[15:0] : CACHE_Q[31:16];
						STATE <= 5'd0;
					end
					
					if (DECI.JC == JC_JUMP) begin
						case (DECI.PCS)
							PCS_REG: PC_NEXT = {RF_RB_Q[31:4],4'h0};
							default: PC_NEXT = PC;
						endcase
					end else if (DECI.JC == JC_COND && J_COND) begin
						case (DECI.PCS)
							PCS_IB: PC_NEXT = PC + { {20{IC[ 7]}},IC[ 7: 0],4'h0 };
							PCS_IW: PC_NEXT = PC + { {12{IW[15]}},IW[15: 0],4'h0 };
							PCS_IL: PC_NEXT = {IW[31: 4],4'h0 };
							default: PC_NEXT = PC;
						endcase
					end else if (DECI.JC == JC_DS && DS_COND) begin
						case (DECI.PCS)
							PCS_K: PC_NEXT = !IC[10] ? PC + { {23{1'b0}},IC[9:5],4'h0 } : PC - { {23{1'b0}},IC[9:5],4'h0 };
							PCS_IW: PC_NEXT = PC + { {12{IW[15]}},IW[15:0],4'h0 };
							default: PC_NEXT = PC;
						endcase
					end else if (DECI.PCW) begin
						if (DECI.LST) begin
							PC_NEXT = PC + 32'h10;
						end else begin
							case (DECI.PCS)
								PCS_IW: PC_NEXT = PC + { {12{IW[15]}},IW[15: 0],4'h0 };
								PCS_IL: PC_NEXT = {IW[31: 4],4'h0 };
								PCS_REG: PC_NEXT = {RF_RB_Q[31:4],4'h0};
								PCS_MEM: PC_NEXT = {MC_DIN[31:4],4'h0};
								default: PC_NEXT = PC;
							endcase
						end
					end
					
					WORD_MASK <= 2'b00;
				end else begin
					if (!PC[4] && !WORD_MASK[0]) begin
						if (DECI.IWL[0]) begin IW[15: 0] <= CACHE_Q[15: 0]; WORD_MASK[0] <= 1; end
						if (DECI.IWL[1]) begin IW[31:16] <= CACHE_Q[31:16]; WORD_MASK[1] <= 1; end
						if (!DECI.IWL[1]) begin
							PC_NEXT = PC + 32'h10;
						end else begin
							PC_NEXT = PC + 32'h20;
						end
						STATE <= DECI.NST;
					end else if (!PC[4] && WORD_MASK[0]) begin
						if (DECI.IWL[1]) begin IW[31:16] <= CACHE_Q[15: 0]; WORD_MASK[1] <= 1; end
						PC_NEXT = PC + 32'h10;
						STATE <= DECI.NST;
					end else begin
						if (DECI.IWL[0]) begin IW[15: 0] <= CACHE_Q[31:16]; WORD_MASK[0] <= 1; end
						PC_NEXT = PC + 32'h10;
						if (!DECI.IWL[1]) STATE <= DECI.NST;
					end
				end
				if (STATE == 5'd7 && RST_EXEC) begin
					RST_EXEC <= 0;
				end
				
				PC <= PC_NEXT;
			end
		end
	end 
	
	bit  [15: 0] LIST;
	bit  [ 3: 0] MM_RN;	
	always @(posedge CLK or negedge RST_N) begin		
		if (!RST_N) begin
			LIST <= 16'h0000;
			MM_RN <= 4'd0;
		end
		else if (EN) begin	
			if (CE_R) begin	
				if (!MC_WAIT && !CACHE_WAIT) begin
					if (DECI.MMS) begin
						LIST <= IW[15:0];
						MM_RN <= BitToReg(IW[15:0],4'd0,0);
					end else if (DECI.MMA) begin
						MM_RN <= BitToReg(LIST,4'd0,0);
					end else begin
						LIST[MM_RN] <= 0;
					end
				end
			end
		end
	end
	assign MM_COND = ~|LIST;

	//Registers bank
	TMS34020_RF RF (
		.CLK(CLK),
		.RST_N(RST_N),
		.CE(CE_R),
		.EN(EN),
		
		.WA_A(RF_WA_N),
		.WA_D(RF_WA_D),
		.WA_WE(RF_WA_WE),
		.WB_A(RF_WB_N),
		.WB_D(RF_WB_D),
		.WB_WE(RF_WB_WE),
		
		.RA_A(RF_RA_N),
		.RA_Q(RF_RA_Q),
		.RB_A(RF_RB_N),
		.RB_Q(RF_RB_Q)
	);
	assign RF_RA_N = {DECI.R,DECI.RD};
	assign RF_RB_N = DECI.MMA ? {DECI.R,MM_RN^{4{~IC[5]}}} : {DECI.R,DECI.RS};
	
	assign RF_WA_N = {DECI.R^DECI.M,DECI.RD};
	assign RF_WA_WE = ~IW_WAIT & ~MC_WAIT & ~CACHE_WAIT & DECI.RWA.WE;
	assign RF_WB_N = DECI.MMA ? {DECI.R,MM_RN^{4{~IC[5]}}} : {DECI.R,DECI.RS};
	assign RF_WB_WE = ~IW_WAIT & ~MC_WAIT & ~CACHE_WAIT & DECI.RWB.WE;
	
	//ALU
	always_comb begin
		case (DECI.RWA.WS)
			RS_REGA: RF_WA_D <= RF_RA_Q;
			RS_REGB: RF_WA_D <= RF_RB_Q;
			RS_ALU:  RF_WA_D <= ALU_R;
			RS_MEM:  RF_WA_D <= MC_DIN;
//			RS_PIX:  RF_WA_D <= PIX_PAT;
			RS_PC:   RF_WA_D <= PC;
			RS_ST:   RF_WA_D <= ST;
			RS_REV:  RF_WA_D <= 32'h00000000;
		endcase
		
		case (DECI.RWB.WS)
			RS_REGA: RF_WB_D <= RF_RA_Q;
			RS_REGB: RF_WB_D <= RF_RB_Q;
			RS_ALU:  RF_WB_D <= ALU_R;
			RS_MEM:  RF_WB_D <= MC_DIN;
//			RS_PIX:  RF_WB_D <= PIX_PAT;
			RS_PC:   RF_WB_D <= PC;
			RS_ST:   RF_WB_D <= ST & ST_RMASK;
			RS_REV:  RF_WB_D <= 32'h00000000;
		endcase
	end
	
	assign PSIZE = IO_REGS.PSIZE[5:0];
	assign CONVDP = IO_REGS.CONVDP;
	assign CONVSP = IO_REGS.CONVSP;
	assign CONVMP = IO_REGS.CONVMP;
	
	always_comb begin
		case (DECI.FT.FSI)
			FSI_F:  {FE,FS} <= !DECI.F ? {ST.FE0,{~|ST.FS0,ST.FS0}} : {ST.FE1,{~|ST.FS1,ST.FS1}};
			FSI_PS: {FE,FS} <= {DECI.FT.FE,PSIZE};
			FSI_PW: {FE,FS} <= {DECI.FT.FE,PPWToFS(PIXBLT_PPW, PSIZE)};
			FSI_8:  {FE,FS} <= {DECI.FT.FE,6'd08};
			FSI_16: {FE,FS} <= {DECI.FT.FE,6'd16};
			FSI_32: {FE,FS} <= {DECI.FT.FE,6'd32};
			default:{FE,FS} <= {DECI.FT.FE,6'd32};
		endcase
	end
	
	bit [ 4: 0] ALU_SA;
	always @(posedge CLK or negedge RST_N) begin		
		bit [31: 0] IMMA, IMMB;
		bit [31: 0] CONSTA, CONSTB;
		bit [31: 0] REGA, REGB;
		
		if (!RST_N) begin
			ALU_A <= '0;
			ALU_B <= '0;
			ALU_SA <= '0;
		end
		else begin		
			case (DECI.AIA.IT)
				IMM_K:    IMMA = {{26{1'b0}} ,~|IC[9:5],IC[9:5]};
				IMM_IW:   IMMA = {{16{IW[15]}},IW[15:0]};
				IMM_IL:   IMMA = IW;
				IMM_FS:   IMMA = {{26{1'b0}},FS};
				default:  IMMA = 32'h00000000;
			endcase
			case (DECI.AIB.IT)
				IMM_K:    IMMB = {{26{1'b0}} ,~|IC[9:5],IC[9:5]};
				IMM_IW:   IMMB = {{16{IW[15]}},IW[15:0]};
				IMM_IL:   IMMB = IW;
				IMM_FS:   IMMB = {{26{1'b0}},FS};
				default:  IMMB = 32'h00000000;
			endcase
			
			case (DECI.AIA.CV)
				CV_0:    CONSTA = 32'h00000000;
				CV_1:    CONSTA = 32'h00000001;
				CV_2:    CONSTA = 32'h00000002;
				CV_4:    CONSTA = 32'h00000004;
				CV_8:    CONSTA = 32'h00000008;
				CV_16:   CONSTA = 32'h00000010;
				CV_32:   CONSTA = 32'h00000020;
				default: CONSTA = 32'h00000000;
			endcase
			case (DECI.AIB.CV)
				CV_0:    CONSTB = 32'h00000000;
				CV_1:    CONSTB = 32'h00000001;
				CV_2:    CONSTB = 32'h00000002;
				CV_4:    CONSTB = 32'h00000004;
				CV_8:    CONSTB = 32'h00000008;
				CV_16:   CONSTB = 32'h00000010;
				CV_32:   CONSTB = 32'h00000020;
				default: CONSTB = 32'h00000000;
			endcase
			
			case (DECI.AIA.AS)
				AS_REGA:  REGA = RF_RA_Q;
				AS_REGB:  REGA = RF_RB_Q;
				AS_IMM:   REGA = IMMA;
				AS_CONST: REGA = CONSTA;
				AS_STF:   REGA = {{26{1'b0}},!IC[9] ? ST[5:0] : ST[11:6]};
				AS_PS:    REGA = {16'h0000,IO_REGS.PSIZE};
				AS_PIX:   REGA = PIXALU_R;
				AS_MDAL:  REGA = MD_ACC[31:0];
				AS_MDAH:  REGA = MD_ACC[63:32];
				AS_MDQ:   REGA = MD_Q;
				default:  REGA = '0;
			endcase
			case (DECI.AIB.AS)
				AS_REGA:  REGB = RF_RA_Q;
				AS_REGB:  REGB = RF_RB_Q;
				AS_IMM:   REGB = IMMB;
				AS_CONST: REGB = CONSTB;
				AS_STF:   REGB = {{26{1'b0}},!IC[9] ? ST[5:0] : ST[11:6]};
				AS_PS:    REGB = {16'h0000,IO_REGS.PSIZE};
				AS_PIX:   REGB = PIXALU_R;
				AS_MDAL:  REGB = MD_ACC[31:0];
				AS_MDAH:  REGB = MD_ACC[63:32];
				AS_MDQ:   REGB = MD_Q;
				default:  REGB = '0;
			endcase
						
			ALU_A <= Ext(REGA, FS, DECI.AIA.EO);
			ALU_B <= Ext(REGB, FS, DECI.AIB.EO);
			
			case (DECI.SHC.AMS)
				SS_REG:   ALU_SA <= RF_RB_Q[4:0];
				SS_IMM:   ALU_SA <= IMMB[4:0];
				SS_CONST: ALU_SA <= CONSTB[4:0];
				SS_FS:    ALU_SA <= FS[4:0];
				default:  ALU_SA <= '0;
			endcase
		end
	end
			
	bit         ADDXY_CX;
	bit         ADDXY_CY;
	always_comb begin
//		bit [31: 0] ADD_B;
		bit [ 1: 0] ADD_CD;
		bit         ADD_BCOMP;
		bit [31: 0] ADDER_RES;
		bit         ADDER_C;
		bit         ADDER_V;
		bit         ADDER_Z;
		bit [31: 0] ADDXY_RES;
		bit [ 1: 0] ADDXY_Z;
		bit [31: 0] LOG_RES;
		bit         LOG_V;
		bit [31: 0] SHIFT_RES;
		bit         SHIFT_C;
		bit         SHIFT_V;
		bit [ 4: 0] LOC_RES;
				
		{SHIFT_C,SHIFT_RES} = CarryShifter(ALU_A, ALU_SA, DECI.SHC.SHOP);
		SHIFT_V = ShiftLeftOvf(ALU_A, ALU_SA);
		
//		ADD_B <= DECI.ALU.OP == ALUOP_DIV ? DIV_Q : ALU_B;
		{ADD_CD,ADD_BCOMP} = !DECI.ALU.CD[2] ? {DECI.ALU.CD[1:0],DECI.ALU.BCOMP} : {1'b0,ALU_B[31],ALU_B[31]};
		{ADDER_C,ADDER_RES} = CarryAdder(ALU_A, ALU_B, ST.C, ADD_CD, ADD_BCOMP, DECI.ALU.OP==ALUOP_ADDXY); 
		ADDER_V = ((ALU_A[31] ^ (ALU_B[31] ^ ~ADD_BCOMP)) ^ ~ADD_CD[0]) & (ALU_A[31] ^ ADDER_RES[31]);
		ADDER_Z = ~|ADDER_RES;
		
		{ADDXY_CY,ADDXY_CX,ADDXY_RES} = XYAdjust(ADDER_RES, PIX_DYDX, DECI.ALU.CD[3]);
		ADDXY_Z = {~|ADDER_RES[31:16], ~|ADDER_RES[15:0]};
		
		ALU_XY_CC = XYCompareWin(RF_RB_Q, WSTART, WEND);
		
		LOG_RES = Logger(SHIFT_RES, ALU_B, DECI.ALU.CD); 
		LOG_V = ~((~|LOG_RES & ~SHIFT_RES[31]) | (&LOG_RES & SHIFT_RES[31]));
		 
		LOC_RES = OneLocate(ALU_B, DECI.ALU.CD[0]);
		
		case (DECI.ALU.OP)
			ALUOP_ADD:   {ALU_N,ALU_Z,ALU_V,ALU_C,ALU_R} <= {ADDER_RES[31],ADDER_Z     ,ADDER_V      ,ADDER_C      ,ADDER_RES};
			ALUOP_ADDXY: {ALU_N,ALU_Z,ALU_V,ALU_C,ALU_R} <= {ADDXY_Z[0]   ,ADDXY_Z[1]  ,ADDXY_RES[15],ADDXY_RES[31],ADDXY_RES};
			ALUOP_CPW:   {ALU_N,ALU_Z,ALU_V,ALU_C,ALU_R} <= {1'b0         ,1'b0        ,|ALU_XY_CC   ,1'b0         ,{24'h000000,ALU_XY_CC,4'h0}};
			ALUOP_LOG:   {ALU_N,ALU_Z,ALU_V,ALU_C,ALU_R} <= {1'b0         ,~|LOG_RES   ,LOG_V        ,1'b0         ,LOG_RES};
			ALUOP_SHIFT: {ALU_N,ALU_Z,ALU_V,ALU_C,ALU_R} <= {1'b0         ,~|SHIFT_RES ,SHIFT_V      ,SHIFT_C      ,SHIFT_RES};
			ALUOP_LOC:   {ALU_N,ALU_Z,ALU_V,ALU_C,ALU_R} <= {1'b0         ,~|ALU_B     ,1'b0         ,1'b0         ,{27'h0000000,LOC_RES}};
			ALUOP_MUL:   {ALU_N,ALU_Z,ALU_V,ALU_C,ALU_R} <= {1'b0         ,~|MD_ACC    ,1'b0         ,1'b0         ,ADDER_RES};
			ALUOP_DIV:   {ALU_N,ALU_Z,ALU_V,ALU_C,ALU_R} <= {ADDER_RES[31],ADDER_Z     ,DIV_V        ,1'b0         ,ADDER_RES};
			default:     {ALU_N,ALU_Z,ALU_V,ALU_C,ALU_R} <= {MC_DIN[31]   ,~|MC_DIN    ,1'b0         ,1'b0         ,MC_DIN};
		endcase 
	end
	
	//DIV unit
		bit [63: 0] MDALU_A;
		bit [63: 0] MDALU_B;
		bit [63: 0] MDALU_R;
		bit [63: 0] MDSHT_R;
		bit         MDALU_C;
		bit         MDALU_Z;
		bit [ 5: 0] MD_STEP;
	always_comb begin
		bit [ 1: 0] ADD_CD;
		bit         ADD_BCOMP;
		bit [63: 0] ADDER_RES;
		bit         ADDER_C;
		bit         ADDER_Z;
		
		case (DECI.MDC.ACCS)
			MDA_ZERO: begin
				MDALU_A = '0;
				MDALU_B = '0;
				{ADD_CD,ADD_BCOMP} = {2'b00,1'b0};
			end
			MDA_MULT: begin
				MDALU_A = MD_ACC;
				MDALU_B = MultStep2(RF_RA_Q, MD_SHIFT[1:0], MD_STEP);
				{ADD_CD,ADD_BCOMP} = {2'b00,1'b0};
			end
			MDA_DIV: begin
				MDALU_A = MD_ACC;
				MDALU_B = MD_SHIFT;
				{ADD_CD,ADD_BCOMP} = {2'b01,1'b1};
			end
			MDA_LDL: begin
				MDALU_A = {{32{ALU_R[31]}},ALU_R};
				MDALU_B = '0;
				{ADD_CD,ADD_BCOMP} = {2'b00,1'b0};
			end
			MDA_LDH: begin
				MDALU_A = {ALU_R,MD_ACC[31:0]};
				MDALU_B = '0;
				{ADD_CD,ADD_BCOMP} = {2'b00,1'b0};
			end
			MDA_NEG: begin
				MDALU_A = '0;
				MDALU_B = MD_ACC;
				{ADD_CD,ADD_BCOMP} = {{1'b0,MD_NEG},MD_NEG};
			end
			default: begin
				MDALU_A = MD_ACC;
				MDALU_B = '0;
				{ADD_CD,ADD_BCOMP} = {2'b00,1'b0};
			end
		endcase
					
		{ADDER_C,ADDER_RES} = MDCarryAdder(MDALU_A, MDALU_B, ADD_CD, ADD_BCOMP);
		ADDER_Z = ~|ADDER_RES;
		
		{MDALU_Z, MDALU_C, MDALU_R} <= {ADDER_Z, ADDER_C, ADDER_C && DECI.MDC.ACCS == MDA_DIV ? MD_ACC : ADDER_RES};
		
		case (DECI.MDC.SHS)
			MDSH_MULT: MDSHT_R <= {MD_SHIFT[63],MD_SHIFT[63],MD_SHIFT[63:2]};
			MDSH_DIV:  MDSHT_R <= {MD_SHIFT[63],MD_SHIFT[63:1]};
			MDSH_LDM:  MDSHT_R <= {{32{ALU_R[31]}},ALU_R};
			MDSH_LDD:  MDSHT_R <= {ALU_R,32'h00000000}; 
			default:   MDSHT_R <= MD_SHIFT;
		endcase 
	end
	
	always @(posedge CLK or negedge RST_N) begin	
		bit [ 5: 0] MUL_STEP_NEXT;
		bit         MUL_STEP_LAST;
		bit [ 5: 0] DIV_STEP_NEXT;
		
		if (!RST_N) begin
			MD_ACC <= '0;
			MD_SHIFT <= '0;
			MD_Q <= '0;
			MD_STEP <= '0;
			MD_COND <= 0;
			MD_NEG <= 0;
			DIV_V <= 0;
		end
		else if (EN && CE_R) begin
			if (!IW_WAIT && !MC_WAIT && !CACHE_WAIT) begin
				MUL_STEP_NEXT = MD_STEP + 6'd2;
				MUL_STEP_LAST = MUL_STEP_NEXT >= (FS - 6'd2);
				DIV_STEP_NEXT = MD_STEP + 6'd1; 
				
				MD_ACC <= MDALU_R;
				MD_SHIFT <= MDSHT_R;
				case (DECI.MDC.OP)
					MDO_MULINIT: begin
						MD_STEP <= '0;
						MD_COND <= 0;
					end
					MDO_MULCHK: begin
						MD_NEG <= ALU_B[31] & ~IC[9];
						MD_COND <= MUL_STEP_LAST;
					end
					MDO_MULSTEP: begin
						MD_STEP <= MUL_STEP_NEXT; 
						MD_COND <= MUL_STEP_LAST;
					end
					
					MDO_DIVINIT: begin
						MD_Q <= '0;
						MD_NEG <= ALU_B[31] & ~IC[9]; 
						MD_STEP <= '0; 
						MD_COND <= 0; 
					end
					MDO_DIVDVNT: begin
						MD_NEG <= ALU_B[31] & ~IC[9]; 
					end
					MDO_DIVDVSR: begin
						DIV_V <= ALU_Z;
						MD_NEG <= (ALU_B[31] ^ MD_NEG) & ~IC[9];
					end
					MDO_DIVSTEP: begin
						MD_Q <= {MD_Q[30:0],~MDALU_C};
						MD_STEP <= DIV_STEP_NEXT; 
						MD_COND <= MD_STEP == 6'd31;
					end
					MDO_DIVQUOT: begin 
						MD_Q <= (MD_Q ^ {32{MD_NEG}}) + MD_NEG;
					end
						
					default: ;
				endcase
			end
		end
	end 
	
	
	//Conditions
	always @(posedge CLK or negedge RST_N) begin		
		if (!RST_N) begin
			DS_Z <= 0;
		end
		else if (EN && CE_R) begin
			if (!IW_WAIT && !MC_WAIT && !CACHE_WAIT) begin
				DS_Z <= ALU_Z;
			end
		end
	end 
	
	always_comb begin
		case (IC[11:8])
			4'h0: J_COND <= 1'b1;	//UC
			4'h1: J_COND <= ~ST.N & ~ST.Z;	//P
			4'h2: J_COND <= ST.C | ST.Z;//LS
			4'h3: J_COND <= ~ST.C & ~ST.Z;//HI
			4'h4: J_COND <= (ST.N & ~ST.V) | (~ST.N & ST.V);//LT
			4'h5: J_COND <= (ST.N & ST.V) | (~ST.N & ~ST.V);//GE
			4'h6: J_COND <= (ST.N & ~ST.V) | (~ST.N & ST.V) | ST.Z;//LE
			4'h7: J_COND <= (ST.N & ST.V & ~ST.Z) | (~ST.N & ~ST.V & ~ST.Z);//GT
			4'h8: J_COND <= ST.C;//LO
			4'h9: J_COND <= ~ST.C;//HS
			4'hA: J_COND <= ST.Z;//EQ
			4'hB: J_COND <= ~ST.Z;//NE
			4'hC: J_COND <= ST.V;//V
			4'hD: J_COND <= ~ST.V;	//NV
			4'hE: J_COND <= ST.N;//N
			4'hF: J_COND <= ~ST.N;//NN
		endcase 
		
		case (STATE)
			5'd0: DS_COND <= ST.Z;
			5'd1: DS_COND <= ~DS_Z;
			default: DS_COND <= 0;
		endcase
	end
	
	//STATUS register
	always @(posedge CLK or negedge RST_N) begin		
		if (!RST_N) begin
			ST <= ST_INIT;
		end
		else if (EN && CE_R) begin
			if (!IW_WAIT && !MC_WAIT && !CACHE_WAIT) begin
				case (DECI.STW.STU)
					STU_ST:  ST <= RF_RA_Q & ST_WMASK;
					STU_MEM: ST <= MC_DIN & ST_WMASK;
					STU_RES: ST <= ST_INIT;
					STU_FS: case (DECI.F)
						1'b0: {ST.FE0,ST.FS0} <= IC[5:0];
						1'b1: {ST.FE1,ST.FS1} <= IC[5:0];
					endcase
					STU_EXFS: case (DECI.F)
						1'b0: {ST.FE0,ST.FS0} <= RF_RA_Q[5:0];
						1'b1: {ST.FE1,ST.FS1} <= RF_RA_Q[5:0];
					endcase
					STU_C:  ST.C <= IC[11];
					STU_IE: ST.IE <= IC[11];
					STU_ALU: begin
						if (DECI.STW.AFU[3]) ST.N <= ALU_N;
						if (DECI.STW.AFU[2]) ST.C <= ALU_C;
						if (DECI.STW.AFU[1]) ST.Z <= ALU_Z;
						if (DECI.STW.AFU[0]) ST.V <= ALU_V;
					end
					default:;
				endcase
			end
		end
	end 
	
	//Pixel unit
	always_comb begin
		bit [31: 0] REGS;
		bit [31: 0] REGD;
		bit [ 4: 0] CONVxP;
		bit [31: 0] PIX_OFFS;
		
		case (DECI.PALU.AS)
			PIXAS_REGA: begin REGS = RF_RA_Q; REGD = RF_RB_Q; end
			PIXAS_REGB: begin REGS = RF_RB_Q; REGD = RF_RA_Q; end
		endcase
			
		case (DECI.PALU.CNVS)
			CNVS_DP: begin CONVxP = CONVDP[4:0]; PIX_OFFS = PIX_DOFFS; end
			CNVS_SP: begin CONVxP = CONVSP[4:0]; PIX_OFFS = PIX_SOFFS; end
			CNVS_MP: begin CONVxP = CONVMP[4:0]; PIX_OFFS = PIX_MOFFS; end
			default: begin CONVxP = '0; PIX_OFFS = '0; end
		endcase
		
		case (DECI.PALU.AOP)
			PIXOP_PPW:   PIXALU_R <= PPWToFS(PIXBLT_PPW, PSIZE);
			PIXOP_XYL:   PIXALU_R <= XYToL(REGS, PSIZE, CONVxP);
			PIXOP_XYS:   PIXALU_R <= {16'h0000,PIXBLT_PPW};
			PIXOP_MOVX:  PIXALU_R <= {REGD[31:16],REGS[15:0]};
			PIXOP_MOVY:  PIXALU_R <= {REGS[31:16],REGD[15:0]};
			PIXOP_OFFS:  PIXALU_R <= PIX_OFFS;
			PIXOP_LNS:   PIXALU_R <= LineStep(PIX_DYDX, LINE_GZ);
			PIXOP_WSTA:  PIXALU_R <= XYWinOffset(REGS, WSTART);
			default:  PIXALU_R <= '0;
		endcase
	end
	
	always @(posedge CLK or negedge RST_N) begin		
		if (!RST_N) begin
			WSTART <= '0;
			WEND <= '0;
			COLOR0 <= '0;
			COLOR1 <= '0;
			PATTERN <= '0;
		end
		else if (EN) begin	
			if (!IW_WAIT & !MC_WAIT && !CACHE_WAIT && CE_R) begin
				if (RF_WA_N[4] && RF_WA_WE)
					case (RF_WA_N[3:0])
						4'd5: WSTART <= RF_WA_D;
						4'd6: WEND <= RF_WA_D;
						4'd8: COLOR0 <= RF_WA_D;
						4'd9: COLOR1 <= RF_WA_D;
						4'd13: PATTERN <= RF_WA_D;
					endcase
					
				if (RF_WB_N[4] && RF_WB_WE)
					case (RF_WB_N[3:0])
						4'd5: WSTART <= RF_WB_D;
						4'd6: WEND <= RF_WB_D;
						4'd8: COLOR0 <= RF_WB_D;
						4'd9: COLOR1 <= RF_WB_D;
						4'd13: PATTERN <= RF_WB_D;
					endcase
			end
		end
	end
	
	always @(posedge CLK or negedge RST_N) begin		
		bit [ 5:0] prest;
		bit [ 5:0] pmax;
		bit [15:0] temp;
		bit [15:0] temp2;
		bit [15:0] pm;
		bit [31:0] PAT;
		
		if (!RST_N) begin
			RP_COND <= 0;
			PIX_XEND <= 0;
			PIX_YEND <= 0;
			PIX_BL <= 0;
			PIXBLT_PPW <= '0;
			PIXBLT_X <= '0;
			PIX_POS <= '0;
			PIX_BIT <= '0;
			LINE_GZ <= 0;
			LINE_COND <= 0;
		end
		else if (EN && CE_R) begin
			if (!IW_WAIT && !MC_WAIT && !CACHE_WAIT) begin
				LINE_COND <= ALU_Z;
		
				case (STATE)
					5'd0: RP_COND <= PSIZE == 6'h20;
					5'd2: RP_COND <= PSIZE == 6'h10;
					5'd3: RP_COND <= PSIZE == 6'h08;
					5'd4: RP_COND <= PSIZE == 6'h04;
					5'd5: RP_COND <= PSIZE == 6'h02;
					5'd6: RP_COND <= PSIZE == 6'h01;
					default: RP_COND <= 0;
				endcase
				
				case (PSIZE)
					default: pm = 16'h0000;
					6'h01: pm = 16'hFFE0;
					6'h02: pm = 16'hFFF0;
					6'h04: pm = 16'hFFF8;
					6'h08: pm = 16'hFFFC;
					6'h10: pm = 16'hFFFE;
					6'h20: pm = 16'hFFFF;
				endcase
				
				case (DECI.PF.BLT)
					PBLT_STRT: begin
						{PIX_YEND,PIX_XEND} <= '0;
						
						case (PSIZE)
							6'h01: pmax = 6'h20 - {1'b0,RF_RA_Q[4:0]};
							6'h02: pmax = 6'h10 - {2'b00,RF_RA_Q[4:1]};
							6'h04: pmax = 6'h08 - {3'b000,RF_RA_Q[4:2]};
							6'h08: pmax = 6'h04 - {4'b0000,RF_RA_Q[4:3]};
							6'h10: pmax = 6'h02 - {5'b00000,RF_RA_Q[4:4]};
							default: pmax = 6'h01;
						endcase
						
						temp = PIX_DYDX.X - 16'd1;
						if (!(temp & pm)) begin
							case (PSIZE)
								6'h01: prest = {PIX_DYDX.X[5:0]};
								6'h02: prest = {1'b0,PIX_DYDX.X[4:0]};
								6'h04: prest = {2'b00,PIX_DYDX.X[3:0]};
								6'h08: prest = {3'b000,PIX_DYDX.X[2:0]};
								6'h10: prest = {4'b0000,PIX_DYDX.X[1:0]};
								default: prest = 6'h01;
							endcase
							PIXBLT_PPW <= prest < pmax ? prest : pmax;
						end else begin
							PIXBLT_PPW <= pmax;
						end
						PIXBLT_X <= '0;
						PIX_POS <= '0;
					end
					
					PBLT_NEXT: begin
						{PIX_YEND,PIX_XEND} <= {ADDXY_CY,ADDXY_CX};

						PIXBLT_X <= RF_RA_Q[15:0];
						
						case (PSIZE)
							default: PIX_BL = 0;
							6'h01: PIX_BL <= 1;
							6'h02: PIX_BL <= &RF_RA_Q[4:4];
							6'h04: PIX_BL <= &RF_RA_Q[4:3];
							6'h08: PIX_BL <= &RF_RA_Q[4:2];
							6'h10: PIX_BL <= &RF_RA_Q[4:1];
							6'h20: PIX_BL <= &RF_RA_Q[4:0];
						endcase
						
						PIX_POS <= ALU_R;
					end
					
					PBLT_BMLD: PIX_BIT <= MC_DIN;
					
					PBLT_STEP: ;
					
					PBLT_DRAW: begin
						temp2 = (PIX_DYDX.X - PIX_POS.X);
						if (!(temp2 & pm)) begin
							PIXBLT_PPW <= (temp2[5:0] & ~pm[5:0]);
						end else begin
							case (PSIZE)
								6'h01: PIXBLT_PPW <= 6'h20;
								6'h02: PIXBLT_PPW <= 6'h10;
								6'h04: PIXBLT_PPW <= 6'h08;
								6'h08: PIXBLT_PPW <= 6'h04;
								6'h10: PIXBLT_PPW <= 6'h02;
								default: PIXBLT_PPW <= 6'h01;
							endcase
						end
					end
					
					default: ;
				endcase
				
				case (DECI.PF.OFFS)
					POFFS_INIT: case (DECI.PALU.CNVS)
						CNVS_DP: PIX_DOFFS <= RF_RA_Q + RF_RB_Q;
						CNVS_SP: PIX_SOFFS <= RF_RA_Q + RF_RB_Q;
						CNVS_MP: PIX_MOFFS <= RF_RA_Q + RF_RB_Q;
						default: ;
					endcase
					POFFS_NEXT: case (DECI.PALU.CNVS)
						CNVS_DP: PIX_DOFFS <= PIX_DOFFS + RF_RB_Q;
						CNVS_SP: PIX_SOFFS <= PIX_SOFFS + RF_RB_Q;
						CNVS_MP: PIX_MOFFS <= PIX_MOFFS + RF_RB_Q;
						default: ;
					endcase
					default: ;
				endcase
					
				case (DECI.PF.LINE)
					PLN_INIT: PIX_BIT <= PATTERN;
					PLN_COND: LINE_GZ <= ~ALU_N | (ALU_Z & ~IC[7]);
					PLN_STEP: PIX_BIT <= {PIX_BIT[0],PIX_BIT[31:1]};
					default: ;
				endcase
				
				case (DECI.PF.WIN)
					WIN_INIT:  PIX_DYDX <= RF_RB_Q;
					WIN_DADJ:  PIX_DYDX <= WinAdjust(RF_RB_Q, WSTART, WEND, &IO_REGS.CONTROL.W);
					WIN_CHECK: PIX_WINCC <= ALU_XY_CC;
//					WIN_CHECK: XYWinOffset();
					default: ;
				endcase
			end
		end
	end 
	
	always_comb begin		
		bit  [31: 0] SRC_PAT;
		bit  [31: 0] DST_PAT;
		bit  [31: 0] RES_PAT;
		bit  [31: 0] PAT0,PAT1;
		bit  [31: 0] TMASK;
		
		case (DECI.PIXO.PATS)
			PATS_B:    SRC_PAT = PatternExpand(PIX_BIT, COLOR0, COLOR1, PIXBLT_X[4:0], PSIZE);
			PATS_LN:   SRC_PAT = PatternExpand(PIX_BIT, COLOR0, COLOR1, 5'h00,         6'h20);
			PATS_COL0: SRC_PAT = COLOR0;
			PATS_COL1: SRC_PAT = COLOR1;
			PATS_REG:  SRC_PAT = RF_RB_Q;
			PATS_MEM:  SRC_PAT = MC_DIN;
			default:   SRC_PAT = '0;
		endcase
		DST_PAT = '0;
		RES_PAT = SRC_PAT;
		
		case (IO_REGS.CONTROL.TM)
			default: PAT0 = RES_PAT;
			3'b001:  PAT0 = SRC_PAT;
			3'b101:  PAT0 = DST_PAT;
		endcase
		PAT1 = COLOR0 & {32{IO_REGS.CONTROL.TM[0]}};
		casex ({IO_REGS.CONTROL.T,IO_REGS.CONTROL.TM})
			4'b1x0x: TMASK = PatternEqual(PAT0, PAT1, PSIZE);
			default: TMASK = 0;
		endcase
			
		PIX_PAT <= RES_PAT;
		PIX_WMASK <= ~TMASK;
	end
	assign PIX_WE = |PIX_WMASK;

	
	//IO
	wire IO_SEL = DBUS_A >= 32'hC0000000 && DBUS_A <= 32'hC0001FFF;
	TMS34020_IO IO
	(
		.CLK(CLK),
		.RST_N(RST_N),
		.EN(EN),
		
		.CE_F(CE_F),
		.CE_R(CE_R),
		
		.RES_N(RES_N),
		.NMI_N(NMI_N),
		.LINT1_N(LINT1_N),
		.LINT2_N(LINT2_N),
		
		.A(DBUS_A[12:0]),
		.DI(DBUS_DO),
		.DO(IO_DO),
		.WE(IO_SEL & DBUS_WE),
		.RD(IO_SEL & DBUS_RD),
		.BE(DBUS_BE),
		
		.REGS(IO_REGS),
		.INT1_REQ(INT1_REQ),
		.INT2_REQ(INT2_REQ),
		.HI_REQ(HI_REQ),
		.DI_REQ(DI_REQ),
		.WV_REQ(WV_REQ),
		
		.SCRREF_ADDR(SCRREF_ADDR),
		.SCRREF_RUN(SCRREF_RUN),
		
		.VCE_R(VCE_R),
		.HS_N(HS_N),
		.VS_N(VS_N),
		.HBL_N(HBL_N),
		.VBL_N(VBL_N)
	);
	
	
	//Memory controller
	always_comb begin
		bit  [11: 0] IO_ADDR;
		
		IO_ADDR = 12'h150;
		
		case (DECI.MC.AS)
			MAS_RA:   MC_ADDR <= RF_RA_Q;
			MAS_RB:   MC_ADDR <= RF_RB_Q;
			MAS_RAIW: MC_ADDR <= RF_RA_Q + {{16{IW[15]}},IW[15:0]};
			MAS_RBIW: MC_ADDR <= RF_RB_Q + {{16{IW[15]}},IW[15:0]};
			MAS_IO:   MC_ADDR <= {20'hC0000,IO_ADDR};
			MAS_IL:   MC_ADDR <= IW;
			MAS_VEC:  MC_ADDR <= {{22{1'b1}},~IC[4:0],5'h00};
			default:  MC_ADDR <= '1;
		endcase
		
		case (DECI.MC.DS)
			MDS_REGA: MC_DOUT <= RF_RA_Q;
			MDS_REGB: MC_DOUT <= RF_RB_Q;
			MDS_PIX:  MC_DOUT <= PIX_PAT;
			MDS_PC:   MC_DOUT <= PC;
			MDS_ST:   MC_DOUT <= ST;
			default:  MC_DOUT <= MC_DIN;
		endcase 
	end

	TMS34020_MC MC (
		.CLK(CLK),
		.RST_N(RST_N),
		.EN(EN),
		
		.CE_F(CE_F),
		.CE_R(CE_R),
		
		.RES_N(RES_N),
		
		.ADDR(MC_ADDR),
		.DOUT(MC_DOUT),
		.DIN(MC_DIN),
		.FS(FS),
		.READ(DECI.MC.AT == MA_READ),
		.WRITE(DECI.MC.AT == MA_WRITE),
		.PIX(DECI.MC.MT),
		.PC(PC),
		.CACHE(CACHE_MISS),
		.CACHE_WR(MC_CACHE_WR),
		.VECT(DECI.MC.AS == MAS_VEC),
		.WAIT(MC_WAIT),
		.PIX_WMASK(PIX_WMASK),
		
		.SCRREF_ADDR(SCRREF_ADDR),
		.SCRREF_RUN(SCRREF_RUN),
		
		.DBUS_A(DBUS_A),
		.DBUS_DI(DBUS_DI),
		.DBUS_DO(DBUS_DO),
		.DBUS_RAS(DBUS_RAS),
		.DBUS_WE(DBUS_WE),
		.DBUS_RD(DBUS_RD),
		.DBUS_BE(DBUS_BE),
		.DBUS_CODE(DBUS_CODE),
		.DBUS_RDY(DBUS_RDY),
		
		.CST(IO_REGS.DPYCTL.CST)
	);
	
	assign DBUS_DI = IO_SEL ? IO_DO : LDI;
	assign DBUS_RDY = IO_SEL | LRDY;
	
	assign LA = {DBUS_A[31:4],DBUS_CODE};
	assign LDO = DBUS_DO;
	assign RAS_N = ~DBUS_RAS;
	assign CAS_N = ~((DBUS_BE & {4{DBUS_WE}}) | {4{DBUS_RD}});
	assign WE_N = ~DBUS_WE;
	assign QE_N = ~DBUS_RD;
	assign ALTCH_N = ~(DBUS_WE | DBUS_RD);
	
	
		
`ifdef DEBUG
	assign DBG_PC = PC[25:3];
	assign DBG_ALU_R = ALU_R;
	assign DBG_ALU_C = ALU_C;
	assign DBG_ALU_Z = ALU_Z;
	assign DBG_ALU_N = ALU_N;
	assign DBG_ALU_V = ALU_V;
	
	assign DBG_PIX_WMASK = PIX_WMASK;
	assign DBG_PIX_PAT = PIX_PAT;
	
//	assign DBG_DBUS_A = {DBUS_A[31:4],4'h0};
	bit  [ 7: 0] OBJ_N[16];
	bit  [15: 0] OBJ_ID[16];
	bit  [31: 0] OBJ_H[16];
	bit  [31: 0] OBJ_X[16];
	bit  [31: 0] OBJ_Y[16];
	always @(posedge CLK or negedge RST_N) begin	
		if (!RST_N) begin
			DBG_SAVE_PC <= '0;
		end
		else if (EN) begin
			DBG_UNUSED <= ~((DBUS_A[31:4] <= 28'h003FFFF) || 
			                (DBUS_A[31:4] >= 28'h2000000 && DBUS_A[31:4] <= 28'h200007F) || 
			                (DBUS_A[31:4] >= 28'h4000000 && DBUS_A[31:4] <= 28'h4000001) || 
							    (DBUS_A[31:4] >= 28'h6000000 && DBUS_A[31:4] <= 28'h6003FFF) || 
							    (DBUS_A[31:4] >= 28'hA000000 && DBUS_A[31:4] <= 28'hA07FFFF) || 
							    (DBUS_A[31:4] >= 28'hA400000 && DBUS_A[31:4] <= 28'hA47FFFF) || 
							    (DBUS_A[31:4] >= 28'hA800000 && DBUS_A[31:4] <= 28'hA8FFFFF) || 
							    (DBUS_A[31:4] >= 28'hAC00000 && DBUS_A[31:4] <= 28'hAC7FFFF) || 
							    (DBUS_A[31:4] >= 28'hB000000 && DBUS_A[31:4] <= 28'hB03FFFF) || 
							    (DBUS_A[31:4] >= 28'hB400000 && DBUS_A[31:4] <= 28'hB43FFFF) || 
							    (DBUS_A[31:4] >= 28'hC000000 && DBUS_A[31:4] <= 28'hC0001FF) || 
			                (DBUS_A[31:4] >= 28'hFC00000 && DBUS_A[31:4] <= 28'hFFFFFFF));
			DBG_UNUSED_PC <= ~(PC[31:4] >= 28'hFC00000 && PC[31:4] <= 28'hFFFFFFF);
			
			if (DBUS_A >= 32'h00002000 && DBUS_A <= 32'h00005FFF && DBUS_WE && CE_R) begin
				case ({DBUS_A[9:5],5'b00000})
					10'h000: if (DBUS_BE[1:0]) OBJ_ID[DBUS_A[13:10]-4'd8] <= DBUS_DO[15:0];
					10'h020: OBJ_H[DBUS_A[13:10]-4'd8] <= DBUS_DO;
					10'h040: OBJ_X[DBUS_A[13:10]-4'd8] <= DBUS_DO;
					10'h060: OBJ_Y[DBUS_A[13:10]-4'd8] <= DBUS_DO;
					default:;
				endcase
			end
			if (DBUS_A >= 32'h0002A280 && DBUS_A <= 32'h0002A37F && DBUS_WE && CE_R) begin
				if (DBUS_BE[1:0]) OBJ_N[{~DBUS_A[7],DBUS_A[6:5],1'b0}] <= DBUS_DO[7:0];
				if (DBUS_BE[3:2]) OBJ_N[{~DBUS_A[7],DBUS_A[6:5],1'b1}] <= DBUS_DO[23:16];
			end
			if ({DBUS_A[31:5],5'b00000} == 32'h00022400 && DBUS_WE && CE_R) begin
				if (DBUS_BE[3:2]) DBG_DI_FLAG <= DBUS_DO[31:16];
			end
			if (MC_ADDR == 32'h00001EA0 && MC_DOUT == 32'h00000000 && DECI.MC.AT == MA_WRITE && CE_R) begin
				DBG_SAVE_PC <= PC;
			end
		end
	end
	assign DBG_TEMP = {OBJ_N[0],OBJ_N[1],OBJ_N[2],OBJ_N[3]}^{OBJ_N[4],OBJ_N[5],OBJ_N[6],OBJ_N[7]}^{OBJ_N[8],OBJ_N[9],OBJ_N[10],OBJ_N[11]}^{OBJ_N[12],OBJ_N[13],OBJ_N[14],OBJ_N[15]}^
	                  {OBJ_ID[0],OBJ_ID[1]}^{OBJ_ID[2],OBJ_ID[3]}^{OBJ_ID[4],OBJ_ID[5]}^{OBJ_ID[6],OBJ_ID[7]}^{OBJ_ID[8],OBJ_ID[9]}^{OBJ_ID[10],OBJ_ID[11]}^{OBJ_ID[12],OBJ_ID[13]}^{OBJ_ID[14],OBJ_ID[15]}^
							OBJ_H[0]^OBJ_H[1]^OBJ_H[2]^OBJ_H[3]^OBJ_H[4]^OBJ_H[5]^OBJ_H[6]^OBJ_H[7]^OBJ_H[8]^OBJ_H[9]^OBJ_H[10]^OBJ_H[11]^OBJ_H[12]^OBJ_H[13]^OBJ_H[14]^OBJ_H[15]^
							OBJ_X[0]^OBJ_X[1]^OBJ_X[2]^OBJ_X[3]^OBJ_X[4]^OBJ_X[5]^OBJ_X[6]^OBJ_X[7]^OBJ_X[8]^OBJ_X[9]^OBJ_X[10]^OBJ_X[11]^OBJ_X[12]^OBJ_X[13]^OBJ_X[14]^OBJ_X[15]^
							OBJ_Y[0]^OBJ_Y[1]^OBJ_Y[2]^OBJ_Y[3]^OBJ_Y[4]^OBJ_Y[5]^OBJ_Y[6]^OBJ_Y[7]^OBJ_Y[8]^OBJ_Y[9]^OBJ_Y[10]^OBJ_Y[11]^OBJ_Y[12]^OBJ_Y[13]^OBJ_Y[14]^OBJ_Y[15];
`endif
	
endmodule
