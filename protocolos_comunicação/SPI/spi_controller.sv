module spi_controller (
    input logic clk,
    input logic rst,
    input logic start,
    // deve ser 2'b11 (4 palavras)
    input logic [1:0] data_words,        
    input logic tied_SS,
    input logic [7:0] tx_data[4],
    output logic [7:0] rx_data[4],
    output logic done,

    // SPI signals
    output logic SCLK,
    output logic MOSI,
    input logic MISO,
    output logic SS
);

    // Estados do FSM
    typedef enum logic [1:0] {
        IDLE,
        SEND,
        WAIT,
        FINISH
    } state_t;

    state_t state, next_state;

    logic [1:0] word_index;
    logic spi_start, spi_busy;
    logic [7:0] spi_tx_data, spi_rx_data;
    logic spi_done;

    logic SS_internal;

    // Instância do spi_master
    spi_master spi_inst (
        .clk(clk),
        .rst(rst),
        .start(spi_start),
        .data_in(spi_tx_data),
        .data_out(spi_rx_data),
        .busy(spi_busy),
        .done(spi_done),
        .SCLK(SCLK),
        .MOSI(MOSI),
        .MISO(MISO),
        .SS(SS_internal)
    );

    

    // Controle de SS externo baseado no tied_SS
    assign SS = tied_SS ? 
      SS_internal : (state == SEND ? SS_internal : 1'b1);

    // FSM de controle
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            word_index <= 0;
            done <= 0;
        end else begin
            state <= next_state;
            if (state == IDLE && start) begin
                word_index <= 0;
                done <= 0;
            end else if (state == SEND && spi_done) begin
                rx_data[word_index] <= spi_rx_data;
                word_index <= word_index + 1;
            end else if (state == FINISH) begin
                done <= 1;
            end
        end
    end

    // Transição de estados
    always @(*) begin
        next_state = state;
        spi_start = 0;
        spi_tx_data = tx_data[word_index];

        case (state)
            IDLE: begin
                if (start)
                    next_state = SEND;
            end

            SEND: begin
                if (!spi_busy && !spi_done)
                    spi_start = 1;
                else if (spi_done)
                    next_state = (word_index == data_words - 1) ? FINISH : WAIT;
            end

            WAIT: begin
                next_state = SEND;
            end

            FINISH: begin
                next_state = IDLE;
            end
        endcase
    end

endmodule
