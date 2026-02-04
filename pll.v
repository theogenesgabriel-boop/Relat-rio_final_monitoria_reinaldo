module pll(
  input sys_clk,
  output pll_clk, pll_lock
);

  // For GW1NSR-4C C6/I5 (Tang Nano 4K proto dev board)
  PLLVR #(
    .FCLKIN("27"),
    // -> PFD = 3 MHz (range: 3-400 MHz)
    .IDIV_SEL(8), 
    // -> CLKOUT = 120 MHz (range: 4.6875-600 MHz)
    .FBDIV_SEL(39),
    // -> VCO = 960 MHz (range: 600-1200 MHz) 
    .ODIV_SEL(8) 
  ) pll (
    .CLKOUTP(), .CLKOUTD(), .CLKOUTD3(), 
    .RESET(1'b0), .RESET_P(1'b0), 
    .CLKFB(1'b0), 
    .FBDSEL(6'b0), 
    .IDSEL(6'b0), 
    .ODSEL(6'b0), 
    .PSDA(4'b0), 
    .DUTYDA(4'b0), 
    .FDLY(4'b0), 
    .VREN(1'b1),
    // 27 MHz
    .CLKIN(sys_clk), 
    // 120 MHz
    .CLKOUT(pll_clk), 
    .LOCK(pll_lock)
  );
endmodule