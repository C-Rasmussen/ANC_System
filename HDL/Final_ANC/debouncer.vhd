library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debouncer is
	generic(
		WAIT_LENGTH		: integer := 50000
	);
	port(
	clk		: in std_logic;
	button	: in std_logic;
	rst		: in std_logic;
	out_debounced	: out std_logic
	
	);
end entity debouncer;


architecture behavior of debouncer is
type state_type is (STANDBY, PRESSED);
signal state : state_type;
signal count 	: integer := 0;

begin
	process (clk) begin
		if (rising_edge(clk)) then
			if rst = '0' then 
				state <= STANDBY;
				count <= 0;
				out_debounced <= '0';
			else
				case state is
					when STANDBY =>
						if button = '0' then
							state <= PRESSED;
							out_debounced <= '1';
						else
							state <= STANDBY;
						end if;
					
					when PRESSED =>
						out_debounced <= '0';
						if button = '0'then
							count <= 0;
							state <= PRESSED;
						elsif button = '1' then
							count <= count + 1;
							if count >= WAIT_LENGTH then
								state <= STANDBY;
							else 
								state <= PRESSED;
							end if;
						end if;
				end case;
			end if;
		end if;
	end process;
								
end architecture behavior;
	
	
		