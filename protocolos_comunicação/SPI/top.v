module top (
    input sys_clk, n_rst, MISO, rx,
    output SCK, MOSI, SS, tx
);

// Definição dos parâmetros dos módulos
localparam
// 120MHz
PLL_FREQ = 120000000,
// Do UART
UART_BAUD_RATE = 19200,
DATA_BITS = 8,


UART_OVERSAMPLING = 16,
UART_STOP_BITS = 1,
SPI_CPOL = 0,
SPI_CPHA = 0,
SPI_LSBF = 0,
SPI_BRDV = 4;

// Declaração das conexões vetoriais
wire [DATA_BITS-1:0] ctrl_uart_tx_data, ctrl_spi_data;
wire [5:0] ctrl_spi_data_words;
wire [DATA_BITS-1:0] spi_ctrl_data;
wire [DATA_BITS-1:0] uart_rx_ctrl_data;

pll PLL_U0(
    // entrada
    .sys_clk(sys_clk),
    // saídas
    .pll_clk(pll_clk),
    // não usado
    .pll_lock(pll_lock) 
);

clock_div #(.CLK_IN(PLL_FREQ), .CLK_OUT(UART_OVERSAMPLING*UART_BAUD_RATE)) CLK_DIV_U0(
    // entradas
    .clk_in(pll_clk),
    .n_rst(n_rst),
    // saída
    .clk_out(clk)
);

bmp280_ctrl BMP_U0(
    // entradas
    .clk(clk),
    .n_rst(n_rst),
    .uart_ready_in(uart_tx_ctrl_ready),
    .uart_valid_in(uart_rx_ctrl_valid),    
    .spi_ready_in(spi_ctrl_ready),     
    .spi_valid_in(spi_ctrl_valid),  
    .uart_data_in(uart_rx_ctrl_data),
    .spi_data_in(spi_ctrl_data),
    // saídas    
    .uart_en(ctrl_uart_tx_en),  
    .tied_SS(ctrl_spi_tied_SS),
    .spi_en(ctrl_spi_en),    
    .uart_data_out(ctrl_uart_tx_data),
    .spi_data_out(ctrl_spi_data),
    .spi_data_words(ctrl_spi_data_words)
);

spi_master #(.DATA_BITS(DATA_BITS), .CPOL(SPI_CPOL), .CPHA(SPI_CPHA), .BRDV(SPI_BRDV), .LSBF(SPI_LSBF)) SPI_M_U0(
    // entradas
    .clk(clk),
    .n_rst(n_rst),
    .spi_en(ctrl_spi_en),
    .tied_SS(ctrl_spi_tied_SS),    
    .MISO(MISO),
    .data_in(ctrl_spi_data),
    .data_words(ctrl_spi_data_words),
    // saídas
    .SCK(SCK),
    .SS(SS),
    .MOSI(MOSI),    
    .ready_out(spi_ctrl_ready),
    .valid_out(spi_ctrl_valid),
    .data_out(spi_ctrl_data) 
);

uart_rx #(.DATA_BITS(DATA_BITS), .STOP_BITS(UART_STOP_BITS), .OVERSAMPLING(UART_OVERSAMPLING)) UART_RX_U0(
    // entradas
    .clk(clk),
    .n_rst(n_rst),
    .rx(rx),
    // saídas
    // não usado
    .ready_out(),
    .valid_out(uart_rx_ctrl_valid),    
    .data_out(uart_rx_ctrl_data)
);

uart_tx #(.DATA_BITS(DATA_BITS), .STOP_BITS(UART_STOP_BITS), .OVERSAMPLING(UART_OVERSAMPLING)) UART_TX_U0(
    // entradas
    .clk(clk),
    .n_rst(n_rst),
    .uart_en(ctrl_uart_tx_en),
    .data_in(ctrl_uart_tx_data),
    // saídas
    .tx(tx),
    .ready_out(uart_tx_ctrl_ready)    
);

endmodule