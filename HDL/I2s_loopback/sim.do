vcom -reportprogress 30 -work work {C:/Users/conno/Documents/senior design/ANC_System/HDL/I2s_loopback/top.vhd}
vcom -reportprogress 30 -work work {C:/Users/conno/Documents/senior design/ANC_System/HDL/I2s_loopback/pll.vhd}
vcom -reportprogress 30 -work work {C:/Users/conno/Documents/senior design/ANC_System/HDL/I2s_loopback/i2s_tx_rx.vhd}
vcom -reportprogress 30 -work work {C:/Users/conno/Documents/senior design/ANC_System/HDL/I2s_loopback/clock_gen.vhd}
vcom -reportprogress 30 -work work {C:/Users/conno/Documents/senior design/ANC_System/HDL/I2s_loopback/top_tb.vhd}
vsim -gui work.top_tb

do wave.do

run 20 us