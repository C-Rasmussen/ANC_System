library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity VGA is

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
end entity VGA;

architecture behavior of VGA is 

	component SYNC_COMP
		generic(
			FP_WAIT : integer := 0;
			SYNC_WAIT : integer := 0;
			BP_WAIT : integer := 0;
			DATA_WAIT : integer := 0
			);
		
		port(
			clk : in std_logic;
			rst : in std_logic;
			sync : out std_logic;
			flag : out std_logic
			);
	end component SYNC_COMP;
	
	component flag_data_driver is 
	port(
		clk : in std_logic;
		rst : in std_logic;
		advance : in std_logic;
		Hflag : in std_logic;
		Vflag : in std_logic;
		red : out std_logic_vector (3 downto 0);
		blue : out std_logic_vector (3 downto 0);
		green : out std_logic_vector (3 downto 0)
		);
	end component flag_data_driver;
	
	constant H_FP_WAIT : integer := 16;
	constant H_SYNC_WAIT : integer := 96;
	constant H_BP_WAIT : integer := 48;
	constant H_DATA_WAIT : integer := 640;
	
	constant V_FP_WAIT : integer := 8000;
	constant V_SYNC_WAIT : integer := 1600;
	constant V_BP_WAIT : integer := 26400;
	constant V_DATA_WAIT : integer := 384000;
	
	signal Hflag : std_logic;
	signal Vflag : std_logic;
	
begin

	Hsync_comp : SYNC_COMP 
	generic map(
		FP_WAIT => H_FP_WAIT,
		SYNC_WAIT => H_SYNC_WAIT,
		BP_WAIT => H_BP_WAIT,
		DATA_WAIT => H_DATA_WAIT
		)
	port map(
		clk => clk,
		rst => rst,
		sync => HSYNC,
		flag => Hflag
		);
		
	Vsync_comp : SYNC_COMP 
	generic map(
		FP_WAIT => V_FP_WAIT,
		SYNC_WAIT => V_SYNC_WAIT,
		BP_WAIT => V_BP_WAIT,
		DATA_WAIT => V_DATA_WAIT
		)
	port map(
		clk => clk,
		rst => rst,
		sync => VSYNC,
		flag => Vflag
		);
		
	flag_generator : flag_data_driver
	port map(
		clk => clk,
		rst => rst,
		advance => advance,
		Hflag => Hflag,
		Vflag => Vflag,
		red => red,
		blue => blue,
		green => green
		);
		
end architecture behavior;
		