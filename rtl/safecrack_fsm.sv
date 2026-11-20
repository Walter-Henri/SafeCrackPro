// =============================================================================
// Módulo     : safecrack_fsm
// Projeto    : SafeCrack Pro – CIN0130 Sistemas Digitais
// Descrição  : Máquina de estados principal do SafeCrack Pro
//
// Evolução da FSM original desenvolvida em sala (snippet GitLab 4909655).
// Em vez de uma sequência fixa de botões, o usuário compõe uma senha de
// 4 dígitos (0–9) usando os push-buttons:
//
//   KEY[3] → decrementa o dígito ativo (wrap-around 0↔9)
//   KEY[2] → incrementa o dígito ativo (wrap-around 0↔9)
//   KEY[1] → confirma o dígito e avança (ou verifica no último dígito)
//   KEY[0] → reset global (tratado fora deste módulo)
//
// Após a quarta confirmação, a senha é comparada com os parâmetros
// PASSWORD_D*. O resultado é indicado via LEDG (sucesso, 5 s) ou LEDR
// (falha, 3 s), retornando automaticamente ao estado inicial.
//
// Arquitetura: FSM clássica de três processos
//   - Registradores sequenciais de estado e dados
//   - Lógica combinacional de próximo estado e datapath
//   - Lógica combinacional de saída
// =============================================================================
module safecrack_fsm #(
    parameter logic [3:0] PASSWORD_D0 = 4'd1,   // dígito exibido em HEX3
    parameter logic [3:0] PASSWORD_D1 = 4'd2,   // dígito exibido em HEX2
    parameter logic [3:0] PASSWORD_D2 = 4'd3,   // dígito exibido em HEX1
    parameter logic [3:0] PASSWORD_D3 = 4'd4,   // dígito exibido em HEX0
    parameter int SUCCESS_CYCLES = 250_000_000, // 5 s @ 50 MHz
    parameter int FAIL_CYCLES    = 150_000_000  // 3 s @ 50 MHz
)(
    input  logic       clk,
    input  logic       rst_n,           // reset síncrono ativo-baixo
    input  logic       key3_pulse,      // pulso limpo: decrementa
    input  logic       key2_pulse,      // pulso limpo: incrementa
    input  logic       key1_pulse,      // pulso limpo: confirma / avança

    output logic [3:0] digit0,          // valor para HEX3 (MSB)
    output logic [3:0] digit1,          // valor para HEX2
    output logic [3:0] digit2,          // valor para HEX1
    output logic [3:0] digit3,          // valor para HEX0 (LSB)
    output logic [1:0] active_idx,      // 0=HEX3 … 3=HEX0 (display mostra 1–4)
    output logic       ledg_on,         // aciona todos os LEDs verdes
    output logic       ledr_on          // aciona todos os LEDs vermelhos
);

   
    // Codificação dos estados
    // Valores numéricos sequenciais mantêm o código simples e legível.
   
    typedef enum logic [3:0] {
        ST_EDIT_0  = 4'd0,  // edição do 1º dígito (HEX3)
        ST_EDIT_1  = 4'd1,  // edição do 2º dígito (HEX2)
        ST_EDIT_2  = 4'd2,  // edição do 3º dígito (HEX1)
        ST_EDIT_3  = 4'd3,  // edição do 4º dígito (HEX0)
        ST_CHECK   = 4'd4,  // comparação da senha (1 ciclo)
        ST_SUCCESS = 4'd5,  // LEDs verdes por SUCCESS_CYCLES
        ST_FAIL    = 4'd6   // LEDs vermelhos por FAIL_CYCLES
    } state_t;

    state_t state, next_state;

    // Registradores dos dígitos e próximos valores
    logic [3:0] d0, d1, d2, d3;
    logic [3:0] next_d0, next_d1, next_d2, next_d3;
    logic [1:0] idx, next_idx;

    // Timer de feedback
    logic [$clog2(SUCCESS_CYCLES+1)-1:0] timer, next_timer;

   
    // Lógica sequencial (registradores)
   
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

   
    // Lógica combinacional de próximo estado e datapath
   
    always_comb begin
        // Atribuições padrão (mantém valores atuais)
        next_state = state;
        next_d0    = d0;
        next_d1    = d1;
        next_d2    = d2;
        next_d3    = d3;
        next_idx   = idx;
        next_timer = timer;

        unique case (state)

            // -----------------------------------------------------------------
            // Estados de edição de dígito
            // KEY[2] incrementa, KEY[3] decrementa o dígito ativo.
            // KEY[1] confirma e avança (ou vai para ST_CHECK no último dígito).
            // -----------------------------------------------------------------
            ST_EDIT_0, ST_EDIT_1, ST_EDIT_2, ST_EDIT_3: begin
                // Incrementa (KEY2)
                if (key2_pulse) begin
                    unique case (idx)
                        2'd0: next_d0 = (d0 == 4'd9) ? 4'd0 : d0 + 4'd1;
                        2'd1: next_d1 = (d1 == 4'd9) ? 4'd0 : d1 + 4'd1;
                        2'd2: next_d2 = (d2 == 4'd9) ? 4'd0 : d2 + 4'd1;
                        2'd3: next_d3 = (d3 == 4'd9) ? 4'd0 : d3 + 4'd1;
                    endcase
                end
                // Decrementa (KEY3)
                if (key3_pulse) begin
                    unique case (idx)
                        2'd0: next_d0 = (d0 == 4'd0) ? 4'd9 : d0 - 4'd1;
                        2'd1: next_d1 = (d1 == 4'd0) ? 4'd9 : d1 - 4'd1;
                        2'd2: next_d2 = (d2 == 4'd0) ? 4'd9 : d2 - 4'd1;
                        2'd3: next_d3 = (d3 == 4'd0) ? 4'd9 : d3 - 4'd1;
                    endcase
                end
                // Confirma / avança (KEY1)
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
            // Verificação da senha (ciclo único)
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
            // Feedback de sucesso – LEDs verdes por 5 segundos
            // -----------------------------------------------------------------
            ST_SUCCESS: begin
                if (timer > 0) begin
                    next_timer = timer - 1'b1;
                end else begin
                    // Retorno automático ao estado inicial
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
            // Feedback de falha – LEDs vermelhos por 3 segundos
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

   
    // Lógica de saída
   
    assign digit0     = d0;
    assign digit1     = d1;
    assign digit2     = d2;
    assign digit3     = d3;
    assign active_idx = idx;
    assign ledg_on    = (state == ST_SUCCESS);
    assign ledr_on    = (state == ST_FAIL);

endmodule
