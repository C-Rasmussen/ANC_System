library ieee;
use ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

-- This module oversamples by a factor of 8.
-- This module should therefore be clocked at 8x
-- the UART baud rate.

entity uart_rx is
port (
    -- globals
    clk:        in std_logic;
    arst_n:     in std_logic;

    -- UART serial in
    rx:         in std_logic;

    -- parallel out
    q:          out std_logic_vector(7 downto 0);
    data_valid: out std_logic
);
end uart_rx;

architecture rtl of uart_rx is

    signal q_i: std_logic_vector(7 downto 0);
    signal sample: unsigned(2 downto 0);
    signal bitc: unsigned(2 downto 0);
    signal vote: unsigned(1 downto 0);

    signal rx_r1: std_logic;
    signal rx_r2: std_logic;

    type state_t is (IDLE, START, DATA, VOTES, SHIFT, WAITS, STOPS);
    signal state: state_t;

begin

    -- Lack of VHDL 2008 support means you cannot read outputs
    q <= q_i;

    -- Double-register to avoid metastability
    process(clk, arst_n)
    begin
        if arst_n = '0' then
            rx_r1 <= '1';
            rx_r2 <= '1';
        else
            rx_r1 <= rx;
            rx_r2 <= rx_r1;
        end if;
    end process;

    -- FSM
    process(clk, arst_n)
    begin
        if arst_n = '0' then
            state <= IDLE;
            data_valid <= '0';
            q_i <= (others => '0');

        elsif rising_edge(clk) then
            case state is

            --------------------
            -- IDLE state
            --------------------
            when IDLE =>
                if rx_r2 = '0' then
                    state <= START;
                    sample <= to_unsigned(1, sample'length);
                end if;

            --------------------
            -- START state
            --------------------
            when START =>
                if sample = 7 then
                    state <= DATA;
                    sample <= (others => '0');
                    bitc <= (others => '0');
                else
                    sample <= sample + 1;
                end if;
                    
            --------------------
            -- DATA state
            --------------------
            when DATA =>
                sample <= sample + 1;
                if sample = 1 then
                    state <= VOTES;
                    vote <= (others => '0');
                end if;

            --------------------
            -- VOTES state
            --------------------
            when VOTES =>
                sample <= sample + 1;
                if rx_r2 = '1' then
                    vote <= vote + 1;
                end if;
                if sample = 4 then
                    state <= SHIFT;
                end if;

            --------------------
            -- SHIFT state
            --------------------
            when SHIFT =>
                sample <= sample + 1;
                if vote >= 2 then
                    q_i <= '1' & q_i(7 downto 1);
                else
                    q_i <= '0' & q_i(7 downto 1);
                end if;
                state <= WAITS;

            --------------------
            -- WAITS state
            --------------------
            when WAITS =>
                if sample = 7 then
                    sample <= (others => '0');
                    if bitc = 7 then
                        state <= STOPS;
                        data_valid <= '1';
                    else
                        state <= DATA;
                        bitc <= bitc + 1;
                    end if;
                else
                    sample <= sample + 1;
                end if;

            --------------------
            -- STOPS state
            --------------------
            when STOPS =>
                data_valid <= '0';
                if sample = 7 then
                    state <= IDLE;
                else
                    sample <= sample + 1;
                end if;
                
            --------------------
            -- Invalid state
            --------------------
            when others =>
                state <= IDLE;
                data_valid <= '0';
                q_i <= (others => '0');

            end case;
        end if;
    end process;
end architecture rtl;
