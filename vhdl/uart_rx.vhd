-- uart_rx.vhd: UART controller - receiving (RX) side
-- Author(s): Name Surname (xlogin00)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;



-- Entity declaration (DO NOT ALTER THIS PART!)
entity UART_RX is
    port(
        CLK      : in std_logic;
        RST      : in std_logic;
        DIN      : in std_logic;
        DOUT     : out std_logic_vector(7 downto 0);
        DOUT_VLD : out std_logic
    );
end entity;



-- Architecture implementation (INSERT YOUR IMPLEMENTATION HERE)
architecture behavioral of UART_RX is
    -- counters
    signal CTR4 : unsigned(3 downto 0);
    signal CTR3 : unsigned(2 downto 0);
    -- delay when chaining CTR3 to CTR4
    signal DELAY : std_logic;
    -- outputs from fsm
    signal RD  : std_logic; -- should read into DOUT
    signal CC3 : std_logic; -- CNT3 should count
    signal CC4 : std_logic; -- CNT4 should count
    signal CLR : std_logic; -- clear DOUT
    -- inputs to fsm
    signal CO3 : std_logic; -- set when CTR3 = "111"
    signal CO4 : std_logic; -- set when CTR4 = "1111"

    function bool_to_log(bool : boolean) return std_logic is
    begin
        if bool then
            return '1';
        end if;
        return '0';
    end function;
begin

    -- Instance of RX FSM
    fsm: entity work.UART_RX_FSM
    port map (
        -- in
        CLK  => CLK,
        RST  => RST,
        DAT  => DIN,
        CNT3 => CO3,
        CNT4 => CO4,
        -- out
        RD  => RD,
        CC3 => CC3,
        CC4 => CC4,
        VLD => DOUT_VLD,
        CLR => CLR
    );

    process (CLK, RST) is
        -- when CTR4 is at its last number
        variable ctr4_end : boolean;
        -- when CTR3 is at its last number
        variable ctr3_end : boolean;
        -- the ctr_end variables must be set when the next iteration is
        -- at the end so that the CNT3 and CNT4 are set at the same time
        -- as CTR4 and CTR3 goes to the last number
        variable next_ctr3 : unsigned(2 downto 0);
        variable next_ctr4 : unsigned(3 downto 0);
    begin
        -- set the variables
        ctr4_end := CTR4 = "1111";
        ctr3_end := CTR3 = "111";

        -- asynchronous reset
        if RST = '1' then
            DOUT <= (others => '0');
            CTR4 <= (others => '0');
            CTR3 <= (others => '0');
            CO3  <= '0';
            CO4  <= '0';
        elsif rising_edge(CLK) then
            --<< reacting on fsm output >>--

            -- clear dout
            if CLR = '1' then
                DOUT <= (others => '0');
            end if;

            -- increment CTR4
            if CC4 = '1' then
                next_ctr4 := CTR4 + 1;
            else
                next_ctr4 := (others => '0');
            end if;

            -- increment CTR3
            if CC3 = '1' then
                -- chain CTR3 after CTR4 when RD = '1'
                if RD = '1' then
                    if DELAY = '1' then
                        next_ctr3 := CTR3 + 1;
                    end if;
                else
                    next_ctr3 := CTR3 + 1;
                end if;
            else
                next_ctr3 := (others => '0');
            end if;

            CTR3 <= next_ctr3;
            CTR4 <= next_ctr4;
            ctr3_end := next_ctr3 = "111";
            ctr4_end := next_ctr4 = "1111";

            --<< setting fsm input >>--

            CO3 <= bool_to_log(ctr3_end);

            CO4 <= bool_to_log(ctr4_end);

            -- setting DOUT
            if RD = '1' and ctr4_end and DIN = '1' then
                DOUT(to_integer(CTR3)) <= '1';
            end if;

            -- updating delay
            DELAY <= bool_to_log(ctr4_end);
        end if;
    end process;
end architecture;
