

## 100 MHz onboard clock
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.000 -waveform {0 5} [get_ports clk]

## Enigma reset button (BTNL) - new reset_0
set_property PACKAGE_PIN T17 [get_ports reset_0]
set_property IOSTANDARD LVCMOS33 [get_ports reset_0]

# pin_rotorpin3_0 -> W16
set_property PACKAGE_PIN W16 [get_ports pin_rotorpin3_0]
set_property IOSTANDARD LVCMOS33 [get_ports pin_rotorpin3_0]

## pin_rotorpin2_0 -> V16
set_property PACKAGE_PIN V16 [get_ports pin_rotorpin2_0]
set_property IOSTANDARD LVCMOS33 [get_ports pin_rotorpin2_0]

## pin_rotorpin1_0 -> V17
set_property PACKAGE_PIN V17 [get_ports pin_rotorpin1_0]
set_property IOSTANDARD LVCMOS33 [get_ports pin_rotorpin1_0]

## Reset button (BTNC)
set_property PACKAGE_PIN U18 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

## Optional error LED (LED0)
set_property PACKAGE_PIN U16 [get_ports error_led]
set_property IOSTANDARD LVCMOS33 [get_ports error_led]

## PS/2 keyboard on JA
set_property PACKAGE_PIN J1 [get_ports ps2_clk]
set_property IOSTANDARD LVCMOS33 [get_ports ps2_clk]

set_property PACKAGE_PIN L2 [get_ports ps2_data]
set_property IOSTANDARD LVCMOS33 [get_ports ps2_data]

## LCD on JB + JC
set_property PACKAGE_PIN A14 [get_ports lcd_rs]
set_property IOSTANDARD LVCMOS33 [get_ports lcd_rs]

set_property PACKAGE_PIN A16 [get_ports lcd_e]
set_property IOSTANDARD LVCMOS33 [get_ports lcd_e]

set_property PACKAGE_PIN B15 [get_ports {lcd_db[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {lcd_db[0]}]

set_property PACKAGE_PIN B16 [get_ports {lcd_db[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {lcd_db[1]}]

set_property PACKAGE_PIN A15 [get_ports {lcd_db[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {lcd_db[2]}]

set_property PACKAGE_PIN A17 [get_ports {lcd_db[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {lcd_db[3]}]

set_property PACKAGE_PIN K17 [get_ports {lcd_db[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {lcd_db[4]}]

set_property PACKAGE_PIN M18 [get_ports {lcd_db[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {lcd_db[5]}]

set_property PACKAGE_PIN N17 [get_ports {lcd_db[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {lcd_db[6]}]

set_property PACKAGE_PIN P18 [get_ports {lcd_db[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {lcd_db[7]}]
