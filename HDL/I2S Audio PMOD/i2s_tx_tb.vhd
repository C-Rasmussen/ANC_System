library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2s_tx_tb is
end entity i2s_tx_tb;

architecture tb_arch of i2s_tx_tb is
    constant CLK_PERIOD : time := 10 ns;
    
    signal b_clk        : std_logic := '0';
    signal rst          : std_logic := '0';
    signal data_frame   : std_logic_vector(15 downto 0);
    signal lr_clk       : std_logic;
    signal dac_bit      : std_logic;

    -- Instantiate the i2s_tx module
entity i2s_tx is

	generic (

		bit_width : integer := 16
	);
	port (
		in_data		: in std_logic_vector(bit_width-1 downto 0);
		m_clk			: in std_logic;
		rst_n			: in std_logic;
		lr_clk		: out std_logic;
		bit_clk		: out std_logic;
		dac_bit		: out std_logic
		
	);
end entity i2s_tx;
	 
	 
	 
	 component data_gen is

			generic (
				freq			: integer := 220;
				bit_width	: integer := 16
			);
	
			port (
				bit_clk		: in std_logic;
				rst_n			: in std_logic;
				out_data		: out std_logic_vector(bit_width-1 downto 0)
		
			);
		end component data_gen;

begin
    -- Instantiate the i2s_tx module
    i2s_tx_inst : i2s_tx
	 
		bit_width : integer := 16
	);
	port (
		in_data		: in std_logic_vector(bit_width-1 downto 0);
		m_clk			: in std_logic;
		rst_n			: in std_logic;
		lr_clk		: out std_logic;
		bit_clk		: out std_logic;
		dac_bit		: out std_logic
		  
		  
		  	data_gen_inst : data_gen

			generic map(
				freq			=> 220,
				bit_width	=> 16
			);
	
			port map(
				bit_clk		=> b_clk,
				rst_n			=> rst
				out_data		=> data_frame
		
			);
		end component data_gen;

	 clk_process: process
    begin
        b_clk <= '0';
        wait for CLK_PERIOD /2;
        b_clk <= '1';
        wait for CLK_PERIOD /2;
    end process;

    -- Stimulus process
    process
    begin
        rst <= '0';  -- Assert reset
        wait for 20 ns;
        rst <= '1';  -- De-assert reset

--		  data_frame <= "1000111100001111000011110000111100001111000011110000111100001111";
--		  wait for 100 ns;
--		  data_frame <= "1100110011001100110011001100110011001100110011001100110011001100";
--        wait for 5000 ns;  -- Run simulation for 5000 ns

        wait;
    end process;

end tb_arch;