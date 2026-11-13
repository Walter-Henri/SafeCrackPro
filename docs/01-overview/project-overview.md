# Visão Geral do Projeto

## Identificação

| Campo | Valor |
|-------|-------|
| Nome | SafeCrack Pro |
| Disciplina | CIN0130 – Sistemas Digitais |
| Professor | Victor Medeiros |
| Semestre | 2026.1 |
| Plataforma | Terasic DE2-115 |
| FPGA | Intel/Altera Cyclone IV E EP4CE115F29C7 |
| Linguagem | SystemVerilog |
| Ferramenta de síntese | Quartus Prime 21.1 |

## Objetivo

Evoluir a FSM SafeCrack apresentada em sala de aula, substituindo a entrada sequencial de botões por um mecanismo de composição de senha de quatro dígitos. O usuário navega cada dígito de 0 a 9 utilizando os push-buttons da DE2-115, confirma dígito a dígito e, ao final, o sistema verifica a senha e fornece feedback visual por meio dos LEDs.

## Escopo

### Incluído
- Entrada de senha de 4 dígitos (0–9) via KEY[3:0]
- Exibição simultânea nos displays HEX3–HEX0
- Indicação do dígito ativo em HEX4
- Debounce e detecção de borda nos botões
- Verificação da senha e feedback por LEDG (sucesso) / LEDR (falha)
- Temporização de 5 s (sucesso) e 3 s (falha)
- Reset global via KEY[0]
- Projeto Quartus completo e testbench de validação

### Não incluído
- Alteração da senha em tempo de execução
- Uso de displays HEX5–HEX7
- Interface com LCD ou outros periféricos da placa
- Comunicação serial ou Ethernet

## Referências de base

- FSM original da disciplina: GitLab snippet 4909655
- Código auxiliar (decoder): GitLab snippet 6002284
- Manual e pinout oficial da Terasic DE2-115
