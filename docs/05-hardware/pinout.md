# Pinagem – Terasic DE2-115

Todas as atribuições foram extraídas do manual oficial da placa e do arquivo de pin assignments padrão.

## Clock

| Sinal | Pino | Padrão I/O |
|-------|------|------------|
| CLOCK_50 | PIN_Y2 | 3.3-V LVTTL |

## Push-buttons (ativos em nível baixo)

| Sinal | Pino | Função no projeto |
|-------|------|-------------------|
| KEY[0] | PIN_M23 | Reset global |
| KEY[1] | PIN_M21 | Confirmação |
| KEY[2] | PIN_N21 | Incremento |
| KEY[3] | PIN_R24 | Decremento |

## Displays de 7 segmentos

| Display | Função | Pinos (HEX[0]…HEX[6]) |
|---------|--------|-----------------------|
| HEX0 | 4º dígito (LSB) | G18, F22, E17, L26, L25, J22, H22 |
| HEX1 | 3º dígito | M24, Y22, W21, W22, W25, U23, U24 |
| HEX2 | 2º dígito | AA25, AA26, Y25, W26, Y26, W27, W28 |
| HEX3 | 1º dígito (MSB) | V21, U21, AB20, AA21, AD24, AF23, Y19 |
| HEX4 | Índice ativo | AB19, AA19, AG21, AH21, AE19, AF19, AE18 |

## LEDs

| Grupo | Quantidade | Função |
|-------|------------|--------|
| LEDG[8:0] | 9 | Feedback de sucesso (todos acendem juntos) |
| LEDR[17:0] | 18 | Feedback de falha (todos acendem juntos) |
