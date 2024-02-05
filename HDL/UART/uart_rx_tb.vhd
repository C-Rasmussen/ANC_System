library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_rx_tb is
end uart_rx_tb;

architecture rtl of uart_rx_tb is

    signal clk: std_logic;
    signal arst_n: std_logic := '0';

    signal clk_count: integer := 0;
    constant CLK_PERIOD: time := 40 ns;

    signal rx: std_logic;
    signal q: std_logic_vector(7 downto 0);
    signal data_valid: std_logic;

    component uart_rx
    port (
        clk: in std_logic;
        arst_n: std_logic;
        rx:         in std_logic;
        q:          out std_logic_vector(7 downto 0);
        data_valid: out std_logic
    );
    end component;

    signal sim_sample: integer := 0;
    signal sim_bit: integer := 0;
    signal sim_data: std_logic_vector(7 downto 0) := x"AC";

begin

    uut: uart_rx
    port map(
        clk => clk,
        arst_n => arst_n,
        rx => rx,
        q => q,
        data_valid => data_valid
    );

    clk_process: process
    begin
        clk <= '0';
        wait for CLK_PERIOD /2;
        clk <= '1';
        wait for CLK_PERIOD /2;
    end process;

    arst_n_proc: process
    begin
        arst_n <= '0';
        wait for CLK_PERIOD;
        arst_n <= '1';
        wait;
    end process;

    clk_count_proc: process(clk)
    begin
        if rising_edge(clk) then
            clk_count <= clk_count + 1;
        end if;
    end process;

    stm_proc1: process(clk)
    begin
        if rising_edge(clk) then
            
            if sim_sample = 7 then
                sim_sample <= 0;
                sim_bit <= sim_bit + 1;
            else
                sim_sample <= sim_sample + 1;
            end if;

        end if;
    end process;
    
    stm_proc2: process(sim_bit)
    begin
        case sim_bit is

        when 0 => --beginning of simulation
            rx <= '1';
        when 1 => --start bit
            rx <= '0';
        when 2 to 9 => -- data
            rx <= sim_data(sim_bit - 2);
        when others =>
            rx <= '1';

        end case;
    end process;

end architecture rtl;