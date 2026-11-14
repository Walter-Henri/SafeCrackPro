# Histórico de Desenvolvimento

## Marco 1 – Análise das referências
- Clonagem e estudo da FSM original (snippet 4909655).
- Análise do decoder auxiliar (snippet 6002284).
- Identificação do que poderia ser reutilizado e do que precisava ser evoluído.

## Marco 2 – Implementação inicial
- Criação da estrutura modular (top, FSM, debounce, decoder).
- Implementação da nova lógica de entrada dígito a dígito.
- Configuração do projeto Quartus para EP4CE115F29C7.

## Marco 3 – Correção do decoder (INC-001)
- Identificação de padrões incorretos nos displays.
- Substituição pela tabela oficial da DE2-115.
- Atualização do testbench.

## Marco 4 – Profissionalização
- Reescrita dos cabeçalhos e comentários.
- Criação da documentação técnica completa sob `docs/`.
- Alinhamento explícito com os critérios de avaliação da disciplina.

## Decisões técnicas registradas

| Decisão | Contexto | Justificativa |
|---------|----------|---------------|
| Manter estados EDIT_0…3 separados | Clareza didática | Facilita mapeamento 1:1 com o dígito ativo e com a explicação no vídeo |
| Timer dentro do FSM | Simplicidade | Evita módulo extra para uma contagem linear |
| Debounce parametrizável | Simulação vs hardware | Permite reduzir o tempo em testbench sem alterar a lógica de produção |
| Senha como parâmetros | Flexibilidade | Permite alterar a senha sem modificar o corpo do código |

## Marco 5 – Ajuste do indicador HEX4 (1–4)

- Orientação do monitor: o display adicional deve mostrar **1 a 4**, não 0 a 3.
- Alteração pontual no top-level (`active_idx + 1`).
- Documentação e testbench sincronizados (INC-002).
