library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity clock_gen is
    port (
        clk : in std_logic;     
        rst_n : in std_logic;
        LRCLK : buffer std_logic;   -- Left-right clock stereo audio output
        SCLK : buffer std_logic    -- Clock for transmitting individual signal bits to PmodI2S
    );
end entity clock_gen;

architecture behavior of clock_gen is
    signal LRCLK_count : integer := 0;
    signal SCLK_count : integer := 0;
begin
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            LRCLK <= '0';
            SCLK <= '0';

            LRCLK_count <= 0;
            SCLK_count <= 0;
        elsif rising_edge(clk) then
            if SCLK_count = 4 then
                SCLK <= not SCLK;
                SCLK_count <= 1;
                
            else
					SCLK_count <= SCLK_count + 1;
            end if;

            if LRCLK_count = 128 then
                LRCLK <= not LRCLK;
                LRCLK_count <= 1;

				else
					LRCLK_count <= LRCLK_count + 1;	
            end if;
        end if;
    end process;
end architecture behavior;
			

