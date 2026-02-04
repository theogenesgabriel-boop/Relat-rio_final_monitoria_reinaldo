module clock_div #(parameter CLK_IN=120000000, CLK_OUT=12000000)(
    input clk_in, n_rst,
    output clk_out
);

// Cálculo do divisor para gerar o clock de saída desejado
localparam DIV = ((CLK_IN/CLK_OUT)/2)-1;

// Declaração dos sinais
/* $clog2(.) = arredondamento superior da função logarítmica de (.) na base 2, usado
para determinar a quantidade mínima de bits necessária para expressar o valor de (.) */
reg [$clog2(DIV)-1:0] clk_cnt = 0;
reg clk_reg = 1'b0;

// Divisor de frequência de clock (gera o sinal clk_reg)
always @(posedge clk_in, negedge n_rst) begin
    if (~n_rst)
    clk_cnt <= 0;
    else begin
        if (clk_cnt == DIV) begin
            clk_reg <= ~clk_reg;
            clk_cnt <= 0;
        end
        else
        clk_cnt <= clk_cnt + 1;
    end
end

// Direcionamento do registrador para a saída
assign clk_out = clk_reg;

endmodule