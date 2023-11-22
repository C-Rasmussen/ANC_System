
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mover is 
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
end entity mover;

architecture behavior of mover is

signal adc_val : unsigned (11 downto 0);
signal rand_num : unsigned (9 downto 0);
signal int_paddle_pos : unsigned (9 downto 0) := "0000000000";

type state_type is (IDLE, SEND_COMMAND, READ_DATA);
signal ADC_state : state_type := IDLE;

type state_type2 is (STILL, MLEFT, MRIGHT);
signal Paddle_state : state_type2 := STILL;


--ADC SIGNALS
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
--ADC SIGNALS


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

component lfsr is	
	port(
		clk : in std_logic;
		rst : in std_logic;
		rand_num : out unsigned (9 downto 0)
		);
end component lfsr;

component ball_mover is 
port(
	clk : in std_logic;
	rst : in std_logic;
	btn : in std_logic;
	rand_num : in unsigned (9 downto 0);
	bricks : in std_logic_vector (1214 downto 0);
	ball_xpos : out unsigned (9 downto 0);
	ball_ypos : out unsigned (9 downto 0);
	paddle_pos : in unsigned (9 downto 0);
	hflag : in std_logic;
	vflag : in std_logic
);
end component ball_mover;

begin

bricks <= (others => '1');

u0 : adc_entity
		port map (
			clock_clk              => ADC_CLK,              --          clock.clk
			reset_sink_reset_n     => rst,     --     reset_sink.reset_n
			adc_pll_clock_clk      => ADC_CLK,      --  adc_pll_clock.clk
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
		
u1 : lfsr
	port map(
		clk => clk,
		rst => rst,
		rand_num => rand_num
		);
		
u2 : ball_mover
	port map(
	clk => clk,
	rst => rst,
	btn => btn,
	rand_num => rand_num,
	bricks => bricks,
	ball_xpos => ball_xpos_sig,
	ball_ypos => ball_ypos_sig,
	paddle_pos => int_paddle_pos,
	hflag => hflag,
	vflag => vflag
	);
process (ADC_CLK) begin
	if rising_edge(ADC_CLK) then
		if rst = '0' then
			command_valid <= '1';
			command_start <= '1';
			command_end <= '1';
			command_channel <= "00001";
			ADC_state <= IDLE;
		end if;
			
		case ADC_state is
			when IDLE =>
				if command_ready = '1' then
					ADC_state <= SEND_COMMAND;
				end if;
				
				if response_valid = '1' then
					ADC_state <= READ_DATA;
					adc_val <= unsigned(response_data);
				end if;
			
			when SEND_COMMAND =>
				ADC_state <= IDLE;
			when READ_DATA =>
				ADC_state <= IDLE;
		end case;
	end if;
end process;

process (clk) begin
	if rst = '0' then
		Paddle_state <= STILL;
		int_paddle_pos <= "0100101100";
	elsif rising_edge(clk) then
		case paddle_state is
			when STILL =>
				if hflag = '1' and vflag = '1' then
					if adc_val < 1300 then
						paddle_state <= MLEFT;
					end if;
					
					if adc_val > 2600 then
						paddle_state <= MRIGHT;
					end if;
				end if;
			
			when MLEFT =>
				if hflag = '0' and vflag = '0' then
					if int_paddle_pos > 3 then
						int_paddle_pos <= int_paddle_pos - 4;
						paddle_state <= STILL;
					end if;
				end if;
				
				if adc_val > 1299 then
					paddle_state <= STILL;
				end if;
			
			when MRIGHT => 
				if hflag = '0' and vflag = '0' then
					if int_paddle_pos < 597 then
						int_paddle_pos <= int_paddle_pos + 4;
						paddle_state <= STILL;
					end if;
				end if;
			
				if adc_val < 2599 then
					paddle_state <= STILL;
				end if;
		end case;
	end if;
	paddle_pos <= int_paddle_pos;
end process;


--process (btn) begin
	--if btn = '0' then
		--if rand_num < 600 then
			--paddle_pos <= rand_num;
		--end if;
	--end if;
--end process;
	


end architecture behavior;
	