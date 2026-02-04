module sobel_filter #(parameter CAM_WIDTH=640, CAM_HEIGHT=480)(
    input PCLK, VSYNC, pixel_valid,
    input [15:0] pixel_in,
    output reg [15:0] pixel_out
);

// Contagem dos períodos de varredura da câmera
reg [$clog2(CAM_WIDTH)-1:0] h_cnt;
reg [$clog2(CAM_HEIGHT)-1:0] v_cnt;
always @(posedge PCLK, negedge VSYNC)
if (~VSYNC) begin
    h_cnt <= 0;
    v_cnt <= 0;
end
else if (pixel_valid) begin
    if (h_cnt == CAM_WIDTH-1) begin
        h_cnt <= 0;
        v_cnt <= v_cnt + 1'b1;
    end
    else h_cnt <= h_cnt + 1'b1;
end

// Matriz de pixels 3 x 3
reg [7:0] pixel_00, pixel_01, pixel_02;
reg [7:0] pixel_10, pixel_11, pixel_12;
reg [7:0] pixel_20, pixel_21, pixel_22;

// Linhas de atraso referentes a v_pos(-2) e v_pos(-1)
reg [7:0] line_2 [0:CAM_WIDTH-1];
reg [7:0] line_1 [0:CAM_WIDTH-1];

// Deslocamento da matriz de pixels 3 x 3
always @(posedge PCLK) begin
    // Deslocamento da matriz de pixels 3 x 3
    pixel_00 <= pixel_01;  pixel_01 <= pixel_02;  pixel_02 <= line_2[h_cnt];
    pixel_10 <= pixel_11;  pixel_11 <= pixel_12;  pixel_12 <= line_1[h_cnt];
    pixel_20 <= pixel_21;  pixel_21 <= pixel_22;  pixel_22 <= pixel_in[15:8];
    // Atualização das linhas de atraso
    line_2[h_cnt] <= line_1[h_cnt];
    line_1[h_cnt] <= pixel_in[15:8];
end

// Cálculo do gradiente convolucional D_x
wire signed [10:0] D_x;
assign D_x = - $signed({3'b000,pixel_00}) + $signed({3'b000,pixel_02})
             - ($signed({3'b000,pixel_10}) <<< 1) + ($signed({3'b000,pixel_12}) <<< 1)
             - $signed({3'b000,pixel_20}) + $signed({3'b000,pixel_22});

// Cálculo do gradiente convolucional D_y
wire signed [10:0] D_y;
assign D_y = + $signed({3'b000,pixel_00}) + ($signed({3'b000,pixel_01}) <<< 1)
             + $signed({3'b000,pixel_02}) - $signed({3'b000,pixel_20})
             - ($signed({3'b000,pixel_21}) <<< 1) - $signed({3'b000,pixel_22});

// Cálculo da magnitude aproximada |D| = |D_x| + |D_y|
reg signed [11:0] mag_D;
always @(posedge PCLK) begin
    mag_D <= (D_x < 0 ? -D_x : D_x) + (D_y < 0 ? -D_y : D_y);
    pixel_out <= (mag_D > 255) ? 8'd255 : {mag_D[7:0], 8'd0};
end

endmodule