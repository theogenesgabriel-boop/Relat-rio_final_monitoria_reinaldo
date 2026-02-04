module timings_480p (
    input pixel_clk, n_rst,
    output h_sync, v_sync, ctl_0, ctl_1, ctl_2, ctl_3,
    output active_video, video_gb, data_island_gb
);
// Parâmetros de temporização para o vídeo com resolução VGA 640x480@60Hz  
localparam H_SYNC=96, H_BP=40, H_LB=8, H_ADDR=640, H_RB=8, H_FP=8;
localparam V_SYNC=2, V_BP=25, V_TB=8, V_ADDR=480, V_BB=8, V_FP=2;
localparam H_TOTAL = H_SYNC + H_BP + H_LB + H_ADDR + H_RB + H_FP;   // 800
localparam V_TOTAL = V_SYNC + V_BP + V_TB + V_ADDR + V_BB + V_FP;   // 525
// Declaração dos sinais
reg [$clog2(H_TOTAL)-1:0] h_cnt;
reg [$clog2(V_TOTAL)-1:0] v_cnt;
// Contagem dos períodos de varredura
always @(posedge pixel_clk, negedge n_rst)
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
assign h_sync = (h_cnt < H_SYNC) ? 1'b0 : 1'b1;
assign v_sync = (v_cnt < V_SYNC) ? 1'b0 : 1'b1;
// Período de vídeo ativo
assign active_video = (h_cnt >= (H_SYNC + H_BP + H_LB) && h_cnt < (H_SYNC + H_BP + H_LB + H_ADDR) &&
                       v_cnt >= (V_SYNC + V_BP + V_TB) && v_cnt < V_SYNC + V_BP + V_TB + V_ADDR) ? 1'b1 : 1'b0;

// Video Leading Guard Band
assign video_gb = (h_cnt >= (H_SYNC + H_BP + H_LB - 2) && h_cnt < (H_SYNC + H_BP + H_LB)) ? 1'b1 : 1'b0;
// Data Island Leading/Trailing Guard Band
assign data_island_gb = 1'b0;
// Preâmbulo para período de vídeo ativo
assign ctl_0 = (h_cnt >= (H_SYNC + H_BP + H_LB - 10) && h_cnt < H_SYNC + H_BP + H_LB - 2) ? 1'b1 : 1'b0;
assign ctl_1 = 1'b0;
assign ctl_2 = 1'b0;
assign ctl_3 = 1'b0;
endmodule