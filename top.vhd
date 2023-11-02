library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
LIBRARY altera_mf;
USE altera_mf.all;

entity top is

port(
	MAX10_CLK1_50 : in std_logic;
	
	KEY : in std_logic_vector(1 downto 0);
	
	VGA_R : out std_logic_vector (3 downto 0);
	VGA_G : out std_logic_vector (3 downto 0);
	VGA_B : out std_logic_vector (3 downto 0);
	VGA_HS : out std_logic;
	VGA_VS : out std_logic
	);
end entity top;

architecture behavior of top is

	signal btn_debounced : std_logic;
	signal PLL_clk : std_logic;

	component debouncer
		port(
			clk 				: in std_logic;
			button 			: in std_logic;
			rst 				: in std_logic;
			out_debounced 	: out std_logic
			);
	end component debouncer;
	
	component PLL
		port(
			inclk0		: IN STD_LOGIC  := '0';
			c0				: OUT STD_LOGIC 
		);
	end component PLL;
	
	component VGA
		port(
			clk : in std_logic;
			rst : in std_logic;
			advance : in std_logic;
			red : out std_logic_vector (3 downto 0);
			blue : out std_logic_vector (3 downto 0);
			green : out std_logic_vector (3 downto 0);
			HSYNC : out std_logic;
			VSYNC : out std_logic
		);
	end component VGA;
		
begin
	
	u0 : debouncer
	port map(
		clk => PLL_clk,
		button => KEY(1),
		rst => KEY(0),
		out_debounced => btn_debounced
		);
		
	u1 : PLL
	port map(
		inclk0 => MAX10_CLK1_50,
		c0 => PLL_clk
		);
		
	u2 : VGA
	port map(
		clk => PLL_clk,
		rst => KEY(0),
		advance => btn_debounced,
		red => VGA_R,
		blue => VGA_B,
		green => VGA_G,
		HSYNC => VGA_HS,
		VSYNC => VGA_VS
		);

end architecture behavior;
		
		
		
		
		
		
		
		
