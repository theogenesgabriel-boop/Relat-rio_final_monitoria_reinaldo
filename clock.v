module clock #(parameter BAUD_RATE = 9600) (
  input pll_clk, n_rst,
  output clk
);
  
  // BAUD_RATE: clk_div = [120MHz/(BAUD_RATE)*16] / 2 - 1

  always @(*) begin
    case(BAUD_RATE)
      4800: clk_div = 780;
      9600: clk_div = 390;
      14400: clk_div = 259;
      19200: clk_div = 194;
      38400: clk_div = 97;
      57600: clk_div = 64;
      115200: clk_div = 32;
      230400: clk_div = 15;
      460800: clk_div = 7;
      921600: clk_div = 3;
    endcase
  end

  // Divisor de frequência de clock
  reg [9:0] clk_div = 390;
  reg [9:0] clk_cnt = 0;
  reg clk_reg = 1'b0;

  always @(posedge pll_clk, negedge n_rst) begin
    if(~n_rst)
      clk_cnt <= 0;
    else begin
      if(clk_cnt == clk_div) begin
        clk_reg <= ~clk_reg;
        clk_cnt <= 0;
      end
      else
        clk_cnt <= 0;
    end
    else
      clk_cnt <= clk_cnt + 1;
  end

  assign clk = clk_reg;

endmodule