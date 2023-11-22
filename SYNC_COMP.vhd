
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SYNC_COMP is
	generic(
	
		FP_WAIT : integer := 0;
		SYNC_WAIT : integer := 0;
		BP_WAIT : integer := 0;
		DATA_WAIT : integer := 0;
		DIVISOR : integer := 0
		);
		
	port(
		clk : in std_logic;
		rst : in std_logic;
		sync : out std_logic;
		flag : out std_logic;
		coordinate : out unsigned (9 downto 0)
		);
end entity SYNC_COMP;

architecture behavioral of SYNC_COMP is

	type state_type is (FP, SYNC_LOW, BP, SEND_DATA);
	signal state : state_type := FP;
	signal count : integer := 0;
	signal int_coord : unsigned (9 downto 0);
	signal coord_counter : integer := 0;

begin

	process (clk, rst) begin
		if rst = '0' then
				state <= FP;
				count <= 0;
				flag <= '0';
				sync <= '1';
				int_coord <= (others => '0');
				coord_counter <= 0;
		elsif rising_edge(clk) then
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
						flag <= '1';
						coord_counter <= coord_counter + 1;
						if coord_counter = DIVISOR - 1 then
							int_coord <= int_coord + 1;
							coord_counter <= 0;
						end if;
						count <= count + 1;
						if count = DATA_WAIT - 1 then
							state <= FP;
							count <= 0;
							int_coord <= (others => '0');
							flag <= '0';
						end if;
				end case;
		end if;
	end process;
	
	coordinate <= int_coord;
	
end architecture behavioral;
	