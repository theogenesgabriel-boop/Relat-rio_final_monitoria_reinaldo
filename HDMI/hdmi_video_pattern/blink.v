module blink #(parameter CLK_IN_HZ=100000000, BLINK_MILI_HZ=500, DUTY_CYCLE=5)(
    input clk_in, n_rst, n_btn,
    output led_out
);

// Cálculo do divisor de clock
localparam PERIOD = ((CLK_IN_HZ/(BLINK_MILI_HZ))*10**3)-1;
localparam ACTIVE = (PERIOD/100)*DUTY_CYCLE;

// Declaração do registrador para contagem de clock
reg [$clog2(PERIOD)-1:0] clk_cnt = 0;

// Declaração do registrador para inversão de polaridade
wire led_reg;
reg pol;

// Divisor de frequência de clock
always @(posedge clk_in, negedge n_rst)
if (~n_rst)
clk_cnt <= 0;
else begin
    pol <= (~n_btn) ? 1'b1 : 1'b0;
    if (clk_cnt == PERIOD)
    clk_cnt <= 0;
    else
    clk_cnt <= clk_cnt + 1;
end

// Direcionamento do registrador para a saída
assign led_reg = clk_cnt < ACTIVE ? 1'b1 : 1'b0;
assign led_out = (pol) ? led_reg : ~led_reg;    // led_D2 ativo em nível baixo

endmodule