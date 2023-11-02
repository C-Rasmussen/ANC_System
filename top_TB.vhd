
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
LIBRARY altera_mf;
USE altera_mf.all;

entity top_TB is 
end top_TB;

architecture behavior of top_TB is
	
	component top
	port(
		MAX10_CLK1_50 : in std_logic;
		KEY : in std_logic_vector(1 downto 0);
		
		VGA_R : out std_logic_vector (3 downto 0);
		VGA_G : out std_logic_vector (3 downto 0);
		VGA_B : out std_logic_vector (3 downto 0);
		VGA_HS : out std_logic;
		VGA_VS : out std_logic
		);
	end component top;
	
	signal clk : std_logic := '0';
	signal rst : std_logic := '1';
	signal advance : std_logic := '1';
	
	signal red :  std_logic_vector(3 downto 0);
	signal blue :  std_logic_vector(3 downto 0);
	signal green :  std_logic_vector(3 downto 0);
	signal hsync : std_logic;
	signal vsync : std_logic;
	
	constant CLK_PERIOD : time := 2 ns;
	
begin 
	uut : top 
	
	port map(
		MAX10_CLK1_50 => clk,
		KEY(0) => rst,
		KEY(1) => advance,
		
		VGA_R => red,
		VGA_B => blue,
		VGA_G => green,
		VGA_HS => hsync,
		VGA_VS => vsync
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
		rst<= '1';
		wait for clk_period * 20;
		rst <= '0';
		wait for clk_period * 100;
		rst <= '1';
		wait;
	end process;
	
end architecture behavior;