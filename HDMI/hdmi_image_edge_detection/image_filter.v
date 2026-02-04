module image_filter #(parameter WIDTH=534, HEIGHT=400)(
    input pixel_clk, n_rst,
    input [7:0] pixel_in,
    input [$clog2(WIDTH)-1:0] h_pos,
    input [$clog2(480)-1:0] v_pos,
    output reg [7:0] pixel_out
);

// Configuração de memória RAM
(* ram_style = "block" *)

// Linhas referentes a v_pos(-1) e v_pos(-2)
reg [7:0] line_1 [0:WIDTH-1];
reg [7:0] line_2 [0:WIDTH-1];

// Matriz de pixels necessária para a convolução
reg [7:0] pixel_00, pixel_01, pixel_02;
reg [7:0] pixel_10, pixel_11, pixel_12;
reg [7:0] pixel_20, pixel_21, pixel_22;

// Gradientes D_x e D_y, baseados nas máscaras de convolução G_x e G_y
reg signed [10:0] D_x;
reg signed [10:0] D_y;

// Magnitude aproximada |D| = |D_x| + |D_y|
reg signed [11:0] mag_D;

// Definição dos pixels válidos
localparam N_WIDTH = (640 - WIDTH) / 2;
localparam N_HEIGHT = (480 - HEIGHT) / 2;

// Pipeline
always @(posedge pixel_clk, negedge n_rst) begin
    if (~n_rst) begin
        pixel_00 <= 8'd0; pixel_01 <= 8'd0; pixel_02 <= 8'd0;
        pixel_10 <= 8'd0; pixel_11 <= 8'd0; pixel_12 <= 8'd0;
        pixel_20 <= 8'd0; pixel_21 <= 8'd0; pixel_22 <= 8'd0;
        D_x <= 11'd0;
        D_y <= 11'd0;
        mag_D <= 12'd0;
        pixel_out <= 8'd0;
    end
    else begin
        // Shift da janela de pixels 3×3
        pixel_00 <= pixel_01;  pixel_01 <= pixel_02;  pixel_02 <= line_2[h_pos];
        pixel_10 <= pixel_11;  pixel_11 <= pixel_12;  pixel_12 <= line_1[h_pos];
        pixel_20 <= pixel_21;  pixel_21 <= pixel_22;  pixel_22 <= pixel_in;
        // Atualiza buffers das linhas 1 e 2
        line_2[h_pos] <= line_1[h_pos];
        line_1[h_pos] <= pixel_in;
        /// Cálculo do gradiente D_x
        D_x <= ( $signed({1'b0,pixel_02}) + ($signed({1'b0,pixel_12}) <<< 1) + $signed({1'b0,pixel_22}) )
             - ( $signed({1'b0,pixel_00}) + ($signed({1'b0,pixel_10}) <<< 1) + $signed({1'b0,pixel_20}) );
        // Cálculo do gradiente D_y
        D_y <= ( $signed({1'b0,pixel_20}) + ($signed({1'b0,pixel_21}) <<< 1) + $signed({1'b0,pixel_22}) )
             - ( $signed({1'b0,pixel_00}) + ($signed({1'b0,pixel_01}) <<< 1) + $signed({1'b0,pixel_02}) );
        // Magnitude aproximada |D| = |D_x| + |D_x|
        mag_D <= (D_x[10] ? -D_x : D_x) + (D_y[10] ? -D_y : D_y);
        // Pixel de saída
        if (h_pos >= (N_WIDTH + 2) && h_pos < (WIDTH + N_WIDTH) &&
            v_pos >= N_HEIGHT && v_pos < (HEIGHT + N_HEIGHT))
            pixel_out <= pixel_in;
        else begin
            if (mag_D < 0) pixel_out <= 8'd0;
            else if (mag_D > 255) pixel_out <= 8'd255;
            else pixel_out <= mag_D[7:0];
        end
    end
end

endmodule