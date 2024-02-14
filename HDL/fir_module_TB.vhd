
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.anc_package.all;

entity fir_module_TB is 
end fir_module_TB;

architecture behavior of fir_module_TB is

	component fir_module		
	port(
		rst_low : in std_logic;
		input_flag : in std_logic;
		output_flag : out std_logic;
		clk : in std_logic;										
		input : in std_logic_vector(23 downto 0);					
		output : out std_logic_vector(23 downto 0)
		);
		
	end component fir_module;
	
	signal rst_low : std_logic := '1';
	signal input_flag : std_logic := '0';
	signal output_flag : std_logic := '0';
	signal clk : std_logic := '0';
	signal input : std_logic_vector(23 downto 0);
	signal output : std_logic_vector(23 downto 0);
	
	constant CLK_PERIOD : time := 20 ns;
	
begin
	
	dut : fir_module
		port map(
		rst_low => rst_low,
		input_flag => input_flag,
		output_flag => output_flag,
		clk => clk,
		input => input,
		output => output
		);

	clk_process : process
	begin
		clk <= '0';
		wait for clk_period / 2;
		clk <= '1';
		wait for clk_period/2;
	end process;
	
		stm_process : process
	begin
		rst_low<= '1';
		wait for clk_period * 10;
		rst_low <= '0';
		wait for clk_period * 10;
		rst_low <= '1';
		wait for clk_period * 10;
		input_flag <= '1';
		input <= "111001110001000100000000";
		wait for clk_period * 10;
		input <= "101000011011110000000000";
		wait for clk_period * 150;
		input <= "101010101100110100001000";
		wait for clk_period * 150;
		input <= "001110000011111100000000";
		wait for clk_period * 150;
		input <= "110010010100010011111110";
		wait for clk_period * 150;
		input <= "000000000010011100000000";
		wait for clk_period * 150;
		input <= "000111011100111111111111";
		wait;
	end process;
end architecture behavior;