library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use std.textio.all;


entity top_tb is 
end entity top_tb;

architecture behavior of top_tb is

    signal clk_count: integer := 0;
    constant CLK_PERIOD_m: time := 195.3 ns;
	 constant CLK_PERIOD: time := 20 ns;



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
	signal MAX10_CLK1_50 : std_logic;

	
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
	
	signal lr_clk_count	: integer := 0;
	
	signal sigHalfPeriod : INTEGER := 0;
	signal cycleCount : INTEGER := 0; 
	
	signal input : std_logic_vector(23 downto 0);


begin

		
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
		
		
	lr_clk_count_proc : process(sclk_tx)
	begin
		if lr_clk_count = 63 then
			lr_clk_count <= 0;
		else
			lr_clk_count <= lr_clk_count + 1;
		end if;
	end process;

		
	clk_process: process
    begin
        MAX10_CLK1_50 <= '1';
        wait for CLK_PERIOD / 2;
        MAX10_CLK1_50 <= '0';
        wait for CLK_PERIOD / 2;
    end process;
	 
	 
	     arst_n_proc: process
    begin
        rst_n <= '0';
		  rst_h <= '1';
        wait for 5*CLK_PERIOD;
        rst_n <= '1';
		  rst_h <= '0';
        wait;
    end process;
	 
	 
	     clk_count_proc: process(m_clk)
    begin
        if rising_edge(m_clk) then
            clk_count <= clk_count + 1;
        end if;
    end process;
	 
	 stim : process
		file text_file : text open read_mode is "test.txt";
		variable text_line : line;
		variable test_signal : integer;				
	begin
		wait for clk_period * 10;
		while not endfile(text_file) loop
		
			wait until lr_clk_count = 62;
			
			readline(text_file, text_line);
			read(text_line, test_signal);
			
			
			input <= std_logic_vector(to_signed(test_signal, 24));
			
			--left
			adc_real <= input(23);
			wait for 4*CLK_PERIOD_m;
			
			adc_real <= input(22);
			wait for 4*CLK_PERIOD_m;
			
			adc_real <= input(21);
			wait for 4*CLK_PERIOD_m;
			
			adc_real <= input(20);
			wait for 4*CLK_PERIOD_m;
			
			adc_real <= input(19);
			wait for 4*CLK_PERIOD_m;
			
			adc_real <= input(18);
			wait for 4*CLK_PERIOD_m;
			
			adc_real <= input(17);
			wait for 4*CLK_PERIOD_m;
			
			adc_real <= input(16);
			wait for 4*CLK_PERIOD_m;
			
			adc_real <= input(15);
			wait for 4*CLK_PERIOD_m;
			
			adc_real <= input(14);
			wait for 4*CLK_PERIOD_m;
			
			adc_real <= input(13);
			wait for 4*CLK_PERIOD_m;
			
			adc_real <= input(12);
			wait for 4*CLK_PERIOD_m;
			
			adc_real <= input(11);
			wait for 4*CLK_PERIOD_m;
			
			adc_real <= input(10);
			wait for 4*CLK_PERIOD_m;
			
			adc_real <= input(9);
			wait for 4*CLK_PERIOD_m;
			
			adc_real <= input(8);
			wait for 4*CLK_PERIOD_m;
			
			adc_real <= input(7);
			wait for 4*CLK_PERIOD_m;
			
			adc_real <= input(6);
			wait for 4*CLK_PERIOD_m;
			
			adc_real <= input(5);
			wait for 4*CLK_PERIOD_m;
			
			adc_real <= input(4);
			wait for 4*CLK_PERIOD_m;
			
			adc_real <= input(3);
			wait for 4*CLK_PERIOD_m;
			
			adc_real <= input(2);
			wait for 4*CLK_PERIOD_m;
			
			adc_real <= input(1);
			wait for 4*CLK_PERIOD_m;
			
			adc_real <= input(0);
			wait for 64*CLK_PERIOD_m; --in between left and right clock
			
			
			adc_real <= input(23);
			wait for 4*CLK_PERIOD_m;
			
			adc_real <= input(22);
			wait for 4*CLK_PERIOD_m;
			
			adc_real <= input(21);
			wait for 4*CLK_PERIOD_m;
			
			adc_real <= input(20);
			wait for 4*CLK_PERIOD_m;
			
			adc_real <= input(19);
			wait for 4*CLK_PERIOD_m;
			
			adc_real <= input(18);
			wait for 4*CLK_PERIOD_m;
			
			adc_real <= input(17);
			wait for 4*CLK_PERIOD_m;
			
			adc_real <= input(16);
			wait for 4*CLK_PERIOD_m;
			
			adc_real <= input(15);
			wait for 4*CLK_PERIOD_m;
			
			adc_real <= input(14);
			wait for 4*CLK_PERIOD_m;
			
			adc_real <= input(13);
			wait for 4*CLK_PERIOD_m;
			
			adc_real <= input(12);
			wait for 4*CLK_PERIOD_m;
			
			adc_real <= input(11);
			wait for 4*CLK_PERIOD_m;
			
			adc_real <= input(10);
			wait for 4*CLK_PERIOD_m;
			
			adc_real <= input(9);
			wait for 4*CLK_PERIOD_m;
			
			adc_real <= input(8);
			wait for 4*CLK_PERIOD_m;
			
			adc_real <= input(7);
			wait for 4*CLK_PERIOD_m;
			
			adc_real <= input(6);
			wait for 4*CLK_PERIOD_m;
			
			adc_real <= input(5);
			wait for 4*CLK_PERIOD_m;
			
			adc_real <= input(4);
			wait for 4*CLK_PERIOD_m;
			
			adc_real <= input(3);
			wait for 4*CLK_PERIOD_m;
			
			adc_real <= input(2);
			wait for 4*CLK_PERIOD_m;
			
			adc_real <= input(1);
			wait for 4*CLK_PERIOD_m;
			
			adc_real <= input(0);
			

		end loop;
		file_close(text_file);
	end process;



end architecture behavior;