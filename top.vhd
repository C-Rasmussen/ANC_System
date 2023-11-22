
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
LIBRARY altera_mf;
USE altera_mf.all;

entity top is

port(
	ADC_CLK_10 	: in std_logic;
	
	KEY 				: in std_logic_vector(1 downto 0);
	
	VGA_R 			: out std_logic_vector (3 downto 0);
	VGA_G 			: out std_logic_vector (3 downto 0);
	VGA_B 			: out std_logic_vector (3 downto 0);
	VGA_HS 			: out std_logic;
	VGA_VS 			: out std_logic
	
--	DRAM_ADDR 		: out std_logic_vector (12 downto 0);
--	DRAM_BA 			: out std_logic_vector (1 downto 0);
--	DRAM_CAS_N 		: out std_logic;
--	DRAM_CKE 		: out std_logic;
--	DRAM_CLK 		: out std_logic;
--	DRAM_CS_N 		: out std_logic;
--	DRAM_DQ 			: inout std_logic_vector (15 downto 0);
--	DRAM_LDQM 		: out std_logic;
--	DRAM_RAS_N 		: out std_logic;
--	DRAM_UDQM 		: out std_logic;
--	DRAM_WE_N 		: out std_logic;
	
	);
end entity top;

architecture behavior of top is

component VGA is
port(
	clk : in std_logic;
	rst : in std_logic;
	red : out std_logic_vector (3 downto 0);
	blue : out std_logic_vector (3 downto 0);
	green : out std_logic_vector (3 downto 0);
	HSYNC : out std_logic;
	VSYNC : out std_logic;
	Bricks : in std_logic_vector (1214 downto 0);
	ball_xpos : in unsigned (9 downto 0);
   ball_ypos : in unsigned (9 downto 0);
   paddle_pos : in unsigned (9 downto 0);
	hflag : out std_logic;
	vflag : out std_logic
	);
end component VGA;

component PLL IS
	PORT
	(
		inclk0		: IN STD_LOGIC  := '0';
		c0		: OUT STD_LOGIC ;
		c1		: OUT STD_LOGIC ;
		locked		: OUT STD_LOGIC 
	);
end component PLL;

component mover is 
port(
	clk : in std_logic;
	adc_clk : in std_logic;
	rst : in std_logic;
	btn : in std_logic;
	pll_locked : in std_logic;
	bricks : out std_logic_vector (1214 downto 0);
	ball_xpos : out unsigned (9 downto 0);
	ball_ypos : out unsigned (9 downto 0);
	paddle_pos : out unsigned (9 downto 0);
	hflag : in std_logic;
	vflag : in std_logic
);
end component mover;


signal bricks : std_logic_vector (1214 downto 0);
signal clk_10 : std_logic;
signal clk_25 : std_logic;
signal pll_locked : std_logic;

signal ball_xpos : unsigned (9 downto 0);
signal ball_ypos : unsigned (9 downto 0);
signal paddle_pos : unsigned (9 downto 0);

signal hflag_sig : std_logic;
signal vflag_sig : std_logic;
 
 
begin 

u0 : VGA 
	port map(
		clk => clk_25,
		rst => KEY(0),
		red => VGA_R,
		green => VGA_G,
		blue => VGA_B,
		HSYNC => VGA_HS,
		VSYNC => VGA_VS,
		bricks => bricks,
		ball_xpos => ball_xpos,
		ball_ypos => ball_ypos,
		paddle_pos => paddle_pos,
		hflag => hflag_sig,
		vflag => vflag_sig
		);
	 
u1 : PLL
	port map(
		inclk0 => ADC_CLK_10,
		c0 => clk_10,
		c1 => clk_25,
		locked => pll_locked
		);
		
u2 : Mover 
	port map(
		clk => clk_25,
		adc_clk => clk_10,
		rst => KEY(0),
		btn => KEY(1),
		pll_locked => pll_locked,
		bricks => bricks,
		ball_xpos => ball_xpos,
		ball_ypos => ball_ypos,
		paddle_pos => paddle_pos,
		hflag => hflag_sig,
		vflag => vflag_sig
		);

end architecture behavior;