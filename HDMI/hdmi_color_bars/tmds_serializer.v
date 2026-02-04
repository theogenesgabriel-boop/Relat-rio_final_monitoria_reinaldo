module tmds_serializer #(parameter WIDTH=10, LSBF=1)(
    input pixel_clk, bit_clk,
    input [WIDTH-1:0] data_in,
    output q_out_n, q_out_p
);
// Declaração dos sinais
reg delay_reg;
wire data_en;
reg [WIDTH-1:0] shift_reg;
/* Detector de transição - gera 1 pulso com período bit_clk/2 ao
   detectar o flanco de subida do sinal pixel_clk */
always @(posedge bit_clk) delay_reg <= pixel_clk;
assign data_en = pixel_clk & ~delay_reg;
// Deslocamento de bit para a serialização
always @(negedge bit_clk)
if (data_en) shift_reg <= data_in;
else shift_reg <= (LSBF) ? shift_reg >> 1 : shift_reg << 1;
// Direcionamento dos registradores para as saídas
assign q_out_n = LSBF ? ~shift_reg[0] : ~shift_reg[WIDTH-1];
assign q_out_p = LSBF ? shift_reg[0] : shift_reg[WIDTH-1];
endmodule