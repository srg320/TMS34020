onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TMS34020_tb/core/CE_F
add wave -noupdate /TMS34020_tb/core/CE_R
add wave -noupdate /TMS34020_tb/core/IEB/DBUS_A
add wave -noupdate /TMS34020_tb/core/IEB/DBUS_DI
add wave -noupdate /TMS34020_tb/core/IEB/DBUS_DO
add wave -noupdate /TMS34020_tb/core/IEB/DBUS_BE
add wave -noupdate /TMS34020_tb/core/IEB/DBUS_WE
add wave -noupdate /TMS34020_tb/core/IEB/DBUS_RD
add wave -noupdate -color Gold -itemcolor Gold /TMS34020_tb/core/IEB/PC_DBG
add wave -noupdate /TMS34020_tb/core/IEB/PC
add wave -noupdate /TMS34020_tb/core/IEB/ST
add wave -noupdate /TMS34020_tb/core/IEB/IC
add wave -noupdate /TMS34020_tb/core/IEB/IW
add wave -noupdate -radix unsigned /TMS34020_tb/core/IEB/STATE
add wave -noupdate -radix unsigned /TMS34020_tb/core/IEB/FS
add wave -noupdate /TMS34020_tb/core/IEB/FE
add wave -noupdate /TMS34020_tb/core/IEB/DECI
add wave -noupdate /TMS34020_tb/core/IEB/MC_STATE
add wave -noupdate /TMS34020_tb/core/IEB/MC_ADDR
add wave -noupdate /TMS34020_tb/core/IEB/DOUT_BUF
add wave -noupdate /TMS34020_tb/core/IEB/DATA_OLD
add wave -noupdate /TMS34020_tb/core/IEB/MC_BE
add wave -noupdate /TMS34020_tb/core/IEB/MC_READ_PEND
add wave -noupdate /TMS34020_tb/core/IEB/RMW
add wave -noupdate /TMS34020_tb/core/IEB/MC_RMW_PEND
add wave -noupdate /TMS34020_tb/core/IEB/MC_WRITE_PEND
add wave -noupdate /TMS34020_tb/core/IEB/MC_EXT_WORD
add wave -noupdate /TMS34020_tb/core/IEB/DIN_BA
add wave -noupdate /TMS34020_tb/core/IEB/DIN_FS
add wave -noupdate /TMS34020_tb/core/IEB/DIN_BUF
add wave -noupdate /TMS34020_tb/core/IEB/MC_WAIT
add wave -noupdate /TMS34020_tb/core/IEB/MC_FETCH_PEND
add wave -noupdate /TMS34020_tb/core/IEB/FETCH_LATCH
add wave -noupdate /TMS34020_tb/core/IEB/SSA
add wave -noupdate /TMS34020_tb/core/IEB/P
add wave -noupdate /TMS34020_tb/core/IEB/CACHE_LRU_STACK
add wave -noupdate /TMS34020_tb/core/IEB/CACHE_SEG
add wave -noupdate /TMS34020_tb/core/IEB/CACHE_SUBSEG
add wave -noupdate /TMS34020_tb/core/IEB/SEG_MISS
add wave -noupdate /TMS34020_tb/core/IEB/SUBSEG_MISS
add wave -noupdate /TMS34020_tb/core/IEB/CACHE_MISS
add wave -noupdate /TMS34020_tb/core/IEB/CACHE_WAIT
add wave -noupdate /TMS34020_tb/core/IEB/LWORD_POS
add wave -noupdate /TMS34020_tb/core/IEB/CACHE_WADDR
add wave -noupdate /TMS34020_tb/core/IEB/CACHE_RADDR
add wave -noupdate /TMS34020_tb/core/IEB/CACHE_Q
add wave -noupdate -expand /TMS34020_tb/core/IEB/RF/A
add wave -noupdate /TMS34020_tb/core/DPYCTL
add wave -noupdate /TMS34020_tb/core/HTOTAL
add wave -noupdate /TMS34020_tb/core/HCOUNT
add wave -noupdate /TMS34020_tb/core/VCOUNT
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {47217569 ns} 0}
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
WaveRestoreZoom {47217453 ns} {47217957 ns}
