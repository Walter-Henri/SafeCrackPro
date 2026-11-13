# Módulo: safecrack_pro_top

**Arquivo:** `rtl/safecrack_pro_top.sv`  
**Tipo:** Top-level entity  
**Sintetizável:** Sim  

## Responsabilidade

Instanciar e interconectar todos os módulos do sistema, gerenciar o reset global (power-on + KEY[0]) e mapear os sinais internos para os pinos físicos da DE2-115.

## Parâmetros

| Parâmetro | Default | Descrição |
|-----------|---------|-----------|
| `PASSWORD_D0` | 4'd1 | Dígito mais significativo (HEX3) |
| `PASSWORD_D1` | 4'd2 | Segundo dígito (HEX2) |
| `PASSWORD_D2` | 4'd3 | Terceiro dígito (HEX1) |
| `PASSWORD_D3` | 4'd4 | Dígito menos significativo (HEX0) |
| `DEBOUNCE_CYCLES` | 250_000 | Ciclos de debounce (~5 ms @ 50 MHz) |
| `SUCCESS_CYCLES` | 250_000_000 | Duração do feedback de sucesso (5 s) |
| `FAIL_CYCLES` | 150_000_000 | Duração do feedback de falha (3 s) |

## Portas

| Porta | Direção | Largura | Descrição |
|-------|---------|---------|-----------|
| `CLOCK_50` | input | 1 | Clock de 50 MHz da placa |
| `KEY` | input | [3:0] | Push-buttons ativos em nível baixo |
| `HEX0`–`HEX4` | output | [6:0] | Displays de 7 segmentos |
| `LEDG` | output | [8:0] | LEDs verdes |
| `LEDR` | output | [17:0] | LEDs vermelhos |

## Funcionamento interno

1. Contador de power-on reset (~16 ciclos).
2. Sincronização de KEY[0] e geração de `rst_n`.
3. Instanciação de três módulos `debounce` para KEY[1..3].
4. Instanciação do `safecrack_fsm`.
5. Instanciação de cinco decoders `bcd_to_7segment`.
6. Drivers de LED (replicação do sinal de controle).

## Dependências

- `debounce`
- `safecrack_fsm`
- `bcd_to_7segment`
