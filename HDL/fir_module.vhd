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

signal wts : COEFF;
signal filt_inputs : COEFF;
signal filt_inputs_temp : COEFF;
signal filt_accum : ACCUM;

signal state : state_type := INITIAL;
signal count : integer := 0;
signal input_integer : integer;
signal temp_output : signed(47 downto 0);
signal error : signed(23 downto 0);
signal mu : signed(23 downto 0);
signal updater : signed(23 downto 0);
signal updater_temp : signed (71 downto 0);


--define temp array of filter length initialized to 0
--define accum array of filter length initialized to 0

begin

process (clk) begin
	if rst_low = '0' then
		filt_inputs <= (others => (others => '0'));
		filt_inputs_temp <= (others => (others => '0'));
		filt_accum <= (others => (others => '0'));
		wts <= (others => (others => '0'));
		state <= INITIAL;
		count <= 0;
		temp_output <= (others => '0');
		mu <= "000000101000111101011100";  --mu = 0.01
	elsif rising_edge (clk) then
		case state is
			when INITIAL =>    --wait until input flag is raised to move onto shift state
				if input_flag = '1' then
					state <= SHIFT1;
				end if;
			
			when SHIFT1 =>  --right shift temp array and set first value of temp array equivalent to latest input
				filt_inputs_temp <= filt_inputs;
				filt_inputs(0) <= signed(input); 
				state <= SHIFT2;
				
			when SHIFT2 =>
			
				filt_inputs((FILT_LENGTH-1) downto 1) <= filt_inputs_temp((FILT_LENGTH - 2) downto 0);
				state <= MULT;
				
			when MULT =>
				if count = (FILT_LENGTH - 1) then
					count <= 0;
					state <= SUM;
				else  
					filt_accum(count) <= filt_inputs(count) * wts(count);
					count <= count + 1;
				end if;
			when SUM =>
				if count = (FILT_LENGTH - 1) then
					count <= 0;
					state <= CALC_ERROR;
				else
					temp_output <= temp_output + filt_accum(count);
					count <= count + 1;
				end if;
			when CALC_ERROR=>
				if count = 0 then
					error <= (filt_inputs(0)) - temp_output(47 downto 24)  ;
					count <= count + 1;
				elsif count = 1 then
					count <= 0;
					updater_temp <= mu * error * filt_inputs(0);
					state <= CALC_COEFFICIENTS_1;
				end if;
				
			when CALC_COEFFICIENTS_1=>
			
				--updater_temp <= mu * error * filt_inputs(count);
				updater <= updater_temp(71 downto 48);
				state <= CALC_COEFFICIENTS_2;
					
			when CALC_COEFFICIENTS_2=>
	
				wts(count) <= wts(count) + updater;
				
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
	
--right shift temp array and set first value of temp array equivalent to latest input

--multiply each value of temp array with corresponding value in the coefficients, store in accum



--take sum of all values currently stored in accum, resulting in filter output value

--end process

end architecture behavior;