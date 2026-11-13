# INC-001 – Decodificador de 7 segmentos com padrões incorretos

| Campo | Valor |
|-------|-------|
| ID | INC-001 |
| Data de identificação | 2026-11-13 |
| Severidade | Alta (funcionalidade visível comprometida) |
| Status | Corrigido |

## Descrição

Os números exibidos nos displays HEX0–HEX4 apareciam distorcidos ou ilegíveis.

## Comportamento esperado

Dígitos 0–9 legíveis e corretos conforme padrão da DE2-115.

## Comportamento observado

Segmentos acendendo de forma inconsistente com o valor BCD.

## Causa raiz

O módulo `bcd_to_7segment` utilizava os padrões do arquivo de referência (`bcd_to_7segment_anodo.sv`), que possuem ordenação e polaridade incompatíveis com o mapeamento real dos displays da DE2-115 (`{g,f,e,d,c,b,a}`, active-low).

## Solução aplicada

Substituição da tabela de verdade pelos padrões oficiais utilizados em exemplos da Terasic/Altera:

```
0: 7'b1000000
1: 7'b1111001
2: 7'b0100100
…
9: 7'b0010000
```

## Arquivos modificados

- `rtl/bcd_to_7segment.sv`
- `sim/tb_safecrack_pro.sv` (função de decode auxiliar)

## Testes de regressão

- Verificação visual da tabela de verdade.
- Atualização do testbench para os novos padrões.
