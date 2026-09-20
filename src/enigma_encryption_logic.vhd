library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity enigma_encryption_logic is
    Port (
        pin_rotorpin1   : in  STD_LOGIC;
        pin_rotorpin2   : in  STD_LOGIC;
        pin_rotorpin3   : in  STD_LOGIC;

        enigma_char     : in  STD_LOGIC_VECTOR(7 downto 0);
        enigma_trigger  : in  STD_LOGIC;
        cmd_enter       : in  STD_LOGIC;
        reset           : in  STD_LOGIC;

        clk             : in  STD_LOGIC;
        trigger         : out STD_LOGIC;
        data_in         : out STD_LOGIC_VECTOR(7 downto 0)
    );
end enigma_encryption_logic;

architecture Behavioral of enigma_encryption_logic is

    type lut26_t is array (0 to 25) of integer range 0 to 25;

    type state_t is (
        ST_IDLE,
        ST_FWD1,
        ST_FWD2,
        ST_FWD3,
        ST_REFLECT,
        ST_REV3,
        ST_REV2,
        ST_REV1,
        ST_OUT
    );

    signal state     : state_t := ST_IDLE;
    signal data_in_o : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal trigger_o : STD_LOGIC := '0';

    signal turn_rotor_1 : integer range 0 to 25 := 0;
    signal turn_rotor_2 : integer range 0 to 25 := 0;
    signal turn_rotor_3 : integer range 0 to 25 := 0;

    signal next_turn_1  : integer range 0 to 25 := 0;
    signal next_turn_2  : integer range 0 to 25 := 0;
    signal next_turn_3  : integer range 0 to 25 := 0;

    signal x_reg        : integer range 0 to 25 := 0;

    -- live selection from pins
    signal r1_fwd_sel : lut26_t;
    signal r1_rev_sel : lut26_t;
    signal r2_fwd_sel : lut26_t;
    signal r2_rev_sel : lut26_t;
    signal r3_fwd_sel : lut26_t;
    signal r3_rev_sel : lut26_t;

    -- latched selection used for the current character
    signal r1_fwd_act : lut26_t;
    signal r1_rev_act : lut26_t;
    signal r2_fwd_act : lut26_t;
    signal r2_rev_act : lut26_t;
    signal r3_fwd_act : lut26_t;
    signal r3_rev_act : lut26_t;

    signal slot1_notch_sel : integer range 0 to 25;
    signal slot2_notch_sel : integer range 0 to 25;

    constant NOTCH_R1 : integer range 0 to 25 := 11;
    constant NOTCH_R2 : integer range 0 to 25 := 17;
    constant NOTCH_R3 : integer range 0 to 25 := 8;

    constant PLUGBOARD_1 : lut26_t := (
        12, 19, 11, 17, 25, 15,  6,  7,  8,  9, 10,  2,  0,
        13, 14,  5, 16,  3, 18,  1, 20, 21, 22, 23, 24,  4
    );

    constant REFLECTOR_B : lut26_t := (
        24, 17, 20,  7, 16, 18, 11,  3, 15, 23, 13,  6, 14,
        10, 12,  8,  4,  1,  5, 25,  2, 22, 21,  9,  0, 19
    );

    constant ROTOR_1_FWD : lut26_t := (
         4, 10, 12,  5, 11,  6,  3, 16, 21, 25, 13, 19, 14,
        22, 24,  7, 23, 20, 18, 15,  0,  8,  1, 17,  2,  9
    );

    constant ROTOR_1_REV : lut26_t := (
        20, 22, 24,  6,  0,  3,  5, 15, 21, 25,  1,  4,  2,
        10, 12, 19,  7, 23, 18, 11, 17,  8, 13, 16, 14,  9
    );

    constant ROTOR_2_FWD : lut26_t := (
         0,  9,  3, 10, 18,  8, 17, 20, 23,  1, 11,  7, 22,
        19, 12,  2, 16,  6, 25, 13, 15, 24,  5, 21, 14,  4
    );

    constant ROTOR_2_REV : lut26_t := (
         0,  9, 15,  2, 25, 22, 17, 11,  5,  1,  3, 10, 14,
        19, 24, 20, 16,  6,  4, 13,  7, 23, 12,  8, 21, 18
    );

    constant ROTOR_3_FWD : lut26_t := (
         1,  3,  5,  7,  9, 11,  2, 15, 17, 19, 23, 21, 25,
        13, 24,  4,  8, 22,  6,  0, 10, 12, 20, 18, 16, 14
    );

    constant ROTOR_3_REV : lut26_t := (
        19,  0,  6,  1, 15,  2, 18,  3, 16,  4, 20,  5, 21,
        13, 25,  7, 24,  8, 23,  9, 22, 11, 17, 10, 14, 12
    );

    function wrap26(v : integer) return integer is
        variable res : integer;
    begin
        if v < 0 then
            res := v + 26;
        elsif v > 25 then
            res := v - 26;
        else
            res := v;
        end if;
        return res;
    end function;

    function rotor_map(
        x_in   : integer;
        turn   : integer;
        wiring : lut26_t
    ) return integer is
        variable idx : integer range 0 to 25;
    begin
        idx := wrap26(x_in + turn);
        return wrap26(wiring(idx) - turn);
    end function;

begin
    data_in <= data_in_o;
    trigger <= trigger_o;

    process(pin_rotorpin1, pin_rotorpin2, pin_rotorpin3)
    begin
        case std_logic_vector'(pin_rotorpin1 & pin_rotorpin2 & pin_rotorpin3) is

            when "000" =>   -- 1 2 3
                r1_fwd_sel      <= ROTOR_1_FWD;
                r1_rev_sel      <= ROTOR_1_REV;
                r2_fwd_sel      <= ROTOR_2_FWD;
                r2_rev_sel      <= ROTOR_2_REV;
                r3_fwd_sel      <= ROTOR_3_FWD;
                r3_rev_sel      <= ROTOR_3_REV;
                slot1_notch_sel <= NOTCH_R1;
                slot2_notch_sel <= NOTCH_R2;

            when "001" =>   -- 1 3 2
                r1_fwd_sel      <= ROTOR_1_FWD;
                r1_rev_sel      <= ROTOR_1_REV;
                r2_fwd_sel      <= ROTOR_3_FWD;
                r2_rev_sel      <= ROTOR_3_REV;
                r3_fwd_sel      <= ROTOR_2_FWD;
                r3_rev_sel      <= ROTOR_2_REV;
                slot1_notch_sel <= NOTCH_R1;
                slot2_notch_sel <= NOTCH_R3;

            when "010" =>   -- 2 1 3
                r1_fwd_sel      <= ROTOR_2_FWD;
                r1_rev_sel      <= ROTOR_2_REV;
                r2_fwd_sel      <= ROTOR_1_FWD;
                r2_rev_sel      <= ROTOR_1_REV;
                r3_fwd_sel      <= ROTOR_3_FWD;
                r3_rev_sel      <= ROTOR_3_REV;
                slot1_notch_sel <= NOTCH_R2;
                slot2_notch_sel <= NOTCH_R1;

            when "011" =>   -- 2 3 1
                r1_fwd_sel      <= ROTOR_2_FWD;
                r1_rev_sel      <= ROTOR_2_REV;
                r2_fwd_sel      <= ROTOR_3_FWD;
                r2_rev_sel      <= ROTOR_3_REV;
                r3_fwd_sel      <= ROTOR_1_FWD;
                r3_rev_sel      <= ROTOR_1_REV;
                slot1_notch_sel <= NOTCH_R2;
                slot2_notch_sel <= NOTCH_R3;

            when "100" =>   -- 3 1 2
                r1_fwd_sel      <= ROTOR_3_FWD;
                r1_rev_sel      <= ROTOR_3_REV;
                r2_fwd_sel      <= ROTOR_1_FWD;
                r2_rev_sel      <= ROTOR_1_REV;
                r3_fwd_sel      <= ROTOR_2_FWD;
                r3_rev_sel      <= ROTOR_2_REV;
                slot1_notch_sel <= NOTCH_R3;
                slot2_notch_sel <= NOTCH_R1;

            when "101" =>   -- 3 2 1
                r1_fwd_sel      <= ROTOR_3_FWD;
                r1_rev_sel      <= ROTOR_3_REV;
                r2_fwd_sel      <= ROTOR_2_FWD;
                r2_rev_sel      <= ROTOR_2_REV;
                r3_fwd_sel      <= ROTOR_1_FWD;
                r3_rev_sel      <= ROTOR_1_REV;
                slot1_notch_sel <= NOTCH_R3;
                slot2_notch_sel <= NOTCH_R2;

            when others =>
                r1_fwd_sel      <= ROTOR_1_FWD;
                r1_rev_sel      <= ROTOR_1_REV;
                r2_fwd_sel      <= ROTOR_2_FWD;
                r2_rev_sel      <= ROTOR_2_REV;
                r3_fwd_sel      <= ROTOR_3_FWD;
                r3_rev_sel      <= ROTOR_3_REV;
                slot1_notch_sel <= NOTCH_R1;
                slot2_notch_sel <= NOTCH_R2;
        end case;
    end process;

    process(clk, reset)
        variable old_r1 : integer range 0 to 25;
        variable old_r2 : integer range 0 to 25;
        variable nr1    : integer range 0 to 25;
        variable nr2    : integer range 0 to 25;
        variable nr3    : integer range 0 to 25;
        variable xi     : integer range 0 to 25;
        variable out_x  : integer range 0 to 25;
    begin
        if reset = '1' then
            state        <= ST_IDLE;
            data_in_o    <= x"00";
            trigger_o    <= '0';
            turn_rotor_1 <= 0;
            turn_rotor_2 <= 0;
            turn_rotor_3 <= 0;
            next_turn_1  <= 0;
            next_turn_2  <= 0;
            next_turn_3  <= 0;
            x_reg        <= 0;

            r1_fwd_act   <= ROTOR_1_FWD;
            r1_rev_act   <= ROTOR_1_REV;
            r2_fwd_act   <= ROTOR_2_FWD;
            r2_rev_act   <= ROTOR_2_REV;
            r3_fwd_act   <= ROTOR_3_FWD;
            r3_rev_act   <= ROTOR_3_REV;

        elsif rising_edge(clk) then
            trigger_o <= '0';

            case state is
                when ST_IDLE =>
                    if enigma_trigger = '1' then
                        if cmd_enter = '1' then
                            data_in_o <= x"0D";
                            trigger_o <= '1';
                        else
                            xi := to_integer(unsigned(enigma_char));

                            old_r1 := turn_rotor_1;
                            old_r2 := turn_rotor_2;

                            nr1 := turn_rotor_1;
                            nr2 := turn_rotor_2;
                            nr3 := turn_rotor_3;

                            if nr1 = 25 then
                                nr1 := 0;
                            else
                                nr1 := nr1 + 1;
                            end if;

                            if (old_r1 = slot1_notch_sel) or (old_r2 = slot2_notch_sel) then
                                if nr2 = 25 then
                                    nr2 := 0;
                                else
                                    nr2 := nr2 + 1;
                                end if;
                            end if;

                            if old_r2 = slot2_notch_sel then
                                if nr3 = 25 then
                                    nr3 := 0;
                                else
                                    nr3 := nr3 + 1;
                                end if;
                            end if;

                            next_turn_1 <= nr1;
                            next_turn_2 <= nr2;
                            next_turn_3 <= nr3;

                            r1_fwd_act <= r1_fwd_sel;
                            r1_rev_act <= r1_rev_sel;
                            r2_fwd_act <= r2_fwd_sel;
                            r2_rev_act <= r2_rev_sel;
                            r3_fwd_act <= r3_fwd_sel;
                            r3_rev_act <= r3_rev_sel;

                            x_reg <= PLUGBOARD_1(xi);
                            state <= ST_FWD1;
                        end if;
                    end if;

                when ST_FWD1 =>
                    x_reg <= rotor_map(x_reg, next_turn_1, r1_fwd_act);
                    state <= ST_FWD2;

                when ST_FWD2 =>
                    x_reg <= rotor_map(x_reg, next_turn_2, r2_fwd_act);
                    state <= ST_FWD3;

                when ST_FWD3 =>
                    x_reg <= rotor_map(x_reg, next_turn_3, r3_fwd_act);
                    state <= ST_REFLECT;

                when ST_REFLECT =>
                    x_reg <= REFLECTOR_B(x_reg);
                    state <= ST_REV3;

                when ST_REV3 =>
                    x_reg <= rotor_map(x_reg, next_turn_3, r3_rev_act);
                    state <= ST_REV2;

                when ST_REV2 =>
                    x_reg <= rotor_map(x_reg, next_turn_2, r2_rev_act);
                    state <= ST_REV1;

                when ST_REV1 =>
                    x_reg <= rotor_map(x_reg, next_turn_1, r1_rev_act);
                    state <= ST_OUT;

                when ST_OUT =>
                    out_x := PLUGBOARD_1(x_reg);

                    data_in_o <= std_logic_vector(to_unsigned(out_x + 65, 8));
                    --data_in_o <= x"41";
                    trigger_o <= '1';

                    turn_rotor_1 <= next_turn_1;
                    turn_rotor_2 <= next_turn_2;
                    turn_rotor_3 <= next_turn_3;

                    state <= ST_IDLE;
            end case;
        end if;
    end process;

end Behavioral;