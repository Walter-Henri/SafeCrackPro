// =============================================================================
// Módulo     : debounce
// Projeto    : SafeCrack Pro – CIN0130 Sistemas Digitais
// Descrição  : Elimina bouncing de push-button e gera um pulso de 1 ciclo
//              por pressionamento, independente do tempo de segurar o botão.
//
// Comportamento:
//   1. Sincroniza btn_n (ativo-baixo) com 2 FFs para evitar metaestabilidade.
//   2. Um contador de DEBOUNCE_CYCLES ciclos valida o estado estável.
//   3. Uma detecção de borda de subida sobre o sinal estável gera btn_pulse
//      com exatamente 1 ciclo de duração.
// =============================================================================
module debounce #(
    parameter int DEBOUNCE_CYCLES = 250_000  // ≈ 5 ms @ 50 MHz
)(
    input  logic clk,
    input  logic rst_n,
    input  logic btn_n,       // entrada ativo-baixo do push-button
    output logic btn_pulse    // pulso de 1 ciclo por pressionamento válido
);

   
    // Sincronizador de 2 estágios
   
    logic btn_sync_0, btn_sync_1;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            btn_sync_0 <= 1'b1;
            btn_sync_1 <= 1'b1;
        end else begin
            btn_sync_0 <= btn_n;
            btn_sync_1 <= btn_sync_0;
        end
    end

    // Converte para nível ativo-alto após a sincronização
    logic btn_raw;
    assign btn_raw = ~btn_sync_1;

   
    // Contador de debounce
    // O contador reinicia sempre que o sinal muda; ao atingir DEBOUNCE_CYCLES,
    // confirma o estado estável.
   
    logic [$clog2(DEBOUNCE_CYCLES+1)-1:0] cnt;
    logic btn_stable;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt        <= '0;
            btn_stable <= 1'b0;
        end else begin
            if (btn_raw != btn_stable) begin
                if (cnt == DEBOUNCE_CYCLES - 1) begin
                    btn_stable <= btn_raw; // confirma novo estado
                    cnt        <= '0;
                end else begin
                    cnt <= cnt + 1'b1;
                end
            end else begin
                cnt <= '0; // sinal mudou antes do timeout: reinicia contagem
            end
        end
    end

   
    // Detector de borda de subida
    // Gera btn_pulse por exatamente 1 ciclo no primeiro ciclo estável.
    // Segurar o botão não repete a ação.
   
    logic btn_stable_d;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) btn_stable_d <= 1'b0;
        else        btn_stable_d <= btn_stable;
    end

    assign btn_pulse = btn_stable & ~btn_stable_d;  // 1 ciclo apenas

endmodule
