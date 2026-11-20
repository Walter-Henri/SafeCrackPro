// =============================================================================
// Módulo     : safecrack_pro_top
// Projeto    : SafeCrack Pro – CIN0130 Sistemas Digitais
// Descrição  : Entidade top-level para a placa Terasic DE2-115
//
// Dispositivo : Intel / Altera Cyclone IV E – EP4CE115F29C7
// Clock       : 50 MHz (CLOCK_50)
//
// Instancia:
//   - Lógica de power-on reset e reset global via KEY[0]
//   - Debounce + detectores de borda para KEY[1..3]
//   - FSM principal do SafeCrack
//   - Cinco decodificadores BCD para 7 segmentos (HEX0–HEX4)
//   - Drivers dos LEDs (todos verdes / todos vermelhos)
//
// A senha é configurável via parâmetros abaixo (padrão = 1234).
// =============================================================================
module safecrack_pro_top #(
    // Senha configurável (alterar e recompilar)
    parameter logic [3:0] PASSWORD_D0 = 4'd1, // HEX3 – dígito mais significativo
    parameter logic [3:0] PASSWORD_D1 = 4'd2, // HEX2
    parameter logic [3:0] PASSWORD_D2 = 4'd3, // HEX1
    parameter logic [3:0] PASSWORD_D3 = 4'd4, // HEX0 – dígito menos significativo

    // Parâmetros de temporização (clock 50 MHz)
    parameter int DEBOUNCE_CYCLES = 250_000,     // ≈ 5 ms
    parameter int SUCCESS_CYCLES  = 250_000_000, // 5 s
    parameter int FAIL_CYCLES     = 150_000_000  // 3 s
)(
    // Clock
    input  logic        CLOCK_50,

    // Push-buttons (ativo-baixo)
    input  logic [3:0]  KEY,

    // Displays de 7 segmentos (ativo-baixo)
    output logic [6:0]  HEX0,   // dígito 3 da senha (LSB)
    output logic [6:0]  HEX1,   // dígito 2 da senha
    output logic [6:0]  HEX2,   // dígito 1 da senha
    output logic [6:0]  HEX3,   // dígito 0 da senha (MSB)
    output logic [6:0]  HEX4,   // indicador do dígito ativo (exibe 1–4)

    // LEDs
    output logic [8:0]  LEDG,   // verdes – sucesso
    output logic [17:0] LEDR    // vermelhos – falha
);

   
    // Power-on reset (contador simples, ~16 ciclos)
   
    logic [3:0] por_cnt;
    logic       por_done;

    always_ff @(posedge CLOCK_50) begin
        if (por_cnt != 4'hF)
            por_cnt <= por_cnt + 1'b1;
    end
    assign por_done = (por_cnt == 4'hF);

   
    // Reset global via KEY[0] (ativo enquanto pressionado)
    // Sincronizador de 2 FFs
   
    logic key0_meta, key0_sync;

    always_ff @(posedge CLOCK_50) begin
        key0_meta <= KEY[0];
        key0_sync <= key0_meta;
    end

    // rst_n é asserted (baixo) durante o power-on ou enquanto KEY[0] está pressionado
    logic rst_n;
    assign rst_n = por_done & key0_sync;

   
    // Debounce + detecção de borda para KEY[1], KEY[2] e KEY[3]
   
    logic key1_pulse, key2_pulse, key3_pulse;

    debounce #(.DEBOUNCE_CYCLES(DEBOUNCE_CYCLES)) u_deb_key1 (
        .clk       (CLOCK_50),
        .rst_n     (rst_n),
        .btn_n     (KEY[1]),
        .btn_pulse (key1_pulse)
    );

    debounce #(.DEBOUNCE_CYCLES(DEBOUNCE_CYCLES)) u_deb_key2 (
        .clk       (CLOCK_50),
        .rst_n     (rst_n),
        .btn_n     (KEY[2]),
        .btn_pulse (key2_pulse)
    );

    debounce #(.DEBOUNCE_CYCLES(DEBOUNCE_CYCLES)) u_deb_key3 (
        .clk       (CLOCK_50),
        .rst_n     (rst_n),
        .btn_n     (KEY[3]),
        .btn_pulse (key3_pulse)
    );

   
    // FSM principal
   
    logic [3:0] digit0, digit1, digit2, digit3;
    logic [1:0] active_idx;
    logic       ledg_on, ledr_on;

    safecrack_fsm #(
        .PASSWORD_D0    (PASSWORD_D0),
        .PASSWORD_D1    (PASSWORD_D1),
        .PASSWORD_D2    (PASSWORD_D2),
        .PASSWORD_D3    (PASSWORD_D3),
        .SUCCESS_CYCLES (SUCCESS_CYCLES),
        .FAIL_CYCLES    (FAIL_CYCLES)
    ) u_fsm (
        .clk        (CLOCK_50),
        .rst_n      (rst_n),
        .key3_pulse (key3_pulse),
        .key2_pulse (key2_pulse),
        .key1_pulse (key1_pulse),
        .digit0     (digit0),
        .digit1     (digit1),
        .digit2     (digit2),
        .digit3     (digit3),
        .active_idx (active_idx),
        .ledg_on    (ledg_on),
        .ledr_on    (ledr_on)
    );

   
    // Decodificadores de 7 segmentos
   
    bcd_to_7segment u_hex3 (.bcd(digit0),              .seg(HEX3)); // MSB
    bcd_to_7segment u_hex2 (.bcd(digit1),              .seg(HEX2));
    bcd_to_7segment u_hex1 (.bcd(digit2),              .seg(HEX1));
    bcd_to_7segment u_hex0 (.bcd(digit3),              .seg(HEX0)); // LSB
    bcd_to_7segment u_hex4 (.bcd({2'b00, active_idx} + 4'd1), .seg(HEX4)); // exibe 1-4

   
    // Drivers dos LEDs – todos os LEDs da mesma cor acendem juntos
   
    assign LEDG = {9{ledg_on}};
    assign LEDR = {18{ledr_on}};

endmodule
