module tmds_clock (
    input pixel_clk,
    output tmds_clk_n, tmds_clk_p
);
// Direcionamento do clock TMDS
assign tmds_clk_n = ~pixel_clk;
assign tmds_clk_p = pixel_clk;
endmodule