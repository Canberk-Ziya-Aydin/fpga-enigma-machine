library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity lcd_controller is
    Port (
        clk     : in  STD_LOGIC;
        reset   : in  STD_LOGIC;
        trigger : in  STD_LOGIC;
        data_in : in  STD_LOGIC_VECTOR(7 downto 0);
        lcd_rs  : out STD_LOGIC;
        lcd_e   : out STD_LOGIC;
        lcd_db  : out STD_LOGIC_VECTOR(7 downto 0);
        busy    : out STD_LOGIC
    );
end lcd_controller;

architecture Behavioral of lcd_controller is
    -- These timings assume a 100 MHz clock.
    constant t_15ms  : integer := 1500000;
    constant t_4ms   : integer := 410000;
    constant t_100us : integer := 10000;
    constant t_40us  : integer := 4000;
    constant t_2ms   : integer := 200000;
    constant t_stb   : integer := 50;

    type state_type is (
        ST_POWER_ON,
        ST_INIT_38,
        ST_WAIT_4MS,
        ST_INIT_0C,
        ST_WAIT_100US,
        ST_INIT_01,
        ST_WAIT_2MS,
        ST_INIT_06,
        ST_IDLE,
        ST_NEW_LINE,
        ST_SEND_CHAR,
        ST_SETUP_E,    -- New state added here
        ST_STROBE_E,
        ST_WAIT_40US
    );

    signal state        : state_type := ST_POWER_ON;
    signal return_state : state_type := ST_POWER_ON;
    signal timer        : INTEGER range 0 to 2000000 := 0;
    signal temp_data    : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal temp_rs      : STD_LOGIC := '0';
    signal busy_r       : STD_LOGIC := '1';

    signal pending_valid: STD_LOGIC := '0';
    signal pending_data : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

begin
    busy   <= busy_r;
    lcd_db <= temp_data;
    lcd_rs <= temp_rs;
    lcd_e  <= '1' when state = ST_STROBE_E else '0';

    process (clk, reset)
    begin
        if reset = '1' then
            state         <= ST_POWER_ON;
            return_state  <= ST_POWER_ON;
            timer         <= 0;
            temp_data     <= (others => '0');
            temp_rs       <= '0';
            busy_r        <= '1';
            pending_valid <= '0';
            pending_data  <= (others => '0');

        elsif rising_edge(clk) then
            -- latch a request if one arrives while controller is busy
            if (trigger = '1') and (state /= ST_IDLE) then
                pending_valid <= '1';
                pending_data  <= data_in;
            end if;

            case state is
                when ST_POWER_ON =>
                    busy_r <= '1';
                    if timer < t_15ms then
                        timer <= timer + 1;
                    else
                        timer <= 0;
                        state <= ST_INIT_38;
                    end if;

                when ST_INIT_38 =>
                    busy_r       <= '1';
                    temp_data    <= x"38";
                    temp_rs      <= '0';
                    return_state <= ST_WAIT_4MS;
                    state        <= ST_SETUP_E; 

                when ST_WAIT_4MS =>
                    busy_r <= '1';
                    if timer < t_4ms then
                        timer <= timer + 1;
                    else
                        timer <= 0;
                        state <= ST_INIT_0C;
                    end if;

                when ST_INIT_0C =>
                    busy_r       <= '1';
                    temp_data    <= x"0C";
                    temp_rs      <= '0';
                    return_state <= ST_WAIT_100US;
                    state        <= ST_SETUP_E;  

                when ST_WAIT_100US =>
                    busy_r <= '1';
                    if timer < t_100us then
                        timer <= timer + 1;
                    else
                        timer <= 0;
                        state <= ST_INIT_01;
                    end if;

                when ST_INIT_01 =>
                    busy_r       <= '1';
                    temp_data    <= x"01";
                    temp_rs      <= '0';
                    return_state <= ST_WAIT_2MS;
                    state        <= ST_SETUP_E;  

                when ST_WAIT_2MS =>
                    busy_r <= '1';
                    if timer < t_2ms then
                        timer <= timer + 1;
                    else
                        timer <= 0;
                        state <= ST_INIT_06;
                    end if;

                when ST_INIT_06 =>
                    busy_r       <= '1';
                    temp_data    <= x"06";
                    temp_rs      <= '0';
                    return_state <= ST_WAIT_40US;
                    state        <= ST_SETUP_E;  

                when ST_IDLE =>
                    busy_r <= '0';
                    if trigger = '1' then
                        busy_r <= '1';
                        if data_in = x"0D" then
                            state <= ST_NEW_LINE;
                        else
                            state <= ST_SEND_CHAR;
                        end if;
                    elsif pending_valid = '1' then
                        busy_r        <= '1';
                        pending_valid <= '0';
                        if pending_data = x"0D" then
                            state <= ST_NEW_LINE;
                        else
                            temp_data <= pending_data;
                            temp_rs   <= '1';
                            return_state <= ST_WAIT_40US;
                            state <= ST_SETUP_E;  
                        end if;
                    end if;

                when ST_NEW_LINE =>
                    busy_r       <= '1';
                    temp_data    <= x"C0";
                    temp_rs      <= '0';
                    return_state <= ST_WAIT_40US;
                    state        <= ST_SETUP_E;  

                when ST_SEND_CHAR =>
                    busy_r       <= '1';
                    temp_data    <= data_in;
                    temp_rs      <= '1';
                    return_state <= ST_WAIT_40US;
                    state        <= ST_SETUP_E;  

                when ST_SETUP_E =>           
                    busy_r <= '1';
                    if timer < 4 then        -- 40ns wait at 100MHz
                        timer <= timer + 1;
                    else
                        timer <= 0;
                        state <= ST_STROBE_E;
                    end if;

                when ST_STROBE_E =>
                    busy_r <= '1';
                    if timer < t_stb then
                        timer <= timer + 1;
                    else
                        timer <= 0;
                        state <= return_state;
                    end if;

                when ST_WAIT_40US =>
                    busy_r <= '1';
                    if timer < t_40us then
                        timer <= timer + 1;
                    else
                        timer <= 0;
                        state <= ST_IDLE;
                    end if;

                when others =>
                    busy_r <= '1';
                    state  <= ST_POWER_ON;
                    timer  <= 0;
            end case;
        end if;
    end process;
end Behavioral;