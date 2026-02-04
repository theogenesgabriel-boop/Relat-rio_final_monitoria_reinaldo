module frame_buffer #(parameter CAM_WIDTH=640, CAM_HEIGHT=480, WIDTH=534, HEIGHT=400)(
    // domínio da câmera
    input n_rst, PCLK, VSYNC, pixel_valid,
    input [15:0] pixel_in,
    // domínio HDMI
    input pixel_clk,
    input [$clog2(640)-1:0] h_pos,
    input [$clog2(480)-1:0] v_pos,
    output reg [7:0] data_out
);

// Configuração de memória RAM
localparam MEM_DEPTH = WIDTH * HEIGHT;
(* ram_style = "block" *)
reg [7:0] mem [0:MEM_DEPTH-1];

// Ponteiro de escrita
reg [$clog2(MEM_DEPTH)-1:0] wr_addr;

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

// Delimitação do frame e escrita da memória
localparam H_MARGIN = (CAM_WIDTH - WIDTH ) / 2;
localparam V_MARGIN = (CAM_HEIGHT - HEIGHT) / 2;
always @(posedge PCLK)
if (~VSYNC) wr_addr <= 0;
else if (pixel_valid && wr_addr < MEM_DEPTH) begin
    if (h_cnt >= H_MARGIN && h_cnt < (H_MARGIN+WIDTH) &&
        v_cnt >= V_MARGIN && v_cnt < (V_MARGIN+HEIGHT)) begin
        mem[wr_addr] <= pixel_in[15:8];
        wr_addr <= wr_addr + 1'b1;
    end
end

// Definição dos pixels válidos
reg [$clog2(WIDTH*HEIGHT)-1:0] n_pos;
always @(posedge pixel_clk, negedge n_rst)
if (~n_rst || n_pos == (MEM_DEPTH-1)) n_pos <= 0;
else if (h_pos >= H_MARGIN && h_pos < (H_MARGIN+WIDTH) &&
         v_pos >= V_MARGIN && v_pos < (V_MARGIN+HEIGHT))
n_pos <= n_pos + 1;

// Leitura da memória
reg [$clog2(MEM_DEPTH)-1:0] rd_addr;
always @(posedge pixel_clk) begin
    rd_addr <= n_pos;
    if (h_pos >= H_MARGIN && h_pos < (H_MARGIN+WIDTH) &&
        v_pos >= V_MARGIN && v_pos < (V_MARGIN+HEIGHT))
    data_out <= mem[rd_addr];
    else
    data_out <= 8'h00;
end
endmodule