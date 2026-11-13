# Estrutura de Diretórios

```
SafeCrackPro/
├── quartus/                    # Projeto Quartus Prime 21.1
│   ├── SafeCrackPro.qpf        # Arquivo de projeto
│   ├── SafeCrackPro.qsf        # Configurações + pin assignments
│   └── SafeCrackPro.sdc        # Constraints de timing
│
├── rtl/                        # Código-fonte SystemVerilog
│   ├── safecrack_pro_top.sv    # Top-level entity
│   ├── safecrack_fsm.sv        # Máquina de estados + datapath
│   ├── debounce.sv             # Sincronizador + debounce + edge detector
│   └── bcd_to_7segment.sv      # Decodificador BCD → 7 segmentos
│
├── sim/                        # Ambiente de simulação
│   └── tb_safecrack_pro.sv     # Testbench SystemVerilog
│
├── docs/                       # Documentação técnica
│   ├── 01-overview/
│   ├── 02-architecture/
│   ├── 03-structure/
│   ├── 04-modules/
│   ├── 05-hardware/
│   ├── 06-fsm/
│   ├── 07-flows/
│   ├── 08-diagrams/
│   ├── 09-testing/
│   ├── 10-evolution/
│   ├── 11-incidents/
│   └── 12-maintenance/
│
├── README.md                   # Ponto de entrada do repositório
└── LICENSE
```

## Responsabilidade de cada diretório

| Diretório | Finalidade |
|-----------|------------|
| `quartus/` | Arquivos necessários para abrir, compilar e programar no Quartus 21.1 |
| `rtl/` | Todo o código sintetizável |
| `sim/` | Código exclusivo de verificação (não sintetizável) |
| `docs/` | Documentação técnica atômica e arquitetural |
