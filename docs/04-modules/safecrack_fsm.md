# Módulo: safecrack_fsm

**Arquivo:** `rtl/safecrack_fsm.sv`  
**Tipo:** FSM + Datapath  
**Sintetizável:** Sim  

## Responsabilidade

Controlar todo o fluxo de operação do cofre: edição dos quatro dígitos, verificação da senha e geração do feedback temporizado.

## Estados

| Estado | Valor | Descrição |
|--------|-------|-----------|
| `ST_EDIT_0` | 0 | Edição do primeiro dígito (HEX3) |
| `ST_EDIT_1` | 1 | Edição do segundo dígito (HEX2) |
| `ST_EDIT_2` | 2 | Edição do terceiro dígito (HEX1) |
| `ST_EDIT_3` | 3 | Edição do quarto dígito (HEX0) |
| `ST_CHECK` | 4 | Comparação da senha (1 ciclo) |
| `ST_SUCCESS` | 5 | Feedback de sucesso (LEDG) |
| `ST_FAIL` | 6 | Feedback de falha (LEDR) |

## Portas principais

| Porta | Direção | Descrição |
|-------|---------|-----------|
| `key3_pulse` | input | Pulso limpo de decremento |
| `key2_pulse` | input | Pulso limpo de incremento |
| `key1_pulse` | input | Pulso limpo de confirmação |
| `digit0`–`digit3` | output | Valores dos quatro dígitos |
| `active_idx` | output | Índice interno (0–3); HEX4 exibe valor+1 (1–4) |
| `ledg_on` / `ledr_on` | output | Controle dos LEDs |

## Regras de negócio implementadas

- Incremento e decremento com wrap-around (0↔9).
- Não é possível voltar a um dígito já confirmado.
- Após o quarto confirm, a comparação ocorre em um único ciclo.
- Os timers de feedback são síncronos e recomeçam apenas ao entrar no estado correspondente.
- Ao término do timer o sistema zera todos os dígitos e retorna a `ST_EDIT_0`.
