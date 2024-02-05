library ieee;
use ieee.std_logic_1164.all;
--MCLK = 5.120 MHz
--SLCK = 1.250 MHz
--LRCLK= 19,531.25 KHz
entity top is

	port (
		MAX10_CLK1_50 : in std_logic;
		GPIO : inout std_logic_vector(35 downto 0);
		KEY	: in std_logic_vector(1 downto 0);
		LEDR	: out std_logic_vector(9 downto 0)
	);
	
end entity top;


architecture behavior of top is

component pmod_out is
    port (
        sig : in std_logic_vector(15 downto 0);
        clk : in std_logic;      -- 500MHz clock
		  rst_n: in std_logic;
        LRCLK : buffer std_logic;   -- Left-right clock stereo audio output
        SCLK : buffer std_logic;    -- Clock for transmitting individual signal bits to PmodI2S
        SDIN : buffer std_logic     -- Current signal bit to transmit
    );
end component pmod_out;


component data_gen is

	generic (
		freq			: integer := 220;
		bit_width	: integer := 16
	);
	
	port (
		clk		: in std_logic;
		--rst_n			: in std_logic;
		out_data		: out std_logic_vector(bit_width-1 downto 0)
	);
end component data_gen;

--
component pll_m_data_clk is
port(
	areset	: in std_logic;
	inclk0	: in std_logic;
	c0			: out std_logic
);
end component pll_m_data_clk;



signal m_clk		: std_logic;
signal lr_clk		: std_logic;
signal bit_clk		: std_logic;
signal reset_h		: std_logic;
signal rst			: std_logic;
signal adc_bit		: std_logic;
signal dac_bit		: std_logic;
--Add in a package
signal in_data		: std_logic_Vector(15 downto 0);


signal cycleCount : INTEGER := 0;        -- Time in clock cycles
signal sigHalfPeriod : INTEGER := 0;
signal sig_internal : STD_LOGIC_VECTOR(15 downto 0) := "0000111111111111";

begin


pmod_out_inst : pmod_out
    port map(
        sig => sig_internal,
        clk =>  m_clk,   
		  rst_n => rst,
        LRCLK => lr_clk,   -- Left-right clock stereo audio output
        SCLK => bit_clk,    -- Clock for transmitting individual signal bits to PmodI2S
        SDIN => dac_bit     -- Current signal bit to transmit
    );
 
		  
	pll_m_data_clk_inst : pll_m_data_clk PORT MAP (
		areset	 => reset_h,
		inclk0	 => MAX10_CLK1_50,
		c0	 => m_clk
	);
			
	rst <= KEY(0);
	reset_h <= not rst;

	GPIO(0) <= m_clk;
	--GPIO(3) <= m_clk;
	
	GPIO(1) <= lr_clk;
	--GPIO(7) <= lr_clk;
	GPIO(2) <= bit_clk;
	--GPIO(11) <= bit_clock;
	
	GPIO(3) <= dac_bit;
	--adc_bit <= GPIO(15);
	
	sigHalfPeriod <= 1000000 / (440 * 2);
	process(m_clk, rst)
    begin
		if rst = '0' then
			cycleCount <= 0;
			sig_internal <= "0000111111111111";
			
        elsif rising_edge(m_clk) then
            if cycleCount >= sigHalfPeriod then
                sig_internal <= not sig_internal;
                cycleCount <= 0;
            else
                cycleCount <= cycleCount + 1;
            end if;
        end if;
    end process;
end architecture behavior;



