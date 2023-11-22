
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lfsr is	
	port(
		clk : in std_logic;
		rst : in std_logic;
		rand_num : out unsigned (9 downto 0)
		);
end entity lfsr;

architecture behavior of lfsr is 

signal seed : unsigned (9 downto 0);
signal lfsr_value : unsigned (9 downto 0);

begin
seed <= "1001001101";
process(clk)
	begin
		if rst = '0' then
			lfsr_value <= seed;
		else 
			if rising_edge(clk) then
				lfsr_value(9) <= lfsr_value(8);
				lfsr_value(8) <= lfsr_value(7);
				lfsr_value(7) <= lfsr_value(6);
				lfsr_value(6) <= lfsr_value(5);
				lfsr_value(5) <= lfsr_value(4);
				lfsr_value(4) <= lfsr_value(3);
				lfsr_value(3) <= lfsr_value(2);
				lfsr_value(2) <= lfsr_value(1);
				lfsr_value(1) <= lfsr_value(0);
				lfsr_value(0) <= lfsr_value(2) xor (lfsr_value(3) xor (lfsr_value(5) xor lfsr_value(9)));
	
			end if;
		end if;
		rand_num <= lfsr_value;
end process;

end architecture behavior;