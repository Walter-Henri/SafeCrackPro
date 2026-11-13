# Módulo: bcd_to_7segment

**Arquivo:** `rtl/bcd_to_7segment.sv`  
**Tipo:** Combinacional  
**Sintetizável:** Sim  

## Responsabilidade

Converter um valor BCD (0–9) no padrão de 7 segmentos compatível com os displays da DE2-115.

## Polaridade e ordenação

- Displays são **common-anode / active-low** (0 acende o segmento).
- Vetor de saída: `seg[6:0] = {g, f, e, d, c, b, a}`.

## Tabela de verdade implementada

| BCD | seg[6:0] (gfedcba) | Símbolo |
|-----|--------------------|---------|
| 0   | 1000000            | 0       |
| 1   | 1111001            | 1       |
| 2   | 0100100            | 2       |
| 3   | 0110000            | 3       |
| 4   | 0011001            | 4       |
| 5   | 0010010            | 5       |
| 6   | 0000010            | 6       |
| 7   | 1111000            | 7       |
| 8   | 0000000            | 8       |
| 9   | 0010000            | 9       |
| outros | 1111111         | blank   |

Estes padrões foram validados contra exemplos oficiais da Terasic/Altera para a DE2-115.
