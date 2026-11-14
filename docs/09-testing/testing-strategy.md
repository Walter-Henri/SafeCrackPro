# Estratégia de Simulação e Validação

## Abordagem

A validação é realizada por meio de um testbench SystemVerilog autocontido (`sim/tb_safecrack_pro.sv`) que exercita os cenários críticos do sistema sem depender da FPGA física.

Os tempos de debounce e de feedback são reduzidos por parâmetros para tornar a simulação prática.

## Cenários cobertos

| ID | Cenário | Resultado esperado |
|----|---------|--------------------|
| T01 | Power-on / estado inicial | Dígitos = 0, HEX4 = 1, LEDs apagados |
| T02 | Incremento sucessivo | 0 → 1 → 2 → 3 |
| T03 | Decremento sucessivo | 3 → 2 → 1 |
| T04 | Wrap-around superior | 9 → 0 |
| T05 | Wrap-around inferior | 0 → 9 |
| T06 | Confirmação e avanço | HEX4 atualizado, dígitos anteriores preservados |
| T07 | Senha correta (1234) | LEDG acesos, retorno após timeout |
| T08 | Senha incorreta | LEDR acesos, retorno após timeout |
| T09 | Pressionamento contínuo | Apenas uma ação gerada |
| T10 | Reset via KEY[0] | Sistema retorna ao estado inicial |

## Assertions

O testbench utiliza assertions SystemVerilog para validar automaticamente as condições esperadas em cada etapa.

## Waveforms

Os sinais principais a serem observados são:

- `clk`, `KEY`, `rst_n`
- `key1_pulse`, `key2_pulse`, `key3_pulse`
- `state`, `active_idx`
- `digit0`…`digit3`
- `LEDG`, `LEDR`
- `HEX0`…`HEX4`
