module tmds_encoder (
    input pixel_clk, n_rst,
    input active_video, d_0, d_1,     
    input [7:0] data_in,
    output [9:0] data_out
);

/* Primeiro estágio da codificação de vídeo: "transition-minimized 9-bit code" */
// Contagem do número de 1s do sinal data_in
wire [3:0] n_1_data_in = data_in[7] + data_in[6] + data_in[5] + data_in[4] +
                         data_in[3] + data_in[2] + data_in[1] + data_in[0];
                         
// Determinação do sinal intermediário q_m
reg [1:0] ctl_reg;
reg [8:0] q_m;
reg [7:0] q_tmp;
integer i;

always @(posedge pixel_clk, negedge n_rst)
if (~n_rst) begin
    ctl_reg <= 2'd0;
    q_m <= 9'd0;
end
else begin
    ctl_reg <= {d_1, d_0};
    q_tmp[0] = data_in[0];
    q_m[0] <= data_in[0];
    if (n_1_data_in > 4 || (n_1_data_in == 4 && data_in[0] == 0)) begin
        q_m[8] <= 1'b0;
        for (i = 1; i < 8; i = i + 1) begin
            q_tmp[i] = q_tmp[i-1] ~^ data_in[i];
            q_m[i] <= q_tmp[i];
        end
    end else begin
        q_m[8] <= 1'b1;
        for (i = 1; i < 8; i = i + 1) begin
            q_tmp[i] = q_tmp[i-1] ^ data_in[i];
            q_m[i] <= q_tmp[i];
        end
    end
end

/* Segundo estágio da codificação de vídeo: "approximate DC balance" */
// Contagem do número de 1s e 0s do sinal intermediário q_m
wire [3:0] n_1_q_m = q_m[7] + q_m[6] + q_m[5] + q_m[4] +
                     q_m[3] + q_m[2] + q_m[1] + q_m[0];
wire [3:0] n_0_q_m = 8 - n_1_q_m;

// Determinação do sinal balanceado q_out
reg [9:0] q_out;
reg signed [4:0] cnt;
always @(posedge pixel_clk, negedge n_rst)
if (~n_rst) begin
    q_out <= 10'd0;
    cnt <= 5'd0;
end
else begin
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

// Padrões de controle fixos no período de blanking
wire [9:0] q_ctl = ctl_reg[1] ? (ctl_reg[0] ? 10'b1010101011 : 10'b0101010100) :
                                (ctl_reg[0] ? 10'b0010101011 : 10'b1101010100);

// Estágio de saída
assign data_out = (active_video) ? q_out : q_ctl;

endmodule
