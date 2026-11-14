# Requisitos Funcionais e Não-Funcionais

## Requisitos Funcionais

| ID | Requisito | Implementação |
|----|-----------|---------------|
| RF-01 | Senha composta por exatamente 4 dígitos (0–9) | Registradores `d0`–`d3` no módulo `safecrack_fsm` |
| RF-02 | HEX3–HEX0 exibem os quatro dígitos simultaneamente | Instâncias de `bcd_to_7segment` |
| RF-03 | HEX4 indica o dígito ativo (1–4) | `active_idx + 1` decodificado em HEX4 |
| RF-04 | KEY[3] decrementa o dígito ativo (wrap 0→9) | Lógica combinacional no FSM |
| RF-05 | KEY[2] incrementa o dígito ativo (wrap 9→0) | Lógica combinacional no FSM |
| RF-06 | KEY[1] confirma e avança; no 4º dígito inicia verificação | Transições ST_EDIT_* → ST_CHECK |
| RF-07 | KEY[0] realiza reset global em qualquer estado | `rst_n` no top-level |
| RF-08 | Cada pressionamento gera exatamente uma ação | Módulo `debounce` |
| RF-09 | Senha correta → todos LEDG por 5 s | Estado ST_SUCCESS + timer |
| RF-10 | Senha incorreta → todos LEDR por 3 s | Estado ST_FAIL + timer |
| RF-11 | Retorno automático ao estado inicial após feedback | Lógica de timeout nos estados de feedback |

## Requisitos Não-Funcionais

| ID | Requisito | Como foi atendido |
|----|-----------|-------------------|
| RNF-01 | Código sintetizável em Quartus Prime 21.1 | Construtos SystemVerilog suportados |
| RNF-02 | Dispositivo EP4CE115F29C7 | Configurado no arquivo `.qsf` |
| RNF-03 | Pinagem oficial da DE2-115 | Atribuições no `.qsf` |
| RNF-04 | Clock de 50 MHz | Constraints no `.sdc` |
| RNF-05 | Modularização e legibilidade | Separação em 4 módulos RTL |
| RNF-06 | Ausência de latches e múltiplos drivers | Estilo `always_ff` / `always_comb` + defaults |
