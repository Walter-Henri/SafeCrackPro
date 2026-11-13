# Documentação Técnica – SafeCrack Pro

**Projeto:** SafeCrack Pro  
**Disciplina:** CIN0130 – Sistemas Digitais  
**FPGA:** Terasic DE2-115 (EP4CE115F29C7)  
**Linguagem:** SystemVerilog  
**Ferramenta:** Quartus Prime 21.1  

Esta documentação descreve a arquitetura, implementação, decisões técnicas e evolução do projeto SafeCrack Pro com o rigor esperado de um sistema digital embarcado profissional.

---

## Índice da Documentação

| Seção | Conteúdo |
|-------|----------|
| [01 – Overview](01-overview/) | Visão geral, objetivos e requisitos |
| [02 – Architecture](02-architecture/) | Arquitetura do sistema digital |
| [03 – Structure](03-structure/) | Organização de diretórios e arquivos |
| [04 – Modules](04-modules/) | Documentação individual dos módulos RTL |
| [05 – Hardware](05-hardware/) | Interface com a placa DE2-115 |
| [06 – FSM](06-fsm/) | Máquina de estados detalhada |
| [07 – Flows](07-flows/) | Fluxos operacionais |
| [08 – Diagrams](08-diagrams/) | Diagramas técnicos |
| [09 – Testing](09-testing/) | Estratégia de simulação e validação |
| [10 – Evolution](10-evolution/) | Histórico e decisões técnicas |
| [11 – Incidents](11-incidents/) | Bugs e correções |
| [12 – Maintenance](12-maintenance/) | Known issues e guia operacional |

---

## Navegação Rápida

- [Como compilar e programar](../README.md#7-como-compilar-e-programar-quartus-prime-211)
- [Diagrama de estados](06-fsm/state-machine.md)
- [Pinagem completa](05-hardware/pinout.md)
- [Registro de bugs](11-incidents/)
