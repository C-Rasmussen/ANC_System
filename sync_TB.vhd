
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sync_TB is 
end sync_TB;

architecture behavior of sync_TB is
	
	constant FP_WAIT : integer := 16;
	constant SYNC_WAIT : integer := 96;
	constant BP_WAIT : integer := 48;
	constant DATA_WAIT : integer := 640;
	
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
	
	signal clk : std_logic := '0';
	signal rst : std_logic := '1';
	signal sync : std_logic := '1';
	signal flag : std_logic := '0';
	
	
	constant CLK_PERIOD : time := 40 ns;
	
begin 

	uut : SYNC_COMP 
	generic map(
		FP_WAIT => FP_WAIT,
		SYNC_WAIT => SYNC_WAIT,
		BP_WAIT => BP_WAIT,
		DATA_WAIT => DATA_WAIT
		)
	port map(
		clk => clk,
		rst => rst,
		sync => sync,
		flag => flag
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
		wait for clk_period * 10;
		rst <= '0';
		wait for clk_period * 10;
		rst <= '1';
		wait;
	end process;
	
end architecture behavior;