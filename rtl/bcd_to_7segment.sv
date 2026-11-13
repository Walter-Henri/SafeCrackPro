// =============================================================================
// Module      : bcd_to_7segment
// Project     : SafeCrack Pro – CIN0130 Sistemas Digitais
// Description : BCD (0-9) to 7-segment decoder for Terasic DE2-115
//
// The DE2-115 7-segment displays are common-anode and active-LOW
// (logic 0 turns a segment ON).
//
// Segment mapping (confirmed with official Terasic / Altera examples):
//   HEX[0] → segment a
//   HEX[1] → segment b
//   HEX[2] → segment c
//   HEX[3] → segment d
//   HEX[4] → segment e
//   HEX[5] → segment f
//   HEX[6] → segment g
//
// Output vector ordering: seg[6:0] = {g, f, e, d, c, b, a}
// =============================================================================
module bcd_to_7segment (
    input  logic [3:0] bcd,   // Binary-coded decimal value (0-9)
    output logic [6:0] seg    // {g,f,e,d,c,b,a} – active low
);

    always_comb begin
        unique case (bcd)
            //          gfedcba
            4'd0: seg = 7'b1000000; // 0
            4'd1: seg = 7'b1111001; // 1
            4'd2: seg = 7'b0100100; // 2
            4'd3: seg = 7'b0110000; // 3
            4'd4: seg = 7'b0011001; // 4
            4'd5: seg = 7'b0010010; // 5
            4'd6: seg = 7'b0000010; // 6
            4'd7: seg = 7'b1111000; // 7
            4'd8: seg = 7'b0000000; // 8
            4'd9: seg = 7'b0010000; // 9
            default:
                  seg = 7'b1111111; // blank (all segments off)
        endcase
    end

endmodule
