# Restrições de temporização – SafeCrack Pro
# Clock: 50 MHz em CLOCK_50 (PIN_Y2)
# Compatível com Quartus Prime 21.1

# Clock principal de 50 MHz
create_clock -name {CLOCK_50} -period 20.000 -waveform { 0.000 10.000 } [get_ports {CLOCK_50}]

# Derivação automática da incerteza de clock
derive_clock_uncertainty

# Entradas assíncronas (botões) – caminho falso
set_false_path -from [get_ports {KEY[*]}]

# Saídas assíncronas (displays e LEDs) – caminho falso
set_false_path -to [get_ports {HEX0[*] HEX1[*] HEX2[*] HEX3[*] HEX4[*]}]
set_false_path -to [get_ports {LEDG[*] LEDR[*]}]
