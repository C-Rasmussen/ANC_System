library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.anc_package.all;

entity top is
	
	port (
		MAX10_CLK1_50	: in std_logic;
		MAX10_CLK2_50	: in std_logic;
		ADC_CLK_10		: in std_logic;

		KEY				: in std_logic_vector(1 downto 0);

		SW				: in std_logic_vector(9 downto 0);
		
		LEDR				: out std_logic_vector(9 downto 0);
		ARDUINO_IO		: inout std_logic_vector(15 downto 0);
		GPIO				: inout std_logic_vector(35 downto 0)

	);

end entity top;


architecture behavior of top is

	component i2s_clock_gen is
   port (
        clk 			: in std_logic;   
        rst_n 			: in std_logic;
        LRCLK 			: buffer std_logic;   -- Left-right clock stereo audio output
        SCLK 			: buffer std_logic    -- Clock for transmitting individual signal bits to PmodI2S
    );
	end component i2s_clock_gen;
	
	
	component i2s_driver is
	port(
		 clk 				: in std_logic;
		 rst_n 			: in std_logic;
		 i2s_bclk 		: in std_logic;
		 i2s_lr 			: in std_logic;
		 i2s_din 		: in std_logic;
		 i2s_dout 		: out std_logic := '0';
		 
		 out_l 			: out signed (23 downto 0) := (others=>'0');
		 out_r 			: out signed (23 downto 0) := (others=>'0');
		 
		 in_l 			: in signed (23 downto 0);
		 in_r 			: in signed (23 downto 0);
		 
		 sync 			: out std_logic := '0'
    );
	end component i2s_driver;
	
	
	component fir_module is
	port(
		rst_low 			: in std_logic;
		input_flag 		: in std_logic;
		output_flag 	: out std_logic;
		clk 				: in std_logic;								--Input from top module, probably ADC_CLK50 for fastest possible filtering
		error_mic		: in std_logic_vector(23 downto 0);
		input 			: in std_logic_vector(23 downto 0);		--Input from I2S2 module, read in from reference microphone											--Input from error module, updated coefficients (might be better to split into 32 individual inputs)
		output 			: out std_logic_vector(23 downto 0);		--Output from filtering.  To be sent to I2S2 module to be played on anti noise speaker
		s1 : out std_logic;
		s2 : out std_logic;
		s3 : out std_logic;
		s4 : out std_logic;
		s5 : out std_logic;
		s6 : out std_logic;
		s7 : out std_logic;
		s8 : out std_logic;
		s9 : out std_logic;
		s10 : out std_logic;
		mu	: in signed(23 downto 0)
		);
	end component fir_module;
	
	
	component pll is
	port(
		areset			: in std_logic  := '0';
		inclk0			: in std_logic  := '0';
		c0					: out std_logic 
	);
	end component pll;
	
	
	component fifo is
	PORT
	(
		aclr				: in std_logic;
		data				: in std_logic_vector (23 DOWNTO 0);
		rdclk				: in std_logic ;
		rdreq				: in std_logic ;
		wrclk				: in std_logic ;
		wrreq				: in std_logic ;
		q					: out std_logic_vector (23 DOWNTO 0);
		rdempty			: out std_logic ;
		wrfull			: out std_logic 
	);
	end component fifo;
	--fifo between i2s tx and fir
	--fir runs on 50 Mhz, i2s_tx runs on 5.120 MHz




--declare signals right here
	signal m_clk		: std_logic;
	signal lr_clk_tx	: std_logic;
	signal sclk_tx		: std_logic;

	
	signal rst_n		: std_logic;
	signal rst_h		: std_logic;
	
	signal clk_uart	: std_logic;
	
	signal dac_real	: std_logic;
	signal sync			: std_logic;
	signal store		: std_logic;
	signal adc_real	: std_logic;
	signal adc_reg		: std_logic;
	signal adc_reg_error : std_logic;
	signal adc_error	: std_logic;
	signal out_l		: signed(23 downto 0);
	signal error_sig	: signed(23 downto 0);
	signal out_r		: signed(23 downto 0);
	signal in_l			: signed(23 downto 0);
	signal in_r			: signed(23 downto 0);
	signal sampled_data : signed(23 downto 0);
	
	signal in_l_dummy			: signed(23 downto 0);
	signal in_r_dummy			: signed(23 downto 0);
	
	signal data_fifo_in 	: std_logic_vector(23 downto 0);
	signal rd_req			: std_logic;
	signal wr_req			: std_logic;
	signal data_fifo_out : std_logic_vector(23 downto 0);
	signal wr_full			: std_logic;
	signal rd_empty		: std_logic;
	signal fifo_clr		: std_logic;

	signal mu			: std_logic_vector(23 downto 0);
	
	signal shift_reg		: DELAY;	
	signal data_s			: std_logic; 
	signal data_inter		: std_logic_vector(7 downto 0);
	
	signal i2s_is_valid	: std_logic;
	signal count			: integer:= 0;
	signal index			: integer:= 0;
	signal rx_request_read : std_logic;
	signal read_delay : integer := 0;
	
	signal s1 : std_logic := '0';
	signal s2 : std_logic := '0';
	signal s3 : std_logic := '0';
	signal s4 : std_logic := '0';
	signal s5 : std_logic := '0';
	signal s6 : std_logic := '0';
	signal s7 : std_logic := '0';
	signal s8 : std_logic := '0';
	signal s9 : std_logic := '0';
	signal s10 : std_logic := '0';

begin

	--component connections between instantiated entities
		
--			
--	
--	uart_tx_inst: uart_tx port map(
--	
--		clk				=> clk_uart,
--		rst_n			=> rst_n,
--		
--		data_in			=> data_inter,
--		data_out			=> data_s,
--		
--		rx_request_read=> rx_request_read, --connect to rd req rec FIFO
--		rx_data_valid	=> not KEY(1)	--connect to not empty
--	);
	
	mu <= "000000000010000000110101";
	--mu <= "00000000000000" & sw(9 downto 0);
	
	i2s_driver_io: i2s_driver port map(
		 clk 			=> m_clk,
		 rst_n 		=> rst_n,
		 
		 i2s_bclk 	=> sclk_tx,
		 i2s_lr 		=> lr_clk_tx,
		 i2s_din 	=> adc_reg,
		 i2s_dout 	=> dac_real,
		 
		 out_l 		=> open,
		 out_r 		=> out_r,
		 
		 in_l 		=> out_r,--signed(shift_reg(SHIFT_LENGTH - 1)),
		 in_r 		=> out_r,--signed(shift_reg(SHIFT_LENGTH - 1)),
		 
		 sync 		=> sync
    );
	 
	 
	 i2s_driver_error: i2s_driver port map(
		 clk 			=> m_clk,
		 rst_n 		=> rst_n,
		 
		 i2s_bclk 	=> sclk_tx,
		 i2s_lr 		=> lr_clk_tx,
		 i2s_din 	=> adc_reg_error,
		 i2s_dout 	=> open,
		 
		 out_l 		=> open,
		 out_r 		=> error_sig,
		 
		 in_l 		=> in_l_dummy,
		 in_r 		=> in_r_dummy,
		 
		 sync 		=> open
    );
	
	
	--I2S entity reads from FIFO
	--FIR filter writes to FIFO
	fifo_inst : fifo port map (
		aclr		 => fifo_clr,
		data	 	 => data_fifo_in,
		rdclk	 	 => m_clk,
		rdreq	 	 => rd_req,
		wrclk	 	 => MAX10_CLK1_50,
		wrreq	 	 => wr_req,
		q	 		 => data_fifo_out,
		rdempty	 => rd_empty,
		wrfull	 => wr_full
	);
	
	
	pll_inst : pll port map(
		areset		=> rst_h,
		inclk0		=> MAX10_CLK1_50,
		c0				=> m_clk
	);
	

	clock_gen_inst : i2s_clock_gen port map(
		  clk 		=> m_clk,   
		  rst_n 		=> rst_n,
		  LRCLK 		=> lr_clk_tx,   
		  SCLK 		=> sclk_tx   
	);
	
	filter_inst : fir_module port map(
		rst_low 			=> rst_n,
		input_flag 		=> sync,
		output_flag 	=> store,
		clk 				=> MAX10_CLK1_50,								--Input from top module, probably ADC_CLK50 for fastest possible filtering
		error_mic		=> std_logic_vector(error_sig),
		input 			=> std_logic_vector(out_r),												--Input from I2S2 module, read in from reference microphone											--Input from error module, updated coefficients (might be better to split into 32 individual inputs)
		output 			=> data_fifo_in,	--Output from filtering.  To be sent to I2S2 module to be played on anti noise speaker
		s1 => s1,
		s2 => s2,
		s3 => s3,
		s4 => s4,
		s5 => s5,
		s6 => s6,
		s7 => s7,
		s8 => s8,
		s9 => s9,
		s10 => s10,
		mu	=> signed(mu)
		);

	
	GPIO(0) <= m_clk;
	GPIO(1) <= lr_clk_tx;
	GPIO(2) <= sclk_tx;
	GPIO(3) <= dac_real;
	
	
	GPIO(6) <= m_clk;
	GPIO(7) <= lr_clk_tx;
	GPIO(8) <= sclk_tx;
	adc_real <= GPIO(9);
	
	GPIO(10) <= m_clk;
	GPIO(11) <= lr_clk_tx;
	GPIO(12) <= sclk_tx;
	adc_error <= GPIO(13);
	
	GPIO(16) <= data_s;
	
	
	rst_n <= KEY(0);
	rst_h <= not KEY(0);
	
	LEDR(0) <= s1;
	LEDR(1) <= s2;
	LEDR(2) <= s3;
	LEDR(3) <= s4;
	LEDR(4) <= s5;
	LEDR(5) <= s6;
	LEDR(6) <= s7;
	LEDR(7) <= s8;
	LEDR(8) <= s9;
	LEDR(9) <= s10;

	--store needs to come out of fir filter saying data is valid
	--Output of fir is always hooked up to FIFO, enable goes high to transfer data
	write_fifo: process(MAX10_CLK1_50) begin
		if rising_edge(MAX10_CLK1_50) then
			if rst_n = '0' then
			else
				if (store = '1' and wr_full = '0') then
					wr_req <= '1';
				else
					wr_req <= '0';
				end if;	
			end if;
		end if;
	end process;
	
delay : process(lr_clk_tx) begin
		if rst_n = '0' then
				shift_reg <= (others => (others => '0'));
		elsif rising_edge(lr_clk_tx) then
				shift_reg(SHIFT_LENGTH - 1 downto 1) <= shift_reg(SHIFT_LENGTH - 2 downto 0);
				shift_reg(0) <= signed(data_fifo_out);
		end if;
	end process;
				
	
	read_fifo: process(m_clk) begin
		if rising_edge(m_clk) then
			if rst_n = '0' then
				fifo_clr <= '1';
			else
--			elsif read_delay > 15 then
				fifo_clr <= '0';
				if rd_empty = '0' then
					rd_req <= '1';
					i2s_is_valid <= '1';
				else
	
					rd_req <= '0';
					i2s_is_valid <= '0';
				end if;
			end if;
		end if;
	end process;
	
	reg: process(m_clk) begin
		if rising_edge(m_clk) then
			adc_reg <= adc_real;
			adc_reg_error <= adc_error;
		end if;
	end process;

	
end architecture behavior;