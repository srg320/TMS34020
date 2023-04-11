module TMS34020_MC
 (
	input              CLK,
	input              RST_N,
	input              EN,
	
	input              CE_F,
	input              CE_R,
	
	input              RES_N,
	
	input      [31: 0] ADDR,
	input      [31: 0] DOUT,
	output     [31: 0] DIN,
	input      [ 5: 0] FS,
	input              READ,
	input              WRITE,
	input              PIX,
	input      [31: 0] PC,
	input              CACHE,
	output             CACHE_WR,
	input              VECT,
	output             WAIT,
	input      [31: 0] PIX_WMASK,
	
	input      [31: 0] SCRREF_ADDR,
	input              SCRREF_RUN,
	
	input              CST,
	
	output reg [31: 0] DBUS_A,
	input      [31: 0] DBUS_DI,
	output reg [31: 0] DBUS_DO,
	output reg         DBUS_RAS,
	output reg         DBUS_WE,
	output reg         DBUS_RD,
	output reg [ 3: 0] DBUS_BE,
	output reg [ 3: 0] DBUS_CODE,
	input              DBUS_RDY
	
`ifdef DEBUG
	,
	output reg [31: 0] DBG_DBUS_A
`endif
);

	import TMS34020_PKG::*;
	
	bit  [31: 0] MC_ADDR;
	bit  [ 3: 0] MC_BE;
	bit  [ 4: 0] DIN_BA;
	bit  [ 5: 0] DIN_FS;
	bit  [ 5: 0] DIN_FS_OLD;
	bit  [ 5: 0] DOUT_FS;
	
	bit  [31: 0] DOUT_BUF;
	bit  [31: 0] DIN_BUF;
	bit          MC_EXT_WORD;
	bit          FETCH_LATCH;
	bit          RMW;
	bit          MC_READ_EXT;
	bit          MC_WRITE_EXT;
	bit  [31: 0] MC_WMASK_EXT;
		
	bit  [63: 0] DATA_WMASK;
	always_comb begin
		MC_ADDR <= !MC_READ_EXT && !MC_WRITE_EXT ? ADDR : {DBUS_A[31:5],5'b00000} + 32'h20;

		DATA_WMASK <= DataWriteMask(ADDR[4:0],FS);
	end
	
	always_comb begin
		if (MC_WRITE_EXT) begin
			MC_BE <= { |MC_WMASK_EXT[31:24], |MC_WMASK_EXT[23:16], |MC_WMASK_EXT[15: 8], |MC_WMASK_EXT[ 7: 0] };
		end else if (WRITE && PIX) begin
			MC_BE <= { |PIX_WMASK[31:24], |PIX_WMASK[23:16], |PIX_WMASK[15: 8], |PIX_WMASK[ 7: 0] } & { |DATA_WMASK[31:24], |DATA_WMASK[23:16], |DATA_WMASK[15: 8], |DATA_WMASK[ 7: 0] };
		end else if (WRITE) begin
			MC_BE <= { |DATA_WMASK[31:24], |DATA_WMASK[23:16], |DATA_WMASK[15: 8], |DATA_WMASK[ 7: 0] };
		end else begin
			MC_BE <= 4'b1111;
		end
	end
	
	bit  [31: 0] DATA_OLD;
	bit  [ 4: 0] DOUT_BA_OLD;
	
	bit          MC_STATE;
	bit          MC_READ_WAIT;
	bit          MC_WRITE_WAIT;
	bit          MC_FETCH_WAIT;
	bit          MC_SCRREF_WAIT;
	
		bit         MC_READ_PEND;
		bit         MC_WRITE_PEND,MC_WRITE_PEND2;
		bit         MC_WRITE_RMW;
		bit         MC_FETCH_PEND;
//		bit         MC_WRITE_SKEEP;
		bit         MC_SCRREF_PEND;
	always @(posedge CLK or negedge RST_N) begin		
		bit         SCRREF_PEND;
		bit         READ_LATCH;
		bit         WRITE_LATCH;
		bit [ 1: 0] FETCH_LSB;
		
		if (!RST_N) begin
			DBUS_A <= '0;
			DBUS_BE <= '0;
//			DBUS_DO <= '0;
			DBUS_WE <= 0;
			DBUS_RD <= 0;
			DBUS_CODE <= 4'b1111;
			DIN_BA <= '0;
			DIN_FS <= '0;
			DOUT_FS <= '0;
			SCRREF_PEND <= 0;
			
			MC_STATE <= 0;
			MC_READ_WAIT <= 0;
			MC_WRITE_WAIT <= 0;
			MC_FETCH_WAIT <= 0;
			MC_SCRREF_WAIT <= 0;
			DOUT_BUF <= '0;
			DIN_BUF <= '0;
			RMW <= 0;
			MC_READ_PEND <= 0;
			MC_WRITE_PEND <= 0;
			MC_WRITE_PEND2 <= 0;
			MC_FETCH_PEND <= 0;
			MC_SCRREF_PEND <= 0;
//			MC_WRITE_SKEEP <= 0;
			MC_EXT_WORD <= 0;
			READ_LATCH <= 0;
			WRITE_LATCH <= 0;
			FETCH_LATCH <= 0;
			FETCH_LSB <= '0;
			MC_READ_EXT <= 0;
			MC_WRITE_EXT <= 0;
		end
		else if (EN) begin
			if (SCRREF_RUN && CE_R) begin	
				SCRREF_PEND <= 1;
			end
			
			if (CE_F) begin
				case (MC_STATE)
				1'b0: begin
					MC_EXT_WORD <= 0;
					DBUS_CODE <= 4'b1111;
					if (MC_READ_EXT) begin
						DBUS_A <= MC_ADDR;
						DBUS_BE <= MC_BE;
						DBUS_RD <= PIX && CST;
						DBUS_WE <= 0;
						DBUS_RAS <= 1;
						DBUS_CODE <= PIX && CST ? 4'b0101 : 4'b1000;
						DIN_BA <= '0;
//						DIN_FS <= DIN_FS - {1'b0,DIN_BA};
						MC_READ_PEND <= 1;
						MC_READ_WAIT <= 1;
						MC_READ_EXT <= 0;
						MC_EXT_WORD <= 1;
					end else if (MC_WRITE_EXT) begin
						DBUS_A <= MC_ADDR;
						DBUS_BE <= MC_BE;
						DBUS_RAS <= 1;
						DBUS_CODE <= PIX && CST ? 4'b0101 : 4'b1000;
						DATA_OLD <= '0;
						DIN_BA <= '0;
//						DIN_FS <= DIN_FS - {1'b0,DIN_BA};
						DOUT_BA_OLD <= DBUS_A[4:0];
						if (MC_WRITE_RMW) begin
							MC_READ_PEND <= 1;
							RMW <= 1;
						end else begin
							DBUS_RD <= PIX && CST;
							DBUS_WE <= PIX && CST;
							MC_WRITE_PEND2 <= 1;
							RMW <= 0;
						end
//						MC_WRITE_WAIT <= 0;
						MC_WRITE_EXT <= 0;
						MC_EXT_WORD <= 1;
					end else if (SCRREF_PEND) begin
						DBUS_A <= {SCRREF_ADDR[31:5],5'b00000};
						DBUS_BE <= 4'b1111;
						DBUS_WE <= 0;
						DBUS_RD <= 1;
						DBUS_RAS <= 1;
						DBUS_CODE <= 4'b0100;
						DIN_BA <= '0;
						DIN_FS <= 6'h20;
						MC_SCRREF_PEND <= 1;
						MC_SCRREF_WAIT <= 1;
						SCRREF_PEND <= 0;
					end else if (READ && !CACHE) begin
						DBUS_A <= MC_ADDR;
						DBUS_BE <= MC_BE;
						DBUS_RD <= PIX && CST;
						DBUS_WE <= 0;
						DBUS_RAS <= 1;
						DBUS_CODE <= PIX && CST ? 4'b0101 : VECT ? 4'b1011 : 4'b1000;
						DIN_BA <= MC_ADDR[4:0];
						DIN_FS <= FS;
						MC_READ_PEND <= 1;
						MC_READ_WAIT <= 1;
						MC_READ_EXT <= (({1'b0,MC_ADDR[4:0]} + FS) > 6'h20);
					end else if (WRITE && !CACHE) begin
						DBUS_A <= MC_ADDR;
						DBUS_BE <= MC_BE;
						DBUS_RAS <= 1;
						DBUS_CODE <= PIX && CST ? 4'b0101 : 4'b1000;
						DATA_OLD <= '0;
						DIN_BA <= MC_ADDR[4:0];
						DIN_FS <= FS;
						DOUT_FS <= FS;
						if ((MC_ADDR[2:0] || FS[2:0]) && !RMW) begin
							MC_READ_PEND <= 1;
							RMW <= 1;
							MC_WRITE_RMW <= 1;
						end else begin
							DBUS_RD <= PIX && CST;
							DBUS_WE <= PIX && CST;
//							DBUS_CODE <= PIX && CST ? 4'b0101 : 4'b1000;
							MC_WRITE_PEND <= 1;
							MC_WRITE_RMW <= 0;
							RMW <= 0;
						end
						MC_WRITE_WAIT <= 0;
						MC_WRITE_EXT <= (({1'b0,MC_ADDR[4:0]} + FS) > 6'h20);
						MC_WMASK_EXT <= DATA_WMASK[63:32];
					end else if (CACHE) begin
						DBUS_A <= {PC[31:7],PC[6:5]+FETCH_LSB,5'b00000};
						DBUS_BE <= 4'b1111;
						DBUS_RAS <= 1;
						DBUS_CODE <= 4'b1001;
						DIN_BA <= '0;
						DIN_FS <= 6'h20;
						MC_FETCH_PEND <= 1;
						MC_FETCH_WAIT <= 1;
					end
				end
				
				1'b1: if (DBUS_RDY) begin
					if (MC_SCRREF_PEND) begin
						MC_SCRREF_PEND <= 0;
						MC_SCRREF_WAIT <= 0;
						WRITE_LATCH <= 1;
					end
					else if (MC_FETCH_PEND) begin
						MC_FETCH_PEND <= 0;
						FETCH_LATCH <= 1;
						FETCH_LSB <= FETCH_LSB + 2'd1;
						if (FETCH_LSB == 2'd3) MC_FETCH_WAIT <= 0;
					end
					else if (MC_READ_PEND) begin	
						MC_READ_PEND <= 0;
						READ_LATCH <= 1;
						RMW <= 0;
						if (!RMW) begin
							MC_READ_WAIT <= MC_READ_EXT;
						end else begin
							MC_WRITE_PEND <= 1;
						end
					end
					else if (MC_WRITE_PEND) begin	
						MC_WRITE_PEND <= 0;
						WRITE_LATCH <= 1;
					end
					else if (MC_WRITE_PEND2) begin	
						MC_WRITE_PEND2 <= 0;
						WRITE_LATCH <= 1;
					end
				end
				endcase
					
				if (FETCH_LATCH) begin
					FETCH_LATCH <= 0;
				end
				if (READ_LATCH) begin	
					if (!MC_EXT_WORD) begin
						DIN_BUF <= InAligner   (DBUS_DI, '0     , DIN_BA, DIN_FS);
						DIN_FS_OLD <= 6'h20 - {1'b0,DIN_BA};
					end else begin
						DIN_BUF <= InAlignerExt(DBUS_DI, DIN_BUF, DIN_FS, DIN_FS_OLD);
					end
					DATA_OLD <= DBUS_DI;
					READ_LATCH <= 0;
				end
				
				if ((MC_READ_PEND && RMW) || MC_WRITE_PEND || MC_WRITE_PEND2 || MC_WRITE_EXT || MC_SCRREF_PEND) begin
					if (READ && !MC_READ_WAIT) begin
						MC_READ_WAIT <= 1;
					end
					if (WRITE && !MC_WRITE_WAIT) begin
						MC_WRITE_WAIT <= 1;
					end
				end
			end 
			else if (CE_R) begin	
				case (MC_STATE)
				1'b0: begin
					if (MC_READ_PEND || MC_WRITE_PEND || MC_WRITE_PEND2 || MC_FETCH_PEND || MC_SCRREF_PEND) begin
						MC_STATE <= 1;
					end
					if ((MC_READ_PEND && RMW) || MC_WRITE_PEND) begin
						DOUT_BUF <= DOUT;
					end
					if (MC_WRITE_PEND || MC_WRITE_PEND2 /*|| MC_SCRREF_PEND*/) begin
						DBUS_WE <= 1;
					end
					if (MC_READ_PEND || MC_FETCH_PEND) begin
						DBUS_RD <= 1;
					end
				end
				
				1'b1: begin
					WRITE_LATCH <= 0;
					if (READ_LATCH || WRITE_LATCH || FETCH_LATCH) begin	
						DBUS_RD <= 0;
						DBUS_WE <= 0;
						DBUS_RAS <= 0;
					end
					
					if (!MC_READ_PEND && !MC_WRITE_PEND && !MC_WRITE_PEND2 && !MC_FETCH_PEND && !MC_SCRREF_PEND) begin
						MC_STATE <= 0;
					end
					if (MC_WRITE_PEND || MC_WRITE_PEND2) begin
						DBUS_WE <= 1;
						DBUS_RAS <= 1;
					end
				end
				endcase
			end
		end
	end
	assign WAIT = MC_READ_WAIT || MC_WRITE_WAIT || MC_FETCH_WAIT || MC_SCRREF_WAIT;
	assign DIN = DIN_BUF;
	assign CACHE_WR = FETCH_LATCH;
	
	always_comb begin
		if (!MC_EXT_WORD)
			DBUS_DO <= OutAligner   (DOUT_BUF, DATA_OLD, DBUS_A[4:0], DOUT_FS);
		else
			DBUS_DO <= OutAlignerExt(DOUT_BUF, DATA_OLD, DOUT_BA_OLD, DOUT_FS);
	end
		
`ifdef DEBUG
	assign DBG_DBUS_A = {DBUS_A[31:4],4'h0};
`endif
	
endmodule
