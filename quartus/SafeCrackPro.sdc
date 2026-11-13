# -------------------------------------------------------------------------- #
# Timing Constraints - SafeCrack Pro
# Clock: 50 MHz on CLOCK_50 (PIN_Y2)
# Compatible with Quartus Prime 21.1
# -------------------------------------------------------------------------- #

# Create the main 50 MHz clock
create_clock -name {CLOCK_50} -period 20.000 -waveform { 0.000 10.000 } [get_ports {CLOCK_50}]

# Automatically derive clock uncertainty
derive_clock_uncertainty

# Asynchronous inputs (buttons) - false path
set_false_path -from [get_ports {KEY[*]}]

# Asynchronous outputs (displays and LEDs) - false path
set_false_path -to [get_ports {HEX0[*] HEX1[*] HEX2[*] HEX3[*] HEX4[*]}]
set_false_path -to [get_ports {LEDG[*] LEDR[*]}]
