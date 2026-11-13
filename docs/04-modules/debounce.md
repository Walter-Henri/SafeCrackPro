# Módulo: debounce

**Arquivo:** `rtl/debounce.sv`  
**Tipo:** Utilitário de entrada  
**Sintetizável:** Sim  

## Responsabilidade

Transformar o sinal assíncrono e ruidoso de um push-button ativo-baixo em um pulso limpo de um único ciclo de clock.

## Estágios internos

1. **Sincronizador de 2 FFs** – proteção contra metastabilidade.
2. **Contador de debounce** – só atualiza o valor estável após `DEBOUNCE_CYCLES` ciclos consecutivos iguais.
3. **Detector de borda de subida** – gera `btn_pulse` por um ciclo quando o sinal estável passa de 0 para 1 (após inversão).

## Parâmetro

| Parâmetro | Default | Uso |
|-----------|---------|-----|
| `DEBOUNCE_CYCLES` | 250_000 | ≈ 5 ms @ 50 MHz (produção) / valor reduzido em simulação |

## Garantia crítica

Manter o botão pressionado **não** gera múltiplos pulsos. Cada pressionamento físico resulta em exatamente uma ação no FSM.
