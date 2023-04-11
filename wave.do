onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TMS34020_tb/core/CE_F
add wave -noupdate /TMS34020_tb/core/CE_R
add wave -noupdate /TMS34020_tb/core/IE/DBUS_A
add wave -noupdate /TMS34020_tb/core/IE/DBUS_DI
add wave -noupdate /TMS34020_tb/core/IE/DBUS_DO
add wave -noupdate /TMS34020_tb/core/IE/DBUS_BE
add wave -noupdate /TMS34020_tb/core/IE/DBUS_WE
add wave -noupdate /TMS34020_tb/core/IE/DBUS_RD
add wave -noupdate /TMS34020_tb/core/IE/DBUS_RDY
add wave -noupdate -color Yellow -itemcolor Yellow /TMS34020_tb/core/IE/DBG_PC
add wave -noupdate /TMS34020_tb/core/IE/PC
add wave -noupdate /TMS34020_tb/core/IE/ST
add wave -noupdate /TMS34020_tb/core/IE/IC
add wave -noupdate /TMS34020_tb/core/IE/IW
add wave -noupdate /TMS34020_tb/core/IE/FS
add wave -noupdate /TMS34020_tb/core/IE/FE
add wave -noupdate -radix unsigned /TMS34020_tb/core/IE/STATE
add wave -noupdate /TMS34020_tb/core/IE/DECI
add wave -noupdate /TMS34020_tb/core/IE/PIX_DYDX
add wave -noupdate /TMS34020_tb/core/IE/PIX_DOFFS
add wave -noupdate /TMS34020_tb/core/IE/PIX_SOFFS
add wave -noupdate /TMS34020_tb/core/IE/PIXBLT_PPW
add wave -noupdate /TMS34020_tb/core/IE/PIX_PAT
add wave -noupdate /TMS34020_tb/core/IE/PIX_WMASK
add wave -noupdate /TMS34020_tb/core/IE/PIX_WE
add wave -noupdate /TMS34020_tb/core/IE/PIX_XEND
add wave -noupdate /TMS34020_tb/core/IE/PIX_YEND
add wave -noupdate /TMS34020_tb/core/IE/ALU_A
add wave -noupdate /TMS34020_tb/core/IE/ALU_B
add wave -noupdate /TMS34020_tb/core/IE/ALU_R
add wave -noupdate /TMS34020_tb/core/IE/ALU_C
add wave -noupdate /TMS34020_tb/core/IE/ALU_V
add wave -noupdate /TMS34020_tb/core/IE/ALU_Z
add wave -noupdate /TMS34020_tb/core/IE/ALU_N
add wave -noupdate /TMS34020_tb/core/IE/MC_ADDR
add wave -noupdate /TMS34020_tb/core/IE/MC_STATE
add wave -noupdate /TMS34020_tb/core/IE/MC_BE
add wave -noupdate /TMS34020_tb/core/IE/DOUT
add wave -noupdate /TMS34020_tb/core/IE/DOUT_BUF
add wave -noupdate /TMS34020_tb/core/IE/DOUT_BA_OLD
add wave -noupdate /TMS34020_tb/core/IE/DOUT_FS
add wave -noupdate /TMS34020_tb/core/IE/DATA_OLD
add wave -noupdate /TMS34020_tb/core/IE/DIN_BA
add wave -noupdate /TMS34020_tb/core/IE/DIN_FS
add wave -noupdate /TMS34020_tb/core/IE/DIN_FS_OLD
add wave -noupdate /TMS34020_tb/core/IE/MC_READ_PEND
add wave -noupdate /TMS34020_tb/core/IE/MC_READ_EXT
add wave -noupdate /TMS34020_tb/core/IE/MC_WRITE_PEND
add wave -noupdate /TMS34020_tb/core/IE/MC_WRITE_PEND2
add wave -noupdate /TMS34020_tb/core/IE/MC_WRITE_EXT
add wave -noupdate /TMS34020_tb/core/IE/MC_EXT_WORD
add wave -noupdate /TMS34020_tb/core/IE/MC_FETCH_PEND
add wave -noupdate /TMS34020_tb/core/IE/MC_READ_WAIT
add wave -noupdate /TMS34020_tb/core/IE/MC_WRITE_WAIT
add wave -noupdate /TMS34020_tb/core/IE/MC_SCRREF_WAIT
add wave -noupdate /TMS34020_tb/core/IE/MC_WAIT
add wave -noupdate /TMS34020_tb/core/IE/DIN_BUF
add wave -noupdate /TMS34020_tb/core/IE/RF/A
add wave -noupdate -expand /TMS34020_tb/core/IE/RF/B
add wave -noupdate /TMS34020_tb/core/CONTROL
add wave -noupdate /TMS34020_tb/core/INTENB
add wave -noupdate /TMS34020_tb/core/INTPEND
add wave -noupdate /TMS34020_tb/core/CONVDP
add wave -noupdate /TMS34020_tb/core/DPYCTL
add wave -noupdate /TMS34020_tb/core/DPYINT
add wave -noupdate /TMS34020_tb/core/DPYST
add wave -noupdate /TMS34020_tb/core/DINC
add wave -noupdate /TMS34020_tb/core/DPYNX
add wave -noupdate /TMS34020_tb/core/HCOUNT
add wave -noupdate /TMS34020_tb/core/VCOUNT
add wave -noupdate /TMS34020_tb/core/HBL
add wave -noupdate /TMS34020_tb/core/VBL
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {24969250 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {24969157 ns} {24969661 ns}
