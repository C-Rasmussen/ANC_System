library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity i2s_rx_tx is
port(
    clk : in std_logic;
	 rst_n : in std_logic;
    
    i2s_bclk : in std_logic;
    i2s_lr : in std_logic;
    i2s_din : in std_logic;
    i2s_dout : out std_logic;
    
    out_l : out signed (23 downto 0);
    out_r : out signed (23 downto 0);
    
    in_l : in signed (23 downto 0);
    in_r : in signed (23 downto 0);
    
    sync : out std_logic
    );
end i2s_rx_tx;

architecture Behavioral of i2s_rx_tx is

signal in_frame : std_logic_vector (63 downto 0) := (others=>'0');
signal out_frame : std_logic_vector (63 downto 0) := (others=>'0');
signal bit_pattern : std_logic_vector (1 downto 0) := (others=>'0');
signal lr_pattern : std_logic_vector (1 downto 0) := (others=>'0');
signal get_new_tx_buffer : std_logic := '0';

begin

	--clk = 4*sclk
	--clk = 5.120 MHz, sclk = 1.280 MHz, LR or Fs = 20 KHz
	process (clk, rst_n)
		begin 
		if rst_n = '0' then
			out_l <= (others => '0');
			out_r <= (others => '0');
			sync	<= '0';
			i2s_dout <= '0';
			
		elsif (rising_edge(clk)) then

			bit_pattern <= bit_pattern(0)&i2s_bclk; --last 2 clock cycles for bit/left,right
			lr_pattern <= lr_pattern(0)&i2s_lr; 

			
			
			if (lr_pattern = "10") then --frame ending, can get new data
				get_new_tx_buffer <= '1';
			elsif (bit_pattern = "01") then
				get_new_tx_buffer <= '0';	--frame starting, cannot switch data
			end if;
			 
			 
			 
			case bit_pattern is
	--ADC PART
				when "10" => 
					in_frame <= in_frame(62 downto 0) & i2s_din; --read in new data on neg edge
					if (lr_pattern = "10") then --input frame finishing, ready to send off
						out_l <= signed(in_frame(62 downto 39));
						out_r <= signed(in_frame(30 downto 7));
						sync <= '1'; --HANDSHAKING to let next stage know that data is ready (write enable to FIFO?)
					end if; 
			
	--DAC PART		
				when "01" =>
					sync <= '0';
					i2s_dout <= out_frame(63); --send out data on pos edge
					out_frame <= out_frame(62 downto 0)&"0";
	--RESET PART			
				when "00" => --get next data if last clock cycle was last one of frame
					sync <= '0';
					if get_new_tx_buffer='1' then --create the next frame
						out_frame <= std_logic_vector(in_l) & "00000000" & std_logic_vector(in_r) & "00000000";
					end if;
				
				when others =>
					sync <= '0';
				
			end case;
			 
		end if;
	end process;

end Behavioral;