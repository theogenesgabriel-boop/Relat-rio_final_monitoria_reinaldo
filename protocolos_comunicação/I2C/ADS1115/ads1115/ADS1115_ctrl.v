module ADS1115_ctrl (
    input clk_in, n_rst,
    input i2c_ready_in, i2c_wr_valid_in, i2c_rd_valid_in,
    input [7:0] i2c_rd_data_in,
    input uart_rx_valid_in,
    input [7:0] uart_rx_data_in,
    input uart_tx_ready_in, uart_tx_valid_in,
    output i2c_rd_wr, i2c_continuous, i2c_en,
    output [6:0] i2c_address,
    output [5:0] i2c_data_bytes,
    output [7:0] i2c_wr_data,
    output uart_tx_en,
    output [7:0] uart_tx_data
);
// Declaração dos estados simbólicos
localparam reg [4:0]
IDLE = 5'd0,
ADDRESS = 5'd1,
CONFIG = 5'd2,
CONFIG_PARAM_1 = 5'd3,
CONFIG_PARAM_2 = 5'd4,
LO_THRESH = 5'd5,
LO_THRESH_PARAM_1 = 5'd6,
LO_THRESH_PARAM_2 = 5'd7,
HI_THRESH = 5'd8,
HI_THRESH_PARAM_1 = 5'd9,
HI_THRESH_PARAM_2 = 5'd10,
CONVERSION = 5'd11,
CONVERSION_READ = 5'd12,
DATA_BYTE_1 = 5'd13,
DATA_BYTE_2 = 5'd14,
UART_TX_DATA_1 = 5'd15,
UART_TX_DATA_2 = 5'd16,
TIMER = 5'd17;
// Seleção de endereço
localparam reg [6:0] ADDRESS_GND = 7'b1001000;
localparam reg [6:0] ADDRESS_VDD = 7'b1001001;
localparam reg [6:0] ADDRESS_SDA = 7'b1001010;
localparam reg [6:0] ADDRESS_SCL = 7'b1001011;
// Mapa de registradores
localparam reg [7:0] CONVERSION_REGISTER = 8'b00000000;
localparam reg [7:0] CONFIG_REGISTER = 8'b00000001;
localparam reg [7:0] LO_THRESH_REGISTER = 8'b00000010;
localparam reg [7:0] HI_THRESH_REGISTER = 8'b00000011;
// Parâmetros para os registradores
localparam reg [7:0] CONFIG_PARAM_1_DATA = 8'b11000010;
localparam reg [7:0] CONFIG_PARAM_2_DATA = 8'b10001000;
localparam reg [7:0] LO_THRESH_PARAM_1_DATA = 8'b00000000;
localparam reg [7:0] LO_THRESH_PARAM_2_DATA = 8'b00000010;
localparam reg [7:0] HI_THRESH_PARAM_1_DATA = 8'b01001110;
localparam reg [7:0] HI_THRESH_PARAM_2_DATA = 8'b00100000;
// Intervalo de tempo entre amostras
localparam TIMER_PARAM = 96*10**6;  // 1 segundo
// Declaração dos sinais
reg [4:0] state, next_state;
reg [26:0] clk_cnt, next_clk;
reg [6:0] i2c_address_reg, next_i2c_address;
reg [7:0] i2c_wr_data_reg, next_i2c_wr_data;
reg [7:0] i2c_rd_data_1_reg, next_i2c_rd_data_1;
reg [7:0] i2c_rd_data_2_reg, next_i2c_rd_data_2;
reg [7:0] uart_tx_data_reg, next_uart_tx_data;
reg [5:0] i2c_data_bytes_reg, next_i2c_data_bytes;
reg i2c_rd_wr_reg, next_i2c_rd_wr;
reg i2c_continuous_reg, next_i2c_continuous;
reg i2c_en_reg, next_i2c_en;
reg uart_tx_en_reg, next_uart_tx_en;
reg writting_reg, next_writting;
// Registradores da máquina de estados para o controlador do conversor ADS1115
always @(posedge clk_in, negedge n_rst)
if (~n_rst) begin
    state <= IDLE;
    clk_cnt <= 0;
    i2c_address_reg <= 0;
    i2c_wr_data_reg <= 0;
    i2c_data_bytes_reg <= 0;
    i2c_rd_wr_reg <= 1'b0;    
    i2c_continuous_reg <= 1'b0;
    i2c_rd_data_1_reg <= 0;
    i2c_rd_data_2_reg <= 0;
    i2c_en_reg <= 1'b0;
    uart_tx_data_reg <= 0;
    uart_tx_en_reg <= 1'b0;
    writting_reg <= 1'b0;
end
else begin
    state <= next_state;
    clk_cnt <= next_clk;
    i2c_address_reg <= next_i2c_address;
    i2c_wr_data_reg <= next_i2c_wr_data;
    i2c_data_bytes_reg <= next_i2c_data_bytes;
    i2c_rd_wr_reg <= next_i2c_rd_wr;    
    i2c_continuous_reg <= next_i2c_continuous;
    i2c_rd_data_1_reg <= next_i2c_rd_data_1;
    i2c_rd_data_2_reg <= next_i2c_rd_data_2;
    i2c_en_reg <= next_i2c_en;
    uart_tx_data_reg <= next_uart_tx_data;
    uart_tx_en_reg <= next_uart_tx_en;
    writting_reg <= next_writting;
end
// Lógica combinacional da máquina de estados para o controlador do conversor ADS1115
always @(*) begin
    next_state = state;
    next_clk = clk_cnt;
    next_i2c_address = i2c_address_reg;
    next_i2c_wr_data = i2c_wr_data_reg;
    next_i2c_data_bytes = i2c_data_bytes_reg;
    next_i2c_rd_wr = i2c_rd_wr_reg;    
    next_i2c_continuous = i2c_continuous_reg;
    next_i2c_rd_data_1 = i2c_rd_data_1_reg;
    next_i2c_rd_data_2 = i2c_rd_data_2_reg;
    next_i2c_en = i2c_en_reg;
    next_uart_tx_data = uart_tx_data_reg;
    next_uart_tx_en = uart_tx_en_reg;
    next_writting = writting_reg;
    case (state)
    IDLE: begin
        next_uart_tx_en = 1'b0;
        if (i2c_ready_in && uart_rx_valid_in) begin
            next_i2c_address = ADDRESS_GND;
            case (uart_rx_data_in)
            "c":
            next_state = CONFIG;
            "l":
            next_state = LO_THRESH;
            "h":
            next_state = HI_THRESH;
            "r":
            next_state = CONVERSION;
            endcase
        end
    end
    CONFIG:
    if (i2c_ready_in) begin
        next_i2c_wr_data = CONFIG_REGISTER;
        next_i2c_rd_wr = 1'b0;
        next_i2c_data_bytes = 3;
        next_i2c_continuous = 1'b1;
        next_i2c_en = 1'b1;
        next_writting = 1'b1;
    end
    else if (writting_reg && ~i2c_ready_in) begin
        next_i2c_en = 1'b0;
        next_writting = 1'b0;
        next_state = CONFIG_PARAM_1;
    end
    CONFIG_PARAM_1:
    if (i2c_wr_valid_in) begin
        next_i2c_wr_data = CONFIG_PARAM_1_DATA;
        next_state = CONFIG_PARAM_2;
    end
    CONFIG_PARAM_2:
    if (i2c_wr_valid_in) begin
        next_i2c_wr_data = CONFIG_PARAM_2_DATA;
        next_state = IDLE;
    end
    LO_THRESH:
    if (i2c_ready_in) begin
        next_i2c_wr_data = LO_THRESH_REGISTER;
        next_i2c_rd_wr = 1'b0;
        next_i2c_data_bytes = 3;
        next_i2c_continuous = 1'b1;
        next_i2c_en = 1'b1;
        next_writting = 1'b1;
    end
    else if (writting_reg && ~i2c_ready_in) begin
        next_i2c_en = 1'b0;
        next_writting = 1'b0;
        next_state = LO_THRESH_PARAM_1;
    end
    LO_THRESH_PARAM_1:
    if (i2c_wr_valid_in) begin
        next_i2c_wr_data = LO_THRESH_PARAM_1_DATA;
        next_state = LO_THRESH_PARAM_2;
    end
    LO_THRESH_PARAM_2:
    if (i2c_wr_valid_in) begin
        next_i2c_wr_data = LO_THRESH_PARAM_2_DATA;
        next_state = IDLE;
    end
    HI_THRESH:
    if (i2c_ready_in) begin
        next_i2c_wr_data = HI_THRESH_REGISTER;
        next_i2c_rd_wr = 1'b0;
        next_i2c_data_bytes = 3;
        next_i2c_continuous = 1'b1;
        next_i2c_en = 1'b1;
        next_writting = 1'b1;
    end
    else if (writting_reg && ~i2c_ready_in) begin
        next_i2c_en = 1'b0;
        next_writting = 1'b0;
        next_state = HI_THRESH_PARAM_1;
    end
    HI_THRESH_PARAM_1:
    if (i2c_wr_valid_in) begin
        next_i2c_wr_data = HI_THRESH_PARAM_1_DATA;
        next_state = HI_THRESH_PARAM_2;
    end
    HI_THRESH_PARAM_2:
    if (i2c_wr_valid_in) begin
        next_i2c_wr_data = HI_THRESH_PARAM_2_DATA;
        next_state = IDLE;
    end
    CONVERSION:
    if (i2c_ready_in) begin
        next_i2c_wr_data = CONVERSION_REGISTER;
        next_i2c_rd_wr = 1'b0;
        next_i2c_data_bytes = 1;
        next_i2c_continuous = 1'b0;
        next_i2c_en = 1'b1;
        next_writting = 1'b1;
    end
    else if (writting_reg && ~i2c_ready_in) begin
        next_i2c_en = 1'b0;
        next_writting = 1'b0;
        next_state = CONVERSION_READ;
    end
    CONVERSION_READ:
    if (i2c_ready_in) begin
        next_i2c_rd_wr = 1'b1;
        next_i2c_data_bytes = 2;
        next_i2c_continuous = 1'b1;
        next_i2c_en = 1'b1;
        next_writting = 1'b1;
    end
    else if (writting_reg && ~i2c_ready_in) begin
        next_i2c_en = 1'b0;
        next_writting = 1'b0;
        next_state = DATA_BYTE_1;
    end
    DATA_BYTE_1:
    if (i2c_rd_valid_in) begin
        next_i2c_rd_data_1 = i2c_rd_data_in;
        next_state = DATA_BYTE_2;
    end
    DATA_BYTE_2:
    if (i2c_rd_valid_in) begin
        next_i2c_rd_data_2 = i2c_rd_data_in;
        next_state = UART_TX_DATA_1;
    end
    UART_TX_DATA_1:
    if (uart_tx_ready_in) begin
        next_uart_tx_data = i2c_rd_data_1_reg;
        next_uart_tx_en = 1'b1;
        next_writting = 1'b1;
    end
    else if (writting_reg && ~uart_tx_ready_in) begin
        next_uart_tx_en = 1'b0;
        next_writting = 1'b0;
        next_state = UART_TX_DATA_2;
    end
    UART_TX_DATA_2:
    if (uart_tx_ready_in) begin
        next_uart_tx_data = i2c_rd_data_2_reg;
        next_uart_tx_en = 1'b1;
        next_writting = 1'b1;
    end
    else if (writting_reg && ~uart_tx_ready_in) begin
        next_uart_tx_en = 1'b0;
        next_writting = 1'b0;
        next_state = TIMER;
    end
    TIMER:
    if (clk_cnt == TIMER_PARAM-1) begin
        next_clk = 0;
        if (uart_rx_data_in == "s")
        next_state = IDLE;
        else
        next_state = CONVERSION_READ;
    end
    else
    next_clk = clk_cnt + 1;
    endcase
end
// Direcionamento dos registradores para as saídas
assign i2c_rd_wr = i2c_rd_wr_reg;
assign i2c_continuous = i2c_continuous_reg;
assign i2c_en = i2c_en_reg;    
assign i2c_address = i2c_address_reg;
assign i2c_data_bytes = i2c_data_bytes_reg;
assign i2c_wr_data = i2c_wr_data_reg;
assign uart_tx_en = uart_tx_en_reg;
assign uart_tx_data = uart_tx_data_reg;

endmodule