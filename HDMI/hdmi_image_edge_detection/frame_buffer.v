module frame_buffer #(parameter WIDTH=534, HEIGHT=400)(
    input uart_clk, pixel_clk, uart_rx_valid,
    input [7:0] data_in,
    input [$clog2(640)-1:0] h_pos,
    input [$clog2(480)-1:0] v_pos,
    output reg [7:0] data_out
);

localparam MEM_DEPTH = WIDTH * HEIGHT;

// Configuração de memória RAM
(* ram_style = "block" *)
reg [7:0] mem [0:MEM_DEPTH-1];

// Ponteiro de escrita
reg [$clog2(MEM_DEPTH)-1:0] wr_addr;

// Escrita da memória
always @(posedge uart_clk) begin
    if (wr_addr < MEM_DEPTH) begin
        if (uart_rx_valid) begin
            mem[wr_addr] <= data_in;
            wr_addr <= wr_addr + 1;
        end
    end
    else if(uart_rx_valid && data_in == 8'b10101010)
    wr_addr <= 0;
end

// Definição dos pixels válidos
localparam N_WIDTH = (640 - WIDTH) / 2;
localparam N_HEIGHT = (480 - HEIGHT) / 2;
reg [$clog2(WIDTH*HEIGHT)-1:0] n_pos;
always @(posedge pixel_clk) begin
    if (n_pos == MEM_DEPTH-1)
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
