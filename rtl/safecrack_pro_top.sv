// =============================================================================
// Module      : safecrack_pro_top
// Project     : SafeCrack Pro – CIN0130 Sistemas Digitais
// Description : Top-level entity for the Terasic DE2-115 board
//
// Device      : Intel / Altera Cyclone IV E – EP4CE115F29C7
// Clock       : 50 MHz (CLOCK_50)
//
// This module instantiates:
//   - Power-on reset and KEY[0] global reset logic
//   - Debounce + edge detectors for KEY[1..3]
//   - The main SafeCrack FSM
//   - Five BCD-to-7-segment decoders (HEX0–HEX4)
//   - LED drivers (all green / all red)
//
// Password is configurable via the parameters below (default = 1234).
// =============================================================================
module safecrack_pro_top #(
    // ---- Configurable password (change and recompile) ----
    parameter logic [3:0] PASSWORD_D0 = 4'd1, // HEX3 – most significant digit
    parameter logic [3:0] PASSWORD_D1 = 4'd2, // HEX2
    parameter logic [3:0] PASSWORD_D2 = 4'd3, // HEX1
    parameter logic [3:0] PASSWORD_D3 = 4'd4, // HEX0 – least significant digit

    // ---- Timing parameters (50 MHz clock) ----
    parameter int DEBOUNCE_CYCLES = 250_000,     // ≈ 5 ms
    parameter int SUCCESS_CYCLES  = 250_000_000, // 5 s
    parameter int FAIL_CYCLES     = 150_000_000  // 3 s
)(
    // Clock
    input  logic        CLOCK_50,

    // Push-buttons (active-low)
    input  logic [3:0]  KEY,

    // 7-segment displays (active-low)
    output logic [6:0]  HEX0,   // password digit 3 (LSB)
    output logic [6:0]  HEX1,   // password digit 2
    output logic [6:0]  HEX2,   // password digit 1
    output logic [6:0]  HEX3,   // password digit 0 (MSB)
    output logic [6:0]  HEX4,   // active digit index (0-3)

    // LEDs
    output logic [8:0]  LEDG,   // green – success
    output logic [17:0] LEDR    // red   – failure
);

    // -------------------------------------------------------------------------
    // Power-on reset (simple counter, ~16 cycles)
    // -------------------------------------------------------------------------
    logic [3:0] por_cnt;
    logic       por_done;

    always_ff @(posedge CLOCK_50) begin
        if (por_cnt != 4'hF)
            por_cnt <= por_cnt + 1'b1;
    end
    assign por_done = (por_cnt == 4'hF);

    // -------------------------------------------------------------------------
    // KEY[0] global reset (active while pressed)
    // 2-FF synchronizer
    // -------------------------------------------------------------------------
    logic key0_meta, key0_sync;

    always_ff @(posedge CLOCK_50) begin
        key0_meta <= KEY[0];
        key0_sync <= key0_meta;
    end

    // rst_n is asserted (low) during power-on or while KEY[0] is pressed
    logic rst_n;
    assign rst_n = por_done & key0_sync;

    // -------------------------------------------------------------------------
    // Debounce + edge detection for KEY[1], KEY[2], KEY[3]
    // -------------------------------------------------------------------------
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

    // -------------------------------------------------------------------------
    // Main FSM
    // -------------------------------------------------------------------------
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

    // -------------------------------------------------------------------------
    // 7-segment decoders
    // -------------------------------------------------------------------------
    bcd_to_7segment u_hex3 (.bcd(digit0),              .seg(HEX3)); // MSB
    bcd_to_7segment u_hex2 (.bcd(digit1),              .seg(HEX2));
    bcd_to_7segment u_hex1 (.bcd(digit2),              .seg(HEX1));
    bcd_to_7segment u_hex0 (.bcd(digit3),              .seg(HEX0)); // LSB
    bcd_to_7segment u_hex4 (.bcd({2'b00, active_idx}), .seg(HEX4)); // index

    // -------------------------------------------------------------------------
    // LED drivers – all LEDs of the same colour light together
    // -------------------------------------------------------------------------
    assign LEDG = {9{ledg_on}};
    assign LEDR = {18{ledr_on}};

endmodule
