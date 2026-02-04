module tmds_timing #(parameter WIDTH=640, HEIGHT=480)(
    input slow_clk, fast_clk, n_rst,
    output pixel_clk, tmds_clk_n, tmds_clk_p,
    output active_video,
    output h_sync, v_sync,
    output [$clog2(WIDTH)-1:0] h_pos,
    output [$clog2(HEIGHT)-1:0] v_pos
);

// Parâmetros de temporização para o vídeo com resolução VGA 640x480@60Hz  
localparam H_SYNC=96, H_BP=48, H_ACTIVE=640, H_FP=16;
localparam V_SYNC=2, V_BP=33, V_ACTIVE=480, V_FP=10;
localparam H_TOTAL = H_SYNC + H_BP + H_ACTIVE + H_FP;   // 800
localparam V_TOTAL = V_ACTIVE + V_FP + V_SYNC + V_BP;   // 525

// Declaração dos sinais
reg [$clog2(H_TOTAL)-1:0] h_cnt;
reg [$clog2(V_TOTAL)-1:0] v_cnt;
reg [$clog2(WIDTH)-1:0] h_pos_cnt;
reg [$clog2(HEIGHT)-1:0] v_pos_cnt;
reg sync_clk_reg;

// Sincronismo entre pixel_clk e bit_clk
always @(posedge fast_clk) sync_clk_reg <= slow_clk;
assign pixel_clk = sync_clk_reg;

// Geração do sinal diferencial de clock TMDS
assign tmds_clk_n = ~pixel_clk;
assign tmds_clk_p = pixel_clk;

// Contagem dos períodos de varredura
always @(posedge sync_clk_reg, negedge n_rst)
if (~n_rst) begin
    h_cnt <= 0;
    v_cnt <= 0;
end 
else begin
    if (h_cnt == H_TOTAL-1) begin
        h_cnt <= 0;
        v_cnt <= (v_cnt == V_TOTAL-1)? 0 : v_cnt + 1;
    end
    else
    h_cnt <= h_cnt + 1;
end

// Geração dos sinais de sincronismo horizontal e vertical
assign h_sync = (h_cnt < H_SYNC) ? 1'b1 : 1'b0;
assign v_sync = (v_cnt < V_SYNC) ? 1'b1 : 1'b0;
assign active_video = (h_cnt >= (H_SYNC+H_BP) && h_cnt < (H_TOTAL-H_FP)) &&
                      (v_cnt < (V_TOTAL-V_SYNC-V_BP-V_FP));

// Geração dos indicadores de posição horizontal e posição vertical
always @(posedge sync_clk_reg, negedge n_rst)
if (~n_rst) begin
    h_pos_cnt <= 0;
    v_pos_cnt <= 0;
end
else begin
    if (active_video) begin
        if (h_pos_cnt == WIDTH-1) begin
            h_pos_cnt <= 0;
            v_pos_cnt <= (v_cnt == HEIGHT-1)? 0 : v_pos_cnt + 1;
        end
        else
        h_pos_cnt <= h_pos_cnt + 1;
    end
end

// Direcionamento dos registradores para as saídas
assign h_pos = h_pos_cnt;
assign v_pos = v_pos_cnt;
                      
endmodule