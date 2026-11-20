// =============================================================================
// Testbench  : tb_safecrack_pro
// Projeto    : SafeCrack Pro – CIN0130 Sistemas Digitais
// Descrição  : Valida FSM, botões, timers, displays e LEDs
//
// Os parâmetros de ciclos são reduzidos para acelerar a simulação.
// A senha de teste é 1234 (mesma da síntese padrão).
// =============================================================================
`timescale 1ns/1ps

module tb_safecrack_pro;

    // Parâmetros reduzidos para simulação rápida
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

    // Clock 50 MHz → período de 20 ns
    initial clk = 0;
    always #10 clk = ~clk;

    // Pressiona um botão brevemente (gera um pulso após debounce)
    task automatic press_key(input int k);
        begin
            KEY[k] = 1'b0;                 // pressiona (ativo-baixo)
            repeat (DEBOUNCE_CYCLES + 3) @(posedge clk);
            KEY[k] = 1'b1;                 // solta
            repeat (DEBOUNCE_CYCLES + 3) @(posedge clk);
        end
    endtask

    // Segura um botão por vários ciclos (deve gerar apenas uma ação)
    task automatic hold_key(input int k, input int cycles);
        begin
            KEY[k] = 1'b0;
            repeat (cycles) @(posedge clk);
            KEY[k] = 1'b1;
            repeat (DEBOUNCE_CYCLES + 3) @(posedge clk);
        end
    endtask

    // Converte padrão de 7 segmentos (ativo-baixo, DE2-115) para caractere
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
        KEY = 4'b1111; // todos os botões soltos

        // Aguarda o power-on reset estabilizar
        repeat (20) @(posedge clk);

        //------------------------------------------------------------------
        // Teste 1: Estado inicial após reset
        //------------------------------------------------------------------
        $display("\n[T1] Estado inicial após POR");
        assert (hex_to_str(HEX3) == "0") else $error("HEX3 not 0");
        assert (hex_to_str(HEX2) == "0") else $error("HEX2 not 0");
        assert (hex_to_str(HEX1) == "0") else $error("HEX1 not 0");
        assert (hex_to_str(HEX0) == "0") else $error("HEX0 not 0");
        assert (hex_to_str(HEX4) == "1") else $error("HEX4 (active digit) not 1");
        assert (LEDG == 9'b0) else $error("LEDG not off");
        assert (LEDR == 18'b0) else $error("LEDR not off");
        $display("  PASS: todos os dígitos 0, ativo=0, LEDs apagados");

        //------------------------------------------------------------------
        // Teste 2: Incremento via KEY[2]
        //------------------------------------------------------------------
        $display("\n[T2] Incrementa dígito ativo");
        press_key(2); // 0 -> 1
        press_key(2); // 1 -> 2
        press_key(2); // 2 -> 3
        assert (hex_to_str(HEX3) == "3") else $error("Expected 3 on HEX3");
        $display("  PASS: 0->1->2->3");

        //------------------------------------------------------------------
        // Teste 3: Decremento via KEY[3]
        //------------------------------------------------------------------
        $display("\n[T3] Decrementa");
        press_key(3);
        press_key(3);
        assert (hex_to_str(HEX3) == "1") else $error("Expected 1 after two decrements");
        $display("  PASS: 3->2->1");

        //------------------------------------------------------------------
        // Testes 4/5: Wrap-around nos dois sentidos
        //------------------------------------------------------------------
        $display("\n[T4/5] Wrap-around");
        // vai a 0 e decrementa → 9
        press_key(3);
        assert (hex_to_str(HEX3) == "0");
        press_key(3);
        assert (hex_to_str(HEX3) == "9") else $error("Wrap 0->9 failed");
        // incrementa de 9 → 0
        press_key(2);
        assert (hex_to_str(HEX3) == "0") else $error("Wrap 9->0 failed");
        $display("  PASS: wrap-around nos dois sentidos");

        //------------------------------------------------------------------
        // Teste 6: Confirma dígitos e avança (digita senha 1234)
        //------------------------------------------------------------------
        $display("\n[T6] Confirma & avança (digita senha 1234)");
        // primeiro dígito = 1
        press_key(2); // 0->1
        press_key(1); // confirma → avança para o 2º dígito, HEX4 deve mostrar 2
        assert (hex_to_str(HEX4) == "2") else $error("active digit not 2");
        assert (hex_to_str(HEX3) == "1") else $error("digit0 lost");

        // segundo dígito = 2
        press_key(2); press_key(2); // 0->1->2
        press_key(1);
        assert (hex_to_str(HEX4) == "3") else $error("active digit not 3");
        assert (hex_to_str(HEX2) == "2");

        // terceiro dígito = 3
        press_key(2); press_key(2); press_key(2);
        press_key(1);
        assert (hex_to_str(HEX4) == "4") else $error("active digit not 4");
        assert (hex_to_str(HEX1) == "3");

        // quarto dígito = 4
        press_key(2); press_key(2); press_key(2); press_key(2);
        press_key(1); // confirma o último → vai para CHECK e depois SUCCESS

        // Aguarda alguns ciclos para a FSM processar
        repeat (5) @(posedge clk);

        //------------------------------------------------------------------
        // Teste 7: Senha correta → LEDs verdes
        //------------------------------------------------------------------
        $display("\n[T7] Feedback de senha correta");
        assert (LEDG == 9'h1FF) else $error("LEDG not all on after correct pwd");
        assert (LEDR == 18'b0)  else $error("LEDR should be off on success");
        $display("  PASS: LEDs verdes acesos");

        // Aguarda o timer expirar e verifica retorno automático
        repeat (SUCCESS_CYCLES + 10) @(posedge clk);
        assert (LEDG == 9'b0) else $error("LEDG did not turn off after timeout");
        assert (hex_to_str(HEX3) == "0") else $error("digits not cleared after success");
        assert (hex_to_str(HEX4) == "1") else $error("active digit not reset to 1");
        $display("  PASS: retorno automático ao estado inicial após timeout de sucesso");

        //------------------------------------------------------------------
        // Teste 8: Senha incorreta
        //------------------------------------------------------------------
        $display("\n[T8] Senha incorreta");
        // digita 0000
        press_key(1); // confirma 0
        press_key(1);
        press_key(1);
        press_key(1); // última confirmação
        repeat (5) @(posedge clk);
        assert (LEDR != 18'b0) else $error("LEDR should be on after wrong pwd");
        assert (LEDG == 9'b0)  else $error("LEDG should be off on fail");
        $display("  PASS: LEDs vermelhos acesos");

        repeat (FAIL_CYCLES + 10) @(posedge clk);
        assert (LEDR == 18'b0) else $error("LEDR did not turn off");
        assert (hex_to_str(HEX4) == "1");
        $display("  PASS: retorno automático após timeout de falha");

        //------------------------------------------------------------------
        // Teste 9: Segurar botão gera apenas uma ação
        //------------------------------------------------------------------
        $display("\n[T9] Manter botão pressionado (ação única)");
        // dígito 0 está em 0; segura KEY[2] por muitos ciclos
        hold_key(2, 50);
        // deve ter incrementado apenas uma vez
        assert (hex_to_str(HEX3) == "1") else $error("Multiple increments on hold");
        $display("  PASS: apenas um incremento ao manter pressionado");

        //------------------------------------------------------------------
        // Testes 11/12/13: Reset via KEY[0]
        //------------------------------------------------------------------
        $display("\n[T11-13] Reset via KEY[0]");
        press_key(2); // deixa o dígito diferente de zero
        press_key(0); // reset
        repeat (10) @(posedge clk);
        assert (hex_to_str(HEX3) == "0");
        assert (hex_to_str(HEX4) == "1");
        assert (LEDG == 9'b0 && LEDR == 18'b0);
        $display("  PASS: KEY[0] reseta o sistema");

        $display("\n=== Todos os testes concluídos ===");
        $finish;
    end

    // Dump de forma de onda para análise pós-simulação
    initial begin
        $dumpfile("safecrack_pro.vcd");
        $dumpvars(0, tb_safecrack_pro);
    end

endmodule
