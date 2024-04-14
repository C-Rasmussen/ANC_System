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
		error_mic : in std_logic_vector(23 downto 0);
		output : out std_logic_vector(23 downto 0);		--Output from filtering.  To be sent to I2S2 module to be played on anti noise speaker
		s1 : out std_logic;
		s2 : out std_logic;
		s3 : out std_logic;
		s4 : out std_logic;
		s5 : out std_logic;
		s6 : out std_logic;
		s7 : out std_logic;
		s8 : out std_logic;
		s9 : out std_logic;
		s10 : out std_logic;
		mu : in signed(23 downto 0)
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
signal temp_output : signed(55 downto 0);  --
signal error : signed(23 downto 0);
signal updater : signed(23 downto 0);
signal real_mu : signed(23 downto 0);
signal updater_temp : signed (71 downto 0); --
signal output_double : signed(47 downto 0);
signal overflow_check : signed(23 downto 0);
signal error_temp : signed(23 downto 0);
signal output_check1 : signed(47 downto 0);
signal output_check2 : signed (23 downto 0);
signal output_check3 : signed (23 downto 0);
signal output_hold : signed(23 downto 0);

begin

error_temp <= signed(error_mic);

process (clk) begin
	if rst_low = '0' then
		filt_inputs <= (others => (others => '0'));
		filt_inputs_temp <= (others => (others => '0'));
		filt_accum <= (others => (others => '0'));
		wts <= (others => (others => '0'));
		state <= INITIAL;
		output_flag <= '0';
		count <= 0;
		temp_output <= (others => '0');
	elsif rising_edge (clk) then
		case state is
			when INITIAL =>    --wait until input flag is raised to move onto shift state
				real_mu <= mu;
				output_flag <= '0';
				if input_flag = '1' then
					state <= SHIFT1;
				end if;
			
			when SHIFT1 =>  --right shift temp array and set first value of temp array equivalent to latest input
				filt_inputs_temp <= filt_inputs;
				filt_inputs(0) <= signed(input); 
				state <= SHIFT2;
				
			when SHIFT2 =>
				filt_inputs((FILT_LENGTH-1) downto 1) <= filt_inputs_temp((FILT_LENGTH - 2) downto 0);
				state <= MULT1;
				
			when MULT1 =>
				output_double <= (filt_inputs(count)*wts(count)); --+ (filt_inputs(count)*wts(count));
				state <= MULT2;
				
			when MULT2 =>
				if count = (FILT_LENGTH - 1) then
					count <= 0;
					filt_accum(count) <= output_double;
					temp_output <= (others => '0');
					state <= SUM;
				else  
					filt_accum(count) <= output_double;
					count <= count + 1;
					state <= MULT1;
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
					output <= std_logic_vector(not(temp_output(55) & temp_output(49 downto 27))); --WORKS FOR SINUSOIDS
					error <= error_temp;
					--error <= filt_inputs(0) - temp_output(47 downto 24);
					count <= count + 1;
				elsif count = 1 then
					count <= 0;
					updater_temp <= real_mu * error * filt_inputs(0);
					state <= CALC_COEFFICIENTS_1;
				end if;
				
			when CALC_COEFFICIENTS_1=>
					updater <= updater_temp(71 downto 48);
					state <= CALC_COEFFICIENTS_2;
					
			when CALC_COEFFICIENTS_2=>
				if updater(23) /= wts(count)(23) then 
					wts(count) <= (wts(count) + updater);
					if count = (FILT_LENGTH - 1) then
						count <= 0;
						output_flag <= '1';
						state <= INITIAL;
					else
						updater_temp <= real_mu * error * filt_inputs(count + 1);
						count <= count + 1;
						state <= CALC_COEFFICIENTS_1;
					end if;
				else
					overflow_check <= (wts(count) + updater);
					state <= CALC_COEFFICIENTS_3;
				end if;
			
			
			when CALC_COEFFICIENTS_3=>
				if overflow_check(23) = wts(count)(23) then
					wts(count) <= (wts(count) + updater);
				end if;
				
				if count = (FILT_LENGTH - 1) then
					count <= 0;
					output_flag <= '1';
					state <= INITIAL;
				else
					updater_temp <= real_mu * error * filt_inputs(count + 1);
					count <= count + 1;
					state <= CALC_COEFFICIENTS_1;
				end if;
		end case;
	end if;
end process;


--process (output_check2, rst_low) begin
--	real_mu <= mu;
--	if rst_low = '0' then
--		output_check3 <= (others => '0');
--		output <= (others => '0');
--	elsif (output_check3(23 downto 22) = "01") and (output_check2(23) = output_check3(23)) then
--		output <= std_logic_vector((output_check2));
--		output_check3 <= output_check2;
--	elsif (output_check3(23 downto 22) = "10") and (output_check2(23) = output_check3(23)) then
--		output <= std_logic_vector((output_check2));
--		output_check3 <= output_check2;
--	elsif (output_check3(23 downto 22) = "00") or (output_check3(23 downto 22) = "11") then
--		output <= std_logic_vector((output_check2));
--		output_check3 <= output_check2;
--	else
--		real_mu <= (others => '0');
--	end if;
--end process;

end architecture behavior;