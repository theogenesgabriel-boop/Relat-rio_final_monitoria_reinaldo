module switch #(parameter CLK_IN_FREQ=10000000)(
    input clk_in, n_rst, sel_btn,
    input [15:0] signal_1, signal_2,
    output [15:0] signal_out
);

// Temporização (delay_ms)
localparam reg [$clog2(CLK_IN_FREQ)-1:0] DELAY_200 = (2*CLK_IN_FREQ/10)-1;   // delay = 200 ms

// Declaração dos sinais
reg [$clog2(CLK_IN_FREQ)-1:0] clk_cnt;
reg output_sel;

// Lógica de seleção de saída
always @(posedge clk_in, negedge n_rst)
if (~n_rst) begin
    clk_cnt <= 0;
    output_sel <= 1'b0;
end
else if (clk_cnt == DELAY_200 && ~sel_btn) begin
    clk_cnt <= 0;
    output_sel <= ~output_sel;
end
else if (clk_cnt < DELAY_200)
clk_cnt <= clk_cnt + 1;

assign signal_out = (output_sel) ? signal_2 : signal_1;

endmodule

