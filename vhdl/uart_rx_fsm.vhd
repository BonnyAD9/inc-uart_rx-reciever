-- uart_rx_fsm.vhd: UART controller - finite state machine controlling RX side
-- Author(s): Name Surname (xlogin00)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;



entity UART_RX_FSM is
    port(
       CLK  : in std_logic;
       RST  : in std_logic;
       DAT  : in std_logic;
       CNT3 : in std_logic;
       CNT4 : in std_logic;
       RD   : out std_logic;
       CC3  : out std_logic;
       CC4  : out std_logic;
       VLD  : out std_logic;
       CLR  : out std_logic
    );
end entity;



architecture behavioral of UART_RX_FSM is
    type state_t is (Idle, Offset, Rds, Wait1, Wait2, Valid);
    signal state : state_t := Idle;
begin
    process (CLK, RST) is
        variable next_state : state_t;
    begin
        -- set the default next_state
        next_state := state;

        -- asynchronous reset
        if RST = '1' then
            state <= Idle;
            RD  <= '0';
            CC3 <= '0';
            CC4 <= '0';
            VLD <= '0';
            CLR <= '1';
        elsif rising_edge(CLK) then

            -- determine the next state
            case state is
                when Idle =>
                    if DAT = '0' then
                        next_state := Offset;
                    end if;
                when Offset =>
                    if CNT3 = '1' then
                        next_state := Rds;
                    end if;
                when Rds =>
                    if CNT3 = '1' and CNT4 = '1' then
                        next_state := Wait1;
                    end if;
                when Wait1 =>
                    if CNT4 = '1' then
                        next_state := Wait2;
                    end if;
                when Wait2 =>
                    if CNT3 = '1' then
                        next_state := Valid;
                    end if;
                when Valid =>
                    next_state := Idle;
            end case;

            state <= next_state;

            -- default values
            RD  <= '0';
            CC3 <= '0';
            CC4 <= '0';
            VLD <= '0';
            CLR <= '1';

            -- set the outputs based on the next state
            case next_state is
                when Idle => null;
                when Offset =>
                    CC3 <= '1';
                when Rds =>
                    CC3 <= '1';
                    CC4 <= '1';
                    RD  <= '1';
                    CLR <= '0';
                when Wait1 =>
                    CC4 <= '1';
                    CLR <= '0';
                when Wait2 =>
                    CC3 <= '1';
                    CLR <= '0';
                when Valid =>
                    VLD <= '1';
                    CLR <= '0';
            end case;
        end if;
    end process;
end architecture;
