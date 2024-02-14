library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.anc_package.all;

entity my_fir is
	port(
		MAX10_CLK1_50 : in std_logic										--Input from top module, probably ADC_CLK50 for fastest possible filterin
		);
end entity my_fir;

architecture behavior of my_fir is

begin

end architecture behavior;