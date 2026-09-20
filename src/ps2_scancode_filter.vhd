library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ps2_scancode_filter is
    Port (
        clk            : in  STD_LOGIC;
        scancode_ready : in  STD_LOGIC;
        scancode       : in  STD_LOGIC_VECTOR(7 downto 0);
        enigma_char    : out STD_LOGIC_VECTOR(7 downto 0);
        enigma_trigger : out STD_LOGIC;
        cmd_enter     : out STD_LOGIC
    );
end ps2_scancode_filter;

architecture Behavioral of ps2_scancode_filter is
    signal break_seen      : STD_LOGIC := '0';
    signal enigma_char_r   : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal enigma_trigger_r: STD_LOGIC := '0';
    signal cmd_enter_r     : STD_LOGIC := '0';
begin
    enigma_char    <= enigma_char_r;
    enigma_trigger <= enigma_trigger_r;
    cmd_enter <= cmd_enter_r;
    process (clk)
    begin
        if rising_edge(clk) then
            enigma_trigger_r <= '0';
            cmd_enter_r <= '0';

            if scancode_ready = '1' then
                if scancode = x"F0" then
                    -- next scancode is key release
                    break_seen <= '1';

                elsif scancode = x"E0" then
                    -- ignore arrow chars, ctrl etc
                    break_seen <= break_seen;

                elsif break_seen = '1' then
                    -- ignores release scancode
                    break_seen <= '0';

                else
                case scancode is
                    when x"1C" => enigma_char_r <= x"00"; enigma_trigger_r <= '1'; -- A
                    when x"32" => enigma_char_r <= x"01"; enigma_trigger_r <= '1'; -- B
                    when x"21" => enigma_char_r <= x"02"; enigma_trigger_r <= '1'; -- C
                    when x"23" => enigma_char_r <= x"03"; enigma_trigger_r <= '1'; -- D
                    when x"24" => enigma_char_r <= x"04"; enigma_trigger_r <= '1'; -- E
                    when x"2B" => enigma_char_r <= x"05"; enigma_trigger_r <= '1'; -- F
                    when x"34" => enigma_char_r <= x"06"; enigma_trigger_r <= '1'; -- G
                    when x"33" => enigma_char_r <= x"07"; enigma_trigger_r <= '1'; -- H
                    when x"43" => enigma_char_r <= x"08"; enigma_trigger_r <= '1'; -- I
                    when x"3B" => enigma_char_r <= x"09"; enigma_trigger_r <= '1'; -- J
                    when x"42" => enigma_char_r <= x"0A"; enigma_trigger_r <= '1'; -- K
                    when x"4B" => enigma_char_r <= x"0B"; enigma_trigger_r <= '1'; -- L
                    when x"3A" => enigma_char_r <= x"0C"; enigma_trigger_r <= '1'; -- M
                    when x"31" => enigma_char_r <= x"0D"; enigma_trigger_r <= '1'; -- N
                    when x"44" => enigma_char_r <= x"0E"; enigma_trigger_r <= '1'; -- O
                    when x"4D" => enigma_char_r <= x"0F"; enigma_trigger_r <= '1'; -- P
                    when x"15" => enigma_char_r <= x"10"; enigma_trigger_r <= '1'; -- Q
                    when x"2D" => enigma_char_r <= x"11"; enigma_trigger_r <= '1'; -- R
                    when x"1B" => enigma_char_r <= x"12"; enigma_trigger_r <= '1'; -- S
                    when x"2C" => enigma_char_r <= x"13"; enigma_trigger_r <= '1'; -- T
                    when x"3C" => enigma_char_r <= x"14"; enigma_trigger_r <= '1'; -- U
                    when x"2A" => enigma_char_r <= x"15"; enigma_trigger_r <= '1'; -- V
                    when x"1D" => enigma_char_r <= x"16"; enigma_trigger_r <= '1'; -- W
                    when x"22" => enigma_char_r <= x"17"; enigma_trigger_r <= '1'; -- X
                    when x"35" => enigma_char_r <= x"18"; enigma_trigger_r <= '1'; -- Y
                    when x"1A" => enigma_char_r <= x"19"; enigma_trigger_r <= '1'; -- Z

                    when x"5A" => cmd_enter_r <= '1'; enigma_trigger_r <= '1';

                    when others => null;
                end case;
                end if;
            end if;
        end if;
    end process;
end Behavioral;