module switch (
    input sel_btn,
    input [7:0] signal_1, signal_2,
    output [7:0] signal_out
);

assign signal_out = (sel_btn) ? signal_1 : signal_2;

endmodule