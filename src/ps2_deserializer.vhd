library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ps2_deserializer is
    Port (
        ps2_clk        : in  STD_LOGIC;
        ps2_data       : in  STD_LOGIC;
        clk            : in  STD_LOGIC;
        scancode_ready : out STD_LOGIC;
        scancode       : out STD_LOGIC_VECTOR(7 downto 0);
        error_led      : out STD_LOGIC
    );
end ps2_deserializer;

architecture Behavioral of ps2_deserializer is
    signal ps2_clk_sync  : STD_LOGIC_VECTOR(2 downto 0) := (others => '1');
    signal ps2_data_sync : STD_LOGIC_VECTOR(1 downto 0) := (others => '1');

    signal bit_count     : INTEGER range 0 to 10 := 0;
    signal shift_reg     : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal parity_bit    : STD_LOGIC := '0';

    signal scancode_r    : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal ready_r       : STD_LOGIC := '0';
    signal error_r       : STD_LOGIC := '0';
begin
    scancode       <= scancode_r;
    scancode_ready <= ready_r;
    error_led      <= error_r;

    process (clk)
        variable odd_parity_ok : STD_LOGIC;
    begin
        if rising_edge(clk) then
            ready_r <= '0';

            -- synchronize PS/2 inputs into clk domain
            ps2_clk_sync  <= ps2_clk_sync(1 downto 0) & ps2_clk;
            ps2_data_sync <= ps2_data_sync(0) & ps2_data;

            -- detect falling edge of PS/2 clock
            if ps2_clk_sync(2 downto 1) = "10" then
                case bit_count is
                    when 0 =>
                        -- start bit must be 0
                        if ps2_data_sync(1) = '0' then
                            bit_count <= 1;
                            error_r   <= '0';
                        else
                            bit_count <= 0;
                            error_r   <= '1';
                        end if;

                    when 1 to 8 =>
                        shift_reg(bit_count - 1) <= ps2_data_sync(1);
                        bit_count <= bit_count + 1;

                    when 9 =>
                        parity_bit <= ps2_data_sync(1);
                        bit_count  <= 10;

                    when 10 =>
                        -- stop bit must be 1 and total parity must be odd
                        odd_parity_ok := shift_reg(0) xor shift_reg(1) xor shift_reg(2) xor shift_reg(3) xor
                                         shift_reg(4) xor shift_reg(5) xor shift_reg(6) xor shift_reg(7) xor
                                         parity_bit;

                        if (ps2_data_sync(1) = '1') and (odd_parity_ok = '1') then
                            scancode_r <= shift_reg;
                            ready_r    <= '1';
                            error_r    <= '0';
                        else
                            error_r    <= '1';
                        end if;

                        bit_count <= 0;

                    when others =>
                        bit_count <= 0;
                end case;
            end if;
        end if;
    end process;
end Behavioral;
