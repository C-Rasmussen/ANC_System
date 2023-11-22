
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
LIBRARY altera_mf;
USE altera_mf.all;

entity ADC_top is 
port(
	ADC_CLK_10 		: in STD_LOGIC;
	MAX10_CLK1_50 	: in STD_LOGIC;
	MAX10_CLK2_50 	: in STD_LOGIC;
	
	HEX0 				: out std_logic_vector (7 downto 0);
	HEX1 				: out std_logic_vector (7 downto 0);
	HEX2 				: out std_logic_vector (7 downto 0);
	HEX3 				: out std_logic_vector (7 downto 0);
	HEX4 				: out std_logic_vector (7 downto 0);
	HEX5 				: out std_logic_vector (7 downto 0);
	
	KEY 				: in STD_LOGIC_VECTOR (1 downto 0);
	
	LEDR 				: out STD_LOGIC_VECTOR (9 downto 0)
);
end entity ADC_top;

architecture behavior of ADC_top is 

component PLL is
	port
	(
		inclk0		: IN STD_LOGIC  := '0';
		c0		: OUT STD_LOGIC ;
		locked		: OUT STD_LOGIC 
	);
end component PLL;

component adc_entity is
	port (
		clock_clk              : in  std_logic                     := 'X';             -- clk
		reset_sink_reset_n     : in  std_logic                     := 'X';             -- reset_n
		adc_pll_clock_clk      : in  std_logic                     := 'X';             -- clk
		adc_pll_locked_export  : in  std_logic                     := 'X';             -- export
		command_valid          : in  std_logic                     := 'X';             -- valid
		command_channel        : in  std_logic_vector(4 downto 0)  := (others => 'X'); -- channel
		command_startofpacket  : in  std_logic                     := 'X';             -- startofpacket
		command_endofpacket    : in  std_logic                     := 'X';             -- endofpacket
		command_ready          : out std_logic;                                        -- ready
		response_valid         : out std_logic;                                        -- valid
		response_channel       : out std_logic_vector(4 downto 0);                     -- channel
		response_data          : out std_logic_vector(11 downto 0);                    -- data
		response_startofpacket : out std_logic;                                        -- startofpacket
		response_endofpacket   : out std_logic                                         -- endofpacket
	);
end component adc_entity;

--signals
signal PLL_CLK : std_logic;
signal PLL_LOCKED : std_logic;
signal command_ready : std_logic;
signal response_ready : std_logic;
signal command_channel : std_logic_vector (4 downto 0);
signal command_valid : std_logic;
signal command_start : std_logic;
signal command_end : std_logic;
signal response_valid : std_logic;
signal response_channel : std_logic_vector(4 downto 0);
signal response_data : std_logic_vector(11 downto 0);
signal response_startofpacket : std_logic;
signal response_endofpacket : std_logic;

type state_type is (IDLE, SEND_COMMAND, READ_DATA);
signal state : state_type;
	
type number_lut is array (0 to 15) of std_logic_vector(7 downto 0);
constant table : number_lut := (X"C0", X"F9", X"A4", X"B0", X"99", X"92", X"82", X"F8", X"80", X"90", X"88", X"83", X"C6", X"A1", X"86", X"8E");



begin
	
	u0 : PLL
	port map(
		inclk0 => ADC_CLK_10,
		c0 => PLL_CLK,
		locked => PLL_LOCKED
		);
		
	u1 : component adc_entity
		port map (
			clock_clk              => PLL_CLK,              --          clock.clk
			reset_sink_reset_n     => KEY(0),     --     reset_sink.reset_n
			adc_pll_clock_clk      => PLL_CLK,      --  adc_pll_clock.clk
			adc_pll_locked_export  => PLL_LOCKED,  -- adc_pll_locked.export
			command_valid          => command_valid,          --        command.valid
			command_channel        => command_channel,        --               .channel
			command_startofpacket  => command_start,  --               .startofpacket
			command_endofpacket    => command_end,    --               .endofpacket
			command_ready          => command_ready,          --               .ready
			response_valid         => response_valid,         --       response.valid
			response_channel       => response_channel,       --               .channel
			response_data          => response_data,          --               .data
			response_startofpacket => response_startofpacket, --               .startofpacket
			response_endofpacket   => response_endofpacket    --               .endofpacket
		);
		
	
	process (ADC_CLK_10) begin
		if rising_edge(ADC_CLK_10) then
			if KEY(0) = '0' then
				command_valid <= '1';
				command_start <= '1';
				command_end <= '1';
				command_channel <= "00001";
				state <= IDLE;
			end if;
			
			case state is
				when IDLE =>
					if command_ready = '1' then
						state <= SEND_COMMAND;
					end if;
					
					if response_valid = '1' then
						state <= READ_DATA;
						LEDR <= response_data(9 downto 0);
					end if;
				
				when SEND_COMMAND =>
					state <= IDLE;
				when READ_DATA =>
					state <= IDLE;
			end case;
		end if;
	end process;
end architecture behavior;
