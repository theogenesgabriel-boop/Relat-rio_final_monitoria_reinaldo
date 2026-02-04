module i2c_master #(
    parameter CLK_IN_FREQ_MHZ = 10, // Frequência do clock de sistema (entrada)
    parameter SCL_FREQ_KHZ = 100,    // Frequência desejada para o barramento I2C
    parameter RETRY_NUM = 3          // Limite de tentativas de retransmissão após NACK
)(
    input clk_in, n_rst, 
    input rd_wr_in,      // Direção da operação: 1 para Leitura, 0 para Escrita
    input continuous_in, // Modo contínuo: 1 para leitura/escrita sequencial de bytes
    input enable_in,     // Pulso para iniciar a transação
    input [6:0] address_in,     // Endereço de 7 bits do dispositivo escravo
    input [5:0] data_bytes_in,  // Número de bytes a serem transferidos (máx 32)
    input [7:0] wr_data_in,     // Byte de dados para operação de escrita
    output ready_out,           // Indica que o barramento está livre/pronto
    output wr_valid_out,        // Pulso de confirmação de escrita de byte realizada
    output rd_valid_out,        // Pulso indicando que um novo byte foi lido
    output [7:0] rd_data_out,   // Saída de dados recebidos via I2C
    inout SCL, SDA              // Linhas bidirecionais físicas do protocolo I2C
);

/* Cálculo de Temporização:
   OVERSAMPLING define quantos ciclos de clk_in formam um ciclo de SCL.
   T_HD_DAT define o tempo de 'Hold' para garantir estabilidade dos dados.
*/
localparam OVERSAMPLING = (CLK_IN_FREQ_MHZ*10**6 / (SCL_FREQ_KHZ*10**3));
localparam T_HD_DAT = 2 * (CLK_IN_FREQ_MHZ / 10); 

// Definição dos Estados da FSM (Máquina de Estados Finita)
localparam reg [3:0]
    IDLE           = 4'b0000, // Estado de repouso
    START          = 4'b0001, // Condição de Início (SDA cai com SCL alto)
    ADDRESS        = 4'b0010, // Transmissão do endereço + bit R/W
    ADDRESS_ACK    = 4'b0011, // Recebimento do ACK do endereço
    WRITE_DATA     = 4'b0100, // Envio de 8 bits de dados ao escravo
    WRITE_DATA_ACK = 4'b0101, // Recebimento do ACK após dado enviado
    READ_DATA      = 4'b0110, // Captura de 8 bits vindos do escravo
    READ_DATA_ACK  = 4'b0111, // Geração de ACK/NACK pelo mestre (leitura)
    REP_START      = 4'b1000, // Condição de Start Repetido
    RETRY          = 4'b1001, // Gerenciamento de retransmissão em caso de erro
    STOP           = 4'b1010; // Condição de Parada (SDA sobe com SCL alto)

// Sinais internos e registradores de controle
wire SCL_line;
reg [3:0] state, next_state;
reg [$clog2(RETRY_NUM)-1:0] retry_cnt, next_retry;
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

/* Monitoramento do Estado do Barramento:
   Verifica se as linhas estão em nível alto (IDLE) por tempo suficiente
   antes de tentar iniciar uma nova comunicação.
*/
reg [$clog2(OVERSAMPLING)-1:0] SCL_busy_cnt = 0;
reg SCL_busy_reg = 1'b1;

always @(posedge clk_in)
    if (~SCL_line) begin
        SCL_busy_cnt <= 0;
        SCL_busy_reg <= 1'b1;
    end
    else if (SCL_busy_cnt == OVERSAMPLING-1) begin
        SCL_busy_cnt <= 0;
        SCL_busy_reg <= 1'b0; // Barramento considerado livre
    end
    else
        SCL_busy_cnt <= SCL_busy_cnt + 1;

/* Sincronismo de Clock (Clock Stretching):
   Implementa a verificação se o SCL físico acompanha o SCL pretendido pelo mestre.
   Essencial para permitir que escravos lentos pausem o mestre.
*/
reg sync_reg = 1'b0;
always @(negedge clk_in)
    sync_reg = (SCL_reg == SCL_line);

// Bloco Sequencial: Atualização dos registradores de estado e controle
always @(posedge clk_in, negedge n_rst)
    if (~n_rst) begin
        state <= IDLE;
        SCL_reg <= 1'b1;
        SDA_reg <= 1'b1;
        {clk_cnt, bit_cnt, byte_cnt} <= 0;
        ready_reg <= 1'b0;
        // ... inicialização dos demais sinais ...
    end else begin
        state <= next_state;
        retry_cnt <= next_retry;
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

// Lógica de Transição de Estados
always @(*) begin
    next_state = state;
    next_retry = retry_cnt;
    next_clk = clk_cnt;
    next_bit = bit_cnt;
    next_byte = byte_cnt;

    case (state)
        IDLE: // Aguarda trigger externo e barramento livre
            if (ready_reg && enable_in && data_bytes_in > 0) begin
                next_clk = 0;
                next_retry = 0;
                next_byte = data_bytes_in;
                next_state = START;
            end

        START: // Estabelece a condição de início do protocolo
            if (clk_cnt == OVERSAMPLING-1) begin
                next_clk = 0;
                next_bit = 0;
                next_state = ADDRESS;
            end else next_clk = clk_cnt + 1;

        ADDRESS: // Transmissão serial do endereço (MSB first)
            // Se houver conflito de barramento (SDA diferente do pretendido), tenta retransmitir
            if (clk_cnt == (78*OVERSAMPLING/100)-1 && SDA_reg != SDA_line)    
                next_state = RETRY;
            else if (clk_cnt == OVERSAMPLING-1) begin
                next_clk = 0;
                if (bit_cnt == 7) next_state = ADDRESS_ACK;
                else next_bit = bit_cnt + 1;
            end else if (sync_reg) next_clk = clk_cnt + 1;

        ADDRESS_ACK: // Amostragem do bit de resposta do escravo
            if (clk_cnt == OVERSAMPLING-1) begin
                if (~ack_reg) begin // ACK recebido (0)
                    next_clk = 0;
                    next_bit = 0;
                    next_state = (rd_wr_in) ? READ_DATA : WRITE_DATA;
                end else next_state = RETRY; // NACK recebido
            end else if (sync_reg) next_clk = clk_cnt + 1;

        WRITE_DATA: // Escrita serial do byte de dados
            if (clk_cnt == (78*OVERSAMPLING/100)-1 && SDA_reg != SDA_line)
                next_state = RETRY;
            else if (clk_cnt == OVERSAMPLING-1) begin
                next_clk = 0;
                if (bit_cnt == 7) begin
                    next_byte = byte_cnt - 1;           
                    next_state = WRITE_DATA_ACK;
                end else next_bit = bit_cnt + 1;
            end else if (sync_reg) next_clk = clk_cnt + 1;

        WRITE_DATA_ACK: // Confirmação de recebimento do dado pelo escravo
            if (clk_cnt == OVERSAMPLING-1) begin
                next_clk = 0;
                if (~ack_reg) // Sucesso
                    if (byte_cnt > 0) 
                        next_state = (continuous_in) ? WRITE_DATA : REP_START;
                    else next_state = STOP;
                else next_state = RETRY;
            end else if (sync_reg) next_clk = clk_cnt + 1;

        READ_DATA: // Captura serial de dados enviados pelo escravo
            if (clk_cnt == OVERSAMPLING-1) begin
                next_clk = 0;
                if (bit_cnt == 7) begin
                    next_byte = byte_cnt - 1;            
                    next_state = READ_DATA_ACK;
                end else next_bit = bit_cnt + 1;
            end else if (sync_reg) next_clk = clk_cnt + 1;

        READ_DATA_ACK: // Mestre gera ACK para continuar leitura ou NACK para finalizar
            if (clk_cnt == OVERSAMPLING-1) begin
                next_clk = 0;
                if (byte_cnt > 0)
                    next_state = (continuous_in) ? READ_DATA : REP_START;
                else next_state = STOP;
            end else if (sync_reg) next_clk = clk_cnt + 1;

        REP_START: // Reinício da transação (ex: mudar de escrita para leitura)
            if (clk_cnt == (55*OVERSAMPLING/100)-1) begin
                next_clk = 0;
                next_state = START;
            end else next_clk = clk_cnt + 1;

        RETRY: // Controle de tentativas em caso de erro no barramento
            if (retry_cnt == RETRY_NUM) next_state = IDLE;
            else if (~SCL_busy_reg) begin
                next_clk = 0;
                next_bit = 0;
                next_retry = retry_cnt + 1;
                next_state = START;
            end

        STOP: // Finaliza a transação e libera o barramento
            if (clk_cnt == OVERSAMPLING-1) next_state = IDLE;
            else if (sync_reg) next_clk = clk_cnt + 1;
    endcase
end

// Gerenciamento dos sinais SCL e SDA (Saídas)
// Utiliza lógica de coletor aberto: '0' força a linha, 'Z' permite que o pull-up a mantenha em '1'
assign SCL = SCL_reg ? 1'bZ : 1'b0;
assign SDA = SDA_reg ? 1'bZ : 1'b0;

// Os sinais SCL_line e SDA_line permitem ler o estado real do pino físico
assign SCL_line = SCL;
assign SDA_line = SDA;

// Sinais de saída para o usuário
assign ready_out = ready_reg;
assign wr_valid_out = wr_valid_reg;
assign rd_valid_out = rd_valid_reg;
assign rd_data_out = rd_data_reg;

endmodule