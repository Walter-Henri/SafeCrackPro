# INC-002 – HEX4 exibia 0–3 em vez de 1–4

| Campo | Valor |
|-------|-------|
| ID | INC-002 |
| Data de identificação | 2026-11-13 |
| Severidade | Média (desvio da especificação orientada pelo monitor) |
| Status | Corrigido |

## Descrição

O display HEX4 (indicador do dígito ativo) mostrava os valores 0, 1, 2 e 3.

## Comportamento esperado (orientação do monitor)

HEX4 deve indicar o dígito ativo como **1, 2, 3 e 4**.

> “Quando ele diz que os displays voltam a exibir 0 ele está falando sobre os displays dos 4 dígitos. O display adicional que indica o dígito atual começa do 1 e vai até 4 em todos os casos.”

## Comportamento observado

HEX4 iniciava em 0 e ia até 3.

## Causa

O índice interno `active_idx` (0–3) era enviado diretamente ao decoder de 7 segmentos.

## Solução aplicada

No top-level, o valor enviado ao decoder de HEX4 passou a ser `active_idx + 1`:

```systemverilog
bcd_to_7segment u_hex4 (.bcd({2'b00, active_idx} + 4'd1), .seg(HEX4));
```

## Arquivos modificados

- `rtl/safecrack_pro_top.sv`
- `sim/tb_safecrack_pro.sv`
- Documentação relacionada (requirements, pinout, FSM, módulos, README)

## Testes de regressão

- Testbench atualizado para esperar 1→2→3→4.
- Reset deve fazer HEX4 voltar a **1**.
