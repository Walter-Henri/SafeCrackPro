// =============================================================================
// Module      : safecrack_fsm
// Project     : SafeCrack Pro – CIN0130 Sistemas Digitais
// Description : Main finite-state machine of SafeCrack Pro
//
// This module evolves the original classroom SafeCrack FSM
// (GitLab snippet 4909655). Instead of a fixed button sequence, the user
// composes a 4-digit password (0-9) using the push-buttons:
//
//   KEY[3] → decrement active digit (wrap-around 0↔9)
//   KEY[2] → increment active digit (wrap-around 0↔9)
//   KEY[1] → confirm digit and advance (or verify on last digit)
//   KEY[0] → global reset (handled outside this module)
//
// After the fourth confirmation the password is compared with the parameters
// PASSWORD_D*. Feedback is given through LEDG (success, 5 s) or LEDR
// (failure, 3 s). The system then returns automatically to the initial state.
//
// Architecture: classic three-process FSM
//   - Sequential state / data registers
//   - Combinational next-state + datapath logic
//   - Combinational output logic
// =============================================================================
module safecrack_fsm #(
    parameter logic [3:0] PASSWORD_D0 = 4'd1,   // digit shown on HEX3
    parameter logic [3:0] PASSWORD_D1 = 4'd2,   // digit shown on HEX2
    parameter logic [3:0] PASSWORD_D2 = 4'd3,   // digit shown on HEX1
    parameter logic [3:0] PASSWORD_D3 = 4'd4,   // digit shown on HEX0
    parameter int SUCCESS_CYCLES = 250_000_000, // 5 s @ 50 MHz
    parameter int FAIL_CYCLES    = 150_000_000  // 3 s @ 50 MHz
)(
    input  logic       clk,
    input  logic       rst_n,           // active-low synchronous reset
    input  logic       key3_pulse,      // clean pulse: decrement
    input  logic       key2_pulse,      // clean pulse: increment
    input  logic       key1_pulse,      // clean pulse: confirm / next

    output logic [3:0] digit0,          // value for HEX3 (MSB)
    output logic [3:0] digit1,          // value for HEX2
    output logic [3:0] digit2,          // value for HEX1
    output logic [3:0] digit3,          // value for HEX0 (LSB)
    output logic [1:0] active_idx,      // 0=HEX3 … 3=HEX0  (display shows 1-4)
    output logic       ledg_on,         // assert all green LEDs
    output logic       ledr_on          // assert all red LEDs
);

    // -------------------------------------------------------------------------
    // State encoding
    // Sequential numeric values keep the code simple and readable.
    // -------------------------------------------------------------------------
    typedef enum logic [3:0] {
        ST_EDIT_0  = 4'd0,  // editing first digit  (HEX3)
        ST_EDIT_1  = 4'd1,  // editing second digit (HEX2)
        ST_EDIT_2  = 4'd2,  // editing third digit  (HEX1)
        ST_EDIT_3  = 4'd3,  // editing fourth digit (HEX0)
        ST_CHECK   = 4'd4,  // one-cycle password comparison
        ST_SUCCESS = 4'd5,  // green LEDs for SUCCESS_CYCLES
        ST_FAIL    = 4'd6   // red LEDs for FAIL_CYCLES
    } state_t;

    state_t state, next_state;

    // Digit registers and next values
    logic [3:0] d0, d1, d2, d3;
    logic [3:0] next_d0, next_d1, next_d2, next_d3;
    logic [1:0] idx, next_idx;

    // Feedback timer
    logic [$clog2(SUCCESS_CYCLES+1)-1:0] timer, next_timer;

    // -------------------------------------------------------------------------
    // Sequential logic (registers)
    // -------------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state  <= ST_EDIT_0;
            d0     <= 4'd0;
            d1     <= 4'd0;
            d2     <= 4'd0;
            d3     <= 4'd0;
            idx    <= 2'd0;
            timer  <= '0;
        end else begin
            state  <= next_state;
            d0     <= next_d0;
            d1     <= next_d1;
            d2     <= next_d2;
            d3     <= next_d3;
            idx    <= next_idx;
            timer  <= next_timer;
        end
    end

    // -------------------------------------------------------------------------
    // Combinational next-state and datapath logic
    // -------------------------------------------------------------------------
    always_comb begin
        // Default assignments (hold current values)
        next_state = state;
        next_d0    = d0;
        next_d1    = d1;
        next_d2    = d2;
        next_d3    = d3;
        next_idx   = idx;
        next_timer = timer;

        unique case (state)

            // -----------------------------------------------------------------
            // Digit-editing states
            // KEY[2] increments, KEY[3] decrements the active digit.
            // KEY[1] confirms and advances (or goes to ST_CHECK on last digit).
            // -----------------------------------------------------------------
            ST_EDIT_0, ST_EDIT_1, ST_EDIT_2, ST_EDIT_3: begin
                // Increment (KEY2)
                if (key2_pulse) begin
                    unique case (idx)
                        2'd0: next_d0 = (d0 == 4'd9) ? 4'd0 : d0 + 4'd1;
                        2'd1: next_d1 = (d1 == 4'd9) ? 4'd0 : d1 + 4'd1;
                        2'd2: next_d2 = (d2 == 4'd9) ? 4'd0 : d2 + 4'd1;
                        2'd3: next_d3 = (d3 == 4'd9) ? 4'd0 : d3 + 4'd1;
                    endcase
                end
                // Decrement (KEY3)
                if (key3_pulse) begin
                    unique case (idx)
                        2'd0: next_d0 = (d0 == 4'd0) ? 4'd9 : d0 - 4'd1;
                        2'd1: next_d1 = (d1 == 4'd0) ? 4'd9 : d1 - 4'd1;
                        2'd2: next_d2 = (d2 == 4'd0) ? 4'd9 : d2 - 4'd1;
                        2'd3: next_d3 = (d3 == 4'd0) ? 4'd9 : d3 - 4'd1;
                    endcase
                end
                // Confirm / advance (KEY1)
                if (key1_pulse) begin
                    if (idx == 2'd3) begin
                        next_state = ST_CHECK;
                    end else begin
                        next_idx   = idx + 2'd1;
                        next_state = state_t'(unsigned'(state) + 1);
                    end
                end
            end

            // -----------------------------------------------------------------
            // Password verification (single cycle)
            // -----------------------------------------------------------------
            ST_CHECK: begin
                if ( (d0 == PASSWORD_D0) &&
                     (d1 == PASSWORD_D1) &&
                     (d2 == PASSWORD_D2) &&
                     (d3 == PASSWORD_D3) ) begin
                    next_state = ST_SUCCESS;
                    next_timer = SUCCESS_CYCLES;
                end else begin
                    next_state = ST_FAIL;
                    next_timer = FAIL_CYCLES;
                end
            end

            // -----------------------------------------------------------------
            // Success feedback – green LEDs for 5 seconds
            // -----------------------------------------------------------------
            ST_SUCCESS: begin
                if (timer > 0) begin
                    next_timer = timer - 1'b1;
                end else begin
                    // Auto-return to initial state
                    next_state = ST_EDIT_0;
                    next_d0    = 4'd0;
                    next_d1    = 4'd0;
                    next_d2    = 4'd0;
                    next_d3    = 4'd0;
                    next_idx   = 2'd0;
                    next_timer = '0;
                end
            end

            // -----------------------------------------------------------------
            // Failure feedback – red LEDs for 3 seconds
            // -----------------------------------------------------------------
            ST_FAIL: begin
                if (timer > 0) begin
                    next_timer = timer - 1'b1;
                end else begin
                    next_state = ST_EDIT_0;
                    next_d0    = 4'd0;
                    next_d1    = 4'd0;
                    next_d2    = 4'd0;
                    next_d3    = 4'd0;
                    next_idx   = 2'd0;
                    next_timer = '0;
                end
            end

            default: next_state = ST_EDIT_0;
        endcase
    end

    // -------------------------------------------------------------------------
    // Output logic
    // -------------------------------------------------------------------------
    assign digit0     = d0;
    assign digit1     = d1;
    assign digit2     = d2;
    assign digit3     = d3;
    assign active_idx = idx;
    assign ledg_on    = (state == ST_SUCCESS);
    assign ledr_on    = (state == ST_FAIL);

endmodule
