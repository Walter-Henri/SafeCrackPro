// =============================================================================
// Module      : debounce
// Project     : SafeCrack Pro – CIN0130 Sistemas Digitais
// Description : Button synchronizer + debouncer + rising-edge detector
//
// The DE2-115 push-buttons are active-LOW (pressed = 0).
// This module:
//   1. Synchronizes the asynchronous button signal with a 2-FF synchronizer
//   2. Debounces the cleaned signal with a configurable counter
//   3. Generates a single-cycle pulse on a clean press (rising edge after invert)
//
// Parameter DEBOUNCE_CYCLES controls the debounce window.
// Default 250_000 cycles ≈ 5 ms at 50 MHz (adequate for mechanical buttons).
// Reduce this value for faster simulation.
// =============================================================================
module debounce #(
    parameter int DEBOUNCE_CYCLES = 250_000
)(
    input  logic clk,
    input  logic rst_n,      // active-low reset
    input  logic btn_n,      // active-low button from KEY[]
    output logic btn_pulse   // single-cycle active-high pulse on clean press
);

    // -------------------------------------------------------------------------
    // 2-FF synchronizer (metastability protection)
    // -------------------------------------------------------------------------
    logic btn_sync_0, btn_sync_1;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            btn_sync_0 <= 1'b1;   // released (active-low idle)
            btn_sync_1 <= 1'b1;
        end else begin
            btn_sync_0 <= btn_n;
            btn_sync_1 <= btn_sync_0;
        end
    end

    // Convert to active-high
    logic btn_raw;
    assign btn_raw = ~btn_sync_1;

    // -------------------------------------------------------------------------
    // Debounce counter
    // -------------------------------------------------------------------------
    logic [$clog2(DEBOUNCE_CYCLES+1)-1:0] cnt;
    logic btn_stable;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt        <= '0;
            btn_stable <= 1'b0;
        end else begin
            if (btn_raw != btn_stable) begin
                if (cnt >= DEBOUNCE_CYCLES-1) begin
                    btn_stable <= btn_raw;
                    cnt        <= '0;
                end else begin
                    cnt <= cnt + 1'b1;
                end
            end else begin
                cnt <= '0;
            end
        end
    end

    // -------------------------------------------------------------------------
    // Rising-edge detector on the stable signal
    // -------------------------------------------------------------------------
    logic btn_stable_d;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            btn_stable_d <= 1'b0;
        else
            btn_stable_d <= btn_stable;
    end

    assign btn_pulse = btn_stable & ~btn_stable_d;

endmodule
