module safecrack_fsm (
    input  logic       clk,
    input  logic       rstn,
    input  logic [2:0] btn,        // entradas dos botões (BTN[2:0])
    output logic       unlocked    // saída: 1 quando o cofre está desbloqueado
);
    // Codificação one-hot
    typedef enum logic [4:0] { 
        S0           = 5'b00001,  // estado inicial
        S1           = 5'b00010,  // BTN = 1 correto
        S2           = 5'b00100,  // BTN = 2 correto
        UNLOCKED_ON  = 5'b01000,  // BTN = 3 correto → cofre aberto
        UNLOCKED_OFF = 5'b10000   // cofre fechando

    } state_t;

    state_t state, next_state;
    logic [2:0] btn_prev, btn_edge, btn_pos;
    logic       any_btn_edge;

    localparam int BLINK_DELAY = 50_000_000;    // 1 segundo a 50 MHz
    logic [$clog2(BLINK_DELAY)-1:0] delay_cnt, next_delay_cnt;
     
    always_comb begin
        btn_pos      = ~btn;              // inverte para nível ativo-alto
        btn_edge     = btn_pos & ~btn_prev; // detecta bordas 0→1
        any_btn_edge = (|btn_edge);       // qualquer borda detectada
    end 
     
    // Lógica sequencial
    always_ff @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            btn_prev  <= 3'b000;
            delay_cnt <= BLINK_DELAY;
            state     <= S0;
        end
        else begin
            btn_prev  <= btn_pos;
            delay_cnt <= next_delay_cnt;
            state     <= next_state;
        end
    end

    // Lógica de transição
    always_comb begin
        // Atribuições padrão
        next_state     = state;
        next_delay_cnt = delay_cnt;

        unique case (state)
            S0: begin
                    if (btn_edge == 3'b001) next_state = S1;      // botão 0: entrada correta
                    else if (any_btn_edge)  next_state = S0;      // entrada inválida: reinicia
                    else                    next_state = S0;      // sem entrada: permanece
                end
            S1: begin
                    if (btn_edge == 3'b010) next_state = S2;      // botão 1: entrada correta
                    else if (any_btn_edge)  next_state = S0;      // entrada inválida: reinicia
                    else                    next_state = S1;      // sem entrada: permanece
                end
            S2: begin
                    if (btn_edge == 3'b100) next_state = UNLOCKED_ON; // botão 2: entrada correta
                    else if (any_btn_edge)  next_state = S0;          // entrada inválida: reinicia
                    else                    next_state = S2;          // sem entrada: permanece
                end
            UNLOCKED_ON: begin
                if (delay_cnt > 0) begin
                    next_delay_cnt = delay_cnt - 1;
                end else begin
                    next_state     = UNLOCKED_OFF;
                    next_delay_cnt = BLINK_DELAY;   // reinicia contador
                end
            end

            UNLOCKED_OFF: begin
                if (delay_cnt > 0) begin
                    next_delay_cnt = delay_cnt - 1;
                end else begin
                    next_state     = UNLOCKED_ON;
                    next_delay_cnt = BLINK_DELAY;   // reinicia contador
                end
            end

            default: next_state = S0;
        endcase
    end

    // Lógica de saída
    always_comb begin
        unlocked = (state == UNLOCKED_ON);
    end

endmodule
