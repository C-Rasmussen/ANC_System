library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity I2S2 is
	
	port (
		MAX10_CLK1_50	: in std_logic;
		MAX10_CLK2_50	: in std_logic;
		ADC_CLK_10		: in std_logic;

		KEY				: in std_logic_vector(1 downto 0);
		
		LEDR				: out std_logic_vector(9 downto 0);
		ARDUINO_IO		: inout std_logic_vector(15 downto 0);
		GPIO				: inout std_logic_vector(35 downto 0)

	);

end entity I2S2;

architecture behavior of I2S2 is

	
	component pll is
	port(
		inclk0			: in std_logic  := '0';
		c0					: out std_logic 
	);
	end component pll;
	

signal m_clk : std_logic;
signal lr_clk : std_logic := '0';
signal s_clk : std_logic := '0';

signal rst_n : std_logic;

signal m_clk_count : integer := 0;
signal s_clk_count : integer := 0;
signal count : integer := 0;

type state_type is (INITIAL, LEFT_WAIT, LEFT_DAT, RIGHT_WAIT, RIGHT_DAT);
signal state : state_type := INITIAL;	

signal line_in_r : signed (23 downto 0);
signal line_in_l : signed(23 downto 0); 

signal line_out_r : signed(23 downto 0);
signal line_out_l : signed(23 downto 0);

signal lr_patt : std_logic_vector(1 downto 0);
signal bit_patt : std_logic_vector(1 downto 0);

begin

	rst_n <= KEY(0);
	
	GPIO(0) <= m_clk;
	GPIO(1) <= lr_clk;
	GPIO(2) <= s_clk;
	
	GPIO(6) <= m_clk;
	GPIO(7) <= lr_clk;
	GPIO(8) <= s_clk;

	pll_inst : pll port map(
		inclk0		=> MAX10_CLK1_50,
		c0				=> m_clk
	);
	
	clockgen : process(m_clk) begin
			if rst_n = '0' then
				m_clk_count <= 0;
				s_clk_count <= 0;
				s_clk <= '0';
				lr_clk <= '0';
			elsif rising_edge(m_clk) then
				if m_clk_count < 3 then
					m_clk_count <= m_clk_count + 1;
				else
					m_clk_count <= 0;
					s_clk_count <= s_clk_count + 1;
					s_clk <= not(s_clk);
					if (s_clk_count >= 63) and (s_clk = '0') then
						lr_clk <= not(lr_clk);
						s_clk_count <= 0;
					end if;
				end if;
			end if;				
	end process;
	
	data : process(s_clk) begin
			lr_patt <= lr_patt(0) & lr_clk;
			bit_patt <= bit_patt(0) & s_clk;
			
			case state is
			when INITIAL =>
				line_in_r <= (others => '0');
				line_in_l <= (others => '0');
				line_out_r <= "101010101010101010101010";
				line_out_l <= "101010101010101010101010";
				if lr_patt = "10" then
					state <= LEFT_DAT;
					count <= 23;
				elsif lr_patt = "01" then
					state <= RIGHT_DAT;
					count <= 23;
				end if;
				
				
			when LEFT_WAIT =>
				if bit_patt = "10" then
					state <= LEFT_DAT;
					count <= 23;
				end if;
				
			when LEFT_DAT =>
				if (bit_patt = "10") and (count >= 0) then
					line_in_l(count) <= GPIO(9);
					GPIO(3) <= line_out_l(count);
					count <= count - 1;
				elsif lr_patt = "01" then
					--line_out_l <= line_in_l;
					state <= RIGHT_DAT;
					count <= 23;
				end if;
			
			when RIGHT_WAIT =>
				if bit_patt = "10" then
					state <= RIGHT_DAT;
					count <= 23;
				end if;
				
			when RIGHT_DAT =>
				if (bit_patt = "10") and (count >= 0) then
					line_in_r(count) <= GPIO(9);
					GPIO(3) <= line_out_r(count);
					count <= count - 1;
				elsif lr_patt = "10" then
					--line_out_r <= line_in_r;
					state <= LEFT_DAT;
					count <= 23;
				end if;
			end case;
	end process;
			
end architecture behavior; 
