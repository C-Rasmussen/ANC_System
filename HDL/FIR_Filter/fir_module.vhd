library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.anc_package.all;

entity fir_module is
	port(
		rst_low : in std_logic;
		input_flag : in std_logic;
		output_flag : out std_logic;
		clk : in std_logic;										--Input from top module, probably ADC_CLK50 for fastest possible filtering
		input : in std_logic_vector(23 downto 0);			--Input from I2S2 module, read in from reference microphone											--Input from error module, updated coefficients (might be better to split into 32 individual inputs)
		output : out std_logic_vector(23 downto 0)		--Output from filtering.  To be sent to I2S2 module to be played on anti noise speaker
		);
end entity fir_module;

architecture behavior of fir_module is
--define signals here

signal wts : WEIGHTS;					--48 bits
signal filt_inputs : COEFF;			--48
signal filt_inputs_temp : COEFF;		--48
signal filt_accum : ACCUM;				--96

signal state : state_type := INITIAL;
signal count : integer := 0;
signal input_integer : integer;
signal temp_output : signed(100 downto 0);  --
signal error : signed(47 downto 0);
signal mu : signed(47 downto 0);
signal updater : signed(47 downto 0);
signal updater_temp : signed (143 downto 0); --
signal output_double : signed(95 downto 0);
signal overflow_check : signed(47 downto 0);

signal output_hold : signed(23 downto 0);
signal error_hold : signed(23 downto 0);
signal wts_hold : TB_VIEW;
signal update_hold : signed(23 downto 0);
signal filt_accum_hold : TB_VIEW;

--define temp array of filter length initialized to 0
--define accum array of filter length initialized to 0

begin


error_hold <= error(47 downto 24);
update_hold <= updater(47 downto 24);

--wts(filt_length-1 downto 1) <= (others => (others => '0'));
--wts(0) <= "011111111111111111111111111111111111111111111111";


wts <= (
	 "111111111111001111000111000000000000000000000000", -- -0.0007459440385
	 "000000000000110111111001000000000000000000000000", -- 0.0008527641185
	 "000000000010111110011100000000000000000000000000", -- 0.002905795584
	 "000000000101011010100100000000000000000000000000", -- 0.005288101267
	 "000000000110010000000100000000000000000000000000", -- 0.006104631815
	 "000000000011001111101001000000000000000000000000", -- 0.003168317256
	 "111111111011010001010010000000000000000000000000", -- -0.004619154613
	 "111111101111110101100110000000000000000000000000", -- -0.01578369364
	 "111111100101110000100100000000000000000000000000", -- -0.0256262105
	 "111111100100001101101000000000000000000000000000", -- -0.02713558078
	 "111111110010001010100111000000000000000000000000", -- -0.01350987423
	 "000000010011000000100011000000000000000000000000", -- 0.0185631644
	 "000001000011111100011011000000000000000000000000", -- 0.06635174155
	 "000001111011100100110100000000000000000000000000", -- 0.1206789017
	 "000010101100010010011110000000000000000000000000", -- 0.1682506651
	 "000011001000110000001101000000000000000000000000", -- 0.1960480213
	 "000011001000110000001101000000000000000000000000", -- 0.1960480213
	 "000010101100010010011110000000000000000000000000", -- 0.1682506651
	 "000001111011100100110100000000000000000000000000", -- 0.1206789017
	 "000001000011111100011011000000000000000000000000", -- 0.06635174155
	 "000000010011000000100011000000000000000000000000", -- 0.0185631644
	 "111111110010001010100111000000000000000000000000", -- -0.01350987423
	 "111111100100001101101001000000000000000000000000", -- -0.02713558078
	 "111111100101110000100100000000000000000000000000", -- -0.0256262105
	 "111111101111110101100110000000000000000000000000", -- -0.01578369364
	 "111111111011010001010010000000000000000000000000", -- -0.004619154613
	 "000000000011001111101001000000000000000000000000", -- 0.003168317256
	 "000000000110010000000100100000000000000000000000", -- 0.006104631815
	 "000000000101011010100100000000000000000000000000", -- 0.005288101267
	 "000000000010111110011100000000000000000000000000", -- 0.002905795584
	 "000000000000110111111001000000000000000000000000", -- 0.0008527641185
	 "111111111111001111000111100000000000000000000000"  -- -0.0007459440385
	);


process (clk) begin
	if rst_low = '0' then
		filt_inputs <= (others => (others => '0'));
		filt_inputs_temp <= (others => (others => '0'));
		filt_accum <= (others => (others => '0'));
		--wts <= (others => (others => '0'));
		state <= INITIAL;
		count <= 0;
		temp_output <= (others => '0');
		mu <= "000110011001100110011010000000000000000000000000";  --mu = 0.01
	elsif rising_edge (clk) then
		case state is
			when INITIAL =>    --wait until input flag is raised to move onto shift state
				if input_flag = '1' then
					state <= SHIFT1;
				end if;
			
			when SHIFT1 =>  --right shift temp array and set first value of temp array equivalent to latest input
				filt_inputs_temp <= filt_inputs;
				filt_inputs(0) <= signed(input) & "000000000000000000000000"; 
				state <= SHIFT2;
				
			when SHIFT2 =>
			
				filt_inputs((FILT_LENGTH-1) downto 1) <= filt_inputs_temp((FILT_LENGTH - 2) downto 0);
				state <= MULT1;
				
			when MULT1 =>
				output_double <= (filt_inputs(count)*wts(count)) + (filt_inputs(count)*wts(count));
				state <= MULT2;
				
			when MULT2 =>
				if count = (FILT_LENGTH - 1) then
					count <= 0;
					temp_output <= (others => '0');
					state <= SUM;
				else  
					filt_accum(count) <= output_double;
					count <= count + 1;
					state <= MULT1;
				end if;
--				if count > 1 then
--					filt_accum_hold(count - 1) <= filt_accum(count - 1)(95 downto 72);
--				end if;
			when SUM =>
				if count = (FILT_LENGTH - 1) then
					count <= 0;
					output_hold <= temp_output(95 downto 72);
					state <= CALC_ERROR;
				else
					temp_output <= temp_output + filt_accum(count);
					count <= count + 1;
				end if;
			when CALC_ERROR=>
				if count = 0 then
					error <= (filt_inputs(0)) - temp_output(95 downto 48)  ;
					count <= count + 1;
				elsif count = 1 then
					count <= 0;
					updater_temp <= mu * error * filt_inputs(0);
					state <= CALC_COEFFICIENTS_1;
				end if;
				
			when CALC_COEFFICIENTS_1=>
				if count > 0 then
					wts_hold(count - 1) <= wts(count - 1)(47 downto 24);
				end if;
				updater <= updater_temp(143 downto 96);
				state <= CALC_COEFFICIENTS_2;
					
			when CALC_COEFFICIENTS_2=>
				if updater(47) /= wts(count)(47) then 
					--wts(count) <= (wts(count) + updater);
					if count = (FILT_LENGTH - 1) then
						count <= 0;
						state <= INITIAL;
					else
						updater_temp <= mu * error * filt_inputs(count + 1);
						count <= count + 1;
						state <= CALC_COEFFICIENTS_1;
					end if;
				else
					overflow_check <= (wts(count) + updater);
					state <= CALC_COEFFICIENTS_3;
				end if;
			
			
			when CALC_COEFFICIENTS_3=>
				if overflow_check(47) = wts(count)(47) then
					--wts(count) <= (wts(count) + updater);
				end if;
				
				if count = (FILT_LENGTH - 1) then
					count <= 0;
					state <= INITIAL;
				else
					updater_temp <= mu * error * filt_inputs(count + 1);
					count <= count + 1;
					state <= CALC_COEFFICIENTS_1;
				end if;
		end case;
	end if;
end process;

end architecture behavior;