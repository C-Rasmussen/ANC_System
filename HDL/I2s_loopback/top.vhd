library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;


entity top is

	port (
	
		MAX10_CLK1_50: in std_logic;
		KEY: in std_logic_vector(1 downto 0);
		GPIO: inout	std_logic_vector(35 downto 0)
		
	);
end entity top;


architecture behavior of top is

	component clock_gen is
    port (
        clk : in std_logic;   
        rst_n : in std_logic;
        LRCLK : buffer std_logic;   -- Left-right clock stereo audio output
        SCLK : buffer std_logic    -- Clock for transmitting individual signal bits to PmodI2S
    );
	end component clock_gen;



	component pll IS
		PORT
		(
			areset		: IN STD_LOGIC  := '0';
			inclk0		: IN STD_LOGIC  := '0';
			c0				: OUT STD_LOGIC 
		);
	END component pll;
	
	
	component i2s_rx_tx is
	port(
		 clk : in std_logic;
		 rst_n : in std_logic;
		 i2s_bclk : in std_logic;
		 i2s_lr : in std_logic;
		 i2s_din : in std_logic;
		 i2s_dout : out std_logic := '0';
		 
		 out_l : out signed (23 downto 0) := (others=>'0');
		 out_r : out signed (23 downto 0) := (others=>'0');
		 
		 in_l : in signed (23 downto 0);
		 in_r : in signed (23 downto 0);
		 
		 sync : out std_logic := '0'
    );
	end component i2s_rx_tx;

	signal m_clk	: std_logic;
	signal lr_clk_tx	: std_logic;
	signal sclk_tx		: std_logic;

	
	signal data			: std_logic_Vector(15 downto 0);
	signal data_real	: std_logic_vector(15 downto 0);
	signal rst_n		: std_logic;
	signal rst_h		: std_logic;
	
	signal dac_bit		: std_logic;
	signal adc_bit		: std_logic;
	
	signal dac_real	: std_logic;
	signal sync			: std_logic;
	signal adc_real	: std_logic;
	signal out_l		: signed(23 downto 0);
	signal out_r		: signed(23 downto 0);
	signal in_l		: signed(23 downto 0);
	signal in_r		: signed(23 downto 0);
	
	signal sigHalfPeriod : INTEGER := 0;
	signal cycleCount : INTEGER := 0; 


	begin
		rst_n <= KEY(0);
		rst_h <= not KEY(0);
		
		
		i2s_rx_tx_inst: i2s_rx_tx 
	port map(
		 clk => m_clk,
		 rst_n => rst_n,
		 
		 i2s_bclk => sclk_tx,
		 i2s_lr => lr_clk_tx,
		 i2s_din => adc_real,
		 i2s_dout => dac_real,
		 
		 out_l => out_l,
		 out_r => out_r,
		 
		 in_l => out_l,
		 in_r => out_r,
		 
		 sync => sync
    );

		
		clock_gen_inst : clock_gen
			 port map(
				  clk =>  m_clk,   
				  rst_n => rst_n,
				  LRCLK => lr_clk_tx,   -- Left-right clock stereo audio output
				  SCLK => sclk_tx    -- Clock for transmitting individual signal bits to PmodI2S
			);
			
				
			
		pll_inst : pll
		port map(
		
			areset		=> rst_h,
			inclk0		=> MAX10_CLK1_50,
			c0				=> m_clk
		);
		
		
	GPIO(0) <= m_clk;
	GPIO(1) <= lr_clk_tx;
	GPIO(2) <= sclk_tx;
	GPIO(3) <= dac_real;
	
	
	GPIO(6) <= m_clk;
	GPIO(7) <= lr_clk_tx;
	GPIO(8) <= sclk_tx;
	adc_real <= GPIO(9);
		
end architecture behavior;




