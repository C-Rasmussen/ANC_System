
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SYNC_COMP is
	generic(
	
		FP_WAIT : integer := 0;
		SYNC_WAIT : integer := 0;
		BP_WAIT : integer := 0;
		DATA_WAIT : integer := 0
		
		);
		
	port(
		clk : in std_logic;
		rst : in std_logic;
		sync : out std_logic;
		flag : out std_logic
		);
end entity SYNC_COMP;

architecture behavioral of SYNC_COMP is

	type state_type is (FP, SYNC_LOW, BP, SEND_DATA);
	signal state : state_type;
	signal count : integer := 0;

begin

	process (clk) begin
		if rising_edge(clk) then
			if rst = '0' then
				state <= FP;
				count <= 0;
				flag <= '0';
				sync <= '1';
			else
				case state is
					
					when FP =>
						count <= count + 1;
						if count = FP_WAIT - 1 then
								state <= SYNC_LOW;
								count <= 0;
								sync <= '0';
						end if;
						
					when SYNC_LOW =>
						count <= count + 1;
						if count = SYNC_WAIT - 1 then
							state <= BP;
							count <= 0;
							sync <= '1';
						end if;
						
					when BP =>
						count <= count + 1;
						if count = BP_WAIT - 1 then
							state <= SEND_DATA;
							count <= 0;
							flag <= '1';
						end if;
					
					when SEND_DATA =>
						count <= count + 1;
						if count = DATA_WAIT - 1 then
							state <= FP;
							count <= 0;
							flag <= '0';
						end if;
				end case;
			end if;
		end if;
	end process;
	
end architecture behavioral;
	