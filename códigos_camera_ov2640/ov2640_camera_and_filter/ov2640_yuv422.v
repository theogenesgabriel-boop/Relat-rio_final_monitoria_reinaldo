module ov2640_yuv422 (
    input PCLK, HREF, VSYNC,
    input [7:0] DATA,
    output valid_out, u_chroma_out,
    output [15:0] pixel_out
);

// Detecção de componente recebido (luminância ou crominância)
reg luma;
reg [3:0] u_chroma;
always @(posedge PCLK, negedge VSYNC)
if (~VSYNC) begin
    luma <= 1'b1;
    u_chroma <= 4'b0100;
end
else begin
    luma <= (HREF) ? ~luma : 1'b1;
    u_chroma <= (u_chroma << 3) | (u_chroma >> 1);
end

// Composição de pixels YUV422 e sinal de validação
reg [15:0] pixel_reg;
reg valid_reg;
always @(posedge PCLK, negedge VSYNC)
if (~VSYNC) begin
    pixel_reg <= 16'd0;
    valid_reg <= 1'b0;
end
else begin
    valid_reg <= 1'b0;
    if (HREF) begin    
        case (luma)
        1'b1: pixel_reg[15:8] <= DATA;
        1'b0: begin
            pixel_reg[7:0] <= DATA;
            valid_reg <= 1'b1;
        end
        endcase
    end    
end

// Direcionamento dos registradores para as saídas
assign valid_out = valid_reg;
assign pixel_out = pixel_reg;
assign u_chroma_out = u_chroma[0];

endmodule

