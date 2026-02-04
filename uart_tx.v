module uart_tx #(parameter DATA_BITS = 8, STOP_BITS = 1) uart_tx(
  input clk, n_rst, valid_in,
  input [DATA_BITS-1:0] data_in,
  output tx, ready_out
);

  // Declaração dos estados simbolicos
  localparam reg [1:0]
    idle = 2'b00,
    start = 2'b01,
    data = 2'b10,
    stop = 2'b11;

  // Declaração dos registradores
  reg tx_reg = 1'b1;
  reg next_tx;
  reg ready_reg, next_ready;
  // registro dos dados
  reg [DATA_BITS - 1:0] data_reg, next_data;
  // estados
  reg [1:0] state, next_state;
  // contador de clock
  reg [4:0] clk_cnt, next_clk_cnt;
  // contagem de bits para transmitir
  reg [2:0] bit_cnt, next_bit;

  // Registrador da máquina de estados

  // Equivalente ao bloco always_ff
  // Registradores da máquina de estados para o transmissor UART
  always @(posedge clk, negedge n_rst) begin
    if(~n_rst) begin
      // Forçamos a máquina para o estado de repouso
      state <= idle;

      // Transmissor transmite nível lógico ALTO
      tx_reg <= 1'b1;

      // Zerar o registrador de prontidão do envio
      ready_reg <= 1'b0;
      // Zerar registrador de dados
      data_reg <= '0;
      // Zerar clk
      clk_reg <= 0;
      // Zerar contagem de bits
      bit_cnt <= 0;
    end
    else begin
      state <= next_state;
      tx_reg <= next_tx;
      ready_reg <= next_ready;
      clk_cnt <= next_clk_cnt;
      bit_cnt <= next_bit;
      data_reg <= next_data;
    end
  end

  // Lógica combinacional da máquina de estados para o transmissor UART
  // Todas as variáveis presentes nesse bloco farão parte da lista sensitiva
  always @(*) begin
    // Valores atuais permanecem
    next_state = state;
    next_tx = tx_reg;
    next_ready = ready_reg;
    next_clk = clk_cnt;
    next_bit = bit_cnt;
    next_data = data_reg;

    case (state)
      // se estiver em repouso...
      idle: begin
        // indica o estado de repouso do tx (1 indica que não está enviando nada)
        next_tx = 1'b1;
        // envio a informação de que pode ser transmitido
        next_ready = 1'b1;
        // se receber um sinal de que há uma informação para transmitir
        if(valid_in) begin
          // prepara o envio do dado
          next_data = data_in;
          // zera o clock
          next_clk = 0;
          next_state = start;
        end
      end
      start: begin
        // se já recebemos os dados

        // não está pronta para receber informações
        next_ready = 1'b0;
        // indica que está 
        next_tx = 1'b0;
        if(clk_cnt == 15) begin
          // se passaram 15 ciclos de clock
          next_clk_cnt = 0;
          next_bit = 0;
          next_state = data;
        end
        else begin
          next_clk_cnt = clk_cnt + 1;
        end
      end
      data: begin
        // Aqui os bits são enviados um de cada vez.
        // Toda vez que entra dentro desse estado,
        // 1 bit de dado (do data_reg) é enviado.
        next_tx = data_reg[0];
        if(clk_cnt == 15) begin
          next_clk = 0;
          // fazemos o deslocamento de bits do registrador de dados
          next_data = data_reg >> 1;

          if(bit_cnt == DATA_BITS - 1)
            next_state = stop;
          else
            next_bit = bit_cnt + 1;
        end
        else 
          next_clk = clk_cnt + 1;
      end
      stop: begin
        // Transmite-se o bit de stop
        next_tx = 1'b1;

        if(clk_cnt == (16 * STOP_BITS) - 1)
          next_state = idle;
        else
          next_clk = clk_cnt + 1;

      end
      default: 
    endcase
  end

  // Direcionamento dos registradores para as saídas
  assign tx = tx_reg;
  assign ready_out = ready_reg;

endmodule