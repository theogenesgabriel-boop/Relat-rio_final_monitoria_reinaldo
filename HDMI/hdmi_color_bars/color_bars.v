module color_bars #(parameter DISPLAY_WIDTH=640)(
    input pixel_clk, n_rst, active_video,
    output [7:0] blue, green, red
);
// Cálculo da largura das barras de cores
localparam BAR_WIDTH = DISPLAY_WIDTH / 7;
// Declaração dos sinais
reg [$clog2(DISPLAY_WIDTH)-1:0] h_cnt;
reg [7:0] red_reg, green_reg, blue_reg;
reg [2:0] bar_index;
// Indexação para a seleção de cores para as barras
always @(posedge pixel_clk, negedge n_rst)
if (~n_rst) begin
    h_cnt <= 0;
    bar_index <= 0;
end
else if (active_video) begin
    if (h_cnt == DISPLAY_WIDTH-1) begin
        h_cnt <= 0;
        bar_index <= 0;
    end
    else if (h_cnt == (BAR_WIDTH-1) || h_cnt == (2*BAR_WIDTH-1) || h_cnt == (3*BAR_WIDTH-1) ||
             h_cnt == (4*BAR_WIDTH-1) || h_cnt == (5*BAR_WIDTH-1) || h_cnt == (6*BAR_WIDTH-1))
    begin
        bar_index <= bar_index + 1;
        h_cnt <= h_cnt + 1;
    end
    else
    h_cnt <= h_cnt + 1;
end
// Seleção de cores
always @(*)
case (bar_index)
0: begin red_reg <= 8'hFF; green_reg <= 8'hFF; blue_reg <= 8'hFF; end // branca
1: begin red_reg <= 8'hFF; green_reg <= 8'hFF; blue_reg <= 8'h00; end // amarela
2: begin red_reg <= 8'h00; green_reg <= 8'hFF; blue_reg <= 8'hFF; end // ciano
3: begin red_reg <= 8'h00; green_reg <= 8'hFF; blue_reg <= 8'h00; end // verde
4: begin red_reg <= 8'hFF; green_reg <= 8'h00; blue_reg <= 8'hFF; end // magenta
5: begin red_reg <= 8'hFF; green_reg <= 8'h00; blue_reg <= 8'h00; end // vermelha
6: begin red_reg <= 8'h00; green_reg <= 8'h00; blue_reg <= 8'hFF; end // azul
endcase
// Direcionamento do sinais para as saídas
assign blue = blue_reg;
assign green = green_reg;
assign red = red_reg;
endmodule
