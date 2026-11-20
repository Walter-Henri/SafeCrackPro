// =============================================================================
// Módulo     : bcd_to_7segment
// Projeto    : SafeCrack Pro – CIN0130 Sistemas Digitais
// Descrição  : Decodificador BCD (0–9) para display de 7 segmentos
//              cátodo comum da DE2-115 (ativo-baixo).
//
// Mapeamento dos segmentos (padrão Terasic DE2-115):
//   seg[0] = a (topo)
//   seg[1] = b (superior direito)
//   seg[2] = c (inferior direito)
//   seg[3] = d (base)
//   seg[4] = e (inferior esquerdo)
//   seg[5] = f (superior esquerdo)
//   seg[6] = g (meio)
//
// Entradas fora do intervalo 0–9 apagam o display (todos os segmentos off).
// =============================================================================
module bcd_to_7segment (
    input  logic [3:0] bcd,
    output logic [6:0] seg   // ativo-baixo: '0' acende o segmento
);

    always_comb begin
        unique case (bcd)
            //          gfedcba
            4'd0: seg = 7'b1000000;
            4'd1: seg = 7'b1111001;
            4'd2: seg = 7'b0100100;
            4'd3: seg = 7'b0110000;
            4'd4: seg = 7'b0011001;
            4'd5: seg = 7'b0010010;
            4'd6: seg = 7'b0000010;
            4'd7: seg = 7'b1111000;
            4'd8: seg = 7'b0000000;
            4'd9: seg = 7'b0010000;
            default: seg = 7'b1111111; // display apagado
        endcase
    end

endmodule
