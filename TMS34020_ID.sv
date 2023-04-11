import TMS34020_PKG::*;

module TMS34020_ID
 (
	input              CLK,
	input              RST_N,
	input              EN,
	
	input              CE_F,
	input              CE_R,
	
	input      [15: 0] IC,
	input      [ 4: 0] STATE,
	input              MD_COND,
	input              MD_NEG,
	input              DIV_V,
	input              J_COND,
	input              DS_COND,
	input              MM_COND,
	input              FE0,
	input              FE1,
	input              RP_COND,
	input              LINE_GZ,
	input              LINE_COND,
	input              PIX_XEND,
	input              PIX_YEND,
	input              PIX_WINEN,
	input      [ 3: 0] PIX_WINCC,
	input              PIX_BL,
	input              PIX_WE,
	
	output DecInstr_t  DECI
);
	
	always_comb begin		
		DECI.RD = IC[3:0];
		DECI.RS = IC[3:0];
		DECI.R = IC[4];
		DECI.M = 0;
		DECI.F = IC[9];
		DECI.AIA = '{IMM_K, CV_0, AS_REGA, EO_NONE};
		DECI.AIB = '{IMM_K, CV_0, AS_REGB, EO_NONE};
		DECI.FT = '{FSI_32, 1'b0};
		DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
		DECI.SHC = '{SS_NONE, 3'b000};
		DECI.MDC = '{MDO_NOP, MDA_NOP, MDSH_NOP};
		DECI.IWL = IW_NONE;
		DECI.MC = '{MAS_RA, MDS_REGA, MA_NONE, MT_DATA};
		DECI.MMS = 0;
		DECI.MMA = 0;
		DECI.RWA = '{RS_REGA, 1'b0};
		DECI.RWB = '{RS_REGA, 1'b0};
		DECI.JC = JC_NONE;
		DECI.PALU = '{PIXOP_NOP, PIXAS_REGA, CNVS_NO};
		DECI.PF = '{PBLT_NONE, POFFS_NONE, WIN_NONE, PLN_NONE};
		DECI.PIXO = '{PATS_NULL};
		DECI.STW = {STU_NONE, 4'b0000};
		DECI.PCS = PCS_NONE;
		DECI.PCW = 1;
		DECI.NST = STATE + 5'd1;
		DECI.LST = 1;
		DECI.ILI = 0;
		case (IC[15:12])
			4'b0000:	begin 
				casex (IC[11:8])
					4'b0000:	begin 
						casex (IC[7:4])
							4'b001x:	begin //REV Rd (REV->Rd)
								DECI.RWA = '{RS_REV, 1'b1};
							end
							4'b1000:	begin //MWAIT	(*Rd)
								DECI.AIA = '{IMM_K, CV_0, AS_IMM, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0, AS_IMM, EO_NONE};
								DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
								DECI.MC = '{MAS_RA, MDS_REGA, MA_READ, MT_DATA};
							end
							default: DECI.ILI = 1;
						endcase
					end
					
					4'b0001:	begin 
						casex (IC[7:4])
//							4'b000x:	begin //EMU
//								
//							end
							4'b001x:	begin //EXGPC Rd (PC->Rd,Rd->PC)
								case (STATE)
								5'd0: begin
									DECI.RWA = '{RS_PC, 1'b1};
									DECI.JC = JC_JUMP;
									DECI.PCS = PCS_REG;
								end
								default: begin
									DECI.LST = 1;
								end
								endcase
							end
							4'b010x:	begin //GETPC Rd (PC->Rd)
								DECI.RWA = '{RS_PC, 1'b1};
							end
							4'b011x:	begin //JUMP Rs (Rs->PC)
								case (STATE)
								5'd0: begin
									DECI.JC = JC_JUMP;
									DECI.PCS = PCS_REG;
									DECI.LST = 0;
								end
								default: begin
									DECI.LST = 1;
								end
								endcase
							end
							4'b100x:	begin //GETST Rd (ST->Rd)
								DECI.RWA = '{RS_ST, 1'b1};
							end
							4'b101x:	begin //PUTST Rs (Rs->ST)
								case (STATE)
								5'd0: begin
									DECI.STW = {STU_ST, 4'b0000};
									DECI.LST = 0;
								end
								5'd1: begin
									DECI.LST = 0;
								end
								default: begin
									DECI.LST = 1;
								end
								endcase
							end
							4'b1100:	begin //POPST
								case (STATE)
								5'd0: begin	//SP+32->SP,*SP->BUF
									DECI.RD = 4'hF;
									DECI.AIA = '{IMM_K, CV_0 , AS_REGA , EO_NONE};
									DECI.AIB = '{IMM_K, CV_32, AS_CONST, EO_NONE};
									DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
									DECI.RWA = '{RS_ALU, 1'b1};
									DECI.MC = '{MAS_RA, MDS_REGA, MA_READ, MT_DATA};
									DECI.LST = 0;
								end
								5'd1: begin	//BUF->ST
									DECI.STW = {STU_MEM, 4'b0000};
									DECI.LST = 0;
								end
								5'd2: begin	
									DECI.LST = 0;
								end
								default: begin
									DECI.LST = 1;
								end
								endcase
							end
							4'b1110:	begin //PUSHST
								case (STATE)
								5'd0: begin	//SP-32-0->ALUR
									DECI.RD = 4'hF;
									DECI.AIA = '{IMM_K, CV_0 , AS_REGA , EO_NONE};
									DECI.AIB = '{IMM_K, CV_32, AS_CONST, EO_NONE};
									DECI.ALU = '{ALUOP_ADD, 4'b0001, 1'b1};
									DECI.RWA = '{RS_ALU, 1'b1};
									DECI.LST = 0;
								end
								default: begin	//ST->*ALUR
									DECI.RD = 4'hF;
									DECI.MC = '{MAS_RA, MDS_ST, MA_WRITE, MT_DATA};
									DECI.LST = 1;
								end
								endcase
							end
							default: DECI.ILI = 1;
						endcase
					end
					
					4'b0010:	begin 
						casex (IC[7:4])
							4'b010x,			//SETCSP Rd
							4'b011x,			//SETCDP Rd
							4'b111x:	begin	//SETCMP Rd
								case (STATE) //TODO
								5'd0: begin
									DECI.LST = 0;
								end
								default: begin //(Rd->*IO)
									DECI.MC = '{MAS_IO, MDS_REGA, MA_WRITE, MT_DATA};
									DECI.LST = 1;
								end
								endcase
							end
							4'b100x:	begin //RPIX Rd
								case (STATE)
								5'd0: begin
									DECI.LST = 0;
								end
								5'd1: begin
									DECI.LST = RP_COND;
								end
								5'd2: begin
									DECI.LST = 0;
								end
								5'd3: begin //((Rd<<16)|Rd->Rd)
									DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
									DECI.AIB = '{IMM_K, CV_16, AS_REGB, EO_NONE};
									DECI.ALU = '{ALUOP_LOG, 4'b0010, 1'b0};
									DECI.SHC = '{SS_CONST, 3'b000};
									DECI.RWA = '{RS_ALU, 1'b1};
									DECI.LST = RP_COND;
								end
								5'd4: begin //((Rd<<8)|Rd->Rd)
									DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
									DECI.AIB = '{IMM_K, CV_8 , AS_REGB, EO_NONE};
									DECI.ALU = '{ALUOP_LOG, 4'b0010, 1'b0};
									DECI.SHC = '{SS_CONST, 3'b000};
									DECI.RWA = '{RS_ALU, 1'b1};
									DECI.LST = RP_COND;
								end
								5'd5: begin //((Rd<<4)|Rd->Rd)
									DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
									DECI.AIB = '{IMM_K, CV_4 , AS_REGB, EO_NONE};
									DECI.ALU = '{ALUOP_LOG, 4'b0010, 1'b0};
									DECI.SHC = '{SS_CONST, 3'b000};
									DECI.RWA = '{RS_ALU, 1'b1};
									DECI.LST = RP_COND;
								end
								5'd6: begin //((Rd<<2)|Rd->Rd)
									DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
									DECI.AIB = '{IMM_K, CV_2 , AS_REGB, EO_NONE};
									DECI.ALU = '{ALUOP_LOG, 4'b0010, 1'b0};
									DECI.SHC = '{SS_CONST, 3'b000};
									DECI.RWA = '{RS_ALU, 1'b1};
									DECI.LST = RP_COND;
								end
								default: begin //((Rd<<1)|Rd->Rd)
									DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
									DECI.AIB = '{IMM_K, CV_1 , AS_REGB, EO_NONE};
									DECI.ALU = '{ALUOP_LOG, 4'b0010, 1'b0};
									DECI.SHC = '{SS_CONST, 3'b000};
									DECI.RWA = '{RS_ALU, 1'b1};
									DECI.LST = 1;
								end
								endcase
							end
							4'b101x:	begin //EXGPS Rd
								case (STATE)
								5'd0: begin
									DECI.LST = 0;
								end
								default: begin //(0+PS->Rd,Rd->*ALUR)
									DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
									DECI.AIB = '{IMM_K, CV_0 , AS_PS   , EO_NONE};
									DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
									DECI.RWA = '{RS_ALU, 1'b1};
									DECI.MC = '{MAS_IO, MDS_REGA, MA_WRITE, MT_DATA};
									DECI.LST = 1;
								end
								endcase
							end
							4'b110x:	begin //GETPS Rd
								case (STATE)
								5'd0: begin
									DECI.LST = 0;
								end
								default: begin //(0+PS->Rd)
									DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
									DECI.AIB = '{IMM_K, CV_0 , AS_PS   , EO_NONE};
									DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
									DECI.RWA = '{RS_ALU, 1'b1};
									DECI.LST = 1;
								end
								endcase
							end
							default: DECI.ILI = 1;
						endcase
					end
					
					4'b0011:	begin 
						casex (IC[7:4])
							4'b0000:	begin //NOP
							end
							4'b0010:	begin //CLRC
								DECI.STW = {STU_C, 4'b0000};
							end
							4'b0100:	begin  //MOVB @SAddr,@DAddr
								case (STATE)
								5'd0: begin //
									DECI.IWL = IW_LONG;
									DECI.LST = 0;
								end
								5'd1: begin //(*IL->BUF)
									DECI.FT = '{FSI_8, 1'b0};
									DECI.MC = '{MAS_IL, MDS_REGA, MA_READ, MT_DATA};
									DECI.LST = 0;
								end
								5'd2: begin //
									DECI.IWL = IW_LONG;
									DECI.LST = 0;
								end
								default: begin //(BUF->*IL)
									DECI.FT = '{FSI_8, 1'b0};
									DECI.MC = '{MAS_IL, MDS_MEM, MA_WRITE, MT_DATA};
									DECI.LST = 1;
								end
								endcase
							end
							4'b0110:	begin //DINT
								case (STATE)
									5'd0: begin
										DECI.STW = {STU_IE, 4'b0000};
										DECI.LST = 0;
									end
									5'd1: begin
										DECI.LST = 0;
									end
									default: begin
										DECI.LST = 1;
									end
								endcase
							end
							
							4'b100x:	begin //ABS Rd (abs(Rd)->Rd)
								DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_REGA , EO_NONE};
								DECI.ALU = '{ALUOP_ADD, 4'b0100, 1'b1};
								DECI.RWA = '{RS_ALU, 1'b1};
								DECI.STW = {STU_ALU, AFU_NZV};
							end
							4'b101x, 		//NEG Rd (0-Rd->Rd)
							4'b110x:	begin //NEGB Rd (0-Rd-C->Rd)
								DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_REGA , EO_NONE};
								DECI.ALU = '{ALUOP_ADD, {2'b00,IC[6],1'b1}, 1'b1};
								DECI.RWA = '{RS_ALU, 1'b1};
								DECI.STW = {STU_ALU, AFU_NCZV};
							end
							4'b111x:	begin //NOT Rd (~Rd->Rd)
								DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_REGA , EO_NONE};
								DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b1};
								DECI.RWA = '{RS_ALU, 1'b1};
								DECI.STW = {STU_ALU, AFU_Z};
							end
							default: DECI.ILI = 1;
						endcase
					end
			
					4'b01x1:	begin 
						casex (IC[7:4])
							4'b000x:	begin //SEXT Rd,F
								case (STATE)
									5'd0: begin	//(extu(Rd)+0+0->Rd)
										DECI.AIA = '{IMM_K, CV_0 , AS_REGA , EO_ZERO};
										DECI.AIB = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
										DECI.FT = '{FSI_F, 1'b0};
										DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
										DECI.RWA = '{RS_ALU, 1'b1};
										DECI.STW = {STU_ALU, AFU_NZ};
										DECI.LST = 0;
									end
									default: begin	//(exts(Rd)+0+0->Rd)
										DECI.AIA = '{IMM_K, CV_0 , AS_REGA , EO_SIGN};
										DECI.AIB = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
										DECI.FT = '{FSI_F, 1'b0};
										DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
										DECI.RWA = '{RS_ALU, 1'b1};////////////////////
										DECI.STW = {STU_ALU, AFU_NZ};
										DECI.LST = 1;
									end
								endcase
							end
							4'b001x:	begin //ZEXT Rd,F
								case (STATE)
									default: begin	//(extu(Rd)+0+0->Rd)
										DECI.AIA = '{IMM_K, CV_0 , AS_REGA , EO_ZERO};
										DECI.AIB = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
										DECI.FT = '{FSI_F, 1'b0};
										DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
										DECI.RWA = '{RS_ALU, 1'b1};
										DECI.STW = {STU_ALU, AFU_Z};
										DECI.LST = 1;
									end
								endcase
							end
							4'b01xx:	begin //SETF FS,FE,F
								DECI.STW = {STU_FS, 4'b0000};
							end
							4'b100x:	begin  //MOVE Rd,@DAddr,F
								case (STATE)
									5'd0: begin //
										DECI.IWL = IW_LONG;
										DECI.LST = 0;
									end
									default: begin //(Rs->*IL)
										DECI.FT = '{FSI_F, 1'b0};
										DECI.MC = '{MAS_IL, MDS_REGA, MA_WRITE, MT_DATA};
										DECI.LST = 1;
									end
								endcase
							end
							4'b101x:	begin  //MOVE @SAddr,Rd,F
								case (STATE)
									5'd0: begin //
										DECI.IWL = IW_LONG;
										DECI.LST = 0;
									end
									5'd1: begin //(*IL->BUF)
										DECI.FT = '{FSI_F, 1'b0};
										DECI.MC = '{MAS_IL, MDS_REGA, MA_READ, MT_DATA};
										DECI.LST = 0;
									end
									5'd2: begin //(BUF->Rd)
										DECI.FT = '{FSI_F, 1'b0};
										DECI.ALU = '{ALUOP_MOV, 4'b0000, 1'b0};
										DECI.RWA = '{RS_MEM, 1'b1};
										DECI.STW = {STU_ALU, AFU_NZ};
										DECI.LST = !IC[9] ? ~FE0 : ~FE1;
									end
									default: begin //(exts(Rd)+0+0->Rd)
										DECI.AIA = '{IMM_K, CV_0 , AS_REGA , EO_SIGN};
										DECI.AIB = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
										DECI.FT = '{FSI_F, 1'b0};
										DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
										DECI.RWA = '{RS_ALU, 1'b1};////////////////////
										DECI.STW = {STU_ALU, AFU_NZ};
										DECI.LST = 1;
									end
								endcase
							end
							4'b110x:	begin  //MOVE @SAddr,@DAddr,F
								case (STATE)
									5'd0: begin //
										DECI.IWL = IW_LONG;
										DECI.LST = 0;
									end
									5'd1: begin //(*IL->BUF)
										DECI.FT = '{FSI_F, 1'b0};
										DECI.MC = '{MAS_IL, MDS_REGA, MA_READ, MT_DATA};
										DECI.LST = 0;
									end
									5'd2: begin //
										DECI.IWL = IW_LONG;
										DECI.LST = 0;
									end
									default: begin //(BUF->*IL)
										DECI.FT = '{FSI_F, 1'b0};
										DECI.MC = '{MAS_IL, MDS_MEM, MA_WRITE, MT_DATA};
										DECI.LST = 1;
									end
								endcase
							end
							4'b111x:	begin  //MOVB @Addr,Rd; MOVB Rd,@Addr
								case (STATE)
									5'd0: begin //
										DECI.IWL = IW_LONG;
										DECI.LST = 0;
									end
									5'd1: begin
										DECI.FT = '{FSI_8, 1'b1};
										if (!IC[9]) begin //(Rs->*IL)
											DECI.MC = '{MAS_IL, MDS_REGA, MA_WRITE, MT_DATA};
											DECI.LST = 1;
										end else begin //(*IL->BUF)
											DECI.MC = '{MAS_IL, MDS_REGA, MA_READ, MT_DATA};
											DECI.LST = 0;
										end
									end
									5'd2: begin //(BUF->Rd)
										DECI.FT = '{FSI_8, 1'b1};
										DECI.ALU = '{ALUOP_MOV, 4'b0000, 1'b0};
										DECI.RWA = '{RS_MEM, 1'b1};
										DECI.STW = {STU_ALU, AFU_NZ};
										DECI.LST = 0;
									end
									default: begin //(exts(Rd)+0+0->Rd)
										DECI.AIA = '{IMM_K, CV_0 , AS_REGA , EO_SIGN};
										DECI.AIB = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
										DECI.FT = '{FSI_8, 1'b1};
										DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
										DECI.RWA = '{RS_ALU, 1'b1};////////////////////
										DECI.STW = {STU_ALU, AFU_NZ};
										DECI.LST = 1;
									end
								endcase
							end
							default: DECI.ILI = 1;
						endcase
					end
			
					4'b1000:	begin 
						casex (IC[7:4])
							4'b0000:	begin //TRAPL N
								case (STATE)
									5'd0: begin	//SP-32-0->SP
										DECI.RD = 4'hF;
										DECI.AIA = '{IMM_K, CV_0 , AS_REGA , EO_NONE};
										DECI.AIB = '{IMM_K, CV_32, AS_CONST, EO_NONE};
										DECI.ALU = '{ALUOP_ADD, 4'b0001, 1'b1};
										DECI.RWA = '{RS_ALU, 1'b1};
										DECI.LST = 0;
									end
									5'd1: begin	//PC->*SP,SP-32-0->SP
										DECI.RD = 4'hF;
										DECI.AIA = '{IMM_K, CV_0 , AS_REGA , EO_NONE};
										DECI.AIB = '{IMM_K, CV_32, AS_CONST, EO_NONE};
										DECI.ALU = '{ALUOP_ADD, 4'b0001, 1'b1};
										DECI.RWA = '{RS_ALU, 1'b1};
										DECI.MC = '{MAS_RA, MDS_PC, MA_WRITE, MT_DATA};
										DECI.LST = 0;
									end
									5'd2: begin	//ST->*SP
										DECI.RD = 4'hF;
										DECI.MC = '{MAS_RA, MDS_ST, MA_WRITE, MT_DATA};
										DECI.LST = 0;
									end
									5'd3: begin	//0x00000010->ST
										DECI.STW = {STU_RES, 4'b0000};
										DECI.IWL = IW_WORD;
										DECI.LST = 0;
									end
									5'd4: begin	//*IW->BUF
										DECI.MC = '{MAS_IL, MDS_REGA, MA_READ, MT_DATA};/////////////////////////////
										DECI.LST = 0;
									end
									5'd5: begin //BUF->PC
										DECI.PCS = PCS_MEM;
										DECI.LST = 0;
									end
									default: begin
										DECI.LST = 1;
									end
								endcase
							end
							default: DECI.ILI = 1;
						endcase
					end
			
					4'b1001:	begin 
						casex (IC[7:4])
							4'b000x:	begin //TRAP N
								case (STATE)
									5'd0: begin	//
										DECI.NST = IC[5:0] == 5'd0 ? 3'd5 : STATE + 5'd1;
										DECI.LST = 0;
									end
									5'd1: begin	//SP-32->SP
										DECI.RD = 4'hF;
										DECI.AIA = '{IMM_K, CV_0 , AS_REGA , EO_NONE};
										DECI.AIB = '{IMM_K, CV_32, AS_CONST, EO_NONE};
										DECI.ALU = '{ALUOP_ADD, 4'b0001, 1'b1};
										DECI.RWA = '{RS_ALU, 1'b1};
										DECI.LST = 0;
									end
									5'd2: begin	//PC->*SP
										DECI.RD = 4'hF;
										DECI.MC = '{MAS_RA, MDS_PC, MA_WRITE, MT_DATA};
										DECI.LST = 0;
									end
									5'd3: begin	//SP-32->SP
										DECI.RD = 4'hF;
										DECI.AIA = '{IMM_K, CV_0 , AS_REGA , EO_NONE};
										DECI.AIB = '{IMM_K, CV_32, AS_CONST, EO_NONE};
										DECI.ALU = '{ALUOP_ADD, 4'b0001, 1'b1};
										DECI.RWA = '{RS_ALU, 1'b1};
										DECI.LST = 0;
									end
									5'd4: begin	//ST->*SP
										DECI.RD = 4'hF;
										DECI.MC = '{MAS_RA, MDS_ST, MA_WRITE, MT_DATA};
										DECI.LST = 0;
									end
									5'd5: begin	//0x00000010->ST
										DECI.STW = {STU_RES, 4'b0000};
										DECI.LST = 0;
									end
									5'd6: begin	//*VEC->BUF
										DECI.MC = '{MAS_VEC, MDS_REGA, MA_READ, MT_DATA};
										DECI.LST = 0;
									end
									5'd7: begin //BUF->PC
										DECI.PCS = PCS_MEM;
										DECI.LST = 0;
									end
									default: begin
										DECI.LST = 1;
									end
								endcase
							end
							4'b001x:	begin //CALL Rs
								case (STATE)
									5'd0: begin	//SP-32->SP
										DECI.RD = 4'hF;
										DECI.AIA = '{IMM_K, CV_0 , AS_REGA , EO_NONE};
										DECI.AIB = '{IMM_K, CV_32, AS_CONST, EO_NONE};
										DECI.ALU = '{ALUOP_ADD, 4'b0001, 1'b1};
										DECI.RWA = '{RS_ALU, 1'b1};
										DECI.LST = 0;
									end
									5'd1: begin	//PC->*SP,Rs->PC
										DECI.RD = 4'hF;
										DECI.MC = '{MAS_RA, MDS_PC, MA_WRITE, MT_DATA};
										DECI.PCS = PCS_REG;
										DECI.LST = 0;
									end
									default: begin
										DECI.LST = 1;
									end
								endcase
							end
							
							4'b0100:	begin //RETI
								case (STATE)
									5'd0: begin	//*SP->BUF,SP+32->SP
										DECI.RD = 4'hF;
										DECI.AIA = '{IMM_K, CV_0 , AS_REGA , EO_NONE};
										DECI.AIB = '{IMM_K, CV_32, AS_CONST, EO_NONE};
										DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
										DECI.RWA = '{RS_ALU, 1'b1};
										DECI.MC = '{MAS_RA, MDS_REGA, MA_READ, MT_DATA};
										DECI.LST = 0;
									end
									5'd1: begin	//*SP->BUF,SP+32->SP,BUF->ST
										DECI.RD = 4'hF;
										DECI.AIA = '{IMM_K, CV_0 , AS_REGA , EO_NONE};
										DECI.AIB = '{IMM_K, CV_32, AS_CONST, EO_NONE};
										DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
										DECI.RWA = '{RS_ALU, 1'b1};
										DECI.MC = '{MAS_RA, MDS_REGA, MA_READ, MT_DATA};
										DECI.STW = {STU_MEM, 4'b0000};
										DECI.LST = 0;
									end
									5'd2: begin	//BUF->PC
										DECI.PCS = PCS_MEM;
										DECI.LST = 0;
									end
									default: begin
										DECI.LST = 1;
									end
								endcase
							end
							
							4'b011x:	begin //RETS N
								case (STATE)
									5'd0: begin	//*SP->BUF,SP+32->SP
										DECI.RD = 4'hF;
										DECI.AIA = '{IMM_K, CV_0 , AS_REGA , EO_NONE};
										DECI.AIB = '{IMM_K, CV_32, AS_CONST, EO_NONE};
										DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
										DECI.RWA = '{RS_ALU, 1'b1};
										DECI.MC = '{MAS_RA, MDS_REGA, MA_READ, MT_DATA};
										DECI.LST = 0;
									end
									5'd1: begin	//BUF->PC
										DECI.PCS = PCS_MEM;
										DECI.LST = 0;
									end
									default: begin
										DECI.LST = 1;
									end
								endcase
							end
							4'b100x:	begin //MMTM Rs,List
								case (STATE)
									5'd0: begin
										DECI.IWL = IW_WORD;
										DECI.LST = 0;
									end
									5'd1: begin
										DECI.MMS = 1;
										DECI.LST = 0;
									end
									5'd2: begin	//Rs-32->Rs
										DECI.AIA = '{IMM_K, CV_0 , AS_REGA , EO_NONE};
										DECI.AIB = '{IMM_K, CV_32, AS_CONST, EO_NONE};
										DECI.ALU = '{ALUOP_ADD, 4'b0001, 1'b1};
										DECI.RWA = '{RS_ALU, ~MM_COND};
//										DECI.MMA = 1;
										DECI.LST = MM_COND;
									end
									default: begin	//Rs-32->Rs,RB->*ALUR
										DECI.MC = '{MAS_RA, MDS_REGB, MA_WRITE, MT_DATA};
										DECI.MMA = 1;
										DECI.NST = !MM_COND ? 5'd2 : STATE + 5'd1;
										DECI.LST = MM_COND;
									end
								endcase
							end
							4'b101x:	begin //MMFM Rs,List
								case (STATE)
									5'd0: begin
										DECI.IWL = IW_WORD;
										DECI.LST = 0;
									end
									5'd1: begin
										DECI.MMS = 1;
										DECI.LST = 0;
									end
									5'd2: begin	//*Rs->RB,Rs+32->Rs
										DECI.AIA = '{IMM_K, CV_0 , AS_REGA , EO_NONE};
										DECI.AIB = '{IMM_K, CV_32, AS_CONST, EO_NONE};
										DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
										DECI.RWA = '{RS_ALU, ~MM_COND};
										DECI.MC = '{MAS_RA, MDS_REGA, MA_READ, MT_DATA};
										DECI.LST = MM_COND;
									end
									default: begin
										DECI.ALU = '{ALUOP_MOV, 4'b0000, 1'b0};
										DECI.RWB = '{RS_MEM, 1'b1};
										DECI.MMA = 1;
										DECI.NST = !MM_COND ? 5'd2 : STATE + 5'd1;
										DECI.LST = MM_COND;
									end
								endcase
							end
							4'b110x, 		//MOVI IW,Rd 
							4'b111x:	begin //MOVI IL,Rd 
								case (STATE)
									5'd0: begin
										DECI.IWL = !IC[5] ? IW_WORD : IW_LONG;
										DECI.LST = 0;
									end
									default: begin //(0+IW/IL->Rd)
										DECI.AIA = '{IMM_K , CV_0 , AS_CONST, EO_NONE};
										if (!IC[5])
											DECI.AIB = '{IMM_IW, CV_0 , AS_IMM  , EO_NONE};
										else
											DECI.AIB = '{IMM_IL, CV_0 , AS_IMM  , EO_NONE};
										DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
										DECI.RWA = '{RS_ALU, 1'b1};
										DECI.STW = {STU_ALU, AFU_NZ};
										DECI.LST = 1;
									end
								endcase
							end
							default: DECI.ILI = 1;
						endcase
					end
			
					4'b1010:	begin 
						casex (IC[7:4])
							4'b011x, 		//CVMXYL Rd
							4'b100x:	begin //CVDXYL Rd
								case (STATE)
									5'd0: begin //XYToL(Rd.XY)->Rd
										DECI.AIA = '{IMM_K, CV_0 , AS_PIX  , EO_NONE};
										DECI.AIB = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
										DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
										DECI.PALU = '{PIXOP_XYL, PIXAS_REGA, !IC[7] ? CNVS_MP : CNVS_DP};
										DECI.RWA = '{RS_ALU, 1'b1};
										DECI.LST = 0;
									end
									default: begin //(Rd+R4->Rd)
										DECI.RS = 4'h4;
										DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
										DECI.AIB = '{IMM_K, CV_0 , AS_REGB, EO_NONE};
										DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
										DECI.RWA = '{RS_ALU, 1'b1};
										DECI.LST = 1;
									end
								endcase
							end
							default: DECI.ILI = 1;
						endcase
					end
			
					4'b1011:	begin 
						casex (IC[7:4])
							4'b000x, 		//ADDI IW,Rd 
							4'b010x:	begin //CMPI IW,Rd 
								case (STATE)
									5'd0: begin
										DECI.IWL = IW_WORD;
										DECI.LST = 0;
									end
									default: begin //(Rd+IW->Rd)
										DECI.AIA = '{IMM_K , CV_0 , AS_REGA, EO_NONE};
										DECI.AIB = '{IMM_IW, CV_0 , AS_IMM , EO_NONE};
										DECI.ALU = '{ALUOP_ADD, {3'b000,IC[6]}, 1'b0};
										DECI.RWA = '{RS_ALU, ~IC[6]};
										DECI.STW = {STU_ALU, AFU_NCZV};
										DECI.LST = 1;
									end
								endcase
							end
							4'b001x, 		//ADDI IL,Rd 
							4'b011x:	begin //CMPI IL,Rd 
								case (STATE)
									5'd0: begin
										DECI.IWL = IW_LONG;
										DECI.LST = 0;
									end
									default: begin //(Rd+IL->Rd)
										DECI.AIA = '{IMM_K , CV_0 , AS_REGA, EO_NONE};
										DECI.AIB = '{IMM_IL, CV_0 , AS_IMM , EO_NONE};
										DECI.ALU = '{ALUOP_ADD, {3'b000,IC[6]}, 1'b0};
										DECI.RWA = '{RS_ALU, ~IC[6]};
										DECI.STW = {STU_ALU, AFU_NCZV};
										DECI.LST = 1;
									end
								endcase
							end
//							4'b010x:	begin //CMPI IW,Rd 
//								case (STATE)
//									5'd0: begin
//										DECI.IWL = IW_WORD;
//										DECI.LST = 0;
//									end
//									default: begin //(Rd-IW)
//										DECI.AIA = '{IMM_K , CV_0 , AS_REGA, EO_NONE};
//										DECI.AIB = '{IMM_IW, CV_0 , AS_IMM , EO_NONE};
//										DECI.ALU = '{ALUOP_ADD, 4'b0001, 1'b0};
//										DECI.STW = {STU_ALU, AFU_NCZV};
//										DECI.LST = 1;
//									end
//								endcase
//							end
//							4'b011x:	begin //CMPI IL,Rd 
//								case (STATE)
//									5'd0: begin
//										DECI.IWL = IW_LONG;
//										DECI.LST = 0;
//									end
//									default: begin //(Rd-IL)
//										DECI.AIA = '{IMM_K , CV_0 , AS_REGA, EO_NONE};
//										DECI.AIB = '{IMM_IL, CV_0 , AS_IMM , EO_NONE};
//										DECI.ALU = '{ALUOP_ADD, 4'b0001, 1'b0};
//										DECI.STW = {STU_ALU, AFU_NCZV};
//										DECI.LST = 1;
//									end
//								endcase
//							end
							4'b100x, 		//ANDI IL,Rd 
							4'b101x, 		//ORI IL,Rd 
							4'b110x:	begin //XORI IL,Rd 
								case (STATE)
									5'd0: begin
										DECI.IWL = IW_LONG;
										DECI.LST = 0;
									end
									default: begin //(Rd&~IL->Rd)
										DECI.AIA = '{IMM_K , CV_0 , AS_REGA, EO_NONE};
										DECI.AIB = '{IMM_IL, CV_0 , AS_IMM , EO_NONE};
										DECI.ALU = '{ALUOP_LOG, {1'b0,IC[6:5],~|IC[6:5]}, 1'b0};
										DECI.RWA = '{RS_ALU, 1'b1};
										DECI.STW = {STU_ALU, AFU_Z};
										DECI.LST = 1;
									end
								endcase
							end
//							4'b101x:	begin //ORI IL,Rd 
//								case (STATE)
//									5'd0: begin
//										DECI.IWL = IW_LONG;
//										DECI.LST = 0;
//									end
//									default: begin //(Rd|IL->Rd)
//										DECI.AIA = '{IMM_K , CV_0 , AS_REGA, EO_NONE};
//										DECI.AIB = '{IMM_IL, CV_0 , AS_IMM , EO_NONE};
//										DECI.ALU = '{ALUOP_LOG, 4'b0010, 1'b0};
//										DECI.RWA = '{RS_ALU, 1'b1};
//										DECI.STW = {STU_ALU, AFU_Z};
//										DECI.LST = 1;
//									end
//								endcase
//							end
//							4'b110x:	begin //XORI IL,Rd 
//								case (STATE)
//									5'd0: begin
//										DECI.IWL = IW_LONG;
//										DECI.LST = 0;
//									end
//									default: begin //(Rd^IL->Rd)
//										DECI.AIA = '{IMM_K , CV_0 , AS_REGA, EO_NONE};
//										DECI.AIB = '{IMM_IL, CV_0 , AS_IMM , EO_NONE};
//										DECI.ALU = '{ALUOP_LOG, 4'b0100, 1'b0};
//										DECI.RWA = '{RS_ALU, 1'b1};
//										DECI.STW = {STU_ALU, AFU_Z};
//										DECI.LST = 1;
//									end
//								endcase
//							end
							4'b111x:	begin //SUBI IW,Rd 
								case (STATE)
									5'd0: begin
										DECI.IWL = IW_WORD;
										DECI.LST = 0;
									end
									default: begin //(Rd-IW->Rd)
										DECI.AIA = '{IMM_K , CV_0 , AS_REGA, EO_NONE};
										DECI.AIB = '{IMM_IW, CV_0 , AS_IMM , EO_NONE};
										DECI.ALU = '{ALUOP_ADD, 4'b0001, 1'b0};
										DECI.RWA = '{RS_ALU, 1'b1};
										DECI.STW = {STU_ALU, AFU_NCZV};
										DECI.LST = 1;
									end
								endcase
							end
						endcase
					end
			
					4'b1100:	begin 
						casex (IC[7:4])
							4'b000x:	begin //ADDXYI IL,Rd 
								case (STATE)
									5'd0: begin
										DECI.IWL = IW_LONG;
										DECI.LST = 0;
									end
									default: begin //(Rd.XY+IL->Rd.XY)
										DECI.AIA = '{IMM_K , CV_0 , AS_REGA, EO_NONE};
										DECI.AIB = '{IMM_IL, CV_0 , AS_IMM , EO_NONE};
										DECI.ALU = '{ALUOP_ADDXY, 4'b0000, 1'b0};
										DECI.RWA = '{RS_ALU, 1'b1};
										DECI.STW = {STU_ALU, AFU_NCZV};
										DECI.LST = 1;
									end
								endcase
							end
							4'b0101:	begin
							
							end
							default: DECI.ILI = 1;
						endcase
					end
			
					4'b1101:	begin 
						casex (IC[7:4])
							4'b000x:	begin //SUBI IL,Rd 
								case (STATE)
									5'd0: begin
										DECI.IWL = IW_LONG;
										DECI.LST = 0;
									end
									default: begin //(Rd-IL->Rd)
										DECI.AIA = '{IMM_K , CV_0 , AS_REGA, EO_NONE};
										DECI.AIB = '{IMM_IL, CV_0 , AS_IMM , EO_NONE};
										DECI.ALU = '{ALUOP_ADD, 4'b0001, 1'b0};
										DECI.RWA = '{RS_ALU, 1'b1};
										DECI.STW = {STU_ALU, AFU_NCZV};
										DECI.LST = 1;
									end
								endcase
							end
							4'b0011:	begin //CALLR Addr
								case (STATE)
									5'd0: begin	//SP-32->SP
										DECI.RD = 4'hF;
										DECI.AIA = '{IMM_K, CV_0 , AS_REGA , EO_NONE};
										DECI.AIB = '{IMM_K, CV_32, AS_CONST, EO_NONE};
										DECI.ALU = '{ALUOP_ADD, 4'b0001, 1'b1};
										DECI.RWA = '{RS_ALU, 1'b1};
										DECI.IWL = IW_WORD;
										DECI.LST = 0;
									end
									5'd1: begin	//PC->*SP,PC+IW->PC
										DECI.RD = 4'hF;
										DECI.MC = '{MAS_RA, MDS_PC, MA_WRITE, MT_DATA};
										DECI.PCS = PCS_IW;
										DECI.LST = 0;
									end
									default: begin
										DECI.LST = 1;
									end
								endcase
							end
							4'b0101:	begin //CALLA Addr
								case (STATE)
									5'd0: begin	//SP-32->SP
										DECI.RD = 4'hF;
										DECI.AIA = '{IMM_K, CV_0 , AS_REGA , EO_NONE};
										DECI.AIB = '{IMM_K, CV_32, AS_CONST, EO_NONE};
										DECI.ALU = '{ALUOP_ADD, 4'b0001, 1'b1};
										DECI.RWA = '{RS_ALU, 1'b1};
										DECI.IWL = IW_LONG;
										DECI.LST = 0;
									end
									5'd1: begin	//PC->*SP,IL->PC
										DECI.RD = 4'hF;
										DECI.MC = '{MAS_RA, MDS_PC, MA_WRITE, MT_DATA};
										DECI.PCS = PCS_IL;
										DECI.LST = 0;
									end
									default: begin
										DECI.LST = 1;
									end
								endcase
							end
							
							4'b0110:	begin //EINT
								case (STATE)
									5'd0: begin
										DECI.STW = {STU_IE, 4'b0000};
										DECI.LST = 0;
									end
									5'd1: DECI.LST = 0;
									default: DECI.LST = 1;
								endcase
							end
							
							4'b100x:	begin //DSJ Rd,Addr
								case (STATE)
									5'd0: begin	//Rd-1->Rd
										DECI.AIA = '{IMM_K, CV_0 , AS_REGA , EO_NONE};
										DECI.AIB = '{IMM_K, CV_1 , AS_CONST, EO_NONE};
										DECI.ALU = '{ALUOP_ADD, 4'b0001, 1'b1};
										DECI.RWA = '{RS_ALU, 1'b1};
										DECI.IWL = IW_WORD;
										DECI.LST = 0;
									end
									5'd1: begin	//PC+IW->PC
										DECI.JC = JC_DS;
										DECI.PCS = PCS_IW;
										DECI.LST = ~DS_COND;
									end
									default: begin
										DECI.LST = 1;
									end
								endcase
							end
							4'b101x:	begin //DSJEQ Rd,Addr
								case (STATE)
									5'd0: begin	//Rd-1->Rd
										DECI.AIA = '{IMM_K, CV_0 , AS_REGA , EO_NONE};
										DECI.AIB = '{IMM_K, CV_1 , AS_CONST, EO_NONE};
										DECI.ALU = '{ALUOP_ADD, 4'b0001, 1'b1};
										DECI.RWA = '{RS_ALU, DS_COND};
										DECI.IWL = IW_WORD;
										DECI.NST = DS_COND ? 5'd1 : 5'd2;
										DECI.LST = 0;
									end
									5'd1: begin	//PC+IW->PC
										DECI.JC = JC_DS;
										DECI.PCS = PCS_IW;
										DECI.LST = ~DS_COND;
									end
									default: begin
										DECI.LST = 1;
									end
								endcase
							end
							4'b110x:	begin //DSJNE Rd,Addr
								case (STATE)
									5'd0: begin	//Rd-1->Rd
										DECI.AIA = '{IMM_K, CV_0 , AS_REGA , EO_NONE};
										DECI.AIB = '{IMM_K, CV_1 , AS_CONST, EO_NONE};
										DECI.ALU = '{ALUOP_ADD, 4'b0001, 1'b1};
										DECI.RWA = '{RS_ALU, ~DS_COND};
										DECI.IWL = IW_WORD;
										DECI.NST = !DS_COND ? 5'd1 : 5'd2;
										DECI.LST = 0;
									end
									5'd1: begin	//PC+IW->PC
										DECI.JC = JC_DS;
										DECI.PCS = PCS_IW;
										DECI.LST = ~DS_COND;
									end
									default: begin
										DECI.LST = 1;
									end
								endcase
							end
							
							4'b1110:	begin //SETC
								DECI.STW = {STU_C, 4'b0000};
								DECI.LST = 1;
							end
							
							default: DECI.ILI = 1;
						endcase
					end
					
					4'b1111:	begin 
						casex (IC[7:4])
							4'b00x0:	begin //PIXBLT L,L; PIXBLT L,XY (B14.XY-curr pos)
								case (STATE)
									5'd0: begin //WinAdjust(B7.XY)->PIX_DYDX
										DECI.RD = 4'd7;
										DECI.RS = 4'd7;
										DECI.R = 1;
										DECI.PF = '{PBLT_NONE, POFFS_NONE, WIN_DADJ, PLN_NONE};
										DECI.NST = IC[5] && PIX_WINEN ? 5'd1 : 5'd8;
										DECI.LST = 0;
									end
									5'd1: begin //B2.XY->B14.XY
										DECI.RD = 4'd14;
										DECI.RS = 4'd2;
										DECI.R = 1;
										DECI.RWA = '{RS_REGB, 1'b1};
										DECI.LST = 0;
									end
									5'd2: begin //B14.XY+B7.XY->B14.XY
										DECI.RD = 4'd14;
										DECI.RS = 4'd7;
										DECI.R = 1;
										DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
										DECI.AIB = '{IMM_K, CV_0 , AS_REGB, EO_NONE};
										DECI.ALU = '{ALUOP_ADDXY, 4'b0000, 1'b0};
										DECI.RWA = '{RS_ALU, 1'b1};
//										DECI.PF = '{PBLT_NONE, POFFS_NONE, WIN_NONE, PLN_NONE};
										DECI.LST = 0;
									end
									5'd3: begin //CPW B14.XY,WSTART,WEND
										DECI.RD = 4'd14;
										DECI.RS = 4'd14;
										DECI.R = 1;
										DECI.PF = '{PBLT_NONE, POFFS_NONE, WIN_CHECK, PLN_NONE};
										DECI.LST = 0;
									end
									5'd4: begin //WinAdjust(B7.XY)->PIX_DYDX
										DECI.RD = 4'd7;
										DECI.RS = 4'd7;
										DECI.R = 1;
										DECI.PF = '{PBLT_NONE, POFFS_NONE, WIN_DADJ, PLN_NONE};
										DECI.LST = (PIX_WINCC[0] | PIX_WINCC[2]) & PIX_WINEN;
									end
									5'd5: begin //XYWinOffset(B2.XY)->B14.XY
										DECI.RD = 4'd14;
										DECI.RS = 4'd2;
										DECI.R = 1;
										DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
										DECI.AIB = '{IMM_K, CV_0 , AS_PIX  , EO_NONE};
										DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
										DECI.PALU = '{PIXOP_WSTA, PIXAS_REGB, CNVS_NO};
										DECI.RWA = '{RS_ALU, 1'b1};
//										DECI.PF = '{PBLT_NONE, POFFS_NONE, WIN_CHECK, PLN_NONE};
										DECI.LST = 0;
									end
									5'd6: begin  //B0+XYToL(B14.XY)->B0
										DECI.RD = 4'd0;
										DECI.RS = 4'd14;
										DECI.R = 1;
										DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
										DECI.AIB = '{IMM_K, CV_0 , AS_PIX , EO_NONE};
										DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
										DECI.PALU = '{PIXOP_XYL, PIXAS_REGB, CNVS_SP};
										DECI.RWA = '{RS_ALU, 1'b1};
										DECI.LST = 0;
									end
									5'd7: begin //B2.XY+B14.XY->B2.XY
										DECI.RD = 4'd2;
										DECI.RS = 4'd14;
										DECI.R = 1;
										DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
										DECI.AIB = '{IMM_K, CV_0 , AS_REGB, EO_NONE};
										DECI.ALU = '{ALUOP_ADDXY, 4'b0000, 1'b0};
										DECI.RWA = '{RS_ALU, 1'b1};
										DECI.LST = 0;
									end
									5'd8: begin //0->B14.XY
										DECI.RD = 4'd14;
										DECI.RS = 4'd14;
										DECI.R = 1;
										DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
										DECI.AIB = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
										DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
										DECI.RWA = '{RS_ALU, 1'b1};
//										DECI.PF = '{PBLT_NONE, POFFS_NONE, WIN_NONE, PLN_NONE};
										DECI.LST = 0;
									end
									5'd9: begin //B0+B1->SOFFS
										DECI.RD = 4'd0;
										DECI.RS = 4'd1;
										DECI.R = 1;
										DECI.PALU = '{PIXOP_NOP, PIXAS_REGB, CNVS_SP};
										DECI.PF = '{PBLT_NONE, POFFS_INIT, WIN_NONE, PLN_NONE};
										DECI.NST = IC[5] ? 5'd10 : 5'd12;
										DECI.LST = 0;
									end
									5'd10: begin  //XYToL(B2.XY)->B2 (XY)
										DECI.RD = 4'd2;
										DECI.RS = 4'd2;
										DECI.R = 1;
										DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
										DECI.AIB = '{IMM_K, CV_0 , AS_PIX  , EO_NONE};
										DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
										DECI.PALU = '{PIXOP_XYL, PIXAS_REGB, CNVS_DP};
										DECI.RWA = '{RS_ALU, 1'b1};
										DECI.LST = 0;
									end
									5'd11: begin //B2+B4->B2 (XY)
										DECI.RD = 4'd2;
										DECI.RS = 4'd4;
										DECI.R = 1;
										DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
										DECI.AIB = '{IMM_K, CV_0 , AS_REGB, EO_NONE};
										DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
										DECI.RWA = '{RS_ALU, 1'b1};
										DECI.LST = 0;
									end
									5'd12: begin //B2+0->PPW, B2+B3->DOFFS
										DECI.RD = 4'd2;
										DECI.RS = 4'd3;
										DECI.R = 1;
										DECI.AIA = '{IMM_K, CV_0 , AS_REGA , EO_NONE};
										DECI.AIB = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
										DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
										DECI.PALU = '{PIXOP_NOP, PIXAS_REGB, CNVS_DP};
										DECI.PF = '{PBLT_STRT, POFFS_INIT, WIN_NONE, PLN_NONE};
										DECI.NST = 5'd14;
										DECI.LST = 0;
									end
									5'd13: begin //
										DECI.LST = 0;
									end
									5'd14: begin	//(*B0->BUF,B0+PW->B0)
										DECI.RD = 4'd0;
//										DECI.RS = 4'd0;
										DECI.R = 1;
										DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
										DECI.AIB = '{IMM_K, CV_0 , AS_PIX , EO_NONE};
										DECI.FT = '{FSI_PW, 1'b0};
										DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
										DECI.PALU = '{PIXOP_PPW, PIXAS_REGB, CNVS_NO};
										DECI.RWA = '{RS_ALU, 1'b1};
										DECI.MC = '{MAS_RA, MDS_REGA, MA_READ, MT_DATA};
										DECI.NST = 5'd16;
										DECI.LST = 0;
									end
									5'd15: begin //
										DECI.LST = 0;
									end
									5'd16: begin	//B14.XY+XStep()->B14.XY, B14.XY>=PIX_DYDX
										DECI.RD = 4'd14;
										DECI.RS = 4'd14;
										DECI.R = 1;
										DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
										DECI.AIB = '{IMM_K, CV_0 , AS_PIX , EO_NONE};
										DECI.ALU = '{ALUOP_ADDXY, 4'b1000, 1'b0};
										DECI.PALU = '{PIXOP_XYS, PIXAS_REGB, CNVS_DP};
										DECI.PF = '{PBLT_NEXT, POFFS_NONE, WIN_NONE, PLN_NONE};
										DECI.RWA = '{RS_ALU, 1'b1};
										DECI.NST = 5'd18;
										DECI.LST = 0;
									end
									5'd17: begin	//
										DECI.LST = 0;
									end 
									5'd18: begin	//(PAT->*B2,B2+PW->B2)
										DECI.RD = 4'd2;
//										DECI.RS = 4'd14;
										DECI.R = 1;
										DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
										DECI.AIB = '{IMM_K, CV_0 , AS_PIX , EO_NONE};
										DECI.FT = '{FSI_PW, 1'b0};
										DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
										DECI.PALU = '{PIXOP_PPW, PIXAS_REGB, CNVS_NO};
										DECI.PF = '{PBLT_DRAW, POFFS_NONE, WIN_NONE, PLN_NONE};
										DECI.PIXO = '{PATS_MEM};
										DECI.RWA = '{RS_ALU, 1'b1};
										DECI.MC = '{MAS_RA, MDS_PIX, MA_WRITE, MT_PIX};
										DECI.NST = PIX_XEND ? 5'd19 : 5'd14;
										DECI.LST = 0;
									end 
									5'd19: begin //0+SOFFS->B0, SOFFS+B1->SOFFS
										DECI.RD = 4'd0;
										DECI.RS = 4'd1;
										DECI.R = 1;
										DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
										DECI.AIB = '{IMM_K, CV_0 , AS_PIX  , EO_NONE};
										DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
										DECI.PALU = '{PIXOP_OFFS, PIXAS_REGB, CNVS_SP};
										DECI.PF = '{PBLT_NONE, POFFS_NEXT, WIN_NONE, PLN_NONE};
										DECI.RWA = '{RS_ALU, 1'b1};
										DECI.LST = 0;
									end
									default: begin	//0+DOFFS->B2, DOFFS+B3->DOFFS
										DECI.RD = 4'd2;
										DECI.RS = 4'd3;
										DECI.R = 1;
										DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
										DECI.AIB = '{IMM_K, CV_0 , AS_PIX  , EO_NONE};
										DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
										DECI.PALU = '{PIXOP_OFFS, PIXAS_REGB, CNVS_DP};
										DECI.PF = '{PBLT_STRT, POFFS_NEXT, WIN_NONE, PLN_NONE};
										DECI.RWA = '{RS_ALU, 1'b1};
										DECI.NST = 5'd14;
										DECI.LST = PIX_YEND;
									end
								endcase
							end
							
							4'b10x0:	begin //PIXBLT B,L; PIXBLT B,XY (B14.XY-curr pos)
								case (STATE)
									5'd0: begin //WinAdjust(B7.XY)->PIX_DYDX
										DECI.RD = 4'd7;
										DECI.RS = 4'd7;
										DECI.R = 1;
										DECI.PF = '{PBLT_NONE, POFFS_NONE, WIN_DADJ, PLN_NONE};
										DECI.NST = IC[5] && PIX_WINEN ? 5'd1 : 5'd8;
										DECI.LST = 0;
									end
									5'd1: begin //B2.XY->B14.XY
										DECI.RD = 4'd14;
										DECI.RS = 4'd2;
										DECI.R = 1;
										DECI.RWA = '{RS_REGB, 1'b1};
										DECI.LST = 0;
									end
									5'd2: begin //B14.XY+B7.XY->B14.XY
										DECI.RD = 4'd14;
										DECI.RS = 4'd7;
										DECI.R = 1;
										DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
										DECI.AIB = '{IMM_K, CV_0 , AS_REGB, EO_NONE};
										DECI.ALU = '{ALUOP_ADDXY, 4'b0000, 1'b0};
										DECI.RWA = '{RS_ALU, 1'b1};
//										DECI.PF = '{PBLT_NONE, POFFS_NONE, WIN_NONE, PLN_NONE};
										DECI.LST = 0;
									end
									5'd3: begin //CPW B14.XY,WSTART,WEND
										DECI.RD = 4'd14;
										DECI.RS = 4'd14;
										DECI.R = 1;
										DECI.PF = '{PBLT_NONE, POFFS_NONE, WIN_CHECK, PLN_NONE};
										DECI.LST = 0;
									end
									5'd4: begin //WinAdjust(B7.XY)->PIX_DYDX
										DECI.RD = 4'd7;
										DECI.RS = 4'd7;
										DECI.R = 1;
										DECI.PF = '{PBLT_NONE, POFFS_NONE, WIN_DADJ, PLN_NONE};
										DECI.LST = (PIX_WINCC[0] | PIX_WINCC[2]) & PIX_WINEN;
									end
									5'd5: begin //XYWinOffset(B2.XY)->B14.XY
										DECI.RD = 4'd14;
										DECI.RS = 4'd2;
										DECI.R = 1;
										DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
										DECI.AIB = '{IMM_K, CV_0 , AS_PIX  , EO_NONE};
										DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
										DECI.PALU = '{PIXOP_WSTA, PIXAS_REGB, CNVS_NO};
										DECI.RWA = '{RS_ALU, 1'b1};
//										DECI.PF = '{PBLT_NONE, POFFS_NONE, WIN_CHECK, PLN_NONE};
										DECI.LST = 0;
									end
									5'd6: begin  //B0+XYToL(B14.XY)->B0
										DECI.RD = 4'd0;
										DECI.RS = 4'd14;
										DECI.R = 1;
										DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
										DECI.AIB = '{IMM_K, CV_0 , AS_PIX , EO_NONE};
										DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
										DECI.PALU = '{PIXOP_XYL, PIXAS_REGB, CNVS_SP};
										DECI.RWA = '{RS_ALU, 1'b1};
										DECI.LST = 0;
									end
									5'd7: begin //B2.XY+B14.XY->B2.XY
										DECI.RD = 4'd2;
										DECI.RS = 4'd14;
										DECI.R = 1;
										DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
										DECI.AIB = '{IMM_K, CV_0 , AS_REGB, EO_NONE};
										DECI.ALU = '{ALUOP_ADDXY, 4'b0000, 1'b0};
//										DECI.PALU = '{PIXOP_NOP, PIXAS_REGB, CNVS_NO};
										DECI.RWA = '{RS_ALU, 1'b1};
										DECI.LST = 0;
									end
									5'd8: begin //0->B14.XY
										DECI.RD = 4'd14;
										DECI.RS = 4'd14;
										DECI.R = 1;
										DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
										DECI.AIB = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
										DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
										DECI.RWA = '{RS_ALU, 1'b1};
//										DECI.PF = '{PBLT_NONE, POFFS_NONE, WIN_NONE, PLN_NONE};
										DECI.LST = 0;
									end
									5'd9: begin //B0+B1->SOFFS
										DECI.RD = 4'd0;
										DECI.RS = 4'd1;
										DECI.R = 1;
										DECI.PALU = '{PIXOP_NOP, PIXAS_REGB, CNVS_SP};
										DECI.PF = '{PBLT_NONE, POFFS_INIT, WIN_NONE, PLN_NONE};
										DECI.NST = IC[5] ? 5'd10 : 5'd12;
										DECI.LST = 0;
									end
									5'd10: begin  //XYToL(B2.XY)->B2 (XY)
										DECI.RD = 4'd2;
										DECI.RS = 4'd2;
										DECI.R = 1;
										DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
										DECI.AIB = '{IMM_K, CV_0 , AS_PIX  , EO_NONE};
										DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
										DECI.PALU = '{PIXOP_XYL, PIXAS_REGB, CNVS_DP};
										DECI.RWA = '{RS_ALU, 1'b1};
										DECI.LST = 0;
									end
									5'd11: begin //XY (B2+B4->B2)
										DECI.RD = 4'd2;
										DECI.RS = 4'd4;
										DECI.R = 1;
										DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
										DECI.AIB = '{IMM_K, CV_0 , AS_REGB, EO_NONE};
										DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
										DECI.RWA = '{RS_ALU, 1'b1};
										DECI.LST = 0;
									end
									5'd12: begin //B2+0->PPW, B2+B3->DOFFS
										DECI.RD = 4'd2;
										DECI.RS = 4'd3;
										DECI.R = 1;
										DECI.AIA = '{IMM_K, CV_0 , AS_REGA , EO_NONE};
										DECI.AIB = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
										DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
										DECI.PALU = '{PIXOP_NOP, PIXAS_REGA, CNVS_DP};
										DECI.PF = '{PBLT_STRT, POFFS_INIT, WIN_NONE, PLN_NONE};
										DECI.NST = 5'd14;
										DECI.LST = 0;
									end
									5'd13: begin //
										DECI.LST = 0;
									end
									5'd14: begin	//(*B0->BUF,B0+32->B0)
										DECI.RD = 4'd0;
										DECI.RS = 4'd0;
										DECI.R = 1;
										DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
										DECI.AIB = '{IMM_K, CV_0 , AS_PIX , EO_NONE};
										DECI.FT = '{FSI_32, 1'b0};
										DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
										DECI.PALU = '{PIXOP_PPW, PIXAS_REGB, CNVS_NO};
										DECI.RWA = '{RS_ALU, 1'b1};
										DECI.MC = '{MAS_RA, MDS_REGA, MA_READ, MT_DATA};
//										DECI.NST = 5'd16;
										DECI.LST = 0;
									end
									5'd15: begin	//BUF->PIX_BIT
										DECI.PF = '{PBLT_BMLD, POFFS_NONE, WIN_NONE, PLN_NONE};
										DECI.LST = 0;
									end
									5'd16: begin	//B14.XY+XStep()->B14.XY, B14.XY>=PIX_DYDX
										DECI.RD = 4'd14;
//										DECI.RS = 4'd14;
										DECI.R = 1;
										DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
										DECI.AIB = '{IMM_K, CV_0 , AS_PIX , EO_NONE};
										DECI.ALU = '{ALUOP_ADDXY, 4'b1000, 1'b0};
										DECI.PALU = '{PIXOP_XYS, PIXAS_REGB, CNVS_NO};
										DECI.PF = '{PBLT_NEXT, POFFS_NONE, WIN_NONE, PLN_NONE};
										DECI.RWA = '{RS_ALU, 1'b1};
										DECI.NST = 5'd18;
										DECI.LST = 0;
									end
									5'd17: begin	//
										DECI.LST = 0;
									end 
									5'd18: begin	//(PAT->*B2,B2+PW->B2)
										DECI.RD = 4'd2;
//										DECI.RS = 4'd14;
										DECI.R = 1;
										DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
										DECI.AIB = '{IMM_K, CV_0 , AS_PIX , EO_NONE};
										DECI.FT = '{FSI_PW, 1'b0};
										DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
										DECI.PALU = '{PIXOP_PPW, PIXAS_REGB, CNVS_NO};
										DECI.RWA = '{RS_ALU, 1'b1};
										DECI.PF = '{PBLT_DRAW, POFFS_NONE, WIN_NONE, PLN_NONE};
										DECI.PIXO = '{PATS_B};
										DECI.MC = '{MAS_RA, MDS_PIX, PIX_WE ? MA_WRITE : MA_NONE, MT_PIX};
										DECI.NST = PIX_XEND ? 5'd19 : PIX_BL ? 5'd14 : 5'd16;
										DECI.LST = 0;
									end 
									5'd19: begin //0+SOFFS->B0, SOFFS+B1->SOFFS
										DECI.RD = 4'd0;
										DECI.RS = 4'd1;
										DECI.R = 1;
										DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
										DECI.AIB = '{IMM_K, CV_0 , AS_PIX  , EO_NONE};
										DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
										DECI.PALU = '{PIXOP_OFFS, PIXAS_REGB, CNVS_SP};
										DECI.PF = '{PBLT_NONE, POFFS_NEXT, WIN_NONE, PLN_NONE};
										DECI.RWA = '{RS_ALU, 1'b1};
										DECI.LST = 0;
									end
									default: begin	//0+DOFFS->B2, DOFFS+B3->DOFFS
										DECI.RD = 4'd2;
										DECI.RS = 4'd3;
										DECI.R = 1;
										DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
										DECI.AIB = '{IMM_K, CV_0 , AS_PIX  , EO_NONE};
										DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
										DECI.PALU = '{PIXOP_OFFS, PIXAS_REGB, CNVS_DP};
										DECI.PF = '{PBLT_STRT, POFFS_NEXT, WIN_NONE, PLN_NONE};
										DECI.RWA = '{RS_ALU, 1'b1};
										DECI.NST = 5'd14;
										DECI.LST = PIX_YEND;
									end
								endcase
							end
								
							4'b11x0:	begin //FILL L; FILL XY
								case (STATE)
									5'd0: begin //WinAdjust(B7.XY)->PIX_DYDX
										DECI.RD = 4'd7;
										DECI.RS = 4'd7;
										DECI.R = 1;
										DECI.PF = '{PBLT_NONE, POFFS_NONE, WIN_DADJ, PLN_NONE};
										DECI.NST = IC[5] && PIX_WINEN ? 5'd1 : 5'd8;
										DECI.LST = 0;
									end
									5'd1: begin //B2.XY->B14.XY
										DECI.RD = 4'd14;
										DECI.RS = 4'd2;
										DECI.R = 1;
										DECI.RWA = '{RS_REGB, 1'b1};
										DECI.LST = 0;
									end
									5'd2: begin //B14.XY+B7.XY->B14.XY
										DECI.RD = 4'd14;
										DECI.RS = 4'd7;
										DECI.R = 1;
										DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
										DECI.AIB = '{IMM_K, CV_0 , AS_REGB, EO_NONE};
										DECI.ALU = '{ALUOP_ADDXY, 4'b0000, 1'b0};
										DECI.RWA = '{RS_ALU, 1'b1};
//										DECI.PF = '{PBLT_NONE, POFFS_NONE, WIN_NONE, PLN_NONE};
										DECI.LST = 0;
									end
									5'd3: begin //CPW B14.XY,WSTART,WEND
										DECI.RD = 4'd14;
										DECI.RS = 4'd14;
										DECI.R = 1;
										DECI.PF = '{PBLT_NONE, POFFS_NONE, WIN_CHECK, PLN_NONE};
										DECI.LST = 0;
									end
									5'd4: begin //WinAdjust(B7.XY)->PIX_DYDX
										DECI.RD = 4'd7;
										DECI.RS = 4'd7;
										DECI.R = 1;
										DECI.PF = '{PBLT_NONE, POFFS_NONE, WIN_DADJ, PLN_NONE};
										DECI.LST = (PIX_WINCC[0] | PIX_WINCC[2]) & PIX_WINEN;
									end
									5'd5: begin //XYWinOffset(B2.XY)->B14.XY
										DECI.RD = 4'd14;
										DECI.RS = 4'd2;
										DECI.R = 1;
										DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
										DECI.AIB = '{IMM_K, CV_0 , AS_PIX  , EO_NONE};
										DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
										DECI.PALU = '{PIXOP_WSTA, PIXAS_REGB, CNVS_NO};
										DECI.RWA = '{RS_ALU, 1'b1};
//										DECI.PF = '{PBLT_NONE, POFFS_NONE, WIN_CHECK, PLN_NONE};
										DECI.LST = 0;
									end
									5'd6: begin  //B0+XYToL(B14.XY)->B0
										DECI.RD = 4'd0;
										DECI.RS = 4'd14;
										DECI.R = 1;
										DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
										DECI.AIB = '{IMM_K, CV_0 , AS_PIX , EO_NONE};
										DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
										DECI.PALU = '{PIXOP_XYL, PIXAS_REGB, CNVS_SP};
										DECI.RWA = '{RS_ALU, 1'b1};
										DECI.LST = 0;
									end
									5'd7: begin //B2.XY+B14.XY->B2.XY
										DECI.RD = 4'd2;
										DECI.RS = 4'd14;
										DECI.R = 1;
										DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
										DECI.AIB = '{IMM_K, CV_0 , AS_REGB, EO_NONE};
										DECI.ALU = '{ALUOP_ADDXY, 4'b0000, 1'b0};
//										DECI.PALU = '{PIXOP_NOP, PIXAS_REGB, CNVS_NO};
										DECI.RWA = '{RS_ALU, 1'b1};
										DECI.LST = 0;
									end
									5'd8: begin //0->B14.XY
										DECI.RD = 4'd14;
										DECI.RS = 4'd14;
										DECI.R = 1;
										DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
										DECI.AIB = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
										DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
										DECI.RWA = '{RS_ALU, 1'b1};
//										DECI.PF = '{PBLT_NONE, POFFS_NONE, WIN_NONE, PLN_NONE};
										DECI.LST = 0;
									end
									5'd9: begin //B0+B1->SOFFS
										DECI.RD = 4'd0;
										DECI.RS = 4'd1;
										DECI.R = 1;
										DECI.PALU = '{PIXOP_NOP, PIXAS_REGB, CNVS_SP};
										DECI.PF = '{PBLT_NONE, POFFS_INIT, WIN_NONE, PLN_NONE};
										DECI.NST = IC[5] ? 5'd10 : 5'd12;
										DECI.LST = 0;
									end
									5'd10: begin  //XYToL(B2.XY)->B2 (XY)
										DECI.RD = 4'd2;
										DECI.RS = 4'd2;
										DECI.R = 1;
										DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
										DECI.AIB = '{IMM_K, CV_0 , AS_PIX  , EO_NONE};
										DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
										DECI.PALU = '{PIXOP_XYL, PIXAS_REGB, CNVS_DP};
										DECI.RWA = '{RS_ALU, 1'b1};
										DECI.LST = 0;
									end
									5'd11: begin //B2+B4->B2 (XY)
										DECI.RD = 4'd2;
										DECI.RS = 4'd4;
										DECI.R = 1;
										DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
										DECI.AIB = '{IMM_K, CV_0 , AS_REGB, EO_NONE};
										DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
										DECI.RWA = '{RS_ALU, 1'b1};
										DECI.LST = 0;
									end
									5'd12: begin //B2+0->PPW, B2+B3->DOFFS
										DECI.RD = 4'd2;
										DECI.RS = 4'd3;
										DECI.R = 1;
										DECI.AIA = '{IMM_K, CV_0 , AS_REGA , EO_NONE};
										DECI.AIB = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
										DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
										DECI.PALU = '{PIXOP_NOP, PIXAS_REGB, CNVS_DP};
										DECI.PF = '{PBLT_STRT, POFFS_INIT, WIN_NONE, PLN_NONE};
										DECI.NST = 5'd14;
										DECI.LST = 0;
									end
									5'd13: begin //
										DECI.LST = 0;
									end
									5'd14: begin	//
										DECI.NST = 5'd16;
										DECI.LST = 0;
									end 
									5'd15: begin	//
										DECI.LST = 0;
									end 
									5'd16: begin	//B14.XY+XStep()->B14.XY, B14.XY>=PIX_DYDX
										DECI.RD = 4'd14;
										DECI.RS = 4'd14;
										DECI.R = 1;
										DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
										DECI.AIB = '{IMM_K, CV_0 , AS_PIX , EO_NONE};
										DECI.ALU = '{ALUOP_ADDXY, 4'b1000, 1'b0};
										DECI.PALU = '{PIXOP_XYS, PIXAS_REGB, CNVS_NO};
										DECI.PF = '{PBLT_NEXT, POFFS_NONE, WIN_NONE, PLN_NONE};
										DECI.RWA = '{RS_ALU, 1'b1};
										DECI.NST = 5'd18;
										DECI.LST = 0;
									end
									5'd17: begin	//
										DECI.LST = 0;
									end 
									5'd18: begin	//(PIX->*B2,B2+PW->B2)
										DECI.RD = 4'd2;
//										DECI.RS = 4'd9;
										DECI.R = 1;
										DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
										DECI.AIB = '{IMM_K, CV_0 , AS_PIX , EO_NONE};
										DECI.FT = '{FSI_PW, 1'b0};
										DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
										DECI.PALU = '{PIXOP_PPW, PIXAS_REGB, CNVS_NO};
										DECI.PF = '{PBLT_DRAW, POFFS_NONE, WIN_NONE, PLN_NONE};
										DECI.RWA = '{RS_ALU, 1'b1};
										DECI.PIXO = '{PATS_COL1};
										DECI.MC = '{MAS_RA, MDS_PIX, MA_WRITE, MT_PIX};
										DECI.NST = PIX_XEND ? 5'd20 : 5'd16;
										DECI.LST = 0;
									end 
									5'd19: begin //
										DECI.LST = 0;
									end
									default: begin	//0+DOFFS->B2, DOFFS+B3->DOFFS
										DECI.RD = 4'd2;
										DECI.RS = 4'd3;
										DECI.R = 1;
										DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
										DECI.AIB = '{IMM_K, CV_0 , AS_PIX  , EO_NONE};
										DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
										DECI.PALU = '{PIXOP_OFFS, PIXAS_REGB, CNVS_DP};
										DECI.PF = '{PBLT_STRT, POFFS_NEXT, WIN_NONE, PLN_NONE};
										DECI.RWA = '{RS_ALU, 1'b1};
										DECI.NST = 5'd14;
										DECI.LST = PIX_YEND;
									end
								endcase
							end
							default: DECI.ILI = 1;
						endcase
					end
							
					default: DECI.ILI = 1;
				endcase
			end
			
			4'b0001:	begin 
				casex (IC[11:8])
					4'b00xx:	begin  //ADDK K,Rd (Rd+K->Rd)
						DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
						DECI.AIB = '{IMM_K, CV_0 , AS_IMM , EO_NONE};
						DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
						DECI.RWA = '{RS_ALU, 1'b1};
						DECI.STW = {STU_ALU, AFU_NCZV};
					end
					4'b01xx:	begin  //SUBK K,Rd (Rd-K->Rd)
						DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
						DECI.AIB = '{IMM_K, CV_0 , AS_IMM , EO_NONE};
						DECI.ALU = '{ALUOP_ADD, 4'b0001, 1'b1};
						DECI.RWA = '{RS_ALU, 1'b1};
						DECI.STW = {STU_ALU, AFU_NCZV};
					end
					4'b10xx:	begin  //MOVK K,Rd (0+K->Rd)
						DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
						DECI.AIB = '{IMM_K, CV_0 , AS_IMM  , EO_NONE};
						DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
						DECI.RWA = '{RS_ALU, 1'b1};
					end
					4'b11xx:	begin  //BTST K,Rd (Rd&BMASK)
						DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
						DECI.AIB = '{IMM_K, CV_0 , AS_IMM , EO_NONE};
						DECI.ALU = '{ALUOP_LOG, 4'b0111, 1'b0};
						DECI.STW = {STU_ALU, AFU_Z};
					end
				endcase
			end
			
			4'b0010:	begin 
				casex (IC[11:8])
					4'b00xx:	begin  //SLA K,Rd
						case (STATE)
							5'd0: begin	//
								DECI.LST = 0;
							end
							5'd1: begin //
								DECI.LST = 0;
							end
							default: begin
								DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_IMM , EO_NONE};
								DECI.ALU = '{ALUOP_SHIFT, 4'b0000, 1'b0};
								DECI.SHC = '{SS_IMM, 3'b010};
								DECI.RWA = '{RS_ALU, 1'b1};
								DECI.STW = {STU_ALU, AFU_NCZV};
								DECI.LST = 1;
							end
						endcase
					end
					4'b01xx:	begin  //SLL K,Rd
						case (STATE)
							default: begin
								DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_IMM , EO_NONE};
								DECI.ALU = '{ALUOP_SHIFT, 4'b0000, 1'b0};
								DECI.SHC = '{SS_IMM, 3'b000};
								DECI.RWA = '{RS_ALU, 1'b1};
								DECI.STW = {STU_ALU, AFU_CZ};
							end
						endcase
					end
					4'b10xx:	begin  //SRA K,Rd
						case (STATE)
							default: begin
								DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_IMM , EO_NONE};
								DECI.ALU = '{ALUOP_SHIFT, 4'b0000, 1'b0};
								DECI.SHC = '{SS_IMM, 3'b011};
								DECI.RWA = '{RS_ALU, 1'b1};
								DECI.STW = {STU_ALU, AFU_NCZ};
							end
						endcase
					end
					4'b11xx:	begin  //SRL K,Rd
						case (STATE)
							default: begin
								DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_IMM , EO_NONE};
								DECI.ALU = '{ALUOP_SHIFT, 4'b0000, 1'b0};
								DECI.SHC = '{SS_IMM, 3'b001};
								DECI.RWA = '{RS_ALU, 1'b1};
								DECI.STW = {STU_ALU, AFU_CZ};
							end
						endcase
					end
				endcase
			end
			
			4'b0011:	begin 
				casex (IC[11:8])
					4'b00xx:	begin  //RL K,Rd
						case (STATE)
							default: begin
								DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_IMM , EO_NONE};
								DECI.ALU = '{ALUOP_SHIFT, 4'b0000, 1'b0};
								DECI.SHC = '{SS_IMM, 3'b100};
								DECI.RWA = '{RS_ALU, 1'b1};
								DECI.STW = {STU_ALU, AFU_CZ};
							end
						endcase
					end
					4'b01xx:	begin  //CMPK K,Rd (Rd-K)
						case (STATE)
							default: begin
								DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_IMM , EO_NONE};
								DECI.ALU = '{ALUOP_ADD, 4'b0001, 1'b1};
								DECI.STW = {STU_ALU, AFU_NCZV};
							end
						endcase
					end
					4'b1xxx:	begin //DSJS Rd,Addr
						case (STATE)
							5'd0: begin	//Rd-1->Rd
								DECI.AIA = '{IMM_K, CV_0 , AS_REGA , EO_NONE};
								DECI.AIB = '{IMM_K, CV_1 , AS_CONST, EO_NONE};
								DECI.ALU = '{ALUOP_ADD, 4'b0001, 1'b1};
								DECI.RWA = '{RS_ALU, 1'b1};
								DECI.LST = 0;
							end
							5'd1: begin	//PC+SS->PC
								DECI.JC = JC_DS;
								DECI.PCS = PCS_K;
								DECI.LST = ~DS_COND;
							end
							default: begin
								DECI.LST = 1;
							end
						endcase
					end
					default: DECI.ILI = 1;
				endcase
			end
			
			4'b0100:	begin 
				DECI.RS = IC[8:5];
				casex (IC[11:8])
					4'b000x:	begin  //ADD Rs,Rd (Rd+Rs->Rd)
						DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
						DECI.RWA = '{RS_ALU, 1'b1};
						DECI.STW = {STU_ALU, AFU_NCZV};
					end
					4'b001x:	begin  //ADDC Rs,Rd (Rd+Rs+C->Rd)
						DECI.ALU = '{ALUOP_ADD, 4'b0010, 1'b0};
						DECI.RWA = '{RS_ALU, 1'b1};
						DECI.STW = {STU_ALU, AFU_NCZV};
					end
					4'b010x:	begin  //SUB Rs,Rd (Rd-Rs->Rd)
						DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
						DECI.AIB = '{IMM_K, CV_0 , AS_REGB, EO_NONE};
						DECI.ALU = '{ALUOP_ADD, 4'b0001, 1'b1};
						DECI.RWA = '{RS_ALU, 1'b1};
						DECI.STW = {STU_ALU, AFU_NCZV};
					end
					4'b011x:	begin  //SUBB Rs,Rd (Rd-Rs-C->Rd)
						DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
						DECI.AIB = '{IMM_K, CV_0 , AS_REGB, EO_NONE};
						DECI.ALU = '{ALUOP_ADD, 4'b0011, 1'b1};
						DECI.RWA = '{RS_ALU, 1'b1};
						DECI.STW = {STU_ALU, AFU_NCZV};
					end
					4'b100x:	begin  //CMP Rs,Rd (Rd-Rs)
						DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
						DECI.AIB = '{IMM_K, CV_0 , AS_REGB, EO_NONE};
						DECI.ALU = '{ALUOP_ADD, 4'b0001, 1'b1};
						DECI.STW = {STU_ALU, AFU_NCZV};
					end
					4'b101x:	begin  //BTST Rs,Rd (Rd&BMASK)
						DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
						DECI.AIB = '{IMM_K, CV_0 , AS_REGB, EO_NONE};
						DECI.ALU = '{ALUOP_LOG, 4'b0110, 1'b0};
						DECI.STW = {STU_ALU, AFU_Z};
					end
					4'b11xx:	begin  //MOVE Rs,Rd (Rs->Rd)
						DECI.M = IC[9];
						DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
						DECI.AIB = '{IMM_K, CV_0 , AS_REGB , EO_NONE};
						DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
						DECI.RWA = '{RS_REGB, 1'b1};
						DECI.STW = {STU_ALU, AFU_NZ};
					end
					default: DECI.ILI = 1;
				endcase
			end
			
			4'b0101:	begin 
				DECI.RS = IC[8:5];
				casex (IC[11:8])
					4'b000x:	begin  //AND Rs,Rd (Rd&Rs->Rd)
						DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
						DECI.AIB = '{IMM_K, CV_0 , AS_REGB, EO_NONE};
						DECI.ALU = '{ALUOP_LOG, 4'b0000, 1'b0};
						DECI.RWA = '{RS_ALU, 1'b1};
						DECI.STW = {STU_ALU, AFU_Z};
					end
					4'b001x:	begin  //ANDN Rs,Rd (Rd&~Rs->Rd)
						DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
						DECI.AIB = '{IMM_K, CV_0 , AS_REGB, EO_NONE};
						DECI.ALU = '{ALUOP_LOG, 4'b0001, 1'b0};
						DECI.RWA = '{RS_ALU, 1'b1};
						DECI.STW = {STU_ALU, AFU_Z};
					end
					4'b010x:	begin  //OR Rs,Rd (Rd|Rs->Rd)
						DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
						DECI.AIB = '{IMM_K, CV_0 , AS_REGB, EO_NONE};
						DECI.ALU = '{ALUOP_LOG, 4'b0010, 1'b0};
						DECI.RWA = '{RS_ALU, 1'b1};
						DECI.STW = {STU_ALU, AFU_Z};
					end
					4'b011x:	begin  //XOR Rs,Rd (Rd^Rs->Rd)
						DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
						DECI.AIB = '{IMM_K, CV_0 , AS_REGB, EO_NONE};
						DECI.ALU = '{ALUOP_LOG, 4'b0100, 1'b0};
						DECI.RWA = '{RS_ALU, 1'b1};
						DECI.STW = {STU_ALU, AFU_Z};
					end
					4'b100x:	begin  //DIVS Rs,Rd
						case (STATE)
							5'd0: begin	//R(d|1)->MD_ACC[31:0]
								DECI.RD = IC[3:0] | 4'h1;
								DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_REGA , EO_NONE};
								DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
								DECI.MDC = '{MDO_DIVINIT, MDA_LDL, MDSH_NOP};
								DECI.NST = !IC[0] ? 5'd1 : 5'd2;
								DECI.LST = 0;
							end
							5'd1: begin	//Rd->MD_ACC[63:32]
								DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_REGA , EO_NONE};
								DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
								DECI.MDC = '{MDO_DIVDVNT, MDA_LDH, MDSH_NOP};
								DECI.LST = 0;
							end
							5'd2: begin	//0-MD_ACC->MD_ACC
								DECI.ALU = '{ALUOP_DIV, {3'b010,MD_NEG}, MD_NEG};
								DECI.MDC = '{MDO_NOP, MDA_NEG, MDSH_NOP};
								DECI.LST = 0;
							end
							5'd3: begin	//abs(Rs)->MD_SHIFT
								DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_REGB , EO_NONE};
								DECI.ALU = '{ALUOP_ADD, 4'b0100, 1'b0};
								DECI.MDC = '{MDO_DIVDVSR, MDA_NOP, MDSH_LDD};
								DECI.LST = 0;
							end
							5'd4: begin	//MD_ACC-MD_SHIFT->MD_ACC
								DECI.ALU = '{ALUOP_DIV, 4'b0001, 1'b1};
								DECI.MDC = '{MDO_DIVSTEP, MDA_DIV, MDSH_DIV};
								DECI.NST = !MD_COND ? 5'd4 : 5'd5;
								DECI.LST = DIV_V;
							end
							5'd5: begin	//0-MD_Q->MD_Q
								DECI.ALU = '{ALUOP_DIV, {3'b010,MD_NEG}, MD_NEG};
								DECI.MDC = '{MDO_DIVQUOT, MDA_NOP, MDSH_NOP};
								DECI.NST = !IC[0] ? 5'd6 : 5'd7;
								DECI.LST = 0;
							end
							5'd6: begin //MD_ACC->Rd+1
								DECI.RD = IC[3:0] | 4'h1;
								DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_MDAL , EO_NONE};
								DECI.MDC = '{MDO_NOP, MDA_NOP, MDSH_NOP};
								DECI.ALU = '{ALUOP_DIV, 4'b0000, 1'b0};
								DECI.RWA = '{RS_ALU, 1'b1};
								DECI.LST = 0;
							end
							default: begin //MD_Q->Rd
								DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_MDQ  , EO_NONE};
								DECI.MDC = '{MDO_NOP, MDA_NOP, MDSH_NOP};
								DECI.ALU = '{ALUOP_DIV, 4'b0000, 1'b0};
								DECI.STW = {STU_ALU, AFU_NZV};
								DECI.RWA = '{RS_ALU, 1'b1};
								DECI.LST = 1;
							end
						endcase
					end
					4'b101x:	begin  //DIVU Rs,Rd
						case (STATE)
							5'd0: begin	//R(d|1)->MD_ACC[31:0]
								DECI.RD = IC[3:0] | 4'h1;
								DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_REGA , EO_NONE};
								DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
								DECI.MDC = '{MDO_DIVINIT, MDA_LDL, MDSH_NOP};
								DECI.NST = !IC[0] ? 5'd1 : 5'd2;
								DECI.LST = 0;
							end
							5'd1: begin	//Rd->MD_ACC[63:32]
								DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_REGA , EO_NONE};
								DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
								DECI.MDC = '{MDO_DIVDVNT, MDA_LDH, MDSH_NOP};
								DECI.LST = 0;
							end
							5'd2: begin	//0-MD_ACC->MD_ACC
								DECI.ALU = '{ALUOP_DIV, {3'b010,MD_NEG}, MD_NEG};
								DECI.MDC = '{MDO_NOP, MDA_NEG, MDSH_NOP};
								DECI.LST = 0;
							end
							5'd3: begin	//Rs->MD_SHIFT
								DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_REGB , EO_NONE};
								DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
								DECI.MDC = '{MDO_DIVDVSR, MDA_NOP, MDSH_LDD};
								DECI.LST = 0;
							end
							5'd4: begin	//MD_ACC-MD_SHIFT->MD_ACC
								DECI.ALU = '{ALUOP_DIV, 4'b0001, 1'b1};
								DECI.MDC = '{MDO_DIVSTEP, MDA_DIV, MDSH_DIV};
								DECI.NST = !MD_COND ? 5'd4 : 5'd5;
								DECI.LST = DIV_V;
							end
							5'd5: begin	//0-MD_Q->MD_Q
								DECI.ALU = '{ALUOP_DIV, {3'b010,MD_NEG}, MD_NEG};
								DECI.MDC = '{MDO_DIVQUOT, MDA_NOP, MDSH_NOP};
								DECI.NST = !IC[0] ? 5'd6 : 5'd7;
								DECI.LST = 0;
							end
							5'd6: begin //MD_ACC->Rd|1
								DECI.RD = IC[3:0] | 4'h1;
								DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_MDAL , EO_NONE};
								DECI.ALU = '{ALUOP_DIV, 4'b0000, 1'b0};
								DECI.MDC = '{MDO_NOP, MDA_NOP, MDSH_NOP};
								DECI.RWA = '{RS_ALU, 1'b1};
								DECI.LST = 0;
							end
							default: begin //MD_Q->Rd
								DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_MDQ  , EO_NONE};
								DECI.ALU = '{ALUOP_DIV, 4'b0000, 1'b0};
								DECI.MDC = '{MDO_NOP, MDA_NOP, MDSH_NOP};
								DECI.STW = {STU_ALU, AFU_ZV};
								DECI.RWA = '{RS_ALU, 1'b1};
								DECI.LST = 1;
							end
						endcase
					end
					4'b110x:	begin  //MPYS Rs,Rd
						case (STATE)
							5'd0: begin	//0->MD_ACC
								DECI.ALU = '{ALUOP_MUL, 4'b0000, 1'b0};
								DECI.MDC = '{MDO_MULINIT, MDA_ZERO, MDSH_NOP};
								DECI.LST = 0;
							end
							5'd1: begin	//abs(Rs)->MD_SHIFT
								DECI.F = 1;
								DECI.FT = '{FSI_F, 1'b0};
								DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_REGB , EO_SIGN};
								DECI.ALU = '{ALUOP_ADD, 4'b0100, 1'b0};
								DECI.MDC = '{MDO_MULCHK, MDA_NOP, MDSH_LDM};
								DECI.LST = 0;
							end
							5'd2: begin	//MD_ACC+Mult()->MD_ACC
								DECI.F = 1;
								DECI.FT = '{FSI_F, 1'b0};
								DECI.ALU = '{ALUOP_MUL, 4'b0000, 1'b0};
								DECI.MDC = '{MDO_MULSTEP, MDA_MULT, MDSH_MULT};
								DECI.NST = !MD_COND ? 5'd2 : 5'd3;
								DECI.LST = 0;
							end
							5'd3: begin	//
								DECI.MDC = '{MDO_NOP, MDA_NOP, MDSH_NOP};
								DECI.NST = MD_NEG ? 5'd4 : 5'd5;
								DECI.LST = 0;
							end
							5'd4: begin	//0-MD_ACC->MD_ACC
								DECI.ALU = '{ALUOP_MUL, 4'b0101, 1'b1};
								DECI.MDC = '{MDO_NOP, MDA_NEG, MDSH_NOP};
								DECI.LST = 0;
							end
							5'd5: begin //MD_ACCL->Rd+1
								DECI.RD = IC[3:0] | 4'h1;
								DECI.F = 1;
								DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_MDAL , EO_NONE};
								DECI.MDC = '{MDO_NOP, MDA_NOP, MDSH_NOP};
								DECI.ALU = '{ALUOP_MUL, 4'b0000, 1'b0};
								DECI.FT = '{FSI_F, 1'b0};
								DECI.STW = {STU_ALU, AFU_Z};
								DECI.RWA = '{RS_ALU, 1'b1};
								DECI.LST = IC[0];
							end
							default: begin	//MD_ACCH->Rd
								DECI.F = 1;
								DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_MDAH , EO_SIGN};
								DECI.MDC = '{MDO_NOP, MDA_NOP, MDSH_NOP};
								DECI.ALU = '{ALUOP_MUL, 4'b0000, 1'b0};
								DECI.FT = '{FSI_F, 1'b0};
								DECI.RWA = '{RS_ALU, 1'b1};
								DECI.LST = 1;
							end
						endcase
					end
					4'b111x:	begin  //MPYU Rs,Rd
						case (STATE)
							5'd0: begin	//0->MD_ACC
								DECI.ALU = '{ALUOP_MUL, 4'b0000, 1'b0};
								DECI.MDC = '{MDO_MULINIT, MDA_ZERO, MDSH_NOP};
								DECI.LST = 0;
							end
							5'd1: begin	//Rs->MD_SHIFT
								DECI.F = 1;
								DECI.FT = '{FSI_F, 1'b0};
								DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_REGB , EO_ZERO};
								DECI.ALU = '{ALUOP_MUL, 4'b0000, 1'b0};
								DECI.MDC = '{MDO_MULCHK, MDA_NOP, MDSH_LDM};
								DECI.LST = 0;
							end
							5'd2: begin	//MD_ACC+Mult()->MD_ACC
								DECI.F = 1;
								DECI.FT = '{FSI_F, 1'b0};
								DECI.ALU = '{ALUOP_MUL, 4'b0000, 1'b0};
								DECI.MDC = '{MDO_MULSTEP, MDA_MULT, MDSH_MULT};
								DECI.NST = !MD_COND ? 5'd2 : 5'd3;
								DECI.LST = 0;
							end
							5'd3: begin	//
								DECI.MDC = '{MDO_NOP, MDA_NOP, MDSH_NOP};
								DECI.NST = MD_NEG ? 5'd4 : 5'd5;
								DECI.LST = 0;
							end
							5'd4: begin	//0-MD_ACC->MD_ACC
								DECI.ALU = '{ALUOP_MUL, 4'b0101, 1'b1};
								DECI.MDC = '{MDO_NOP, MDA_NEG, MDSH_NOP};
								DECI.LST = 0;
							end
							5'd5: begin //MD_ACCL->Rd (odd)
								DECI.RD = IC[3:0] | 4'h1;
								DECI.F = 1;
								DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_MDAL , EO_NONE};
								DECI.ALU = '{ALUOP_MUL, 4'b0000, 1'b0};
								DECI.FT = '{FSI_F, 1'b0};
								DECI.MDC = '{MDO_NOP, MDA_NOP, MDSH_NOP};
								DECI.STW = {STU_ALU, AFU_Z};
								DECI.RWA = '{RS_ALU, 1'b1};
								DECI.LST = IC[0];
							end
							default: begin	//MD_ACCH->Rd (even)
								DECI.F = 1;
								DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_MDAH , EO_ZERO};
								DECI.ALU = '{ALUOP_MUL, 4'b0000, 1'b0};
								DECI.FT = '{FSI_F, 1'b0};
								DECI.MDC = '{MDO_NOP, MDA_NOP, MDSH_NOP};
								DECI.RWA = '{RS_ALU, 1'b1};
								DECI.LST = 1;
							end
						endcase
					end
					default: DECI.ILI = 1;
				endcase
			end
			
			4'b0110:	begin 
				DECI.RS = IC[8:5];
				casex (IC[11:8])
					4'b000x:	begin  //SLA Rs,Rd
						case (STATE)
							5'd0: begin	//
								DECI.LST = 0;
							end
							5'd1: begin //
								DECI.LST = 0;
							end
							default: begin
								DECI.ALU = '{ALUOP_SHIFT, 4'b0000, 1'b0};
								DECI.SHC = '{SS_REG, 3'b010};
								DECI.RWA = '{RS_ALU, 1'b1};
								DECI.STW = {STU_ALU, AFU_NCZV};
							end
						endcase
					end
					4'b001x:	begin  //SLL Rs,Rd
						DECI.ALU = '{ALUOP_SHIFT, 4'b0000, 1'b0};
						DECI.SHC = '{SS_REG, 3'b000};
						DECI.RWA = '{RS_ALU, 1'b1};
						DECI.STW = {STU_ALU, AFU_CZ};
					end
					4'b010x:	begin  //SRA Rs,Rd
						DECI.ALU = '{ALUOP_SHIFT, 4'b0000, 1'b0};
						DECI.SHC = '{SS_REG, 3'b011};
						DECI.RWA = '{RS_ALU, 1'b1};
						DECI.STW = {STU_ALU, AFU_NCZ};
					end
					4'b011x:	begin  //SRL Rs,Rd
						DECI.ALU = '{ALUOP_SHIFT, 4'b0000, 1'b0};
						DECI.SHC = '{SS_REG, 3'b001};
						DECI.RWA = '{RS_ALU, 1'b1};
						DECI.STW = {STU_ALU, AFU_CZ};
					end
					4'b100x:	begin  //RL Rs,Rd
						DECI.ALU = '{ALUOP_SHIFT, 4'b0000, 1'b0};
						DECI.SHC = '{SS_REG, 3'b100};
						DECI.RWA = '{RS_ALU, 1'b1};
						DECI.STW = {STU_ALU, AFU_CZ};
					end
					4'b101x:	begin  //LMO Rs,Rd
						DECI.ALU = '{ALUOP_LOC, 4'b0000, 1'b0};
						DECI.RWA = '{RS_ALU, 1'b1};
						DECI.STW = {STU_ALU, AFU_Z};
					end
					4'b110x:	begin	//MODS Rs,Rd
						case (STATE)
							5'd0: begin	//R(d|1)->MD_ACC[31:0]
								DECI.RD = IC[3:0] | 4'h1;
								DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_REGA , EO_NONE};
								DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
								DECI.MDC = '{MDO_DIVINIT, MDA_LDL, MDSH_NOP};
								DECI.NST = 5'd2;
								DECI.LST = 0;
							end
							5'd1: begin	//Rd->MD_ACC[63:32]
								DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_REGA , EO_NONE};
								DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
								DECI.MDC = '{MDO_DIVDVNT, MDA_LDH, MDSH_NOP};
								DECI.LST = 0;
							end
							5'd2: begin	//0-MD_ACC->MD_ACC
								DECI.ALU = '{ALUOP_DIV, {3'b010,MD_NEG}, MD_NEG};
								DECI.MDC = '{MDO_NOP, MDA_NEG, MDSH_NOP};
								DECI.LST = 0;
							end
							5'd3: begin	//abs(Rs)->MD_SHIFT
								DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_REGB , EO_NONE};
								DECI.ALU = '{ALUOP_ADD, 4'b0100, 1'b0};
								DECI.MDC = '{MDO_DIVDVSR, MDA_NOP, MDSH_LDD};
								DECI.LST = 0;
							end
							5'd4: begin	//MD_ACC-MD_SHIFT->MD_ACC
								DECI.ALU = '{ALUOP_DIV, 4'b0001, 1'b1};
								DECI.MDC = '{MDO_DIVSTEP, MDA_DIV, MDSH_DIV};
								DECI.NST = !MD_COND ? 5'd4 : 5'd5;
								DECI.LST = DIV_V;
							end
							5'd5: begin	//0-MD_Q->MD_Q
								DECI.ALU = '{ALUOP_DIV, {3'b010,MD_NEG}, MD_NEG};
								DECI.MDC = '{MDO_DIVQUOT, MDA_NOP, MDSH_NOP};
								DECI.LST = 0;
							end
							default: begin //MD_ACC->Rd
								DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_MDAL , EO_NONE};
								DECI.ALU = '{ALUOP_DIV, 4'b0000, 1'b0};
								DECI.MDC = '{MDO_NOP, MDA_NOP, MDSH_NOP};
								DECI.STW = {STU_ALU, AFU_ZV};
								DECI.RWA = '{RS_ALU, 1'b1};
								DECI.LST = 0;
							end
						endcase
					end
					4'b111x:	begin	//MODU Rs,Rd
						case (STATE)
							5'd0: begin	//Rd->MD_ACC
								DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_REGA , EO_NONE};
								DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
								DECI.MDC = '{MDO_DIVINIT, MDA_LDL, MDSH_NOP};
								DECI.NST = 5'd2;
								DECI.LST = 0;
							end
							5'd1: begin	//
								DECI.MDC = '{MDO_DIVDVNT, MDA_LDH, MDSH_NOP};
								DECI.LST = 0;
							end
							5'd2: begin	//0-MD_ACC->MD_ACC
								DECI.ALU = '{ALUOP_DIV, {3'b010,MD_NEG}, MD_NEG};
								DECI.MDC = '{MDO_NOP, MDA_NEG, MDSH_NOP};
								DECI.LST = 0;
							end
							5'd3: begin	//Rs->MD_SHIFT
								DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_REGB , EO_NONE};
								DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
								DECI.MDC = '{MDO_DIVDVSR, MDA_NEG, MDSH_LDD};
								DECI.LST = 0;
							end
							5'd4: begin	//MD_ACC-MD_SHIFT->MD_ACC
								DECI.ALU = '{ALUOP_DIV, 4'b0001, 1'b1};
								DECI.MDC = '{MDO_DIVSTEP, MDA_DIV, MDSH_DIV};
								DECI.NST = !MD_COND ? 5'd4 : 5'd5;
								DECI.LST = DIV_V;
							end
							5'd5: begin	//0-MD_Q->MD_Q
								DECI.ALU = '{ALUOP_DIV, {3'b010,MD_NEG}, MD_NEG};
								DECI.MDC = '{MDO_DIVQUOT, MDA_NOP, MDSH_NOP};
								DECI.LST = 0;
							end
							default: begin //MD_ACC->Rd
								DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_MDAL , EO_NONE};
								DECI.ALU = '{ALUOP_DIV, 4'b0000, 1'b0};
								DECI.MDC = '{MDO_NOP, MDA_NOP, MDSH_NOP};
								DECI.STW = {STU_ALU, AFU_ZV};
								DECI.RWA = '{RS_ALU, 1'b1};
								DECI.LST = 1;
							end
						endcase;
					end
					default: DECI.ILI = 1;
				endcase
			end
			
			4'b0111:	begin 
				DECI.RS = IC[8:5];
				casex (IC[11:8])
					4'b101x:	begin  //RMO Rs,Rd
						DECI.ALU = '{ALUOP_LOC, 4'b0001, 1'b0};
						DECI.RWA = '{RS_ALU, 1'b1};
						DECI.STW = {STU_ALU, AFU_Z};
					end
//					4'b111x:	begin  //SWAPF Rs,Rd,F
//						
//					end
					default: DECI.ILI = 1;
				endcase
			end
			
			4'b1000:	begin 
				DECI.RS = IC[8:5];
				casex (IC[11:8])
					4'b00xx:	begin  //MOVE Rs,*Rd,F 
						case (STATE)
							default: begin //(Rs->*Rd)
								DECI.FT = '{FSI_F, 1'b0};
								DECI.MC = '{MAS_RA, MDS_REGB, MA_WRITE, MT_DATA};
								DECI.LST = 1;
							end
						endcase
					end
					4'b01xx:	begin  //MOVE *Rs,Rd,F
						case (STATE)
							5'd0: begin //(*Rs->BUF)
								DECI.FT = '{FSI_F, 1'b0};
								DECI.MC = '{MAS_RB, MDS_REGA, MA_READ, MT_DATA};
								DECI.LST = 0;
							end
							5'd1: begin //(BUF->Rd)
								DECI.FT = '{FSI_F, 1'b0};
								DECI.ALU = '{ALUOP_MOV, 4'b0000, 1'b0};
								DECI.RWA = '{RS_MEM, 1'b1};
								DECI.STW = {STU_ALU, AFU_NZ};
								DECI.LST = !IC[9] ? ~FE0 : ~FE1;
							end
							default: begin //(exts(Rd)+0->Rd)
								DECI.AIA = '{IMM_K, CV_0 , AS_REGA , EO_SIGN};
								DECI.AIB = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
								DECI.FT = '{FSI_F, 1'b0};
								DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
								DECI.RWA = '{RS_ALU, 1'b1};////////////
								DECI.STW = {STU_ALU, AFU_NZ};
								DECI.LST = 1;
							end
						endcase
					end
					4'b10xx:	begin  //MOVE *Rs,*Rd,F
						case (STATE)
							5'd0: begin //(*Rs->BUF)
								DECI.FT = '{FSI_F, 1'b0};
								DECI.MC = '{MAS_RB, MDS_REGA, MA_READ, MT_DATA};
								DECI.LST = 0;
							end
							default: begin //(BUF->*Rd)
								DECI.FT = '{FSI_F, 1'b0};
								DECI.MC = '{MAS_RA, MDS_MEM, MA_WRITE, MT_DATA};
								DECI.LST = 1;
							end
						endcase
					end
					4'b110x:	begin  //MOVB Rs,*Rd 
						case (STATE)
							default: begin //(Rs->*Rd)
								DECI.FT = '{FSI_8, 1'b1};
								DECI.MC = '{MAS_RA, MDS_REGB, MA_WRITE, MT_DATA};
								DECI.LST = 1;
							end
						endcase
					end
					4'b111x:	begin  //MOVB *Rs,Rd
						case (STATE)
							5'd0: begin //(*Rs->BUF)
								DECI.FT = '{FSI_8, 1'b1};
								DECI.MC = '{MAS_RB, MDS_REGA, MA_READ, MT_DATA};
								DECI.LST = 0;
							end
							5'd1: begin //(BUF->Rd)
								DECI.FT = '{FSI_8, 1'b1};
								DECI.ALU = '{ALUOP_MOV, 4'b0000, 1'b0};
								DECI.RWA = '{RS_MEM, 1'b1};
								DECI.STW = {STU_ALU, AFU_NZ};
								DECI.LST = 0;
							end
							default: begin //(exts(Rd)+0->Rd)
								DECI.AIA = '{IMM_K, CV_0 , AS_REGA , EO_SIGN};
								DECI.AIB = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
								DECI.FT = '{FSI_8, 1'b1};
								DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
								DECI.RWA = '{RS_ALU, 1'b1};////////////
								DECI.STW = {STU_ALU, AFU_NZ};
								DECI.LST = 1;
							end
						endcase
					end
					default: DECI.ILI = 1;
				endcase
			end
			
			4'b1001:	begin 
				DECI.RS = IC[8:5];
				casex (IC[11:8])
					4'b00xx:	begin  //MOVE Rs,*Rd+,F 
						case (STATE)
							default: begin //(Rs->*Rd,Rd+FS->Rd)
								DECI.AIA = '{IMM_K , CV_0 , AS_REGA, EO_NONE};
								DECI.AIB = '{IMM_FS, CV_0 , AS_IMM , EO_NONE};
								DECI.FT = '{FSI_F, 1'b0};
								DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
								DECI.RWA = '{RS_ALU, 1'b1};
								DECI.MC = '{MAS_RA, MDS_REGB, MA_WRITE, MT_DATA};
							end
						endcase
					end
					4'b01xx:	begin  //MOVE *Rs+,Rd,F
						case (STATE)
							5'd0: begin //(*Rs->BUF,FS+Rs->Rs)
								DECI.AIA = '{IMM_FS, CV_0 , AS_IMM , EO_NONE};
								DECI.AIB = '{IMM_K , CV_0 , AS_REGB, EO_NONE};
								DECI.FT = '{FSI_F, 1'b0};
								DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
								DECI.RWB = '{RS_ALU, 1'b1};
								DECI.MC = '{MAS_RB, MDS_REGA, MA_READ, MT_DATA};
								DECI.LST = 0;
							end
							5'd1: begin //(BUF->Rd)
								DECI.FT = '{FSI_F, 1'b0};
								DECI.ALU = '{ALUOP_MOV, 4'b0000, 1'b0};
								DECI.RWA = '{RS_MEM, 1'b1};
								DECI.STW = {STU_ALU, AFU_NZ};
								DECI.LST = !IC[9] ? ~FE0 : ~FE1;
							end
							default: begin //(exts(Rd)+0->Rd)
								DECI.AIA = '{IMM_K, CV_0 , AS_REGA , EO_SIGN};
								DECI.AIB = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
								DECI.FT = '{FSI_F, 1'b0};
								DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
								DECI.RWA = '{RS_ALU, 1'b1};/////////
								DECI.STW = {STU_ALU, AFU_NZ};
								DECI.LST = 1;
							end
						endcase
					end
					4'b10xx:	begin  //MOVE *Rs+,*Rd+,F
						case (STATE)
							5'd0: begin //(*Rs->BUF,FS+Rs->Rs)
								DECI.AIA = '{IMM_FS, CV_0 , AS_IMM , EO_NONE};
								DECI.AIB = '{IMM_K , CV_0 , AS_REGB, EO_NONE};
								DECI.FT = '{FSI_F, 1'b0};
								DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
								DECI.RWB = '{RS_ALU, 1'b1};
								DECI.MC = '{MAS_RB, MDS_REGA, MA_READ, MT_DATA};
								DECI.LST = 0;
							end
							default: begin //(BUF->*Rd,Rd+FS->Rd)
								DECI.AIA = '{IMM_K , CV_0 , AS_REGA, EO_NONE};
								DECI.AIB = '{IMM_FS, CV_0 , AS_IMM , EO_NONE};
								DECI.FT = '{FSI_F, 1'b0};
								DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
								DECI.RWA = '{RS_ALU, 1'b1};
								DECI.MC = '{MAS_RA, MDS_MEM, MA_WRITE, MT_DATA};
								DECI.LST = 1;
							end
						endcase
					end
					4'b110x:	begin  //MOVB *Rs,*Rd
						case (STATE)
							5'd0: begin //(*Rs->BUF)
								DECI.FT = '{FSI_8, 1'b1};
								DECI.MC = '{MAS_RB, MDS_REGA, MA_READ, MT_DATA};
								DECI.LST = 0;
							end
							default: begin //(BUF->*Rd)
								DECI.FT = '{FSI_8, 1'b1};
								DECI.MC = '{MAS_RA, MDS_MEM, MA_WRITE, MT_DATA};
								DECI.LST = 1;
							end
						endcase
					end
					default: DECI.ILI = 1;
				endcase
			end
			
			4'b1010:	begin
				DECI.RS = IC[8:5];
				casex (IC[11:8])
					4'b00xx:	begin  //MOVE Rs,-*Rd,F 
						case (STATE)
							5'd0: begin //(Rd-FS->Rd)
								DECI.AIA = '{IMM_K , CV_0, AS_REGA, EO_NONE};
								DECI.AIB = '{IMM_FS, CV_0, AS_IMM , EO_NONE};
								DECI.ALU = '{ALUOP_ADD, 4'b0001, 1'b1};
								DECI.FT = '{FSI_F, 1'b0};
								DECI.RWA = '{RS_ALU, 1'b1};
								DECI.LST = 0;
							end
							default: begin //(Rs->*Rd);
								DECI.FT = '{FSI_F, 1'b0};
								DECI.MC = '{MAS_RA, MDS_REGB, MA_WRITE, MT_DATA};
								DECI.LST = 1;
							end
						endcase
					end
					4'b01xx:	begin  //MOVE -*Rs,Rd,F
						case (STATE)
							5'd0: begin //(Rs-FS->Rs)
								DECI.AIA = '{IMM_K , CV_0, AS_REGB, EO_NONE};
								DECI.AIB = '{IMM_FS, CV_0, AS_IMM , EO_NONE};
								DECI.ALU = '{ALUOP_ADD, 4'b0001, 1'b1};
								DECI.FT = '{FSI_F, 1'b0};
								DECI.RWB = '{RS_ALU, 1'b1};
								DECI.LST = 0;
							end
							5'd1: begin //(*Rs->BUF)
								DECI.FT = '{FSI_F, 1'b0};
								DECI.MC = '{MAS_RB, MDS_REGA, MA_READ, MT_DATA};
								DECI.LST = 0;
							end
							5'd2: begin //(BUF->Rd)
								DECI.FT = '{FSI_F, 1'b0};
								DECI.ALU = '{ALUOP_MOV, 4'b0000, 1'b0};
								DECI.RWA = '{RS_MEM, 1'b1};
								DECI.STW = {STU_ALU, AFU_NZ};
								DECI.LST = 0;
							end
							default: begin //(exts(Rd)+0->Rd)
								DECI.AIA = '{IMM_K, CV_0 , AS_REGA , EO_SIGN};
								DECI.AIB = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
								DECI.FT = '{FSI_F, 1'b0};
								DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
								DECI.RWA = '{RS_ALU, 1'b1};/////////
								DECI.STW = {STU_ALU, AFU_NZ};
								DECI.LST = 1;
							end
						endcase
					end
					4'b10xx:	begin  //MOVE -*Rs,-*Rd,F
						case (STATE)
							5'd0: begin //(Rs-FS->Rs)
								DECI.AIA = '{IMM_K , CV_0, AS_REGB, EO_NONE};
								DECI.AIB = '{IMM_FS, CV_0, AS_IMM , EO_NONE};
								DECI.ALU = '{ALUOP_ADD, 4'b0001, 1'b1};
								DECI.FT = '{FSI_F, 1'b0};
								DECI.RWB = '{RS_ALU, 1'b1};
								DECI.LST = 0;
							end
							5'd1: begin //(Rd-FS->Rd,*Rs->BUF)
								DECI.AIA = '{IMM_K , CV_0, AS_REGA, EO_NONE};
								DECI.AIB = '{IMM_FS, CV_0, AS_IMM , EO_NONE};
								DECI.ALU = '{ALUOP_ADD, 4'b0001, 1'b1};
								DECI.FT = '{FSI_F, 1'b0};
								DECI.RWA = '{RS_ALU, 1'b1};
								DECI.MC = '{MAS_RB, MDS_REGA, MA_READ, MT_DATA};
								DECI.LST = 0;
							end
							default: begin //(BUF->*Rd)
								DECI.FT = '{FSI_F, 1'b0};
								DECI.MC = '{MAS_RA, MDS_MEM, MA_WRITE, MT_DATA};
								DECI.LST = 1;
							end
						endcase
					end
					4'b110x:	begin  //MOVB Rs,*Rd(offs)
						case (STATE)
							5'd0: begin //
								DECI.IWL = IW_WORD;
								DECI.LST = 0;
							end
							default: begin //(BUF->*(Rd+IW))
								DECI.FT = '{FSI_8, 1'b0};
								DECI.MC = '{MAS_RAIW, MDS_REGB, MA_WRITE, MT_DATA};
								DECI.LST = 1;
							end
						endcase
					end
					4'b111x:	begin  //MOVB *Rs(offs),Rd
						case (STATE)
							5'd0: begin //
								DECI.IWL = IW_WORD;
								DECI.LST = 0;
							end
							5'd1: begin //(*(Rs+IW)->BUF)
								DECI.FT = '{FSI_8, 1'b1};
								DECI.MC = '{MAS_RBIW, MDS_REGA, MA_READ, MT_DATA};
								DECI.LST = 0;
							end
							5'd2: begin //(BUF->Rd)
								DECI.FT = '{FSI_8, 1'b1};
								DECI.ALU = '{ALUOP_MOV, 4'b0000, 1'b0};
								DECI.RWA = '{RS_MEM, 1'b1};
								DECI.STW = {STU_ALU, AFU_NZ};
								DECI.LST = 0;
							end
							default: begin //(exts(Rd)+0->Rd)
								DECI.AIA = '{IMM_K, CV_0 , AS_REGA , EO_SIGN};
								DECI.AIB = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
								DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
								DECI.FT = '{FSI_8, 1'b1};
								DECI.RWA = '{RS_ALU, 1'b1};/////////
								DECI.STW = {STU_ALU, AFU_NZ};
								DECI.LST = 1;
							end
						endcase
					end
					default: DECI.ILI = 1;
				endcase
			end
			
			4'b1011:	begin
				DECI.RS = IC[8:5];
				casex (IC[11:8])
					4'b00xx:	begin  //MOVE Rs,*Rd(offs),F
						case (STATE)
							5'd0: begin //
								DECI.IWL = IW_WORD;
								DECI.LST = 0;
							end
							default: begin //(BUF->*(Rd+IW))
								DECI.FT = '{FSI_F, 1'b0};
								DECI.MC = '{MAS_RAIW, MDS_REGB, MA_WRITE, MT_DATA};
								DECI.LST = 1;
							end
						endcase
					end
					4'b01xx:	begin  //MOVE *Rs(offs),Rd,F
						case (STATE)
							5'd0: begin //
								DECI.IWL = IW_WORD;
								DECI.LST = 0;
							end
							5'd1: begin //(*(Rs+IW)->BUF)
								DECI.FT = '{FSI_F, 1'b0};
								DECI.MC = '{MAS_RBIW, MDS_REGA, MA_READ, MT_DATA};
								DECI.LST = 0;
							end
							5'd2: begin //(BUF->Rd)
								DECI.FT = '{FSI_F, 1'b0};
								DECI.ALU = '{ALUOP_MOV, 4'b0000, 1'b0};
								DECI.RWA = '{RS_MEM, 1'b1};
								DECI.STW = {STU_ALU, AFU_NZ};
								DECI.LST = !IC[9] ? ~FE0 : ~FE1;
							end
							default: begin //(exts(Rd)+0->Rd)
								DECI.AIA = '{IMM_K, CV_0 , AS_REGA , EO_SIGN};
								DECI.AIB = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
								DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
								DECI.FT = '{FSI_F, 1'b0};
								DECI.RWA = '{RS_ALU, 1'b1};/////////
								DECI.STW = {STU_ALU, AFU_NZ};
								DECI.LST = 1;
							end
						endcase
					end
					4'b10xx:	begin  //MOVE *Rs(offs),*Rd(offs),F
						case (STATE)
							5'd0: begin //
								DECI.IWL = IW_WORD;
								DECI.LST = 0;
							end
							5'd1: begin //(*(Rs+IW)->BUF)
								DECI.FT = '{FSI_F, 1'b0};
								DECI.MC = '{MAS_RBIW, MDS_REGA, MA_READ, MT_DATA};
								DECI.LST = 0;
							end
							5'd2: begin //
								DECI.IWL = IW_WORD;
								DECI.LST = 0;
							end
							default: begin //(BUF->*(Rd+IW))
								DECI.FT = '{FSI_F, 1'b0};
								DECI.MC = '{MAS_RAIW, MDS_MEM, MA_WRITE, MT_DATA};
								DECI.LST = 1;
							end
						endcase
					end
					4'b110x:	begin  //MOVB *Rs(offs),*Rd(offs)
						case (STATE)
							5'd0: begin //
								DECI.IWL = IW_WORD;
								DECI.LST = 0;
							end
							5'd1: begin //(*(Rs+IW)->BUF)
								DECI.FT = '{FSI_8, 1'b1};
								DECI.MC = '{MAS_RBIW, MDS_REGA, MA_READ, MT_DATA};
								DECI.LST = 0;
							end
							5'd2: begin //
								DECI.IWL = IW_WORD;
								DECI.LST = 0;
							end
							default: begin //(BUF->*(Rd+IW))
								DECI.FT = '{FSI_8, 1'b1};
								DECI.MC = '{MAS_RAIW, MDS_MEM, MA_WRITE, MT_DATA};
								DECI.LST = 1;
							end
						endcase
					end
					default: DECI.ILI = 1;
				endcase
			end
			
			4'b1100:	begin  //JAcc Addr
				casex (IC[7:0])
					8'bx0000000: begin
						case (STATE)
							5'd0: begin
								DECI.IWL = IC[7] ? IW_LONG : IW_WORD;
								DECI.LST = 0;
							end
							5'd1: begin
								DECI.JC = JC_COND;
								DECI.PCS = IC[7] ? PCS_IL : PCS_IW;
								DECI.LST = ~J_COND;
							end
							default: begin
								DECI.LST = 1;
							end
						endcase
					end
					default: begin
						case (STATE)
							5'd0: begin
								DECI.JC = JC_COND;
								DECI.PCS = PCS_IB;
								DECI.LST = ~J_COND;
							end
							default: begin
								DECI.LST = 1;
							end
						endcase
					end
				endcase
			end
			
			4'b1101:	begin
				DECI.RS = IC[8:5];
				casex (IC[11:8])
					4'b00xx:	begin  //MOVE *Rs(offs),*Rd+,F
						case (STATE)
							5'd0: begin //
								DECI.IWL = IW_WORD;
								DECI.LST = 0;
							end
							5'd1: begin //(*(Rs+IW)->BUF)
								DECI.FT = '{FSI_F, 1'b0};
								DECI.MC = '{MAS_RBIW, MDS_REGA, MA_READ, MT_DATA};
								DECI.LST = 0;
							end
							default: begin //(BUF->*Rd,Rd+FS->Rd)
								DECI.AIA = '{IMM_K , CV_0 , AS_REGA, EO_NONE};
								DECI.AIB = '{IMM_FS, CV_0 , AS_IMM , EO_NONE};
								DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
								DECI.FT = '{FSI_F, 1'b0};
								DECI.RWA = '{RS_ALU, 1'b1};
								DECI.MC = '{MAS_RA, MDS_MEM, MA_WRITE, MT_DATA};
								DECI.LST = 1;
							end
						endcase
					end
					4'b01x0:	begin  //MOVE @SAddr,*Rd+,F
						case (STATE)
							5'd0: begin //
								DECI.IWL = IW_LONG;
								DECI.LST = 0;
							end
							5'd1: begin //(*IL->BUF)
								DECI.FT = '{FSI_F, 1'b0};
								DECI.MC = '{MAS_IL, MDS_REGA, MA_READ, MT_DATA};
								DECI.LST = 0;
							end
							default: begin //(BUF->*Rd,Rd+FS->Rd)
								DECI.AIA = '{IMM_K , CV_0 , AS_REGA, EO_NONE};
								DECI.AIB = '{IMM_FS, CV_0 , AS_IMM , EO_NONE};
								DECI.FT = '{FSI_F, 1'b0};
								DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
								DECI.RWA = '{RS_ALU, 1'b1};
								DECI.MC = '{MAS_RA, MDS_MEM, MA_WRITE, MT_DATA};
								DECI.LST = 1;
							end
						endcase
					end
					4'b01x1:	begin  //EXGF Rd,F
						case (STATE)
							default: begin //[ST.FEx,ST.FSx]->Rd, Rd->[ST.FEx,ST.FSx]
								DECI.AIA = '{IMM_K, CV_0 , AS_STF  , EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
								DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
								DECI.RWA = '{RS_ALU, 1'b1};
								DECI.STW = {STU_EXFS, 4'b0000};
								DECI.LST = 1;
							end
						endcase
					end
//					4'b0111:	begin  //EXGF Rd,1
//						case (STATE)
//							5'd0: begin //[ST.FE1,ST.FS1]->Rd, Rd->[ST.FE1,ST.FS1]
//								DECI.AIA = '{IMM_K, CV_0 , AS_STF1 , EO_NONE};
//								DECI.AIB = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
//								DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
//								DECI.RWA = '{RS_ALU, 1'b1};
//								DECI.STW = {STU_EXFS, 4'b0000};
//								DECI.LST = 0;
//							end
//							default: begin 
//								DECI.LST = 1;
//							end
//						endcase
//					end
					
					4'b1111:	begin  //LINE 0/1
						case (STATE)
							5'd0: begin //B7+0->PIX_DYDX
								DECI.RD = 4'd7;
								DECI.RS = 4'd7;
								DECI.R = 1;
								DECI.AIA = '{IMM_K, CV_0 , AS_REGA , EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
								DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
								DECI.PF = '{PBLT_NONE, POFFS_NONE, WIN_INIT, PLN_NONE};
								DECI.LST = 0;
							end
							5'd1: begin //B2.XY->B14.XY, PATTERN->PIX_BIT
								DECI.RD = 4'd14;
								DECI.RS = 4'd2;
								DECI.R = 1;
								DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_REGB , EO_NONE};
								DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
								DECI.PALU = '{PIXOP_NOP, PIXAS_REGB, CNVS_SP};
								DECI.RWA = '{RS_ALU, 1'b1};
								DECI.PF = '{PBLT_NONE, POFFS_NONE, WIN_NONE, PLN_INIT};
								DECI.LST = 0;
							end
							5'd2: begin  //XYToL(B2.XY)->B2
								DECI.RD = 4'd2;
								DECI.RS = 4'd2;
								DECI.R = 1;
								DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_PIX  , EO_NONE};
								DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
								DECI.PALU = '{PIXOP_XYL, PIXAS_REGB, CNVS_DP};
								DECI.RWA = '{RS_ALU, 1'b1};
								DECI.LST = 0;
							end
							5'd3: begin //B2+B4->B2
								DECI.RD = 4'd2;
								DECI.RS = 4'd4;
								DECI.R = 1;
								DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_REGB, EO_NONE};
								DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
								DECI.RWA = '{RS_ALU, 1'b1};
								DECI.LST = 0;
							end
							5'd4: begin //B0+0, N,Z
								DECI.RD = 4'd0;
								DECI.RS = 4'd0;
								DECI.R = 1;
								DECI.AIA = '{IMM_K, CV_0 , AS_REGA , EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
								DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
								DECI.PF = '{PBLT_NONE, POFFS_NONE, WIN_NONE, PLN_COND};
								DECI.LST = 0;
							end
							5'd5: begin	//B10-1->B10, Z
								DECI.RD = 4'd10;
								DECI.RS = 'd10;
								DECI.R = 1;
								DECI.AIA = '{IMM_K, CV_0 , AS_REGA , EO_NONE};
								DECI.AIB = '{IMM_K, CV_1 , AS_CONST, EO_NONE};
								DECI.ALU = '{ALUOP_ADD, 4'b0001, 1'b1};
								DECI.RWA = '{RS_ALU, 1'b1};
								DECI.LST = 0;
							end
							5'd6: begin	//B14.XY+B11/B12->B14.XY
								DECI.RD = 4'd14;
								DECI.RS = LINE_GZ ? 4'd11 : 4'd12;
								DECI.R = 1;
								DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_REGB, EO_NONE};
								DECI.ALU = '{ALUOP_ADDXY, 4'b0000, 1'b0};
//								DECI.PF = '{PBLT_NONE, POFFS_NONE, WIN_NONE, PLN_NONE};
								DECI.RWA = '{RS_ALU, 1'b1};
								DECI.NST = 5'd8;
								DECI.LST = LINE_COND;
							end
							5'd7: begin	//
								DECI.LST = 0;
							end 
							5'd8: begin	//PIX->*B2
								DECI.RD = 4'd2;
								DECI.R = 1;
								DECI.AIA = '{IMM_K, CV_0 , AS_REGA , EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
								DECI.FT = '{FSI_PS, 1'b0};
								DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
								DECI.PF = '{PBLT_NONE, POFFS_NONE, WIN_NONE, PLN_STEP};
//								DECI.RWA = '{RS_ALU, 1'b1};
								DECI.PIXO = '{PATS_LN};
								DECI.MC = '{MAS_RA, MDS_PIX, MA_WRITE, MT_PIX};
								DECI.LST = 0;
							end 
							5'd9: begin	//B2+XYToL(B11/B12)->B2
								DECI.RD = 4'd2;
								DECI.RS = LINE_GZ ? 4'd11 : 4'd12;
								DECI.R = 1;
								DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_PIX , EO_NONE};
								DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
								DECI.PALU = '{PIXOP_XYL, PIXAS_REGB, CNVS_DP};
//								DECI.PF = '{PBLT_NONE, POFFS_NONE, WIN_NONE, PLN_NONE};
								DECI.RWA = '{RS_ALU, 1'b1};
								DECI.LST = 0;
							end 
							default: begin	//B0+LineStep()->B0, N,Z
								DECI.RD = 4'd0;
								DECI.RS = 4'd0;
								DECI.R = 1;
								DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_PIX , EO_NONE};
								DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
								DECI.PALU = '{PIXOP_LNS, PIXAS_REGB, CNVS_NO};
								DECI.PF = '{PBLT_NONE, POFFS_NONE, WIN_NONE, PLN_COND};
								DECI.RWA = '{RS_ALU, 1'b1};
								DECI.NST = 5'd5;
								DECI.LST = 0;
							end	
						endcase
					end
					default: DECI.ILI = 1;
				endcase
			end
			
			4'b1110:	begin 
				DECI.RS = IC[8:5];
				casex (IC[11:8])
					4'b000x,  		//ADDXY Rs,Rd 
					4'b001x, 		//SUBXY Rs,Rd 
					4'b010x:	begin //CMPXY Rs,Rd 
						case (STATE)
							default: begin //(Rd+Rs->Rd)
								DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_REGB, EO_NONE};
								DECI.ALU = '{ALUOP_ADDXY, {3'b000,|IC[10:9]}, |IC[10:9]};
								DECI.RWA = '{RS_ALU, ~IC[10]};
								DECI.STW = {STU_ALU, AFU_NCZV};
							end
						endcase
					end
//					4'b010x:	begin  //CMPXY Rs,Rd 
//						case (STATE)
//							default: begin //(Rd-Rs)
//								DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
//								DECI.AIB = '{IMM_K, CV_0 , AS_REGB, EO_NONE};
//								DECI.ALU = '{ALUOP_ADDXY, 4'b0001, 1'b1};
//								DECI.STW = {STU_ALU, AFU_NCZV};
//							end
//						endcase
//					end
					4'b011x:	begin  //CPW Rs,Rd 
						case (STATE)
							default: begin //(WSTART>Rs>WEND->Rd)
								DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_REGB, EO_NONE};
								DECI.ALU = '{ALUOP_CPW, 4'b0000, 1'b0};
								DECI.RWA = '{RS_ALU, 1'b1};
								DECI.STW = {STU_ALU, AFU_V};
							end
						endcase
					end
					
					4'b100x:	begin //CVXYL Rs,Rd
						case (STATE)
							5'd0: begin //(Rs->Rd)
								DECI.RWA = '{RS_REGB, 1'b1};
								DECI.LST = 0;
							end
							5'd1: begin //XYToL(Rd.XY)->Rd
								DECI.AIA = '{IMM_K, CV_0 , AS_PIX  , EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
								DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
								DECI.PALU = '{PIXOP_XYL, PIXAS_REGA, CNVS_DP};
								DECI.RWA = '{RS_ALU, 1'b1};
								DECI.LST = 0;
							end
							default: begin //(Rd+B4->Rd)//TODO: if Rd in A file
								DECI.RS = 4'd4;
								DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_REGB, EO_NONE};
								DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
								DECI.RWA = '{RS_ALU, 1'b1};
								DECI.LST = 1;
							end
						endcase
					end
					4'b101x:	begin  //CVSXYL Rs,Rd
						case (STATE)
							5'd0: begin //XYToL(Rd.XY)->Rd
								DECI.RS = IC[3:0];
								DECI.AIA = '{IMM_K, CV_0 , AS_PIX  , EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
								DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
								DECI.PALU = '{PIXOP_XYL, PIXAS_REGA, CNVS_SP};
								DECI.RWA = '{RS_ALU, 1'b1};
								DECI.LST = 0;
							end
							default: begin //(Rd+Rs->Rd)
								DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_REGB, EO_NONE};
								DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
								DECI.RWA = '{RS_ALU, 1'b1};
								DECI.LST = 0;
							end
						endcase
					end
					4'b110x,  		//MOVX Rs,Rd 
					4'b111x:	begin	//MOVY Rs,Rd
						case (STATE)
							default: begin //(Rs&h0000FFFF | Rd&hFFFF0000->Rd)
								DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_PIX, EO_NONE};
								DECI.ALU = '{ALUOP_LOG, 4'b0010, 1'b0};
								DECI.PALU = '{!IC[9] ? PIXOP_MOVX : PIXOP_MOVY, PIXAS_REGB, CNVS_NO};
								DECI.RWA = '{RS_ALU, 1'b1};
							end
						endcase
					end
					default: DECI.ILI = 1;
				endcase
			end
			
			4'b1111:	begin 
				DECI.RS = IC[8:5];
				casex (IC[11:8])
					4'b000x:	begin  //PIXT Rs,*Rd.XY
						case (STATE)
							5'd0: begin //XYToL(Rd.XY)->Rd
								DECI.AIA = '{IMM_K, CV_0 , AS_PIX  , EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
								DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
								DECI.PALU = '{PIXOP_XYL, PIXAS_REGA, CNVS_DP};
								DECI.RWA = '{RS_ALU, 1'b1};
								DECI.LST = 0;
							end
							5'd1: begin //(Rd+R4->Rd)
								DECI.RS = 4'd4;
								DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_REGB, EO_NONE};
								DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
								DECI.RWA = '{RS_ALU, 1'b1};
								DECI.LST = 0;
							end
							default: begin //(Rs->*Rd)
								DECI.FT = '{FSI_PS, 1'b0};
								DECI.PIXO = '{PATS_REG};
								DECI.MC = '{MAS_RA, MDS_PIX, MA_WRITE, MT_PIX};
								DECI.LST = 1;
							end
						endcase
					end
					4'b001x:	begin  //PIXT *Rs.XY,Rd
						case (STATE)
							5'd0: begin //XYToL(Rs.XY)->Rs
								DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_PIX  , EO_NONE};
								DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
								DECI.PALU = '{PIXOP_XYL, PIXAS_REGB, CNVS_SP};
								DECI.RWB = '{RS_ALU, 1'b1};
								DECI.LST = 0;
							end
							5'd1: begin //(Rs+R4->Rd)
								DECI.RD = 4'd4;
								DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_REGB, EO_NONE};
								DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
								DECI.RWB = '{RS_ALU, 1'b1};
								DECI.LST = 0;
							end
							5'd2: begin //(*Rs->BUF)
								DECI.FT = '{FSI_PS, 1'b0};
								DECI.MC = '{MAS_RB, MDS_REGA, MA_READ, MT_PIX};
								DECI.LST = 0;
							end
							default: begin //(BUF->Rd)
								DECI.FT = '{FSI_PS, 1'b0};
								DECI.ALU = '{ALUOP_MOV, 4'b0000, 1'b0};
								DECI.RWA = '{RS_MEM, 1'b1};
								DECI.LST = 1;
							end
						endcase
					end
					4'b010x:	begin  //PIXT *Rs.XY,*Rd.XY
						case (STATE)
							5'd0: begin //XYToL(Rs.XY)->Rs
								DECI.AIA = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_PIX  , EO_NONE};
								DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
								DECI.PALU = '{PIXOP_XYL, PIXAS_REGB, CNVS_SP};
								DECI.RWB = '{RS_ALU, 1'b1};
								DECI.LST = 0;
							end
							5'd1: begin //(Rs+R4->Rd)
								DECI.RD = 4'd4;
								DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_REGB, EO_NONE};
								DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
								DECI.RWB = '{RS_ALU, 1'b1};
								DECI.LST = 0;
							end
							5'd2: begin //XYToL(Rd.XY)->Rd
								DECI.AIA = '{IMM_K, CV_0 , AS_PIX  , EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_CONST, EO_NONE};
								DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
								DECI.RWA = '{RS_ALU, 1'b1};
								DECI.PALU = '{PIXOP_XYL, PIXAS_REGA, CNVS_DP};
								DECI.LST = 0;
							end
							5'd3: begin //(Rd+R4->Rd)
								DECI.RS = 4'd4;
								DECI.AIA = '{IMM_K, CV_0 , AS_REGA, EO_NONE};
								DECI.AIB = '{IMM_K, CV_0 , AS_REGB, EO_NONE};
								DECI.ALU = '{ALUOP_ADD, 4'b0000, 1'b0};
								DECI.RWA = '{RS_ALU, 1'b1};
								DECI.LST = 0;
							end
							5'd4: begin //(*Rs->BUF)
								DECI.FT = '{FSI_PS, 1'b0};
								DECI.MC = '{MAS_RB, MDS_REGA, MA_READ, MT_PIX};
								DECI.LST = 0;
							end
							default: begin //(BUF->*Rd)
								DECI.FT = '{FSI_PS, 1'b0};
								DECI.PIXO = '{PATS_MEM};
								DECI.MC = '{MAS_RA, MDS_PIX, MA_WRITE, MT_PIX};
								DECI.LST = 1;
							end
						endcase
					end
					
					4'b100x:	begin  //PIXT Rs,*Rd
						case (STATE)
							default: begin //(Rs->*Rd)
								DECI.FT = '{FSI_PS, 1'b0};
								DECI.PIXO = '{PATS_REG};
								DECI.MC = '{MAS_RA, MDS_PIX, MA_WRITE, MT_PIX};
								DECI.LST = 1;
							end
						endcase
					end
					4'b101x:	begin  //PIXT *Rs,Rd
						case (STATE)
							5'd0: begin //(*Rs->BUF)
								DECI.FT = '{FSI_PS, 1'b0};
								DECI.MC = '{MAS_RB, MDS_REGA, MA_READ, MT_PIX};
								DECI.LST = 0;
							end
							default: begin //(BUF->Rd)
								DECI.FT = '{FSI_PS, 1'b0};
								DECI.ALU = '{ALUOP_MOV, 4'b0000, 1'b0};
								DECI.RWA = '{RS_MEM, 1'b1};
								DECI.LST = 1;
							end
						endcase
					end
					4'b110x:	begin  //PIXT *Rs,*Rd
						case (STATE)
							5'd0: begin //(*Rs->BUF)
								DECI.FT = '{FSI_PS, 1'b0};
								DECI.MC = '{MAS_RB, MDS_REGA, MA_READ, MT_PIX};
								DECI.LST = 0;
							end
							default: begin //(BUF->*Rd)
								DECI.FT = '{FSI_PS, 1'b0};
								DECI.PIXO = '{PATS_MEM};
								DECI.MC = '{MAS_RA, MDS_PIX, MA_WRITE, MT_PIX};
								DECI.LST = 1;
							end
						endcase
					end
					default: DECI.ILI = 1;
				endcase
			end
			
			default: DECI.ILI = 1;
		endcase
	end
	


endmodule
