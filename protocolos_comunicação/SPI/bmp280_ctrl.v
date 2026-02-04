module bmp280_ctrl (
    // uart_ready_in: Indica se o UART está preparado para fazer uma transmissão
    // uart_valid_in: Indica de o receptor do UART recebeu um dado válido
    // spi_ready_in: Indica se o SPI está pronto para a transferência de informações
    // spi_valid_in: Indica se o modo SPI concluiu esta transferência
    input clk, n_rst, uart_ready_in, uart_valid_in, spi_ready_in, spi_valid_in,
    // Byte recebido por meio da UART
    // Byte recebido por meio da SPI
    input [7:0] uart_data_in, spi_data_in,
    // tied_SS: Indica se o SS deve ficar ativo durante uma transferência 
    // consecutiva de palavras
    // spi_en: Habilitação da comunicação SPI
    // uart_en: Habilitação da comunicação UART
    output uart_en, tied_SS, spi_en,
    // Bytes recebidos da UART e do SPI
    output [7:0] uart_data_out, spi_data_out,
    // Indica a quantidade de palavras sequenciais que são necessárias 
    output [5:0] spi_data_words
);

// Declaração dos estados simbólicos
// Declaração dos estados simbólicos
localparam [4:0]
// Repouso
idle = 0,
// Endereço de identificação do sensor
add_id = 1,
// Valor de identificação do sensor
rd_id = 2,
// Endereço do status do sensor
add_status = 3,
// Leitura do status do sensor
rd_status = 4,
// Endereço de controle da medição
add_ctrl_meas = 5,
// Escrita do controle da medição 
wr_ctrl_meas = 6,
// Endereço da configuração
add_config = 7,
// Escrita da configuração
wr_config = 8,
// Endereço da informação da pressão (byte mais significativo)
add_press_msb = 9,
// Valor da informação da pressão (byte mais significativo)
rd_press_msb = 10,
// Endereço da informação da pressão (byte menos significativo)
add_press_lsb = 11,
// Valor da informação da pressão (byte menos significativo)
rd_press_lsb = 12,
// Endereço da informação da pressão (últimos 4 bits)
add_press_xlsb = 13,
// Valor da informação da pressão (últimos 4 bits)
rd_press_xlsb = 14,
// Endereço da informação da pressão (byte mais significativo)
add_temp_msb = 15,
// Valor da informação da temperatura (byte mais significativo)
rd_temp_msb = 16,
// Endereço da informação da temperatura (byte menos significativo)
add_temp_lsb = 17,
// Valor da informação da temperatura (byte menos significativo)
rd_temp_lsb = 18,
// Endereço da informação da temperatura (últimos 4 bits)
add_temp_xlsb = 19,
// Valor da informação da temperatura (últimos 4 bits)
rd_temp_xlsb = 20;

// Declaração dos sinais

// Informa o estado do controlador BMP280
reg[4:0] state, next_state;
// Contagem das palavras sequenciais transmitidas pelo SPI
reg[4:0] word_cnt, next_word;
// Indica quantas palavras sequenciais o SPI quer que execute
reg[5:0] data_words_reg, next_data_words;
// Dados a serem transmitidos por meio do SPI  
reg[DATA_BITS-1:0] spi_data_reg, next_spi_data;
// Dados a serem transmitidos por meio do UART  
reg[DATA_BITS-1:0] uart_data_reg, next_uart_data;
// O seletor de escrevos deve permanecer ativo durante a transmissão sequencial
reg tied_SS_reg, next_tied_SS;
// Habilitação SPI 
reg spi_en_reg, next_spi_en;
// Habilitação UART
reg uart_en_reg, next_uart_en;

// Registradores da máquina de estados para o controlador BMP280
always @(posedge clk, negedge n_rst) begin
    if (~n_rst) begin
        state <= idle;
        word_cnt <= 0;
        data_words_reg <= 0;
        spi_data_reg <= '0;
        uart_data_reg <= '0;
        tied_SS_reg <= 1'b0;
        spi_en_reg <= 1'b0;
        uart_en_reg <= 1'b0;
    end
    else begin
        state <= next_state;
        word_cnt <= next_word;
        data_words_reg <= next_data_words;
        spi_data_reg <= next_spi_data;
        uart_data_reg <= next_uart_data;
        tied_SS_reg <= next_tied_SS;
        spi_en_reg <= next_spi_en;
        uart_en_reg <= next_uart_en;
    end
end

// Lógica combinacional da máquina de estados para o controlador BMP280
always @(*) begin
    next_state = state;
    next_word = word_cnt;
    next_data_words = data_words_reg;
    next_spi_data = spi_data_reg;
    next_uart_data = uart_data_reg;
    next_tied_SS = tied_SS_reg;
    next_spi_en = spi_en_reg;
    next_uart_en = uart_en_reg;
    case (state)
    idle: begin
        // Desabilitando a transmissão UART
        next_uart_en = 1'b0;
        next_tied_SS = 1'b0;
        // Se recebermos do módulo UART uma informação válida e for == "m"
        if (uart_valid_in && uart_data_in == "m")
            // Damos inicio a configuração do sensor para receber os dados
            next_state = add_id;
    end
    add_id: begin
        // Verificamos se o módulo SPI e UART
        // está pronto para estabelecer uma comunicação
        if (spi_ready_in && uart_ready_in) begin
            // Amarramos o seletor (porque será transmitido duas palavras)
            next_tied_SS = 1'b1;
            // Quantidade de palavras transmitidas  
            next_data_words = 2;
            // Endereço de configuração é atribuido aos dados do SPI
            next_spi_data = 8'hD0;
            // Habilitamos a transferência pela comunicação SPI
            next_spi_en = 1'b1;
            // Zeramos a quantidade de palavras que foram transferidas
            next_word = 0;
            // Passamos para o próximo estado
            next_state = rd_id;
        end
    end
    rd_id: begin
        // Desabilitamos a transferência pela comunicação SPI
        // (ficou apenas um ciclo de clock habilitado)
        next_spi_en = 1'b0;
        // Se a contagem de palavras for igual a 2 (data_words_reg)
        if (word_cnt == 2) begin  
            // Se os dados que foram lidos foram completos (2 palavras),
            // habilitamos o UART para transmissão
            next_uart_en = 1'b1;
            // Somente quando não houver mais palavras para transmitir
            // que passamos para o próximo estado
            if (~uart_ready_in)
                next_state = add_status;
        end
        // Se o SPI estiver habilitado
        else if (spi_valid_in) begin
            // A transferência de dados ocorre
            // next_uart_data fica com o valor de identificação do sensor
            next_uart_data = spi_data_in;
            // Contagem de palavras   
            next_word = word_cnt + 1;
        end        
    end
    add_status: begin
        // Desabilitamos a transmissão UART
        next_uart_en = 1'b0;
        // Verificamos se o módulo SPI e UART
        // está pronto para estabelecer uma comunicação
        if (spi_ready_in && uart_ready_in) begin            
            next_data_words = 2;
            // Endereço da leitura do status  
            next_spi_data = 8'hF3;
            next_spi_en = 1'b1;
            next_word = 0;
            next_state = rd_status;
        end
    end
    rd_status: begin
        // Desabilitamos a transferência pela comunicação SPI
        // (ficou apenas um ciclo de clock habilitado)
        next_spi_en = 1'b0;

        // O RESTO SEGUE A MESMA IDEIA ANTERIOR
        if (word_cnt == 2) begin       
            next_uart_en = 1'b1;
            if (~uart_ready_in)
                next_state = add_ctrl_meas;
        end
        else if (spi_valid_in) begin   
            next_uart_data = spi_data_in;         
            next_word = word_cnt + 1;
        end
    end
    add_ctrl_meas: begin
        // Desabilitamos a transmissão UART
        next_uart_en = 1'b0;

        // Somente escrita no BMP280
        // Não precisamos retransmitir a informação para o UART
        // Por isso não o verificamos
        if (spi_ready_in) begin         
            next_data_words = 2;
            // Endereço de escrita
            next_spi_data = 8'h74;
            next_spi_en = 1'b1;
            next_word = 0;
            next_state = wr_ctrl_meas;
        end
    end
    wr_ctrl_meas: begin
        // Desabilitamos a transferência pela comunicação SPI
        // (ficou apenas um ciclo de clock habilitado)
        next_spi_en = 1'b0;

        // Contagem de palavras para mudar de estado
        if (word_cnt == 2) begin
            next_state = add_config;
        end
        else if (spi_valid_in) begin
            // Após a transmissão do endereço do estado anterior
            // Transmitimos para escrita os valores abaixo de configuração de dados
            next_spi_data = 8'b01011101;
            next_word = word_cnt + 1;
        end
    end
    add_config: begin
        if (spi_ready_in) begin         
            next_data_words = 2;
            // Endereço de outras configurações para o BMP280
            next_spi_data = 8'h75;
            next_spi_en = 1'b1;
            next_word = 0;
            next_state = wr_config;
        end
    end
    wr_config: begin
        // Desabilitamos a transferência pela comunicação SPI
        // (ficou apenas um ciclo de clock habilitado)
        next_spi_en = 1'b0;

        // Contagem de palavras para mudar de estado
        if (word_cnt == 2) begin
            next_state = add_press_msb;
        end
        else if (spi_valid_in) begin
            // Após a transmissão do endereço do estado anterior
            // Transmitimos para escrita os valores abaixo de configuração de dados
            next_spi_data = 8'b00010000;
            next_word = word_cnt + 1;
        end
    end
    add_press_msb: begin
        if (spi_ready_in && uart_ready_in) begin            
            next_data_words = 2;
            next_spi_data = 8'hF7;
            next_spi_en = 1'b1;
            next_word = 0;
            next_state = rd_press_msb;
        end
    end
    rd_press_msb: begin
        next_spi_en = 1'b0;
        if (word_cnt == 2) begin        
            next_uart_en = 1'b1;
            if (~uart_ready_in)
            next_state = add_press_lsb;
        end
        else if (spi_valid_in) begin  
            next_uart_data = spi_data_in;          
            next_word = word_cnt + 1;
        end
    end
    add_press_lsb: begin
        next_uart_en = 1'b0;
        if (spi_ready_in && uart_ready_in) begin            
            next_data_words = 2;
            next_spi_data = 8'hF8;
            next_spi_en = 1'b1;
            next_word = 0;
            next_state = rd_press_lsb;
        end
    end
    rd_press_lsb: begin
        next_spi_en = 1'b0;
        if (word_cnt == 2) begin       
            next_uart_en = 1'b1;
            if (~uart_ready_in)
            next_state = add_press_xlsb;
        end
        else if (spi_valid_in) begin    
            next_uart_data = spi_data_in;        
            next_word = word_cnt + 1;
        end
    end
    add_press_xlsb: begin
        next_uart_en = 1'b0;
        if (spi_ready_in && uart_ready_in) begin            
            next_data_words = 2;
            next_spi_data = 8'hF9;
            next_spi_en = 1'b1;
            next_word = 0;
            next_state = rd_press_xlsb;
        end
    end
    rd_press_xlsb: begin
        next_spi_en = 1'b0;
        if (word_cnt == 2) begin     
            next_uart_en = 1'b1;
            if (~uart_ready_in)
            next_state = add_temp_msb;
        end
        else if (spi_valid_in) begin    
            next_uart_data = spi_data_in;        
            next_word = word_cnt + 1;
        end
    end
    add_temp_msb: begin
        next_uart_en = 1'b0;
        if (spi_ready_in && uart_ready_in) begin            
            next_data_words = 2;
            next_spi_data = 8'hFA;
            next_spi_en = 1'b1;
            next_word = 0;
            next_state = rd_temp_msb;
        end
    end
    rd_temp_msb: begin
        next_spi_en = 1'b0;
        if (word_cnt == 2) begin   
            next_uart_en = 1'b1;
            if (~uart_ready_in)
            next_state = add_temp_lsb;
        end
        else if (spi_valid_in) begin        
            next_uart_data = spi_data_in;    
            next_word = word_cnt + 1;
        end
    end
    add_temp_lsb: begin
        next_uart_en = 1'b0;
        if (spi_ready_in && uart_ready_in) begin            
            next_data_words = 2;
            next_spi_data = 8'hFB;
            next_spi_en = 1'b1;
            next_word = 0;
            next_state = rd_temp_lsb;
        end
    end
    rd_temp_lsb: begin
        next_spi_en = 1'b0;
        if (word_cnt == 2) begin   
            next_uart_en = 1'b1;
            if (~uart_ready_in)
            next_state = add_temp_xlsb;
        end
        else if (spi_valid_in) begin      
            next_uart_data = spi_data_in;      
            next_word = word_cnt + 1;
        end
    end
    add_temp_xlsb: begin
        next_uart_en = 1'b0;
        if (spi_ready_in && uart_ready_in) begin            
            next_data_words = 2;
            next_spi_data = 8'hFC;
            next_spi_en = 1'b1;
            next_word = 0;
            next_state = rd_temp_xlsb;
        end
    end
    rd_temp_xlsb: begin
        next_spi_en = 1'b0;
        if (word_cnt == 2) begin   
            next_uart_en = 1'b1;
            if (~uart_ready_in)
            next_state = idle;
        end
        else if (spi_valid_in) begin         
            next_uart_data = spi_data_in;   
            next_word = word_cnt + 1;
        end
    end
    endcase
end

// Direcionamento dos registradores para as saídas
assign tied_SS = tied_SS_reg;
assign spi_en = spi_en_reg;
assign uart_en = uart_en_reg;
assign uart_data_out = uart_data_reg;
assign spi_data_out = spi_data_reg;
assign spi_data_words = data_words_reg;

/* Após a aquisição dos bits correspondentes às leituras
de pressão e temperatura, deverão ser feitos cálculos para a conversão
para as respectivas unidades de medida.*/

endmodule