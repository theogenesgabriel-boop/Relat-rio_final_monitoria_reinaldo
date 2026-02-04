`timescale 1ns/1ps

module tb_spi_controller;

  // Clock and reset
  logic clk;
  logic rst_n;

  // Inputs to controller
  logic start;
  logic [1:0] data_words;
  logic tied_SS;

  // SPI signals
  logic MISO;
  logic MOSI;
  logic SCLK;
  logic SS;

  // Inputs to controller (data to transmit)
  logic [7:0] tx_data [0:3];

  // Outputs from controller
  logic [7:0] rx_data [0:3];

  // Clock generation
  always #5 clk = ~clk;

  // Instantiate SPI Controller
  spi_controller controller (
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .data_words(data_words),
    .tied_SS(tied_SS),
    .tx_data(tx_data),
    .rx_data(rx_data),
    .MISO(MISO),
    .MOSI(MOSI),
    .SCLK(SCLK),
    .SS(SS)
  );

  // Emulate SPI slave response
  // (simplesmente reflete valor recebido, por exemplo)
  logic [7:0] slave_mem [0:3];
  integer bit_cnt = 0;
  integer word_idx = 0;
  logic [7:0] shift_reg;

  always_ff @(negedge SCLK) begin
    if (!SS) begin
      MISO <= slave_mem[word_idx][7 - bit_cnt];
    end
  end

  always_ff @(posedge SCLK) begin
    if (!SS) begin
      shift_reg[7 - bit_cnt] <= MOSI;
      bit_cnt <= bit_cnt + 1;

      if (bit_cnt == 7) begin
        $display("Slave received: %h", shift_reg);
        bit_cnt <= 0;
        word_idx <= word_idx + 1;
      end
    end
  end

  initial begin
    // Inicialização
    clk = 0;
    rst_n = 0;
    start = 0;
    tied_SS = 1;
    // 4 palavras -> 2'b11
    data_words = 2'd3;
    MISO = 0;

    slave_mem[0] = 8'hA1;
    slave_mem[1] = 8'hB2;
    slave_mem[2] = 8'hC3;
    slave_mem[3] = 8'hD4;

    tx_data[0] = 8'hFA;
    tx_data[1] = 8'hFB;
    tx_data[2] = 8'hFC;
    tx_data[3] = 8'hFE;

    #12 rst_n = 1;
    #10 start = 1;
    #10 start = 0;

    // Espera transmissão terminar
    #1000;

    // Mostra dados recebidos
    $display("Received data:");
    $display("rx_data[0] = %h", rx_data[0]);
    $display("rx_data[1] = %h", rx_data[1]);
    $display("rx_data[2] = %h", rx_data[2]);
    $display("rx_data[3] = %h", rx_data[3]);

    $finish;
  end

endmodule
