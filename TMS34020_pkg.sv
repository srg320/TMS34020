package TMS34020_PKG; 

	typedef enum bit[3:0] {
		ALUOP_MOV   = 4'b0000, 
		ALUOP_ADD   = 4'b0001, 
		ALUOP_ADDXY = 4'b0010,
		ALUOP_CPW   = 4'b0011,
		ALUOP_LOG   = 4'b0100,
		ALUOP_SHIFT = 4'b0101,
		ALUOP_LOC   = 4'b0110,
		ALUOP_MUL   = 4'b0111,
		ALUOP_DIV   = 4'b1000
	} ALUOp_t; 
	
	typedef struct packed
	{
		ALUOp_t     OP;		//ALU operation type
		bit [ 3: 0] CD;		//ALU operation code
		bit         BCOMP;	//ALU B inverted
	} ALU_t; 
	
	//ALU operation code
	//ADD: [0] 0:add,1:sub; [2:1] 00:0->ci,01:1->ci,1X:C->ci;
	//LOG: [1:0] 0:and,1:or,2:xor,3:and bitmask; [2] 0:b,1:not b;
	//Shifter operation code
	//[0] 0:left,1:right; [2:1] 00:logical,01:arithmetic,1X:rotate;
	
	typedef enum bit[1:0] {
		IMM_K    = 2'b00,
		IMM_IW   = 2'b01,
		IMM_IL   = 2'b10,
		IMM_FS   = 2'b11
	} IMMType_t; 
	
	typedef enum bit[2:0] {
		CV_0  = 3'b000,
		CV_1  = 3'b001,
		CV_2  = 3'b010,
		CV_4  = 3'b011,
		CV_8  = 3'b100,
		CV_16 = 3'b101,
		CV_32 = 3'b110
	} Const_t; 
	
	typedef enum bit[3:0] {
		AS_REGA = 4'b0000,
		AS_REGB = 4'b0001,
		AS_IMM  = 4'b0010,
		AS_CONST= 4'b0011,
		AS_STF  = 4'b0100,
		AS_PS   = 4'b0101,
		AS_PPW  = 4'b0110,
		AS_PIX  = 4'b0111,
		AS_MDAL = 4'b1000,
		AS_MDAH = 4'b1001,
		AS_MDQ  = 4'b1010
	} ALUSource_t;
	
	typedef enum bit[1:0] {
		EO_NONE  = 2'b00,
		EO_ZERO  = 2'b01,
		EO_SIGN  = 2'b10
	} ExtOp_t;
	
	typedef struct packed
	{
		IMMType_t   IT;	//Imm type
		Const_t     CV;	//Const value
		ALUSource_t AS;	//ALU source
		ExtOp_t     EO;	//Extend operation
	} ALUInput_t;
	
	typedef enum bit[2:0] {
		SS_NONE = 3'b000,
		SS_REG  = 3'b001,
		SS_IMM  = 3'b010,
		SS_CONST= 3'b011,
		SS_FS   = 3'b100
	} ShiftSrc_t;
	
	typedef struct packed
	{
		ShiftSrc_t  AMS;	//Shift amount	source
		bit [ 2: 0] SHOP;	//Shift operation	
	} Shift_t;
	
	typedef enum bit[3:0] {
		MDO_NOP     = 4'b0000,
		MDO_MULINIT = 4'b0001,
		MDO_MULCHK  = 4'b0010,
		MDO_MULSTEP = 4'b0011,
		MDO_DIVINIT = 4'b0100,
		MDO_DIVDVNT = 4'b0101,
		MDO_DIVDVSR = 4'b0110,
		MDO_DIVSTEP = 4'b0111,
		MDO_DIVQUOT = 4'b1000
	} MulDivOp_t;
	
	typedef enum bit[2:0] {
		MDA_NOP  = 3'b000,
		MDA_ZERO = 3'b001,
		MDA_MULT = 3'b010,
		MDA_DIV  = 3'b011,
		MDA_LDL  = 3'b100,
		MDA_LDH  = 3'b101,
		MDA_NEG  = 3'b110
	} MulDivACC_t;
	
	typedef enum bit[2:0] {
		MDSH_NOP  = 3'b000,
		MDSH_MULT = 3'b001,
		MDSH_DIV  = 3'b010,
		MDSH_LDM  = 3'b011,
		MDSH_LDD  = 3'b100
	} MulDivSh_t;
	
	typedef struct packed
	{
		MulDivOp_t  OP;	//MUL/DIV operation
		MulDivACC_t ACCS;	//MUL/DIV ACC source	
		MulDivSh_t  SHS;	//MUL/DIV shift source	
	} MulDiv_t;
	
	typedef enum bit[2:0] {
		FSI_F  = 3'b000,
		FSI_PS = 3'b001,
		FSI_PW = 3'b010,
		FSI_8  = 3'b011,
		FSI_16 = 3'b100,
		FSI_32 = 3'b101
	} FSImm_t;
	
	typedef struct packed
	{
		FSImm_t     FSI;	//Field size value
		bit         FE;	//Field extend
	} FieldType_t;
	
	typedef enum bit[2:0] {
		MAS_RA   = 3'b000,
		MAS_RB   = 3'b001,
		MAS_RAIW = 3'b010,
		MAS_RBIW = 3'b011,
		MAS_IL   = 3'b100,
		MAS_IO   = 3'b101,
		MAS_VEC  = 3'b110
	} MASource_t;
	
	typedef enum bit[2:0] {
		MDS_REGA = 3'b000,
		MDS_REGB = 3'b001,
		MDS_PC   = 3'b010,
		MDS_ST   = 3'b011,
		MDS_MEM  = 3'b100,
		MDS_PIX  = 3'b101
	} MDSource_t;
	
	typedef enum bit[1:0] {
		MS_LONG  = 2'b00,
		MS_FIELD = 2'b01,
		MS_BYTE  = 2'b10
	} MemSize_t;
	
	typedef enum bit[1:0] {
		MA_NONE  = 2'b00,
		MA_READ  = 2'b01,
		MA_WRITE = 2'b10
	} MemAccess_t;
	
	typedef enum bit[0:0] {
		MT_DATA  = 1'b0,
		MT_PIX   = 1'b1
	} MemType_t;
	
	typedef struct packed
	{
		MASource_t  AS;	//Memory address source
		MDSource_t  DS;	//Memory data source
		MemAccess_t AT;	//Data memory access type
		MemType_t   MT;	//Memory data type
	} Mem_t; 
	
	typedef enum bit[2:0] {
		RS_REGA = 3'b000,
		RS_REGB = 3'b001,
		RS_ALU  = 3'b010,
		RS_MEM  = 3'b011,
//		RS_PIX  = 3'b100,
		RS_PC   = 3'b101,
		RS_ST   = 3'b110,
		RS_REV  = 3'b111
	} RegSrc_t;
	
	typedef struct packed
	{
		RegSrc_t    WS;	//Register write source
		bit         WE;	//Register write enable
	} RegDest_t;
	
	typedef enum bit[2:0] {
		JC_NONE = 3'b000,
		JC_JUMP = 3'b001,
		JC_COND = 3'b010,
		JC_DS   = 3'b011,
		JC_DSZ  = 3'b100,
		JC_DSNZ = 3'b101
	} JumpCond_t;
	
	typedef enum bit[1:0] {
		CNVS_NO = 2'b00,
		CNVS_DP = 2'b01,
		CNVS_SP = 2'b10,
		CNVS_MP = 2'b11
	} ConvSrc_t;
	
	typedef enum bit[3:0] {
		PIXOP_NOP  = 4'b0000,
		PIXOP_PPW  = 4'b0001,
		PIXOP_XYL  = 4'b0010,
		PIXOP_XYS  = 4'b0011,
		PIXOP_MOVX = 4'b0100,
		PIXOP_MOVY = 4'b0101,
		PIXOP_OFFS = 4'b0110,
		PIXOP_LNS  = 4'b0111,
		PIXOP_WSTA = 4'b1000
	} PixALUOp_t;
	
	typedef enum bit[1:0] {
		PIXAS_REGA  = 2'b00,
		PIXAS_REGB  = 2'b01
	} PixALUSrc_t;
	
	typedef struct packed
	{
		PixALUOp_t  AOP;	//ALU operation
		PixALUSrc_t AS;	//ALU source
		ConvSrc_t   CNVS;	//
	} PixALU_t;
	
	
	typedef enum bit[1:0] {
		POFFS_NONE  = 2'b00,
		POFFS_INIT  = 2'b01,
		POFFS_NEXT  = 2'b10
	} PixOffs_t;
	
	typedef enum bit[2:0] {
		PBLT_NONE  = 3'b000,
		PBLT_STRT  = 3'b001,
		PBLT_NEXT  = 3'b010,
		PBLT_BMLD  = 3'b011,
		PBLT_STEP  = 3'b100,
		PBLT_DRAW  = 3'b101
	} PixBlt_t;
	
	typedef enum bit[1:0] {
		WIN_NONE  = 2'b00,
		WIN_INIT  = 2'b01,
		WIN_CHECK = 2'b10,
		WIN_DADJ  = 2'b11
	} PixWin_t;
	
	typedef enum bit[1:0] {
		PLN_NONE  = 2'b00,
		PLN_INIT  = 2'b01,
		PLN_COND  = 2'b10,
		PLN_STEP  = 2'b11
	} PixLine_t;
	
	typedef struct packed
	{
		PixBlt_t    BLT;	//pixblt action 
		PixOffs_t   OFFS; //address offset action
		PixWin_t    WIN;	//Window action 
		PixLine_t   LINE;	//Line action 
	} PixFunc_t;
	
	typedef enum bit[2:0] {
		PATS_NULL = 3'b000,
		PATS_MEM  = 3'b001,
		PATS_REG  = 3'b010,
		PATS_B    = 3'b011,
		PATS_LN   = 3'b100,
		PATS_COL0 = 3'b101,
		PATS_COL1 = 3'b110
	} PixPatt_t;
	
	typedef struct packed
	{
		PixPatt_t   PATS; //Pixel patter source
	} PixOut_t;
	
	typedef enum bit[3:0] {
		STU_NONE = 4'b0000,
		STU_ST   = 4'b0001,
		STU_FS   = 4'b0010,
		STU_EXFS = 4'b0011,
		STU_MEM  = 4'b0100,
		STU_RES  = 4'b0101,
		STU_ALU  = 4'b0110,
		STU_C    = 4'b0111,
		STU_IE   = 4'b1000
	} STUpdate_t;
	
	typedef struct packed
	{
		STUpdate_t  STU;	//STATUS register update
		bit [ 3: 0] AFU;	//ALU flag update
	} StatWrite_t;
	
	typedef enum bit[2:0] {
		PCS_NONE = 3'b000,
		PCS_REG  = 3'b001,
		PCS_MEM  = 3'b010,
		PCS_K    = 3'b011,
		PCS_IB   = 3'b100,
		PCS_IW   = 3'b101,
		PCS_IL   = 3'b110
	} PCSource_t;
	
	typedef struct packed
	{
		bit [ 3: 0] RD;	//Destination register number
		bit [ 3: 0] RS;	//Source register number
		bit         R;		//Register file (0-A,1-B)
		bit         M;		//Register file move
		bit         F;		//Field select	
		ALUInput_t  AIA;	//ALU input A
		ALUInput_t  AIB;	//ALU input B
		ALU_t       ALU;
		Shift_t     SHC;	//Shifter control	
		MulDiv_t    MDC;	//MUL/DIV control	
		bit [ 1: 0] IWL;	//Instruction word load (0-2 words)		
		FieldType_t FT;	//Field type
		Mem_t       MC;	//Memory control ()
		bit         MMS;	//MMxM start
		bit         MMA;	//MMxM access
		RegDest_t   RWA;	//Register write A
		RegDest_t   RWB;	//Register write B
		JumpCond_t  JC;	//Jump condition
		PixALU_t    PALU; //Pixel function ALU
		PixFunc_t   PF;
		PixOut_t    PIXO; //Pixel out
		StatWrite_t STW;	//STATUS write 
		PCSource_t  PCS;	//PC source 
		bit         PCW;	//PC write
		bit [ 4: 0] NST;	//Next state
		bit         LST;	//Last state		
		bit         ILI;	//Illegal instruction 
	} DecInstr_t; 
	
	parameter bit [ 1: 0] IW_NONE = 2'b00;
	parameter bit [ 1: 0] IW_WORD = 2'b01;
	parameter bit [ 1: 0] IW_LONG = 2'b11; 
	
	parameter bit [ 3: 0] AFU_NCZV = 4'b1111;
	parameter bit [ 3: 0] AFU_NCZ  = 4'b1110;
	parameter bit [ 3: 0] AFU_NZV  = 4'b1011;
	parameter bit [ 3: 0] AFU_NZ   = 4'b1010;
	parameter bit [ 3: 0] AFU_ZV   = 4'b0011;
	parameter bit [ 3: 0] AFU_CZ   = 4'b0110;
	parameter bit [ 3: 0] AFU_N    = 4'b1000;
	parameter bit [ 3: 0] AFU_C    = 4'b0100;
	parameter bit [ 3: 0] AFU_Z    = 4'b0010;
	parameter bit [ 3: 0] AFU_V    = 4'b0001;
		
	typedef struct packed
	{
		bit [15: 0] Y;
		bit [15: 0] X;	
	} XY_t;
	
	function bit [31:0] Swap(input bit [31:0] data, input bit [5:0] fs, input bit [1:0] op);
		bit [31: 0] res;
		
		case (op)
			2'b00: res = data;
			2'b01: res = {data[15:0],data[31:16]};
			2'b10: res = {data[31:16],data[7:0],data[15:8]};
			2'b11: res = data;
		endcase
	
		return res;
	endfunction 
	
	function bit [31:0] Ext(input bit [31:0] data, input bit [5:0] fs, input bit [1:0] op);
		bit [31: 0] mask;
		bit         sign;
		bit [31: 0] res;
		
		mask = 32'hFFFFFFFF<<fs;
		sign = data[fs[4:0]-1];
		casex ({sign,op})
			3'bx00: res = data;
			3'bx01: res = data & ~mask;
			3'b010: res = data & ~mask;
			3'b110: res = data |  mask;
			default: res = data;
		endcase
	
		return res;
	endfunction 
	
	function bit [31:0] Shift(input bit [31:0] val, input bit [4:0] sa, input bit [2:0] code);
		bit [31: 0] tmp0, tmp1, tmp2, tmp3, tmp4;
		bit [ 4: 0] s;
		bit         rot,arith,dir;
		
		s = (sa ^ {5{code[0]}}) + {4'b0000,code[0]};
		{rot,arith,dir} = code[2:0];
		
		tmp0 = !s[0] ?  val : (dir ? { { 1{ val[31]}}&{ 1{arith}}, val[31: 1]} : { val[30:0], val[31:31]&{ 1{rot}} });
		tmp1 = !s[1] ? tmp0 : (dir ? { { 2{tmp0[31]}}&{ 2{arith}},tmp0[31: 2]} : {tmp0[29:0],tmp0[31:30]&{ 2{rot}} });
		tmp2 = !s[2] ? tmp1 : (dir ? { { 4{tmp1[31]}}&{ 4{arith}},tmp1[31: 4]} : {tmp1[27:0],tmp1[31:28]&{ 4{rot}} });
		tmp3 = !s[3] ? tmp2 : (dir ? { { 8{tmp2[31]}}&{ 8{arith}},tmp2[31: 8]} : {tmp2[23:0],tmp2[31:24]&{ 8{rot}} });
		tmp4 = !s[4] ? tmp3 : (dir ? { {16{tmp3[31]}}&{16{arith}},tmp3[31:16]} : {tmp3[15:0],tmp3[31:16]&{16{rot}} });
		return tmp4;
	endfunction
	
	function bit [16:0] CarryAdder16(input bit [15:0] a, input bit [15:0] b, input bit ci);
		bit [16: 0] sum;
		
		sum = {1'b0,a} + {1'b0,b} + {{16{1'b0}},ci};
		
		return sum;
	endfunction 
	
	function bit [32:0] CarryAdder(input bit [31:0] a, input bit [31:0] b, input bit ci, input bit [1:0] code, input bit bcomp, input bit xy);
		bit         ci2;
		bit [31: 0] b2;
		bit [31: 0] res;
		bit         co0,co;
		
		b2 = b ^ {32{bcomp}};
		ci2 = code[1] ? ci ^ code[0] : code[0];

		{co0,res[15: 0]} = CarryAdder16(a[15: 0], b2[15: 0], ci2);
		{co ,res[31:16]} = CarryAdder16(a[31:16], b2[31:16], xy ? ci2 : co0);
		
		
		return {co ^ code[0],res};
	endfunction
		
	function bit [31:0] Logger(input bit [31:0] a, input bit [31:0] b, input bit [3:0] code);
		bit [31: 0] b2;
		bit [31: 0] bmask;
		bit [31: 0] res;
		
		b2 = b ^ {32{code[0]}};
		bmask = 32'h00000001<<b2[4:0];
		casex (code[2:1])
			2'b00: res = a & b2;
			2'b01: res = a | b2;
			2'b10: res = a ^ b2;
			2'b11: res = a & bmask;
		endcase
	
		return res;
	endfunction 
	
	function bit [32:0] CarryShifter(input bit [31:0] val, input bit [4:0] sa, input bit [3:0] code);
		bit [31: 0] tmp0, tmp1, tmp2, tmp3, tmp4;
		bit         cl0, cl1, cl2, cl3, cl4;
		bit         cr0, cr1, cr2, cr3, cr4;
		bit [ 4: 0] s;
		bit         rot,arith,dir;
		
		s = (sa ^ {5{code[0]}}) + {4'b0000,code[0]};
		{rot,arith,dir} = code[2:0];
		
		{cl0,tmp0,cr0} = !s[0] ? {1'b0, val,1'b0} : (dir ? { 1'b0,{ 1{ val[31]}}&{ 1{arith}}, val[31: 1], val[ 0]} : { val[31], val[30:0], val[31:31]&{ 1{rot}},1'b0 });
		{cl1,tmp1,cr1} = !s[1] ? { cl0,tmp0, cr0} : (dir ? { 1'b0,{ 2{tmp0[31]}}&{ 2{arith}},tmp0[31: 2],tmp0[ 1]} : {tmp0[30],tmp0[29:0],tmp0[31:30]&{ 2{rot}},1'b0 });
		{cl2,tmp2,cr2} = !s[2] ? { cl1,tmp1, cr1} : (dir ? { 1'b0,{ 4{tmp1[31]}}&{ 4{arith}},tmp1[31: 4],tmp1[ 3]} : {tmp1[28],tmp1[27:0],tmp1[31:28]&{ 4{rot}},1'b0 });
		{cl3,tmp3,cr3} = !s[3] ? { cl2,tmp2, cr2} : (dir ? { 1'b0,{ 8{tmp2[31]}}&{ 8{arith}},tmp2[31: 8],tmp2[ 7]} : {tmp2[24],tmp2[23:0],tmp2[31:24]&{ 8{rot}},1'b0 });
		{cl4,tmp4,cr4} = !s[4] ? { cl3,tmp3, cr3} : (dir ? { 1'b0,{16{tmp3[31]}}&{16{arith}},tmp3[31:16],tmp3[15]} : {tmp3[16],tmp3[15:0],tmp3[31:16]&{16{rot}},1'b0 });
		return {dir?cr4:cl4,tmp4};
	endfunction
	
	function bit ShiftLeftOvf(input bit [31:0] val, input bit [4:0] sa);
		bit [31: 0] tmp0, tmp1, tmp2, tmp3, tmp4;
		bit         one0, one1, one2, one3, one4;
		bit         zero0, zero1, zero2, zero3, zero4;
				
		{zero0,one0,tmp0} = !sa[0] ? {1'b0,1'b0, val} : { ~& val[31:31], | val[31:31],  val[30:0], { 1{1'b0}} };
		{zero1,one1,tmp1} = !sa[1] ? {1'b0,1'b0,tmp0} : { ~&tmp0[31:30], |tmp0[31:30], tmp0[29:0], { 2{1'b0}} };
		{zero2,one2,tmp2} = !sa[2] ? {1'b0,1'b0,tmp1} : { ~&tmp1[31:28], |tmp1[31:28], tmp1[27:0], { 4{1'b0}} };
		{zero3,one3,tmp3} = !sa[3] ? {1'b0,1'b0,tmp2} : { ~&tmp2[31:24], |tmp2[31:24], tmp2[23:0], { 8{1'b0}} };
		{zero4,one4,tmp4} = !sa[4] ? {1'b0,1'b0,tmp3} : { ~&tmp3[31:16], |tmp3[31:16], tmp3[15:0], {16{1'b0}} };
		
		return val[31] ? zero1|zero2|zero3|zero4 : one1|one2|one3|one4;
	endfunction
	
	function bit [4:0] OneLocate(input bit [31:0] val, input bit dir);
		bit [ 4: 0] res;
		bit [15: 0] tmp0;
		bit [ 7: 0] tmp1;
		bit [ 3: 0] tmp2;
		bit [ 1: 0] tmp3;
		bit [ 0: 0] tmp4;
		
		tmp0 = !dir ? ( val[31:16] ?  val[31:16] :  val[15: 0]) : ( val[15: 0] ?  val[15: 0] :  val[31:16]);
		tmp1 = !dir ? (tmp0[15: 8] ? tmp0[15: 8] : tmp0[ 7: 0]) : (tmp0[ 7: 0] ? tmp0[ 7: 0] : tmp0[15: 8]);
		tmp2 = !dir ? (tmp1[ 7: 4] ? tmp1[ 7: 4] : tmp1[ 3: 0]) : (tmp1[ 3: 0] ? tmp1[ 3: 0] : tmp1[ 7: 4]);
		tmp3 = !dir ? (tmp2[ 3: 2] ? tmp2[ 3: 2] : tmp2[ 1: 0]) : (tmp2[ 1: 0] ? tmp2[ 1: 0] : tmp2[ 3: 2]);
		tmp4 = !dir ? (tmp3[ 1: 1] ? tmp3[ 1: 1] : tmp3[ 0: 0]) : (tmp3[ 0: 0] ? tmp3[ 0: 0] : tmp3[ 1: 1]);
		
		res[4] = !dir ? | val[31:16] : | val[15: 0];
		res[3] = !dir ? |tmp0[15: 8] : |tmp0[ 7: 0];
		res[2] = !dir ? |tmp1[ 7: 4] : |tmp1[ 3: 0];
		res[1] = !dir ? |tmp2[ 3: 2] : |tmp2[ 1: 0];
		res[0] = !dir ? |tmp3[ 1: 1] : |tmp3[ 0: 0];
		
		return res ^ {5{~dir}};
	endfunction
	
	
	function bit [64:0] MDCarryAdder(input bit [63:0] a, input bit [63:0] b, input bit [1:0] code, input bit bcomp);
		bit [63: 0] b2;
		bit [63: 0] res;
		bit         co;
		
		b2 = b ^ {64{bcomp}};
		{co,res} = {1'b0,a} + {1'b0,b2} + {{64{1'b0}},code[0]};		
		
		return {co ^ code[0],res};
	endfunction
	
	function bit [63:0] MultStep(input bit [31:0] a, input bit [31:0] b, input bit [4:0] s);
		bit [63: 0] m0;
		bit [63: 0] m1;
		
		m0 = b[s  ] ? ({{32{a[31]}},a}<<s)     : '0;
		m1 = b[s+1] ? ({{32{a[31]}},a}<<(s+1)) : '0;
		
		return m0 + m1;
	endfunction
	
	function bit [63:0] MultStep2(input bit [31:0] a, input bit [1:0] b, input bit [4:0] s);
		bit [63: 0] m0;
		bit [63: 0] m1;
		
		m0 = b[0] ? ({{32{a[31]}},a}<<(s+0)) : '0;
		m1 = b[1] ? ({{32{a[31]}},a}<<(s+1)) : '0;
		
		return m0 + m1;
	endfunction
	
	function bit [63:0] Neg64(input bit [63:0] a, input bit en);
		bit [63: 0] res;
		
		res = (a ^ {64{en}}) + en;
		
		return res;
	endfunction
	
	function bit [3:0] BitToReg(input bit [15:0] val, input bit [3:0] currbit, input bit dir);
		bit [ 3: 0] res;
		bit [15: 0] mask;
		bit [15: 0] val0;
		bit [ 7: 0] tmp0;
		bit [ 3: 0] tmp1;
		bit [ 1: 0] tmp2;
		bit [ 0: 0] tmp3;
		
		mask = 16'hFFFF>>currbit;
		val0 = val & mask;
		
		tmp0 = !dir ? (val0[15: 8] ? val0[15: 8] : val0[ 7: 0]) : (val0[ 7: 0] ? val0[ 7: 0] : val0[15: 8]);
		tmp1 = !dir ? (tmp0[ 7: 4] ? tmp0[ 7: 4] : tmp0[ 3: 0]) : (tmp0[ 3: 0] ? tmp0[ 3: 0] : tmp0[ 7: 4]);
		tmp2 = !dir ? (tmp1[ 3: 2] ? tmp1[ 3: 2] : tmp1[ 1: 0]) : (tmp1[ 1: 0] ? tmp1[ 1: 0] : tmp1[ 3: 2]);
		tmp3 = !dir ? (tmp2[ 1: 1] ? tmp2[ 1: 1] : tmp2[ 0: 0]) : (tmp2[ 0: 0] ? tmp2[ 0: 0] : tmp2[ 1: 1]);
		
		res[3] = !dir ? |val0[15: 8] : |val0[ 7: 0];
		res[2] = !dir ? |tmp0[ 7: 4] : |tmp0[ 3: 0];
		res[1] = !dir ? |tmp1[ 3: 2] : |tmp1[ 1: 0];
		res[0] = !dir ? |tmp2[ 1: 1] : |tmp2[ 0: 0];
		
		return res;
	endfunction
	
	function bit [33:0] XYAdjust(input bit [31:0] a, input bit [31:0] max, input bit en);
		bit [15: 0] x,y;
		bit [15: 0] maxx,maxy;
		bit [15: 0] tmpy;
		bit [15: 0] resx,resy;
		bit         cox,coy;

		{y,x} = a;
		{maxy,maxx} = max;
		
		{cox,resx} = {1'b0,x};
		{coy,resy} = {1'b0,y};
		tmpy = '0;
		if (en) begin
			if (x >= maxx) begin
				{cox,resx} = {1'b1,16'h0000};
				{coy,tmpy} = {1'b0,y+16'h1};
			end else begin
				{cox,resx} = {1'b0,x};
				{coy,tmpy} = {1'b0,y};
			end
			if (tmpy >= maxy) begin
				{coy,resy} = {1'b1,16'h0000};
			end else begin
				{coy,resy} = {1'b0,tmpy};
			end
		end
		
		return {coy,cox,resy,resx};
	endfunction
	
	function bit [3:0] XYCompareWin(input bit [31:0] v, input bit [31:0] min, input bit [31:0] max);
		bit [15: 0] minxs;
		bit [15: 0] minys;
		bit [15: 0] maxxs;
		bit [15: 0] maxys;
		
		minxs = v[15: 0] - min[15: 0];
		minys = v[31:16] - min[31:16];
		maxxs = max[15: 0] - v[15: 0];
		maxys = max[31:16] - v[31:16];

		return {maxys[15],minys[15],maxxs[15],minxs[15]};
	endfunction
	
	function XY_t XYWinOffset(input XY_t v, input XY_t ws);
		XY_t res;
		
		res.X = ws.X > v.X ? ws.X - v.X : '0;
		res.Y = ws.Y > v.Y ? ws.Y - v.Y : '0;

		return res;
	endfunction
	
	function XY_t WinAdjust(input XY_t dydx, input XY_t wstart, input XY_t wend, input bit wen);
		XY_t res;
		bit [15: 0] wdx,wdy;
		
		wdx = wend.X - wstart.X + 16'd1;
		wdy = wend.Y - wstart.Y + 16'd1;
		res.X = wen && wdx < dydx.X ? wdx : dydx.X;
		res.Y = wen && wdy < dydx.Y ? wdy : dydx.Y;

		return res;
	endfunction
	
	function bit [31:0] XYToL(input XY_t coord, input bit [5:0] ps, input bit [4:0] xp);
		bit [31: 0] xtol;
		bit [31: 0] ytol;
		
		case (ps)
			default: xtol = { {16{coord.X[15]}},coord.X };
			6'h01:   xtol = { {16{coord.X[15]}},coord.X };
			6'h02:   xtol = { {15{coord.X[15]}},coord.X,1'b0 };
			6'h04:   xtol = { {14{coord.X[15]}},coord.X,2'b00 };
			6'h08:   xtol = { {13{coord.X[15]}},coord.X,3'b000 };
			6'h10:   xtol = { {12{coord.X[15]}},coord.X,4'b0000 };
			6'h20:   xtol = { {11{coord.X[15]}},coord.X,5'b00000 };
		endcase
		ytol = { {16{coord.Y[15]}},coord.Y } << (~xp);
		
		return xtol + ytol;
	endfunction
	
	function bit [31:0] XStep(input bit [5:0] ps);
		bit [15: 0] x;
		
		case (ps)
			default: x = 16'h0000;
			6'h01: x = 16'h0020;
			6'h02: x = 16'h0010;
			6'h04: x = 16'h0008;
			6'h08: x = 16'h0004;
			6'h10: x = 16'h0002;
			6'h20: x = 16'h0001;
		endcase

		return {16'h0000,x};
	endfunction
	
	function bit [31:0] LineStep(input XY_t dydx, input bit gz);
		bit [15: 0] a,b;
		bit [31: 0] res;
		
		{b,a} = dydx;
		res = {{15{b[15]}},b,1'b0} - (gz ? {{15{a[15]}},a,1'b0} : 32'h0);//2b-2a

		return res;
	endfunction
	
	function bit [4:0] PSToShift(input bit [5:0] ps);
		bit [ 4: 0] res;
		
		case (ps)
			16'h0001: res = 5'd0;
			16'h0002: res = 5'd1;
			16'h0004: res = 5'd2;
			16'h0008: res = 5'd3;
			16'h0010: res = 5'd4;
			16'h0020: res = 5'd5;
			default:  res = 5'd0;
		endcase
		
		return res;
	endfunction
	
	
	function bit [5:0] PPWToFS(input bit [5:0] ppw, input bit [5:0] ps);
		bit [ 5: 0] res;
		
		case (ps)
			6'h01: res = {ppw[5:0]};
			6'h02: res = {ppw[4:0],1'b0};
			6'h04: res = {ppw[3:0],2'b00};
			6'h08: res = {ppw[2:0],3'b000};
			6'h10: res = {ppw[1:0],4'b0000};
			6'h20: res = {ppw[0:0],5'b00000};
			default: res = 5'd0;
		endcase
		
		return res;
	endfunction
	
	function bit [31:0] PatternExpand(input bit [31:0] bset, input bit [31:0] c0, input bit [31:0] c1, input bit [4:0] px, input bit [5:0] ps);
		bit [31: 0] res;
		bit [31: 0] mask;
		
		case (ps)
			6'h01: mask = bset;
			6'h02: mask = { { 2{bset[px+15]}},{ 2{bset[px+14]}},{2{bset[px+13]}},{2{bset[px+12]}},{2{bset[px+11]}},{2{bset[px+10]}},{2{bset[px+9]}},{2{bset[px+8]}},
			                { 2{bset[px+ 7]}},{ 2{bset[px+ 6]}},{2{bset[px+ 5]}},{2{bset[px+ 4]}},{2{bset[px+ 3]}},{2{bset[px+ 2]}},{2{bset[px+1]}},{2{bset[px+0]}} };
			6'h04: mask = { { 4{bset[px+ 7]}},{ 4{bset[px+ 6]}},{4{bset[px+ 5]}},{4{bset[px+ 4]}},{4{bset[px+ 3]}},{4{bset[px+ 2]}},{4{bset[px+1]}},{4{bset[px+0]}} };
			6'h08: mask = { { 8{bset[px+ 3]}},{ 8{bset[px+ 2]}},{8{bset[px+ 1]}},{8{bset[px+ 0]}} };
			6'h10: mask = { {16{bset[px+ 1]}},{16{bset[px+ 0]}} };
			6'h20: mask = { {32{bset[px+ 0]}} };
			default: mask = 5'd0;
		endcase
		res = (c0 & ~mask) | (c1 & mask);
		
		return res;
	endfunction
	
	function bit [31:0] PatternEqual(input bit [31:0] pat, input bit [31:0] col, input bit [5:0] ps);
		bit [31: 0] res;
		bit [31: 0] temp;
		bit [15: 0] m2;
		bit [ 7: 0] m4;
		bit [ 3: 0] m8;
		bit [ 1: 0] m16;
		
		temp = pat ^ ~col;
//		m2  = { {2{&temp[31:30]}},{2{&temp[29:28]}},{2{&temp[27:26]}},{2{&temp[25:24]}},{2{&temp[23:22]}},{2{&temp[21:20]}},{2{&temp[19:18]}},{2{&temp[17:16]}},
//		        {2{&temp[15:14]}},{2{&temp[13:12]}},{2{&temp[11:10]}},{2{&temp[ 9: 8]}},{2{&temp[ 7: 6]}},{2{&temp[ 5: 4]}},{2{&temp[ 3: 2]}},{2{&temp[ 1: 0]}} };
//		m4  = { {2{&  m2[15:14]}},{2{&  m2[13:12]}},{2{&  m2[11:10]}},{2{&  m2[ 9: 8]}},{2{&  m2[ 7: 6]}},{2{&  m2[ 5: 4]}},{2{&  m2[ 3: 2]}},{2{&  m2[ 1: 0]}} };
//		m8  = { {2{&  m4[ 7: 6]}},{2{&  m4[ 5: 4]}},{2{&  m4[ 3: 2]}},{2{&  m4[ 1: 0]}} };
//		m16 = { {2{&  m8[ 3: 2]}},{2{&  m8[ 1: 0]}} };
		
		case (ps)
			6'h01: res = '1;
			6'h02: res = { { 2{&temp[31:30]}},{ 2{&temp[29:28]}},{2{&temp[27:26]}},{2{&temp[25:24]}},{2{&temp[23:22]}},{2{&temp[21:20]}},{2{&temp[19:18]}},{2{&temp[17:16]}},
			               { 2{&temp[15:14]}},{ 2{&temp[13:12]}},{2{&temp[11:10]}},{2{&temp[ 9: 8]}},{2{&temp[ 7: 6]}},{2{&temp[ 5: 4]}},{2{&temp[ 3: 2]}},{2{&temp[ 1: 0]}} };
			6'h04: res = { { 4{&temp[31:28]}},{ 4{&temp[27:24]}},{4{&temp[23:20]}},{4{&temp[19:16]}},{4{&temp[15:12]}},{4{&temp[11: 8]}},{4{&temp[ 7: 4]}},{4{&temp[ 3: 0]}} };
			6'h08: res = { { 8{&temp[31:24]}},{ 8{&temp[23:16]}},{8{&temp[15: 8]}},{8{&temp[ 7: 0]}} };
			6'h10: res = { {16{&temp[31:16]}},{16{&temp[15: 0]}} };
			6'h20: res = { {32{&temp[31: 0]}} };
			default: res = 5'd0;
		endcase
		
		return res;
	endfunction
	
	function bit [63:0] DataWriteMask(input bit [4:0] ba, input bit [5:0] fsize);
		bit [63:0] res;
		bit [63:0] lmask,rmask;
		
		lmask = 64'hFFFFFFFFFFFFFFFF<<ba;
		rmask = 64'hFFFFFFFFFFFFFFFF<<(fsize+ba);
		res = lmask & ~rmask;
		
		return res;
	endfunction
	
//	function bit [63:0] PixWriteMask(input bit [4:0] ba, input bit [5:0] fsize);
//		bit [63:0] res;
//		bit [63:0] lmask,rmask;
//		
//		lmask = 64'hFFFFFFFFFFFFFFFF<<ba;
//		rmask = 64'hFFFFFFFFFFFFFFFF<<(fsize+ba);
//		res = lmask & ~rmask;
//		
//		return res;
//	endfunction
	
	function bit [31:0] InAligner(input bit [31:0] data, input bit [31:0] old, input bit [4:0] ba, input bit [5:0] fsize);
		bit [31:0] res;
		bit [31:0] mask;
		
		mask = 32'hFFFFFFFF<<fsize;
		res = ((data>>ba) & ~mask) | (old & mask);
		
		return res;
	endfunction
	
	function bit [31:0] InAlignerExt(input bit [31:0] data, input bit [31:0] old, input bit [5:0] fsize, input bit [5:0] fsize_old);
		bit [31:0] res;
		bit [31:0] mask,omask;
		
		mask = 32'hFFFFFFFF<<fsize;
		omask = 32'hFFFFFFFF<<fsize_old;
		res = ((data << fsize_old) & ~mask) | (old & ~omask);
		
		return res;
	endfunction
	
	function bit [31:0] OutAligner(input bit [31:0] data, input bit [31:0] old, input bit [4:0] ba, input bit [5:0] fsize);
		bit [31:0] res;
		bit [31:0] bmask,fbmask;
		
		bmask = 32'hFFFFFFFF<<ba; 
		fbmask = 32'hFFFFFFFF<<(fsize+ba);
		res = ((data<<ba) & ~fbmask) | (old & (fbmask | ~bmask));
		
		return res;
	endfunction
	
	function bit [31:0] OutAlignerExt(input bit [31:0] data, input bit [31:0] old, input bit [4:0] ba_old, input bit [5:0] fsize);
		bit [31:0] res;
		bit [31:0] bmask,fbmask;
		
//		bmask = 32'hFFFFFFFF<<ba; 
		fbmask = 32'hFFFFFFFF<<(fsize[4:0]+ba_old);
		res = ((data>>(5'h00-ba_old)) & ~fbmask) | (old & fbmask);
		
		return res;
	endfunction
	
	typedef struct packed
	{
		bit         N;
		bit         C;
		bit         Z;
		bit         V;
		bit         UNUSED;
		bit         BF;
		bit         IX;
		bit [ 1: 0] UNUSED2;
		bit         SS;
		bit         IE;
		bit [ 8: 0] UNUSED3;
		bit         FE1;
		bit [ 4: 0] FS1;
		bit         FE0;
		bit [ 4: 0] FS0;
	} ST_t;
	parameter bit [31:0] ST_WMASK = 32'hF6600FFF;
	parameter bit [31:0] ST_RMASK = 32'hF6600FFF;
	parameter bit [31:0] ST_INIT = 32'h00000010;
	
	//IO registers
	typedef bit [15:0] VESYNC_t;		//R/W;C0000000
	parameter bit [15:0] VESYNC_WMASK = 16'hFFFF;
	parameter bit [15:0] VESYNC_RMASK = 16'hFFFF;
	parameter bit [15:0] VESYNC_INIT = 16'h0000;
	
	typedef bit [15:0] HESYNC_t;		//R/W;C0000010
	parameter bit [15:0] HESYNC_WMASK = 16'hFFFF;
	parameter bit [15:0] HESYNC_RMASK = 16'hFFFF;
	parameter bit [15:0] HESYNC_INIT = 16'h0000;
	
	typedef bit [15:0] VEBLNK_t;		//R/W;C0000020
	parameter bit [15:0] VEBLNK_WMASK = 16'hFFFF;
	parameter bit [15:0] VEBLNK_RMASK = 16'hFFFF;
	parameter bit [15:0] VEBLNK_INIT = 16'h0000; 
	
	typedef bit [15:0] HEBLNK_t;		//R/W;C0000030
	parameter bit [15:0] HEBLNK_WMASK = 16'hFFFF;
	parameter bit [15:0] HEBLNK_RMASK = 16'hFFFF;
	parameter bit [15:0] HEBLNK_INIT = 16'h0000; 
	
	typedef bit [15:0] VSBLNK_t;		//R/W;C0000040
	parameter bit [15:0] VSBLNK_WMASK = 16'hFFFF;
	parameter bit [15:0] VSBLNK_RMASK = 16'hFFFF;
	parameter bit [15:0] VSBLNK_INIT = 16'h0000; 
	
	typedef bit [15:0] HSBLNK_t;		//R/W;C0000050
	parameter bit [15:0] HSBLNK_WMASK = 16'hFFFF;
	parameter bit [15:0] HSBLNK_RMASK = 16'hFFFF;
	parameter bit [15:0] HSBLNK_INIT = 16'h0000; 
	
	typedef bit [15:0] VTOTAL_t;		//R/W;C0000060
	parameter bit [15:0] VTOTAL_WMASK = 16'hFFFF;
	parameter bit [15:0] VTOTAL_RMASK = 16'hFFFF;
	parameter bit [15:0] VTOTAL_INIT = 16'h0000; 
	
	typedef bit [15:0] HTOTAL_t;		//R/W;C0000070
	parameter bit [15:0] HTOTAL_WMASK = 16'hFFFF;
	parameter bit [15:0] HTOTAL_RMASK = 16'hFFFF;
	parameter bit [15:0] HTOTAL_INIT = 16'h0000; 
	
	typedef struct packed		//R/W;C0000080
	{
		bit         ENV;
		bit         NIL;			//
		bit         UNUSED;		
		bit         SRE;			//
		bit         CST;			//
		bit [ 2: 0] UNUSED2;
		bit         VCD;			//
		bit         SSV;			//
		bit [ 1: 0] UNUSED3;
		bit         CVD;			
		bit         CSD;			
		bit         VSD;			
		bit         HSD;			
	} DPYCTL_t;
	parameter bit [15:0] DPYCTL_WMASK = 16'hD8CF;
	parameter bit [15:0] DPYCTL_RMASK = 16'hD8CF;
	parameter bit [15:0] DPYCTL_INIT = 16'h0000; 
	
	typedef bit [15:0] DPYSTRT_t;		//R/W;C0000090
	parameter bit [15:0] DPYSTRT_WMASK = 16'hFFFF;
	parameter bit [15:0] DPYSTRT_RMASK = 16'hFFFF;
	parameter bit [15:0] DPYSTRT_INIT = 16'h0000; 
	
	typedef bit [15:0] DPYINT_t;		//R/W;C00000A0
	parameter bit [15:0] DPYINT_WMASK = 16'hFFFF;
	parameter bit [15:0] DPYINT_RMASK = 16'hFFFF;
	parameter bit [15:0] DPYINT_INIT = 16'h0000; 
	
	typedef struct packed		//R/W;C00000B0/C0000190
	{
		bit         CD;			//
		bit [ 4: 0] PPOP;			//
		bit         PBV;			//		
		bit         PBH;			//
		bit [ 1: 0] W;				//
		bit         T;				//
		bit [ 1: 0] UNUSED;
		bit [ 2: 0] TM;			//
	} CONTROL_t;
	parameter bit [15:0] CONTROL_WMASK = 16'hFFE7;
	parameter bit [15:0] CONTROL_RMASK = 16'hFFE7;
	parameter bit [15:0] CONTROL_INIT = 16'h0000; 
	
	typedef bit [15:0] HSTDATA_t;		//R/W;C00000C0
	parameter bit [15:0] HSTDATA_WMASK = 16'hFFFF;
	parameter bit [15:0] HSTDATA_RMASK = 16'hFFFF;
	parameter bit [15:0] HSTDATA_INIT = 16'h0000; 
	
	typedef bit [15:0] HSTADRL_t;		//R/W;C00000D0
	parameter bit [15:0] HSTADRL_WMASK = 16'hFFFF;
	parameter bit [15:0] HSTADRL_RMASK = 16'hFFFF;
	parameter bit [15:0] HSTADRL_INIT = 16'h0000; 
	
	typedef bit [15:0] HSTADRH_t;		//R/W;C00000E0
	parameter bit [15:0] HSTADRH_WMASK = 16'hFFFF;
	parameter bit [15:0] HSTADRH_RMASK = 16'hFFFF;
	parameter bit [15:0] HSTADRH_INIT = 16'h0000;
	
	typedef struct packed		//R/W;C00000F0
	{
		bit         HBREN;		//
		bit         HBFI;
		bit         HRYI;			//
		bit         EMIEN;		//
		bit         EMG;			//		
		bit         EMR;			//
		bit [ 1: 0] UNUSED;
		bit         INTOUT;		//
		bit [ 2: 0] MSGOUT;		//
		bit         INTIN;		//
		bit [ 2: 0] MSGIN;
	} HSTCTLL_t;
	parameter bit [15:0] HSTCTLL_WMASK = 16'hFCFF;
	parameter bit [15:0] HSTCTLL_RMASK = 16'hFCFF;
	parameter bit [15:0] HSTCTLL_INIT = 16'h0000; 
	
	typedef struct packed		//R/W;C0000100
	{
		bit         HLT;			//
		bit         CF;			//
		bit         UNUSED;
		bit         HINC;			//
		bit         HPFW;			//
		bit         UNUSED2;
		bit         NMIM;			//		
		bit         NMI;			//
		bit         RST;			//
		bit [ 1: 0] HLB;			//
		bit         HACK;			//
		bit [ 3: 0] UNUSED3;
	} HSTCTLH_t;
	parameter bit [15:0] HSTCTLH_WMASK = 16'hDBF0;
	parameter bit [15:0] HSTCTLH_RMASK = 16'hDBF0;
	parameter bit [15:0] HSTCTLH_INIT = 16'h0000; 
	
	typedef struct packed		//R/W;C0000110
	{
		bit [ 3: 0] UNUSED;
		bit         WVE;			//
		bit         DIE;			//
		bit         HIE;			//
		bit [ 5: 0] UNUSED2;		
		bit         X2E;			//
		bit         X1E;			
		bit         UNUSED3;
	} INTENB_t;
	parameter bit [15:0] INTENB_WMASK = 16'h0E06;
	parameter bit [15:0] INTENB_RMASK = 16'h0E06;
	parameter bit [15:0] INTENB_INIT = 16'h0000; 
	
	typedef struct packed		//R/W;C0000120
	{
		bit [ 3: 0] UNUSED;
		bit         WVP;			//
		bit         DIP;			//
		bit         HIP;			//
		bit [ 5: 0] UNUSED2;		
		bit         X2P;			//
		bit         X1P;			
		bit         UNUSED3;
	} INTPEND_t;
	parameter bit [15:0] INTPEND_WMASK = 16'h0E06;
	parameter bit [15:0] INTPEND_RMASK = 16'h0E06;
	parameter bit [15:0] INTPEND_INIT = 16'h0000; 
	
	typedef bit [15:0] CONVSP_t;		//R/W;C0000130
	parameter bit [15:0] CONVSP_WMASK = 16'hFFFF;
	parameter bit [15:0] CONVSP_RMASK = 16'hFFFF;
	parameter bit [15:0] CONVSP_INIT = 16'h0000; 
	
	typedef bit [15:0] CONVDP_t;		//R/W;C0000140
	parameter bit [15:0] CONVDP_WMASK = 16'hFFFF;
	parameter bit [15:0] CONVDP_RMASK = 16'hFFFF;
	parameter bit [15:0] CONVDP_INIT = 16'h0000;
	
	typedef bit [15:0] PSIZE_t;		//R/W;C0000150
	parameter bit [15:0] PSIZE_WMASK = 16'hFFFF;
	parameter bit [15:0] PSIZE_RMASK = 16'hFFFF;
	parameter bit [15:0] PSIZE_INIT = 16'h0000;
	
	typedef bit [31:0] PMASK_t;		//R/W;C0000160
	parameter bit [31:0] PMASK_WMASK = 32'hFFFFFFFF;
	parameter bit [31:0] PMASK_RMASK = 32'hFFFFFFFF;
	parameter bit [31:0] PMASK_INIT = 32'h00000000;
	
	typedef bit [15:0] CONVMP_t;		//R/W;C0000180
	parameter bit [15:0] CONVMP_WMASK = 16'hFFFF;
	parameter bit [15:0] CONVMP_RMASK = 16'hFFFF;
	parameter bit [15:0] CONVMP_INIT = 16'h0000;
	
	//typedef bit [15:0] CONTROL_t;	//R/W;C0000190
	
	typedef struct packed		//R/W;C00001A0
	{
		bit [ 2: 0] UNUSED;
		bit [ 2: 0] RR;			//
		bit         UNUSED2;		
		bit         VEN;			//
		bit [ 3: 0] UNUSED3;
		bit         CBP;			//
		bit [ 1: 0] RCM;			//
		bit         BEN;			
	} CONFIG_t;
	parameter bit [15:0] CONFIG_WMASK = 16'h1D0F;
	parameter bit [15:0] CONFIG_RMASK = 16'h1D0F;
	parameter bit [15:0] CONFIG_INIT = 16'h0000; 
	
	typedef bit [15:0] DPYTAP_t;		//R/W;C00001B0
	parameter bit [15:0] DPYTAP_WMASK = 16'hFFFF;
	parameter bit [15:0] DPYTAP_RMASK = 16'hFFFF;
	parameter bit [15:0] DPYTAP_INIT = 16'h0000; 
	
	typedef bit [15:0] VCOUNT_t;		//R/W;C00001C0
	parameter bit [15:0] VCOUNT_WMASK = 16'hFFFF;
	parameter bit [15:0] VCOUNT_RMASK = 16'hFFFF;
	parameter bit [15:0] VCOUNT_INIT = 16'h0000;
	
	typedef bit [15:0] HCOUNT_t;		//R/W;C00001D0
	parameter bit [15:0] HCOUNT_WMASK = 16'hFFFF;
	parameter bit [15:0] HCOUNT_RMASK = 16'hFFFF;
	parameter bit [15:0] HCOUNT_INIT = 16'h0000; 
	
	typedef bit [15:0] DPYADR_t;		//R/W;C00001E0
	parameter bit [15:0] DPYADR_WMASK = 16'hFFFF;
	parameter bit [15:0] DPYADR_RMASK = 16'hFFFF;
	parameter bit [15:0] DPYADR_INIT = 16'h0000; 
	
	typedef bit [15:0] REFADR_t;		//R/W;C00001F0
	parameter bit [15:0] REFADR_WMASK = 16'hFFFF;
	parameter bit [15:0] REFADR_RMASK = 16'hFFFF;
	parameter bit [15:0] REFADR_INIT = 16'h0000;
	
	typedef struct packed		//R/W;C0000200
	{
		bit [26: 0] SRST;			//
		bit [ 4: 0] UNUSED;		//
	} DPYST_t;
	parameter bit [31:0] DPYST_WMASK = 32'hFFFFFFFF;
	parameter bit [31:0] DPYST_RMASK = 32'hFFFFFFFF;
	parameter bit [31:0] DPYST_INIT = 32'h00000000; 
	
	typedef struct packed		//R/W;C0000220
	{
		bit [26: 0] SRNX;			//
		bit [ 4: 0] YZCNT;		//
	} DPYNX_t;
	parameter bit [31:0] DPYNX_WMASK = 32'hFFFFFFFF;
	parameter bit [31:0] DPYNX_RMASK = 32'hFFFFFFFF;
	parameter bit [31:0] DPYNX_INIT = 32'h00000000; 
	
	typedef struct packed		//R/W;C0000240
	{
		bit [26: 0] SRINC;			//
		bit [ 4: 0] YZINC;		//
	} DINC_t;
	parameter bit [31:0] DINC_WMASK = 32'hFFFFFFFF;
	parameter bit [31:0] DINC_RMASK = 32'hFFFFFFFF;
	parameter bit [31:0] DINC_INIT = 32'h00000000; 
	
	typedef bit [15:0] HESERR_t;		//R/W;C0000270
	parameter bit [15:0] HESERR_WMASK = 16'hFFFF;
	parameter bit [15:0] HESERR_RMASK = 16'hFFFF;
	parameter bit [15:0] HESERR_INIT = 16'h0000;
	
	typedef bit [15:0] SCOUNT_t;		//R/W;C00002C0
	parameter bit [15:0] SCOUNT_WMASK = 16'hFFFF;
	parameter bit [15:0] SCOUNT_RMASK = 16'hFFFF;
	parameter bit [15:0] SCOUNT_INIT = 16'h0000;
	
	typedef bit [15:0] BSFLTST_t;		//R/W;C00002D0
	parameter bit [15:0] BSFLTST_WMASK = 16'hFFFF;
	parameter bit [15:0] BSFLTST_RMASK = 16'hFFFF;
	parameter bit [15:0] BSFLTST_INIT = 16'h0000; 
	
	typedef bit [15:0] DPYMSK_t;		//R/W;C00002E0
	parameter bit [15:0] DPYMSK_WMASK = 16'hFFFF;
	parameter bit [15:0] DPYMSK_RMASK = 16'hFFFF;
	parameter bit [15:0] DPYMSK_INIT = 16'h0000; 
	
	typedef bit [15:0] SETVCNT_t;		//R/W;C0000300
	parameter bit [15:0] SETVCNT_WMASK = 16'hFFFF;
	parameter bit [15:0] SETVCNT_RMASK = 16'hFFFF;
	parameter bit [15:0] SETVCNT_INIT = 16'h0000;
	
	typedef bit [15:0] SETHCNT_t;		//R/W;C0000310
	parameter bit [15:0] SETHCNT_WMASK = 16'hFFFF;
	parameter bit [15:0] SETHCNT_RMASK = 16'hFFFF;
	parameter bit [15:0] SETHCNT_INIT = 16'h0000;
	
	typedef bit [31:0] BSFLTD_t;		//R/W;C0000320
	parameter bit [31:0] BSFLTD_WMASK = 32'hFFFFFFFF;
	parameter bit [31:0] BSFLTD_RMASK = 32'hFFFFFFFF;
	parameter bit [31:0] BSFLTD_INIT = 32'h00000000; 
	
	typedef bit [31:0] IHOSTx_t;		//R/W;C0000380,C00003A0,C00003C0,C00003E0
	parameter bit [31:0] IHOSTx_WMASK = 32'hFFFFFFFF;
	parameter bit [31:0] IHOSTx_RMASK = 32'hFFFFFFFF;
	parameter bit [31:0] IHOSTx_INIT = 32'h00000000; 
	
	typedef struct packed
	{
		VESYNC_t VESYNC;
		HESYNC_t HESYNC;
		VEBLNK_t VEBLNK;
		HEBLNK_t HEBLNK;
		VSBLNK_t VSBLNK;
		HSBLNK_t HSBLNK;
		VTOTAL_t VTOTAL;
		HTOTAL_t HTOTAL;
		DPYCTL_t DPYCTL;
		DPYSTRT_t DPYSTRT;
		DPYINT_t DPYINT;
		CONTROL_t CONTROL;
		HSTDATA_t HSTDATA;
		HSTADRL_t HSTADRL;
		HSTADRH_t HSTADRH;
		HSTCTLL_t HSTCTLL;
		HSTCTLH_t HSTCTLH;
		INTENB_t INTENB;
		INTPEND_t INTPEND;
		CONVSP_t CONVSP;
		CONVDP_t CONVDP;
		PSIZE_t      PSIZE;
		PMASK_t PMASK;
		CONVMP_t CONVMP;
		CONFIG_t CONFIG;
		DPYTAP_t DPYTAP;
		VCOUNT_t VCOUNT;
		HCOUNT_t HCOUNT;
		DPYADR_t DPYADR;
		REFADR_t REFADR;
		DPYST_t DPYST;
		DPYNX_t DPYNX;
		DINC_t DINC;
		HESERR_t HESERR;
		SCOUNT_t SCOUNT;
		BSFLTST_t BSFLTST;
		BSFLTD_t BSFLTD;
		DPYMSK_t DPYMSK;
		SETVCNT_t SETVCNT;
		SETHCNT_t SETHCNT;
		IHOSTx_t IHOST1;
		IHOSTx_t IHOST2;
		IHOSTx_t IHOST3;
		IHOSTx_t IHOST4;
	} IOReg_t;


endpackage
