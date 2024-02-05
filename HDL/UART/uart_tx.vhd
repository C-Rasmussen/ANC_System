library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx is 
port(
	clk:				in std_logic;
	rst_n:			in std_logic;
	
	data_in:			in std_logic_vector(7 downto 0); --connect to rec FIFO
	data_out:		out std_logic;
	
	rx_request_read: out std_logic; --connect to rd req rec FIFO
	rx_data_valid: in std_logic	--connect to not empty
);
end entity;

architecture behavior of uart_tx is

	type states is (IDLE, GET_DATA, SEND_DATA, SEND_STOP);
	signal state: 			states;
	signal data_counter:	integer;
	
	begin
	
		process(clk, rst_n) begin
			if rst_n = '0' then
				state <= IDLE;
				data_counter <= 0;
				data_out <= '1';
			elsif rising_edge(clk) then
				case state is 
					when IDLE =>
						data_counter <= 0;
						data_out <= '1';
						if rx_data_valid = '1' then
							rx_request_read <= '1';
							state <= GET_DATA;
						else
							state <= IDLE;
						end if;
						
					when GET_DATA =>
						rx_request_read <= '0';
						state <= SEND_DATA;
						data_out <= '0'; --start bit is low
						
					when SEND_DATA =>
						data_counter <= data_counter + 1;
						data_out <= data_in(data_counter);
						if data_counter = 7 then
							state <= SEND_STOP;
						else
							state <= SEND_DATA;
						end if;
					when SEND_STOP =>
						state <= IDLE;
						data_out <= '1';
				end case;
			end if;
		end process;
	end behavior;
					
						
				