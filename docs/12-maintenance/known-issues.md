# Known Issues e Limitações

| ID | Descrição | Impacto | Mitigação / Observação |
|----|-----------|---------|------------------------|
| KI-01 | Arquivo `.sof` não pré-gerado | Usuário precisa compilar | Esperado – compilação deve ser feita no Quartus 21.1 local |
| KI-02 | Displays HEX5–HEX7 não utilizados | Nenhum | Fora do escopo da especificação |
| KI-03 | Senha fixa em tempo de compilação | Não é possível alterar em runtime | Decisão de projeto; parâmetros facilitam alteração |
| KI-04 | Debounce de 5 ms | Pode ser longo para alguns botões | Valor configurável via parâmetro |

## Incidentes corrigidos

| ID | Descrição | Status |
|----|-----------|--------|
| [INC-001](../11-incidents/INC-001-7segment-decoder.md) | Padrões incorretos do decoder de 7 segmentos | Corrigido |
| [INC-002](../11-incidents/INC-002-hex4-indexing.md) | HEX4 exibia 0–3 em vez de 1–4 | Corrigido |

Nenhum bug funcional conhecido permanece aberto.
