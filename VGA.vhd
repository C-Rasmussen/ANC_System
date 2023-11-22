library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity VGA is

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
end entity VGA;

architecture behavior of VGA is 

	component SYNC_COMP
		generic(
			FP_WAIT : integer := 0;
			SYNC_WAIT : integer := 0;
			BP_WAIT : integer := 0;
			DATA_WAIT : integer := 0;
			DIVISOR : integer := 0
			);
		
		port(
			clk : in std_logic;
			rst : in std_logic;
			sync : out std_logic;
			flag : out std_logic;
			coordinate : out unsigned (9 downto 0)
			);
	end component SYNC_COMP;
	
	component RGB_Driver
		port(
			clk : in std_logic;
			rst : in std_logic;
			hflag : in std_logic;
			vflag : in std_logic;
			red : out std_logic_vector (3 downto 0);
			blue : out std_logic_vector (3 downto 0);
			green : out std_logic_vector (3 downto 0);
			xpos : in unsigned (9 downto 0);
			ypos : in unsigned (9 downto 0);
			ball_xpos : in unsigned (9 downto 0);
			ball_ypos : in unsigned (9 downto 0);
			paddle_pos : in unsigned (9 downto 0);
			bricks : in std_logic_vector(1214 downto 0)
			);
	end component RGB_Driver;
	
	--type BRICKS is array (0 to 39, 0 to 29) of STD_LOGIC;
	
	constant H_FP_WAIT : integer := 16;
	constant H_SYNC_WAIT : integer := 96;
	constant H_BP_WAIT : integer := 48;
	constant H_DATA_WAIT : integer := 640;
	constant H_DIVISOR : integer := 1;
	
	constant V_FP_WAIT : integer := 8000;
	constant V_SYNC_WAIT : integer := 1600;
	constant V_BP_WAIT : integer := 26400;
	constant V_DATA_WAIT : integer := 384000;
	constant V_DIVISOR : integer := 800;
	
	signal Hflag_sig : std_logic;
	signal Vflag_sig : std_logic;
	
	signal Xcoord : unsigned (9 downto 0);
	signal Ycoord : unsigned (9 downto 0);
	
begin

	hflag <= hflag_sig;
	vflag <= vflag_sig;

	Hsync_comp : SYNC_COMP 
	generic map(
		FP_WAIT => H_FP_WAIT,
		SYNC_WAIT => H_SYNC_WAIT,
		BP_WAIT => H_BP_WAIT,
		DATA_WAIT => H_DATA_WAIT,
		DIVISOR => H_DIVISOR
		)
	port map(
		clk => clk,
		rst => rst,
		sync => HSYNC,
		flag => Hflag_sig,
		coordinate => Xcoord
		);
		
	Vsync_comp : SYNC_COMP 
	generic map(
		FP_WAIT => V_FP_WAIT,
		SYNC_WAIT => V_SYNC_WAIT,
		BP_WAIT => V_BP_WAIT,
		DATA_WAIT => V_DATA_WAIT,
		DIVISOR => V_DIVISOR
		)
	port map(
		clk => clk,
		rst => rst,
		sync => VSYNC,
		flag => Vflag_sig,
		coordinate => Ycoord
		);
		
	Driver : RGB_Driver
		port map(
			clk => clk,
			rst => rst,
			hflag => hflag_sig,
			vflag => vflag_sig,
			red => red,
			green => green,
			blue => blue,
			xpos => xcoord,
			ypos => ycoord,
			bricks => bricks,
			ball_xpos => ball_xpos,
			ball_ypos => ball_ypos,
			paddle_pos => paddle_pos
		);
		
end architecture behavior;
		