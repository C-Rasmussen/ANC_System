
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.anc_package.all;
use std.textio.all;

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
	signal input_count : integer;
	
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
	
--		stm_process : process
--	begin
--		rst_low<= '1';
--		wait for clk_period * 10;
--		rst_low <= '0';
--		wait for clk_period * 10;
--		rst_low <= '1';
--		wait for clk_period * 10;
--		input_flag <= '1';
--		input <= "111001110001000100000000";
--		wait for clk_period * 10;
--		input <= "101000011011110000000000";
--		wait for clk_period * 150;
--		input <= "101010101100110100001000";
--		wait for clk_period * 150;
--		input <= "001110000011111100000000";
--		wait for clk_period * 150;
--		input <= "110010010100010011111110";
--		wait for clk_period * 150;
--		input <= "000000000010011100000000";
--		wait for clk_period * 150;
--		input <= "000111011100111111111111";
--		wait;
--	end process;


	stim : process
		file text_file : text open read_mode is "test.dat";
		variable text_line : line;
		variable test_signal : integer;
				
	begin
		rst_low<= '1';
		input_count <= 0;
		wait for clk_period * 10;
		rst_low <= '0';
		wait for clk_period * 10;
		rst_low <= '1';
		wait for clk_period * 10;
		
		while not endfile(text_file) loop
			readline(text_file, text_line);
			read(text_line, test_signal);
			input_count <= input_count + 1;
			input_flag <= '1';
			input <= std_logic_vector(to_signed(test_signal, 24));
			wait for 40 ns;
			input_flag <= '0';
			wait for 3000 ns;
		end loop;
		file_close(text_file);
	end process;
end architecture behavior;