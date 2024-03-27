library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.anc_package.all;

entity uart_tb is
end entity uart_tb;


architecture behavior of uart_tb is

	 signal clk_uart 			: std_logic;
	 signal clk					: std_logic;
    signal rst_n				: std_logic;
    signal clk_count			: integer := 0;
    constant CLK_PERIOD		: time := 40 ns;
	 signal data_fifo_in		: std_logic_vector(23 downto 0);
	 signal sampled_data		: std_logic_Vector(23 downto 0);
	 signal btn_debounced 	: std_logic;
	 signal rx_request_read : std_logic;
	 signal rx_data_valid 	: std_logic;
	 signal temp				: std_logic_Vector(7 downto 0);
	 signal data_inter		: std_logic_vector(7 downto 0);
	 signal fifo_clr			: std_logic;
	 signal key					: std_logic;
	 signal counter			: integer;
	 signal rst_h				: std_logic;
	 signal m_clk				: std_logic;
	 signal uart_fifo_wr_req: std_logic;
	 signal not_rx_data_valid: std_logic;
	 
	 signal data_s				: std_logic;
	 
	 type states is (IDLE, SAMPLE, STALL);
	signal state: 			states;
	 

		component uart_tx is 
	port(
		clk:				in std_logic; --19200
		rst_n:			in std_logic;
		
		data_in:			in std_logic_vector(7 downto 0); --connect to rec FIFO
		data_out:		out std_logic;
		
		rx_request_read: out std_logic; --connect to rd req rec FIFO
		rx_data_valid: in std_logic	--connect to not empty
	);
	end component uart_tx;
	
	
	
		component uart_fifo IS
	PORT
	(
		aclr		: IN STD_LOGIC ;
		rdclk		: IN STD_LOGIC ;
		wrclk		: in std_logic;
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		rdreq		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		rdempty		: OUT STD_LOGIC ;
		q			: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
	END component uart_fifo;
	
	
	
		component debouncer is
		generic(
			WAIT_LENGTH		: integer := 100
		);
		port(
		clk				: in std_logic;
		button			: in std_logic;
		rst				: in std_logic;
		out_debounced	: out std_logic
		
		);
	end component debouncer;
	
	
	component pll is
	port(
		areset			: in std_logic  := '0';
		inclk0			: in std_logic  := '0';
		c0					: out std_logic;
		c1					: out std_logic
	);
	end component pll;
	
	
	
	begin
	rx_data_valid <= not not_rx_data_valid;
	
	pll_inst : pll port map(
		areset		=> rst_h,
		inclk0		=> clk,
		c0				=> m_clk,
		c1				=> clk_uart
	);
	
	
	uart_tx_inst: uart_tx port map(
	
		clk				=> clk,--clk_uart,
		rst_n				=> rst_n,
		
		data_in			=> data_inter,
		data_out			=> data_s,
		
		rx_request_read=> rx_request_read, --connect to rd req rec FIFO
		rx_data_valid	=> rx_data_valid
	);
	
	
	
	debouncer_inst: debouncer port map(
		clk				=> clk,
		button			=> key,
		rst				=> rst_n,
		out_debounced	=> btn_debounced
		
		);
		
		
		
		
	uart_fifo_inst : uart_fifo PORT MAP (
		aclr	 => fifo_clr,
		wrclk	 => clk,
		rdclk	 => clk,--clk_uart,
		data	 => temp,
		rdreq	 => rx_request_read,
		wrreq	 => uart_fifo_wr_req,
		rdempty	 => not_rx_data_valid,
		q	 	 => data_inter
	);
	
clk_process: process
  begin
		clk <= '1';
		wait for CLK_PERIOD / 2;
		clk <= '0';
		wait for CLK_PERIOD / 2;
  end process;
  
  
   clk_count_proc: process(clk)
        begin
            if rising_edge(clk) then
                clk_count <= clk_count + 1;
            end if;
        end process;
	 
	 
	 
	 
	  arst_n_proc: process
        begin
            rst_n <= '0';
				rst_h <= '1';
            wait for CLK_PERIOD * 2;
            rst_n <= '1';
				rst_h <= '0';
            wait;
      end process;
		
		
		
	data_process: process
	begin
	
		wait for CLK_PERIOD*5;
		data_fifo_in <= "101010101010101010101010";
		key <= '0';
		wait for CLK_PERIOD*5;
		
		key <= '1';
		wait for CLK_PERIOD*10000;
		
		
		
		wait;
			
	end process;

	fifo_clr <= not rst_n;
		
	UART : process(clk) begin
	
		if rising_edge(clk) then
			if rst_n = '0' then
				state <= IDLE;
				counter <= 23;
			else
				case state is
					when IDLE => 
						if btn_debounced = '1' then
							sampled_data <= data_fifo_in;
							state <= SAMPLE;
						else
							
							state <= IDLE;
							uart_fifo_wr_req <= '0';
						end if;
					when SAMPLE =>
							uart_fifo_wr_req <= '1';
							if counter >= 0 then
								if sampled_data(counter) = '0' then
									temp <= "00110000";
								elsif sampled_data(counter) = '1' then
									temp <= "00110001";
								end if;
								
								state <= STALL;
								counter <= counter - 1;
							else
								temp <= "00001010"; --newline
								counter <= 23;
								state <= IDLE;
							end if;
					when STALL =>
							uart_fifo_wr_req <= '0';
							state <= SAMPLE;
				end case;
			end if;				
		end if;
	end process;
end architecture behavior;