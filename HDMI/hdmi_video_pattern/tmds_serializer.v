module tmds_serializer (
    input slow_clk, fast_clk,
    input [9:0] data_in,
    output q_out_n, q_out_p
);
// Declaração dos sinais
reg delay_reg;
wire data_en;
reg [9:0] data_shift;
/* Detector de transição - gera 1 pulso com período bit_clk/2 ao
   detectar o flanco de subida do sinal pixel_clk */
always @(negedge fast_clk) delay_reg <= slow_clk;
assign data_en = slow_clk & (~delay_reg);

// Deslocamento de bit para a serialização
always @(posedge fast_clk) begin
    if (data_en) data_shift <= data_in;
    else data_shift <= data_shift >> 1;
end
// Direcionamento dos registradores para as saídas
assign q_out_n = ~data_shift[0];
assign q_out_p = data_shift[0];
endmodule