module tmds_encoder #(parameter CHANNEL=0)(
    input pixel_clk, n_rst,
    /* Canal 0: d_0 = h_sync e d_1 = v_sync
       Canal 1: d_0 = ctl_0 e d_1 = ctl_1
       Canal 2: d_0 = ctl_2 e d_1 = ctl_3 */
    input active_video, d_0, d_1, video_gb, data_island_gb,     
    input [7:0] data_in,
    output [9:0] data_out
);
// Declaração dos sinais
reg [3:0] n_1_data_in;
reg [3:0] n_1_q_m;
reg [3:0] n_0_q_m;
reg [8:0] q_m;
reg [9:0] q_out;
reg signed [4:0] cnt;
integer i;
// Codificação de vídeo
always @(posedge pixel_clk, negedge n_rst)
if (~n_rst) begin
    cnt <= 0;
    q_out <= 10'b0000000000;
end
else if (active_video) begin
    // Contagem do número de 1s do sinal data_in
    n_1_data_in <= data_in[7] + data_in[6] + data_in[5] + data_in[4] +
                   data_in[3] + data_in[2] + data_in[1] + data_in[0];
    // Geração do sinal q_m
    q_m[0] <= data_in[0];
    if (n_1_data_in > 4 || (n_1_data_in == 4 && data_in[0] == 0)) begin
        q_m[8] <= 1'b1;
        for (i = 1; i < 8; i = i + 1)
        q_m[i] <= q_m[i-1] ~^ data_in[i];
    end
    else begin
        q_m[8] <= 1'b0;
        for (i = 1; i < 8; i = i + 1)
        q_m[i] <= q_m[i-1] ^ data_in[i];
    end
    // Contagem do número de 1s e do número de 0s em q_m[7:0]
    n_1_q_m <= q_m[7] + q_m[6] + q_m[5] + q_m[4] +
               q_m[3] + q_m[2] + q_m[1] + q_m[0];
    n_0_q_m <= 8 - n_1_q_m;
    // Escolha de inversão para manter o balanço DC
    if (cnt == 0 || n_1_q_m == n_0_q_m) begin
        q_out[9:8] <= {~q_m[8], q_m[8]};
        if (q_m[8]) begin
            q_out[7:0] <= q_m[7:0];
            cnt <= cnt + (n_1_q_m - n_0_q_m);
        end
        else begin
            q_out[7:0] <= ~q_m[7:0];
            cnt <= cnt + (n_0_q_m - n_1_q_m);
        end
    end
    else if ((cnt > 0 && n_1_q_m > n_0_q_m) || (cnt < 0 && n_0_q_m > n_1_q_m)) begin
        q_out <= {1'b1, q_m[8], ~q_m[7:0]};
        cnt <= cnt + 2 * q_m[8] + (n_0_q_m - n_1_q_m);
    end
    else begin
        q_out <= {1'b0, q_m[8], q_m[7:0]};
        cnt <= cnt - 2 * (~q_m[8]) + (n_1_q_m - n_0_q_m);
    end
end
else begin
    if (video_gb) begin
        // Video Leading Guard Band
        case (CHANNEL)
        0: q_out <= 10'b1011001100;
        1: q_out <= 10'b0100110011;
        2: q_out <= 10'b1011001100;
        endcase
    end
    else if (data_island_gb) begin
        // Data Island Leading/Trailling Guard Band
        if (CHANNEL != 0) q_out <= 10'b0100110011;
    end
    else begin
        // Padrões de controle fixos no período de blanking
        case ({d_1, d_0})
        2'b00: q_out <= 10'b1101010100;
        2'b01: q_out <= 10'b0010101011;
        2'b10: q_out <= 10'b0101010100;
        2'b11: q_out <= 10'b1010101011;
        endcase
    end
    cnt <= 0;
end
// Direcionamento do registrador para a saída
assign data_out = ~q_out;
endmodule
