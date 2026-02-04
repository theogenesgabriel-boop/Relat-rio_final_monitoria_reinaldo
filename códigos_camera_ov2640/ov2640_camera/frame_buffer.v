module frame_buffer #(parameter WIDTH=534, HEIGHT = 400)(
    // domínio da câmera
    input PCLK, VSYNC, pixel_valid,
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

// Resolução da câmera
localparam CAM_WIDTH  = 640;
localparam CAM_HEIGHT = 480;

// Contagem dos períodos de varredura da câmera
reg [$clog2(CAM_WIDTH)-1:0] h_cnt;
reg [$clog2(CAM_HEIGHT)-1:0] v_cnt;
always @(posedge PCLK)
if (~VSYNC) begin
    h_cnt <= 0;
    v_cnt <= 0;
end else if (pixel_valid) begin
    if (h_cnt == CAM_WIDTH-1) begin
        h_cnt <= 0;
        v_cnt <= v_cnt + 1'b1;
    end
    else h_cnt <= h_cnt + 1'b1;
end

// Delimitação do frame e escrita da memória
localparam N_WIDTH = (CAM_WIDTH - WIDTH ) / 2;
localparam N_HEIGHT = (CAM_HEIGHT - HEIGHT) / 2;
always @(posedge PCLK)
if (~VSYNC) wr_addr <= 0;
else if (pixel_valid && wr_addr < MEM_DEPTH) begin
    if (h_cnt >= N_WIDTH && h_cnt < (N_WIDTH+WIDTH) &&
        v_cnt >= N_HEIGHT && v_cnt < (N_HEIGHT+HEIGHT)) begin
        mem[wr_addr] <= pixel_in[15:8];
        wr_addr <= wr_addr + 1'b1;
    end
end

// Definição dos pixels válidos
reg [$clog2(WIDTH*HEIGHT)-1:0] n_pos;
always @(posedge pixel_clk) begin
    if (n_pos == (MEM_DEPTH-1))
    n_pos <= 0;
    else if (h_pos >= N_WIDTH && h_pos < (WIDTH+N_WIDTH) &&
             v_pos >= N_HEIGHT && v_pos < (HEIGHT+N_HEIGHT))
    n_pos <= n_pos + 1;
end

// Leitura da memória
reg [$clog2(MEM_DEPTH)-1:0] rd_addr;
always @(posedge pixel_clk) begin
    rd_addr <= n_pos;
    if (h_pos >= N_WIDTH && h_pos < (WIDTH + N_WIDTH) &&
        v_pos >= N_HEIGHT && v_pos < (HEIGHT + N_HEIGHT))
    data_out <= mem[rd_addr];
    else
    data_out <= 8'h00;
end
endmodule
