module video_pattern #(parameter WIDTH=640, HEIGHT=480)(
    input pixel_clk, n_rst, active_video,
    input [$clog2(WIDTH)-1:0] h_pos,
    input [$clog2(HEIGHT)-1:0] v_pos,
    output [7:0] blue, green, red
);
// Declaração dos sinais
reg [7:0] red_reg, green_reg, blue_reg;
wire [2:0] v_index, h_index;
reg [22:0] clk_cnt;
reg [2:0] n_cnt;
// Contador para gerar um padrão variante no tempo
always @(posedge pixel_clk) begin
    if (clk_cnt == 6299000) begin
        if (n_cnt == 7) begin
            n_cnt <= 0;
            clk_cnt <= 0;
        end
        n_cnt <= n_cnt + 1;
        clk_cnt <= 0;
    end
    else
    clk_cnt <= clk_cnt + 1;
end
// Indexadores para a seleção de cores
assign h_index = (h_pos * n_cnt) / WIDTH;
assign v_index = (v_pos * n_cnt) / HEIGHT;
assign h_phase = ((h_pos * n_cnt) / WIDTH);

// Seleção de cores
always @(*)
if (v_index == 0) begin
    case (h_index)
    0: begin red_reg <= 8'hFF; green_reg <= 8'hFF; blue_reg <= 8'hFF; end // branca
    1: begin red_reg <= 8'hFF; green_reg <= 8'hFF; blue_reg <= 8'h00; end // amarela
    2: begin red_reg <= 8'h00; green_reg <= 8'hFF; blue_reg <= 8'hFF; end // ciano
    3: begin red_reg <= 8'h00; green_reg <= 8'hFF; blue_reg <= 8'h00; end // verde
    4: begin red_reg <= 8'hFF; green_reg <= 8'h00; blue_reg <= 8'hFF; end // magenta
    5: begin red_reg <= 8'hFF; green_reg <= 8'h00; blue_reg <= 8'h00; end // vermelha
    6: begin red_reg <= 8'h00; green_reg <= 8'h00; blue_reg <= 8'hFF; end // azul
    endcase
end
else if (v_index == 1) begin
    case (h_phase)
    0: begin red_reg <= 8'hFF; green_reg <= 8'h00; blue_reg <= 8'h00; end // vermelha
    1: begin red_reg <= 8'h00; green_reg <= 8'h00; blue_reg <= 8'hFF; end // azul
    2: begin red_reg <= 8'hFF; green_reg <= 8'hFF; blue_reg <= 8'hFF; end // branca
    3: begin red_reg <= 8'hFF; green_reg <= 8'hFF; blue_reg <= 8'h00; end // amarela
    4: begin red_reg <= 8'h00; green_reg <= 8'hFF; blue_reg <= 8'hFF; end // ciano
    5: begin red_reg <= 8'h00; green_reg <= 8'hFF; blue_reg <= 8'h00; end // verde
    6: begin red_reg <= 8'hFF; green_reg <= 8'h00; blue_reg <= 8'hFF; end // magenta    
    endcase
end
else if (v_index == 2) begin
    case (h_index)
    0: begin red_reg <= 8'h00; green_reg <= 8'hFF; blue_reg <= 8'h00; end // verde
    1: begin red_reg <= 8'hFF; green_reg <= 8'h00; blue_reg <= 8'hFF; end // magenta
    2: begin red_reg <= 8'hFF; green_reg <= 8'h00; blue_reg <= 8'h00; end // vermelha
    3: begin red_reg <= 8'h00; green_reg <= 8'h00; blue_reg <= 8'hFF; end // azul
    4: begin red_reg <= 8'hFF; green_reg <= 8'hFF; blue_reg <= 8'hFF; end // branca
    5: begin red_reg <= 8'hFF; green_reg <= 8'hFF; blue_reg <= 8'h00; end // amarela
    6: begin red_reg <= 8'h00; green_reg <= 8'hFF; blue_reg <= 8'hFF; end // ciano
    endcase
end
else if (v_index == 3) begin
    case (h_phase)
    0: begin red_reg <= 8'hFF; green_reg <= 8'hFF; blue_reg <= 8'h00; end // amarela
    1: begin red_reg <= 8'h00; green_reg <= 8'hFF; blue_reg <= 8'hFF; end // ciano
    2: begin red_reg <= 8'h00; green_reg <= 8'hFF; blue_reg <= 8'h00; end // verde
    3: begin red_reg <= 8'hFF; green_reg <= 8'h00; blue_reg <= 8'hFF; end // magenta
    4: begin red_reg <= 8'hFF; green_reg <= 8'h00; blue_reg <= 8'h00; end // vermelha
    5: begin red_reg <= 8'h00; green_reg <= 8'h00; blue_reg <= 8'hFF; end // azul
    6: begin red_reg <= 8'hFF; green_reg <= 8'hFF; blue_reg <= 8'hFF; end // branca
    endcase
end
else if (v_index == 4) begin
    case (h_index)
    0: begin red_reg <= 8'h00; green_reg <= 8'h00; blue_reg <= 8'hFF; end // azul
    1: begin red_reg <= 8'hFF; green_reg <= 8'hFF; blue_reg <= 8'hFF; end // branca
    2: begin red_reg <= 8'hFF; green_reg <= 8'hFF; blue_reg <= 8'h00; end // amarela
    3: begin red_reg <= 8'h00; green_reg <= 8'hFF; blue_reg <= 8'hFF; end // ciano
    4: begin red_reg <= 8'h00; green_reg <= 8'hFF; blue_reg <= 8'h00; end // verde
    5: begin red_reg <= 8'hFF; green_reg <= 8'h00; blue_reg <= 8'hFF; end // magenta
    6: begin red_reg <= 8'hFF; green_reg <= 8'h00; blue_reg <= 8'h00; end // vermelha    
    endcase
end
else if (v_index == 5) begin
    case (h_phase)
    0: begin red_reg <= 8'hFF; green_reg <= 8'h00; blue_reg <= 8'hFF; end // magenta
    1: begin red_reg <= 8'hFF; green_reg <= 8'h00; blue_reg <= 8'h00; end // vermelha
    2: begin red_reg <= 8'h00; green_reg <= 8'h00; blue_reg <= 8'hFF; end // azul
    3: begin red_reg <= 8'hFF; green_reg <= 8'hFF; blue_reg <= 8'hFF; end // branca
    4: begin red_reg <= 8'hFF; green_reg <= 8'hFF; blue_reg <= 8'h00; end // amarela
    5: begin red_reg <= 8'h00; green_reg <= 8'hFF; blue_reg <= 8'hFF; end // ciano
    6: begin red_reg <= 8'h00; green_reg <= 8'hFF; blue_reg <= 8'h00; end // verde        
    endcase
end
else if (v_index == 6) begin
    case (h_index)
    0: begin red_reg <= 8'h00; green_reg <= 8'hFF; blue_reg <= 8'hFF; end // ciano
    1: begin red_reg <= 8'h00; green_reg <= 8'hFF; blue_reg <= 8'h00; end // verde
    2: begin red_reg <= 8'hFF; green_reg <= 8'h00; blue_reg <= 8'hFF; end // magenta
    3: begin red_reg <= 8'hFF; green_reg <= 8'h00; blue_reg <= 8'h00; end // vermelha
    4: begin red_reg <= 8'h00; green_reg <= 8'h00; blue_reg <= 8'hFF; end // azul
    5: begin red_reg <= 8'hFF; green_reg <= 8'hFF; blue_reg <= 8'hFF; end // branca
    6: begin red_reg <= 8'hFF; green_reg <= 8'hFF; blue_reg <= 8'h00; end // amarela            
    endcase
end

// Direcionamento do sinais para as saídas
assign blue = blue_reg;
assign green = green_reg;
assign red = red_reg;

endmodule
