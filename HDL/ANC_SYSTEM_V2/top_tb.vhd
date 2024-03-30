
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.anc_package.all;
use std.textio.all;

entity top_TB is 
end top_TB;

architecture behavior of top_TB is

	component fir_module is
	port(
		rst_low 			: in std_logic;
		input_flag 		: in std_logic;
		output_flag 	: out std_logic;
		clk 				: in std_logic;								
		error_mic		: in std_logic_vector(23 downto 0);
		input 			: in std_logic_vector(23 downto 0);		
		output 			: out std_logic_vector(23 downto 0);
		s1 : out std_logic;
		s2 : out std_logic;
		s3 : out std_logic;
		s4 : out std_logic;
		s5 : out std_logic;
		s6 : out std_logic;
		s7 : out std_logic;
		s8 : out std_logic;
		s9 : out std_logic;
		s10 : out std_logic
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
	port(
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
	
--	component i2s_clock_gen is
--   port (
--        clk 			: in std_logic;   
--        rst_n 			: in std_logic;
--        LRCLK 			: buffer std_logic;   
--        SCLK 			: buffer std_logic
--    );
--	end component i2s_clock_gen;
--	
	
	signal rst_low : std_logic := '1';
	signal rst_high : std_logic := '0';
	signal input_flag : std_logic := '0';
	signal clk : std_logic := '0';
	signal input : std_logic_vector(23 downto 0);
	signal fir_to_fifo : std_logic_vector(23 downto 0);
	signal input_count : integer;
	signal pll_clk : std_logic;
	signal lr_clk : std_logic;
	signal sclk : std_logic;
	
	signal store : std_logic;
	signal wr_full : std_logic;
	signal wr_req : std_logic;
	signal fifo_clr : std_logic;
	signal rd_empty : std_logic;
	signal rd_req : std_logic;
	signal fifo_out : std_logic_vector(23 downto 0);
	
	signal read_delay : integer := 0;
	
	signal error_sig : std_logic_vector(23 downto 0);
	
	signal i2s_is_valid : std_logic;
	
	constant CLK_PERIOD : time := 20 ns;
	
	
	
begin
	
	dut1 : fir_module
		port map(
		rst_low => rst_low,
		input_flag => input_flag,
		output_flag => store,
		error_mic => error_sig,
		clk => clk,
		input => input,
		output => fir_to_fifo
		);
		
	dut2 : pll
		port map(
		areset => rst_high,
		inclk0 => clk,
		c0 => pll_clk
		);
		
	dut3 : fifo
		port map(
		aclr => fifo_clr,
		data => fir_to_fifo,
		rdclk => pll_clk,
		rdreq => rd_req,
		wrclk => clk,
		wrreq => wr_req,
		q => fifo_out,
		rdempty => rd_empty,
		wrfull => wr_full
		);
		
--	dut4 : i2s_clock_gen port map(
--		  clk 		=> pll_clk,   
--		  rst_n 		=> rst_low,
--		  LRCLK 		=> lr_clk,   
--		  SCLK 		=> sclk   
--	);

	clk_process : process
	begin
		clk <= '0';
		wait for clk_period / 2;
		clk <= '1';
		wait for clk_period/2;
	end process;	

	
	write_fifo: process(clk) begin
		if rising_edge(clk) then
			if rst_low = '0' then
			else
				if (store = '1' and wr_full = '0') then
					wr_req <= '1';
				else
					wr_req <= '0';
				end if;	
			end if;
		end if;
	end process;
	
--	delay : process(lr_clk) begin
--		if rising_edge(lr_clk) then
--			if rst_low = '0' then
--				read_delay <= 0;
--			elsif read_delay < 18 then
--				read_delay <= read_delay + 1;
--			end if;
--		end if;
--	end process;
				
	
	read_fifo: process(pll_clk) begin
		if rising_edge(pll_clk) then
			if rst_low = '0' then
				fifo_clr <= '1';
			else
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

	stim : process
		file text_file : text open read_mode is "test.dat";
		variable text_line : line;
		variable test_signal : integer;				
	begin
		rst_low <= '1';
		rst_high <= '0';
		input_count <= 0;
		wait for clk_period * 10;
		rst_low <= '0';
		rst_high <= '1';
		wait for clk_period * 10;
		rst_low <= '1';
		rst_high <= '0';
		wait for clk_period * 10;
		while not endfile(text_file) loop
			readline(text_file, text_line);
			read(text_line, test_signal);
			input_count <= input_count + 1;
			input_flag <= '1';
			input <= std_logic_vector(to_signed(test_signal, 24));
			error_sig <= std_logic_vector(to_signed(test_signal, 24));
			wait for 195 ns;
			input_flag <= '0';
			wait for 49805 ns;
		end loop;
		file_close(text_file);
	end process;
	
	
	
end architecture behavior;