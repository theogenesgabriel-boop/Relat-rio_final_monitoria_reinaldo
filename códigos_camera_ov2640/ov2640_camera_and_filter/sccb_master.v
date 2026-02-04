module sccb_master #(parameter CLK_IN_FREQ_MHZ=10, SCL_FREQ_KHZ=100)(
    input clk_in, n_rst,
    input three_phase_in, rd_wr_in, enable_in,
    input [6:0] address_in,
    input [7:0] wr_data_in,
    output ready_out, wr_valid_out, rd_valid_out,
    output [7:0] rd_data_out,
    inout SCL, SDA
);

/* Cálculo dos parâmetros OVERSAMPLING e T_HD_CNT, considerando CLK_IN_FREQ entre 10 MHz e 100 MHz,
múltiplo de 10 MHz, e SCL_FREQ entre 1 kHz e 400 kHz */
localparam OVERSAMPLING = (CLK_IN_FREQ_MHZ*10**6 / (SCL_FREQ_KHZ*10**3));
localparam T_HD_DAT = 2 * (CLK_IN_FREQ_MHZ / 10);   // t_HD;DAT = 200 ns

// Declaração dos estados simbólicos
localparam reg [3:0]
IDLE = 4'b0000,
START = 4'b0001,
ADDRESS = 4'b0010,
ADDRESS_DC = 4'b0011,
WRITE_DATA = 4'b0100,
WRITE_DATA_DC = 4'b0101,
READ_DATA = 4'b0110,
READ_DATA_ACK = 4'b0111,
STOP = 4'b1010;

// Declaração dos sinais
wire SCL_line;
reg [3:0] state, next_state;
reg SCL_reg, next_SCL;
reg SDA_reg, next_SDA;
reg [$clog2(OVERSAMPLING)-1:0] clk_cnt, next_clk;
reg [2:0] bit_cnt, next_bit;
reg [5:0] byte_cnt, next_byte;
reg [6:0] address_reg, next_address;
reg rd_wr_reg, next_rd_wr;
reg [7:0] wr_data_reg, next_wr_data;
reg [7:0] rd_data_reg, next_rd_data;
reg ready_reg, next_ready;
reg wr_valid_reg, next_wr_valid;
reg rd_valid_reg, next_rd_valid;
reg [7:0] word_reg, next_word;
reg ack_reg, next_ack;

/* Verificação da disponibilidade da linha SCL: período mínimo
para "bus free condition": ~1/2 ciclo de SCL em nível alto */
reg [$clog2(OVERSAMPLING)-1:0] SCL_busy_cnt = 0;
reg SCL_busy_reg = 1'b1;
always @(posedge clk_in)
if (~SCL_line) begin
    SCL_busy_cnt <= 0;
    SCL_busy_reg <= 1'b1;
end
else if (SCL_busy_cnt == OVERSAMPLING-1) begin
    SCL_busy_cnt <= 0;
    SCL_busy_reg <= 1'b0;
end
else
SCL_busy_cnt <= SCL_busy_cnt + 1;

/* Verificação do sincronismo entre SCL_reg e SCL_line, feita no flanco
negativo do clk_in para pausar a contagem de clock no próximo flanco de subida */
reg sync_reg = 1'b0;
always @(negedge clk_in)
if (SCL_reg == SCL_line)
sync_reg = 1'b1;
else
sync_reg = 1'b0;

// Registradores para a máquina de estados do comunicador I2C
always @(posedge clk_in, negedge n_rst)
if (~n_rst) begin
    state <= IDLE;
    SCL_reg <= 1'b1;
    SDA_reg <= 1'b1;
    clk_cnt <= 0;
    bit_cnt <= 0;
    byte_cnt <= 0;
    address_reg <= 0;
    rd_wr_reg <= 1'b0;
    wr_data_reg <= 0;
    rd_data_reg <= 0;
    ready_reg <= 1'b0;
    wr_valid_reg <= 1'b0;
    rd_valid_reg <= 1'b0;
    word_reg <= 0;
    ack_reg <= 1'b1;
end
else begin
    state <= next_state;
    SCL_reg <= next_SCL;
    SDA_reg <= next_SDA;
    clk_cnt <= next_clk;
    bit_cnt <= next_bit;
    byte_cnt <= next_byte;
    address_reg <= next_address;
    rd_wr_reg <= next_rd_wr;
    wr_data_reg <= next_wr_data;
    rd_data_reg <= next_rd_data;
    ready_reg <= next_ready;
    wr_valid_reg <= next_wr_valid;
    rd_valid_reg <= next_rd_valid;
    word_reg <= next_word;
    ack_reg <= next_ack;
end

// Lógica combinacional para as transições entre estados
always @(*) begin
    next_state = state;
    next_clk = clk_cnt;
    next_bit = bit_cnt;
    next_byte = byte_cnt;
    case (state)
    IDLE:
    if (ready_reg && enable_in) begin
        next_clk = 0;
        next_byte = (three_phase_in) ? 2 : 1;
        next_state = START;
    end
    START:
    if (clk_cnt == OVERSAMPLING-1) begin
        next_clk = 0;
        next_bit = 0;
        next_state = ADDRESS;
    end
    else
    next_clk = clk_cnt + 1;
    ADDRESS:
    if (clk_cnt == (78*OVERSAMPLING/100)-1 && SDA_reg != SDA_line)    
    next_state = STOP;
    else if (clk_cnt == OVERSAMPLING-1) begin
        next_clk = 0;
        if (bit_cnt == 7)
        next_state = ADDRESS_DC;
        else
        next_bit = bit_cnt + 1;
    end
    else if (sync_reg)
    next_clk = clk_cnt + 1;
    ADDRESS_DC:
    if (clk_cnt == OVERSAMPLING-1) begin
        next_clk = 0;
        next_bit = 0;
        if (~rd_wr_in)
        next_state = WRITE_DATA;
        else
        next_state = READ_DATA;
    end
    else if (sync_reg)
    next_clk = clk_cnt + 1;
    WRITE_DATA:
    if (clk_cnt == (78*OVERSAMPLING/100)-1 && SDA_reg != SDA_line)
    next_state = STOP;
    else if (clk_cnt == OVERSAMPLING-1) begin
        next_clk = 0;
        if (bit_cnt == 7) begin
            next_byte = byte_cnt - 1;           
            next_state = WRITE_DATA_DC;
        end
        else
        next_bit = bit_cnt + 1;
    end
    else if (sync_reg)
    next_clk = clk_cnt + 1;
    WRITE_DATA_DC:
    if (clk_cnt == OVERSAMPLING-1) begin
        next_clk = 0;
        if (byte_cnt > 0) begin
            next_bit = 0;
            next_state = WRITE_DATA;
        end
        else
        next_state = STOP;
    end
    else if (sync_reg)
    next_clk = clk_cnt + 1;
    READ_DATA:
    if (clk_cnt == OVERSAMPLING-1) begin
        next_clk = 0;
        if (bit_cnt == 7) begin
            next_byte = byte_cnt - 1;            
            next_state = READ_DATA_ACK;
        end
        else
        next_bit = bit_cnt + 1;
    end
    else if (sync_reg)
    next_clk = clk_cnt + 1;
    READ_DATA_ACK:
    if (clk_cnt == OVERSAMPLING-1) begin
        next_clk = 0;
        next_state = STOP;
    end
    else if (sync_reg)
    next_clk = clk_cnt + 1;
    STOP:
    if (clk_cnt == OVERSAMPLING-1)
    next_state = IDLE;
    else if (sync_reg)
    next_clk = clk_cnt + 1;
    endcase
end

// Lógica combinacional para o clock serial SCL
always @(*) begin
    next_SCL = SCL_reg;
    case (state)
    IDLE:
    next_SCL = 1'b1;
    START:
    if (clk_cnt == OVERSAMPLING-1)
    next_SCL = 1'b0;
    ADDRESS_DC:
    if (clk_cnt == (55*OVERSAMPLING/100)-1)
    next_SCL = 1'b1;
    else if (clk_cnt == OVERSAMPLING-1)
    next_SCL = 1'b0;
    WRITE_DATA_DC:
    if (clk_cnt == (55*OVERSAMPLING/100)-1)
    next_SCL = 1'b1;
    else if (clk_cnt == OVERSAMPLING-1)
    next_SCL = 1'b0;
    STOP:
    if (clk_cnt == (55*OVERSAMPLING/100)-1)
    next_SCL = 1'b1;
    default:
    if (clk_cnt == (55*OVERSAMPLING/100)-1)
    next_SCL = 1'b1;
    else if (clk_cnt == OVERSAMPLING-1)
    next_SCL = 1'b0;
    endcase
end

// Lógica combinacional para a linha serial de dados SDA e para os demais registradores
always @(*) begin
    next_SDA = SDA_reg;
    next_address = address_reg;
    next_rd_wr = rd_wr_reg;
    next_wr_data = wr_data_reg;
    next_rd_data = rd_data_reg;
    next_ready = ready_reg;
    next_wr_valid = wr_valid_reg;
    next_rd_valid = rd_valid_reg;
    next_word = word_reg;
    next_ack = ack_reg;
    case (state)
    IDLE:
    if (ready_reg && enable_in) begin
        next_address = address_in;
        next_rd_wr = rd_wr_in;
        if (~rd_wr_in)              // se operação = escrita
        next_wr_data = wr_data_in;
        next_ready = 1'b0;
    end
    else begin
        if (~SCL_busy_reg)
        next_ready = 1'b1;
        next_wr_valid = 1'b0;
        next_rd_valid = 1'b0;
        next_SDA = 1'b1;
    end
    START: begin
        if (clk_cnt == (55*OVERSAMPLING/100)-1)
        next_SDA = 1'b0;
        next_word = {address_reg, rd_wr_reg};
    end
    ADDRESS:
    if (clk_cnt == T_HD_DAT-1)      // t_hd;dat = 200 ns
    next_SDA = word_reg[7];
    else if (clk_cnt == (78*OVERSAMPLING/100)-1)
    next_word = word_reg << 1;
    ADDRESS_DC:
    if (clk_cnt == T_HD_DAT-1)      // t_hd;dat = 200 ns
    next_SDA = 1'b1;                // permite verificar o ADDRESS_ACK
    else if (clk_cnt == (78*OVERSAMPLING/100)-1)
    next_ack = SDA_line;
    else if (clk_cnt == OVERSAMPLING-1 && ~rd_wr_in)
    next_word = {wr_data_reg};
    WRITE_DATA:
    if (clk_cnt == T_HD_DAT-1)      // t_hd;dat = 200 ns
    next_SDA = word_reg[7];
    else if (clk_cnt == (78*OVERSAMPLING/100)-1)
    next_word = word_reg << 1;
    WRITE_DATA_DC:
    if (clk_cnt == T_HD_DAT-1)      // t_hd;dat = 200 ns
    next_SDA = 1'b1;                // permite verificar o WRITE_DATA_ACK
    else if (clk_cnt == (78*OVERSAMPLING/100)-1) begin
        next_ack = SDA_line;
        next_wr_valid = 1'b1;
    end
    else if (clk_cnt == (78*OVERSAMPLING/100))
    next_wr_valid = 1'b0;
    else if (clk_cnt == OVERSAMPLING-1 && byte_cnt > 0) begin
        next_wr_data = wr_data_in;
        if (three_phase_in)
        next_word = wr_data_in;
    end
    READ_DATA:
    if (clk_cnt == T_HD_DAT-1)      // t_hd;dat = 200 ns
    next_SDA = 1'b1;                // permite leitura da linha SDA em modo contínuo
    else if (clk_cnt == (78*OVERSAMPLING/100)-1)
    next_word[7] = SDA_line;
    else if (clk_cnt == OVERSAMPLING-1)
    next_word = (word_reg << 1) | (word_reg >> 7);
    READ_DATA_ACK:
    if (clk_cnt == T_HD_DAT-1)      // t_hd;dat = 200 ns
        if (byte_cnt == 0)
        next_SDA = 1'b1;            // NACK
        else
        next_SDA = 1'b0;            // ACK
    else if (clk_cnt == (78*OVERSAMPLING/100)-1) begin
        next_rd_data = word_reg;
        next_rd_valid = 1'b1;
    end
    else if (clk_cnt == 78*OVERSAMPLING/100)
    next_rd_valid = 1'b0;
    STOP:
    if (clk_cnt == T_HD_DAT-1)      // t_hd;dat = 200 ns
    next_SDA = 1'b0;
    else if (clk_cnt == OVERSAMPLING-1)
    next_SDA = 1'b1;
    endcase
end

// Direcionamento dos registradores para as saídas
assign ready_out = ready_reg;
assign wr_valid_out = wr_valid_reg;
assign rd_valid_out = rd_valid_reg;
assign SCL = SCL_reg ? 1'bZ : 1'b0;
assign SCL_line = SCL;
assign SDA = SDA_reg ? 1'bZ : 1'b0;
assign SDA_line = SDA;
assign rd_data_out = rd_data_reg;

endmodule
