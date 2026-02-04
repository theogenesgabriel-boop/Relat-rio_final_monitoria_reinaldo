module top (
  input sys_clk, n_rst, rx,
  output tx,
  output [5:0] led
);

  pll PLL_U(
    .sys_clk(sys_clk),
    .pll_clk(pll_clk)
  );

  localparam DATA_BITS = 8;
  wire pll_clk, sys_clk, n_rst, rx, tx, clk, valid_out;
  wire [5:0] led;
  wire [DATA_BITS-1:0] data;

  clock #(.BAUD_RATE(115200)) CLK_U(
    .pll_clk(pll_clk),
    .n_rst(n_rst),
    .clk(clk)
  );

  uart_rx #(.DATA_BITS(DATA_BITS), .STOP_BITS(1)) RX_U(
    .clk(clk),
    .n_rst(n_rst),
    .rx(rx),
    .valid_out(valid_out),
    .data_out(data_out),
    .led(led)
  );

  uart_tx #(.DATA_BITS(DATA_BITS), .STOP_BITS(1)) TX_U(
    .clk(clk),
    .n_rst(n_rst),
  );
  
endmodule 