
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


package anc_package is
	
	constant FILT_LENGTH : integer := 32; --filter length 32
	
	type COEFF is array (FILT_LENGTH-1 downto 0) of signed(23 downto 0);
	type ACCUM is array (FILT_LENGTH-1 downto 0) of signed(47 downto 0);
	
	
	type state_type is (INITIAL, SHIFT1, SHIFT2,  MULT, SUM, CALC_ERROR, CALC_COEFFICIENTS_1, CALC_COEFFICIENTS_2);
	
end package anc_package;

package body anc_package is

end package body anc_package;