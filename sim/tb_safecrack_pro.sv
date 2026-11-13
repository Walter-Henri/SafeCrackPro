// ============================================================================
// Testbench: tb_safecrack_pro
// Validates SafeCrack Pro FSM, buttons, timers, displays and LEDs
// Uses reduced cycle counts for fast simulation
// ============================================================================
`timescale 1ns/1ps

module tb_safecrack_pro;

    // Reduced parameters for simulation speed
    localparam int DEBOUNCE_CYCLES = 5;
    localparam int SUCCESS_CYCLES  = 20;
    localparam int FAIL_CYCLES     = 12;
    localparam logic [3:0] PWD0 = 4'd1;
    localparam logic [3:0] PWD1 = 4'd2;
    localparam logic [3:0] PWD2 = 4'd3;
    localparam logic [3:0] PWD3 = 4'd4;

    logic        clk;
    logic [3:0]  KEY;
    logic [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4;
    logic [8:0]  LEDG;
    logic [17:0] LEDR;

    // DUT
    safecrack_pro_top #(
        .PASSWORD_D0   (PWD0),
        .PASSWORD_D1   (PWD1),
        .PASSWORD_D2   (PWD2),
        .PASSWORD_D3   (PWD3),
        .DEBOUNCE_CYCLES(DEBOUNCE_CYCLES),
        .SUCCESS_CYCLES (SUCCESS_CYCLES),
        .FAIL_CYCLES    (FAIL_CYCLES)
    ) dut (
        .CLOCK_50 (clk),
        .KEY      (KEY),
        .HEX0     (HEX0),
        .HEX1     (HEX1),
        .HEX2     (HEX2),
        .HEX3     (HEX3),
        .HEX4     (HEX4),
        .LEDG     (LEDG),
        .LEDR     (LEDR)
    );

    // Clock 50 MHz -> 20 ns period
    initial clk = 0;
    always #10 clk = ~clk;

    // Helper: press a key for a short time (generates one pulse after debounce)
    task automatic press_key(input int k);
        begin
            KEY[k] = 1'b0;                 // press (active low)
            repeat (DEBOUNCE_CYCLES + 3) @(posedge clk);
            KEY[k] = 1'b1;                 // release
            repeat (DEBOUNCE_CYCLES + 3) @(posedge clk);
        end
    endtask

    // Helper: hold key (should produce only one action)
    task automatic hold_key(input int k, input int cycles);
        begin
            KEY[k] = 1'b0;
            repeat (cycles) @(posedge clk);
            KEY[k] = 1'b1;
            repeat (DEBOUNCE_CYCLES + 3) @(posedge clk);
        end
    endtask

    // Decode HEX for debug (matches corrected DE2-115 active-low patterns)
    function automatic string hex_to_str(input logic [6:0] h);
        case (h)
            7'b1000000: return "0";
            7'b1111001: return "1";
            7'b0100100: return "2";
            7'b0110000: return "3";
            7'b0011001: return "4";
            7'b0010010: return "5";
            7'b0000010: return "6";
            7'b1111000: return "7";
            7'b0000000: return "8";
            7'b0010000: return "9";
            default:    return "?";
        endcase
    endfunction

    initial begin
        $display("=== SafeCrack Pro Testbench Start ===");
        KEY = 4'b1111; // all released

        // Wait power-on reset
        repeat (20) @(posedge clk);

        //------------------------------------------------------------------
        // Test 1: Reset / Initial state
        //------------------------------------------------------------------
        $display("\n[T1] Initial state after POR");
        assert (hex_to_str(HEX3) == "0") else $error("HEX3 not 0");
        assert (hex_to_str(HEX2) == "0") else $error("HEX2 not 0");
        assert (hex_to_str(HEX1) == "0") else $error("HEX1 not 0");
        assert (hex_to_str(HEX0) == "0") else $error("HEX0 not 0");
        assert (hex_to_str(HEX4) == "0") else $error("HEX4 (active idx) not 0");
        assert (LEDG == 9'b0) else $error("LEDG not off");
        assert (LEDR == 18'b0) else $error("LEDR not off");
        $display("  PASS: all digits 0, active=0, LEDs off");

        //------------------------------------------------------------------
        // Test 2: Increment (KEY2)
        //------------------------------------------------------------------
        $display("\n[T2] Increment active digit");
        press_key(2); // 0 -> 1
        press_key(2); // 1 -> 2
        press_key(2); // 2 -> 3
        assert (hex_to_str(HEX3) == "3") else $error("Expected 3 on HEX3");
        $display("  PASS: 0->1->2->3");

        //------------------------------------------------------------------
        // Test 3: Decrement (KEY3)
        //------------------------------------------------------------------
        $display("\n[T3] Decrement");
        press_key(3);
        press_key(3);
        assert (hex_to_str(HEX3) == "1") else $error("Expected 1 after two decrements");
        $display("  PASS: 3->2->1");

        //------------------------------------------------------------------
        // Test 4/5: Wrap-around
        //------------------------------------------------------------------
        $display("\n[T4/5] Wrap-around");
        // go to 0 then decrement -> 9
        press_key(3);
        assert (hex_to_str(HEX3) == "0");
        press_key(3);
        assert (hex_to_str(HEX3) == "9") else $error("Wrap 0->9 failed");
        // increment from 9 -> 0
        press_key(2);
        assert (hex_to_str(HEX3) == "0") else $error("Wrap 9->0 failed");
        $display("  PASS: wrap-around both directions");

        //------------------------------------------------------------------
        // Test 6: Confirm digits and advance
        //------------------------------------------------------------------
        $display("\n[T6] Confirm & advance (enter password 1234)");
        // set first digit = 1
        press_key(2); // 0->1
        press_key(1); // confirm -> go to digit 1, HEX4 should be 1
        assert (hex_to_str(HEX4) == "1") else $error("active_idx not 1");
        assert (hex_to_str(HEX3) == "1") else $error("digit0 lost");

        // second digit = 2
        press_key(2); press_key(2); // 0->1->2
        press_key(1);
        assert (hex_to_str(HEX4) == "2");
        assert (hex_to_str(HEX2) == "2");

        // third digit = 3
        press_key(2); press_key(2); press_key(2);
        press_key(1);
        assert (hex_to_str(HEX4) == "3");
        assert (hex_to_str(HEX1) == "3");

        // fourth digit = 4
        press_key(2); press_key(2); press_key(2); press_key(2);
        press_key(1); // confirm last -> should go to CHECK then SUCCESS

        // Wait a few cycles for state machine
        repeat (5) @(posedge clk);

        //------------------------------------------------------------------
        // Test 7: Correct password -> green LEDs
        //------------------------------------------------------------------
        $display("\n[T7] Correct password feedback");
        assert (LEDG == 9'h1FF) else $error("LEDG not all on after correct pwd");
        assert (LEDR == 18'b0)  else $error("LEDR should be off on success");
        $display("  PASS: green LEDs on");

        // Wait for timer to expire
        repeat (SUCCESS_CYCLES + 10) @(posedge clk);
        assert (LEDG == 9'b0) else $error("LEDG did not turn off after timeout");
        assert (hex_to_str(HEX3) == "0") else $error("digits not cleared after success");
        assert (hex_to_str(HEX4) == "0") else $error("active idx not reset");
        $display("  PASS: auto return to initial after success timeout");

        //------------------------------------------------------------------
        // Test 8: Incorrect password
        //------------------------------------------------------------------
        $display("\n[T8] Incorrect password");
        // enter 0000
        press_key(1); // confirm 0
        press_key(1);
        press_key(1);
        press_key(1); // last confirm
        repeat (5) @(posedge clk);
        assert (LEDR != 18'b0) else $error("LEDR should be on after wrong pwd");
        assert (LEDG == 9'b0)  else $error("LEDG should be off on fail");
        $display("  PASS: red LEDs on");

        repeat (FAIL_CYCLES + 10) @(posedge clk);
        assert (LEDR == 18'b0) else $error("LEDR did not turn off");
        assert (hex_to_str(HEX4) == "0");
        $display("  PASS: auto return after fail timeout");

        //------------------------------------------------------------------
        // Test 9: Continuous press produces single action
        //------------------------------------------------------------------
        $display("\n[T9] Hold key (single action)");
        // current digit0 = 0, hold KEY2 for many cycles
        hold_key(2, 50);
        // should have incremented only once
        assert (hex_to_str(HEX3) == "1") else $error("Multiple increments on hold");
        $display("  PASS: only one increment on long press");

        //------------------------------------------------------------------
        // Test 11/12/13: Reset during operation
        //------------------------------------------------------------------
        $display("\n[T11-13] Reset via KEY0");
        press_key(2); // make digit non-zero
        press_key(0); // reset
        repeat (10) @(posedge clk);
        assert (hex_to_str(HEX3) == "0");
        assert (hex_to_str(HEX4) == "0");
        assert (LEDG == 9'b0 && LEDR == 18'b0);
        $display("  PASS: KEY0 resets system");

        $display("\n=== All tests finished ===");
        $finish;
    end

    // Optional waveform dump
    initial begin
        $dumpfile("safecrack_pro.vcd");
        $dumpvars(0, tb_safecrack_pro);
    end

endmodule
