library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity pmod_out is
    port (
        sig : in std_logic_vector(15 downto 0);
        clk : in std_logic;      -- 500MHz clock
        rst_n : in std_logic;
        LRCLK : buffer std_logic;   -- Left-right clock stereo audio output
        SCLK : buffer std_logic;    -- Clock for transmitting individual signal bits to PmodI2S
        SDIN : buffer std_logic     -- Current signal bit to transmit
    );
end entity pmod_out;

architecture behavior of pmod_out is
    signal LRCLK_count : integer := 0;
    signal SCLK_count : integer := 0;
    signal sig_temp : std_logic_vector(15 downto 0) := (others => '0');
begin
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            LRCLK <= '0';
            SCLK <= '0';
            
            sig_temp <= sig;
            LRCLK_count <= 0;
            SCLK_count <= 0;
        elsif rising_edge(clk) then
            if SCLK_count = 4 then
                SCLK <= not SCLK;
                SCLK_count <= 1;
                
                -- Transmit the signal bit-by-bit at every negative edge of the SCLK
                if SCLK = '0' then
                    SDIN <= sig_temp(15);
                    sig_temp <= sig_temp(14 downto 0) & '0';
                end if;
            else
					SCLK_count <= SCLK_count + 1;
            end if;

            if LRCLK_count = 256 then
                LRCLK <= not LRCLK;
                LRCLK_count <= 1;
               
                sig_temp <= sig;
				else
					LRCLK_count <= LRCLK_count + 1;	
            end if;
        end if;
    end process;
end architecture behavior;
			

