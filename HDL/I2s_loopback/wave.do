onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group rst_ctrl /top_tb/rst_n
add wave -noupdate -expand -group rst_ctrl /top_tb/rst_h
add wave -noupdate -expand -group clocks /top_tb/m_clk
add wave -noupdate -expand -group clocks /top_tb/lr_clk_tx
add wave -noupdate -expand -group clocks /top_tb/sclk_tx
add wave -noupdate -expand -group clocks /top_tb/MAX10_CLK1_50
add wave -noupdate /top_tb/input
add wave -noupdate /top_tb/adc_real
add wave -noupdate -expand -group I/O_I2S /top_tb/i2s_rx_tx_inst/out_l
add wave -noupdate -expand -group I/O_I2S /top_tb/i2s_rx_tx_inst/out_r
add wave -noupdate -expand -group I/O_I2S /top_tb/i2s_rx_tx_inst/in_l
add wave -noupdate -expand -group I/O_I2S /top_tb/i2s_rx_tx_inst/in_r
add wave -noupdate /top_tb/lr_clk_count
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {26994451 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {105 us}
