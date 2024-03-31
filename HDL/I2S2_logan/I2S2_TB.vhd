library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity I2S2_TB is 
end I2S2_TB;

architecture behavior of I2S2_TB is

component I2S2 is
	port(
		MAX10_CLK1_50	: in std_logic;
		MAX10_CLK2_50	: in std_logic;
		ADC_CLK_10		: in std_logic;

		KEY				: in std_logic_vector(1 downto 0);
		
		LEDR				: out std_logic_vector(9 downto 0);
		ARDUINO_IO		: inout std_logic_vector(15 downto 0);
		GPIO				: inout std_logic_vector(35 downto 0)
	);
end component I2S2;

signal clk : std_logic := '0';
signal adc_clk : std_logic := '0';

signal key : std_logic_vector (1 downto 0);
signal led : std_logic_vector (9 downto 0);
signal ard : std_logic_vector (15 downto 0);
signal gpio : std_logic_vector (35 downto 0);

constant CLK_PERIOD : time := 20 ns;

begin
	
	dut1 : I2S2
		port map(
			MAX10_CLK1_50 => clk,
			MAX10_CLK2_50 => clk,
			ADC_CLK_10 => adc_clk,
			KEY => key,
			LEDR => led,
			ARDUINO_IO => ard,
			GPIO => gpio
		);


	clk_process : process
	begin
		clk <= '0';
		wait for clk_period / 2;
		clk <= '1';
		wait for clk_period/2;
	end process;	

	stim : process begin
		key(0) <= '1';
		wait for clk_period*10;
		key(0) <= '0';
		wait for clk_period*10;
		key(0) <= '1';
		GPIO(9) <= '1';
		wait;
	end process;


end architecture behavior;