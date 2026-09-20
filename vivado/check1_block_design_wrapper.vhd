--Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
--Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2025.2 (win64) Build 6299465 Fri Nov 14 19:35:11 GMT 2025
--Date        : Fri Apr 24 20:40:02 2026
--Host        : LAPTOP-6F5THOHB running 64-bit major release  (build 9200)
--Command     : generate_target check1_block_design_wrapper.bd
--Design      : check1_block_design_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity check1_block_design_wrapper is
  port (
    clk : in STD_LOGIC;
    error_led : out STD_LOGIC;
    lcd_db : out STD_LOGIC_VECTOR ( 7 downto 0 );
    lcd_e : out STD_LOGIC;
    lcd_rs : out STD_LOGIC;
    pin_rotorpin1_0 : in STD_LOGIC;
    pin_rotorpin2_0 : in STD_LOGIC;
    pin_rotorpin3_0 : in STD_LOGIC;
    ps2_clk : in STD_LOGIC;
    ps2_data : in STD_LOGIC;
    reset : in STD_LOGIC;
    reset_0 : in STD_LOGIC
  );
end check1_block_design_wrapper;

architecture STRUCTURE of check1_block_design_wrapper is
  component check1_block_design is
  port (
    error_led : out STD_LOGIC;
    reset : in STD_LOGIC;
    clk : in STD_LOGIC;
    ps2_clk : in STD_LOGIC;
    ps2_data : in STD_LOGIC;
    lcd_db : out STD_LOGIC_VECTOR ( 7 downto 0 );
    lcd_e : out STD_LOGIC;
    lcd_rs : out STD_LOGIC;
    reset_0 : in STD_LOGIC;
    pin_rotorpin1_0 : in STD_LOGIC;
    pin_rotorpin2_0 : in STD_LOGIC;
    pin_rotorpin3_0 : in STD_LOGIC
  );
  end component check1_block_design;
begin
check1_block_design_i: component check1_block_design
     port map (
      clk => clk,
      error_led => error_led,
      lcd_db(7 downto 0) => lcd_db(7 downto 0),
      lcd_e => lcd_e,
      lcd_rs => lcd_rs,
      pin_rotorpin1_0 => pin_rotorpin1_0,
      pin_rotorpin2_0 => pin_rotorpin2_0,
      pin_rotorpin3_0 => pin_rotorpin3_0,
      ps2_clk => ps2_clk,
      ps2_data => ps2_data,
      reset => reset,
      reset_0 => reset_0
    );
end STRUCTURE;
