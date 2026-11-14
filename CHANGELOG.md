# Changelog – SafeCrack Pro

Todas as mudanças relevantes do projeto são documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/).

---

## [1.1.0] – 2026-11-13

### Changed
- **Indicador do dígito ativo (HEX4)** passa a exibir **1, 2, 3 e 4** (em vez de 0, 1, 2 e 3), conforme orientação do monitor da disciplina.
  - Implementação: `active_idx + 1` no top-level (`safecrack_pro_top.sv`).
  - O índice interno do FSM continua 0–3; apenas o valor apresentado no display foi ajustado.
- Documentação atualizada em:
  - `README.md`
  - `docs/01-overview/requirements.md` (RF-03)
  - `docs/04-modules/safecrack_pro_top.md`
  - `docs/04-modules/safecrack_fsm.md`
  - `docs/05-hardware/pinout.md`
  - `docs/06-fsm/state-machine.md`
  - Testbench (`sim/tb_safecrack_pro.sv`)

### Fixed
- Asserções do testbench alinhadas à nova numeração 1–4 do HEX4.

---

## [1.0.1] – 2026-11-13

### Fixed
- **INC-001**: Decodificador de 7 segmentos com padrões incorretos para a DE2-115.
  - Tabela de verdade substituída pelos padrões oficiais (active-low, ordem `{g,f,e,d,c,b,a}`).
  - Arquivo: `rtl/bcd_to_7segment.sv`.

### Documentation
- Criação da estrutura completa de documentação técnica sob `docs/`.
- README principal reescrito (didático + profissional).
- Registro formal do incidente INC-001.

---

## [1.0.0] – 2026-11-12

### Added
- Implementação inicial do SafeCrack Pro a partir das referências da disciplina (snippets 4909655 e 6002284).
- Módulos RTL:
  - `safecrack_pro_top.sv`
  - `safecrack_fsm.sv`
  - `debounce.sv`
  - `bcd_to_7segment.sv`
- Projeto Quartus Prime 21.1 configurado para EP4CE115F29C7.
- Pinagem completa da DE2-115.
- Testbench com cenários principais de validação.
- Senha configurável por parâmetros (padrão: 1234).
- Feedback de sucesso (LEDG, 5 s) e falha (LEDR, 3 s).
- Reset global via KEY[0].
