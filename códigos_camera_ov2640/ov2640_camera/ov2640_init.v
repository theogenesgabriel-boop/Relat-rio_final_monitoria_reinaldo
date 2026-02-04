module ov2640_init #(parameter CLK_IN_FREQ=10000000)(
    input clk_in, n_rst,
    output camera_ready,
    // interface com sccb_master
    input sccb_ready_in, sccb_wr_valid_in, sccb_rd_valid_in,
    output sccb_three_phase, sccb_rd_wr, sccb_enable,
    output [6:0] sccb_address,
    output [7:0] sccb_wr_data,
    // sinais para a câmera
    output PWDN, RST
);

// Declaração dos estados simbólicos
localparam reg [2:0]
POWER_ON = 3'd0,
HW_RESET = 3'd1,
DEV_CTRL_REG = 3'd2,
CTRL_REG_PARAM = 3'd3,
NEXT_CTRL_REG = 3'd4,
CONFIG_DONE = 3'd5;

// Endereço da câmera
localparam reg [6:0] OV2640_ADDRESS = 7'h30;

// Temporização (delay_ms)
localparam reg [$clog2(CLK_IN_FREQ/100)-1:0] DELAY_10 = (CLK_IN_FREQ/100)-1;  //delay = 10 ms
localparam reg [$clog2(CLK_IN_FREQ/50)-1:0] DELAY_20 = (CLK_IN_FREQ/50)-1;  //delay = 20 ms
localparam reg [$clog2(CLK_IN_FREQ/20)-1:0] DELAY_50 = (CLK_IN_FREQ/20)-1;  //delay = 50 ms
localparam reg [$clog2(CLK_IN_FREQ/10)-1:0] DELAY_100 = (CLK_IN_FREQ/10)-1;   // delay = 100 ms

// Declaração dos sinais
reg [2:0] state, next_state;
reg PWDN_reg, next_PWDN;
reg RST_reg, next_RST;
reg [$clog2(CLK_IN_FREQ/10):0] clk_cnt, next_clk;
reg [$clog2(250)-1:0] rom_address, next_rom_address;
reg sccb_three_phase_reg, next_sccb_three_phase;
reg sccb_rd_wr_reg, next_sccb_rd_wr;
reg sccb_enable_reg, next_sccb_enable;
reg [6:0] sccb_address_reg, next_sccb_address;
reg [7:0] sccb_wr_data_reg, next_sccb_wr_data;
reg writting_reg, next_writting;
reg camera_ready_reg, next_camera_ready;

// Registradores de controle e seus parâmetros
reg [15:0] rom [0:250];
initial begin    
rom[0] = 16'hFF00;
rom[1] = 16'h2CFF;
rom[2] = 16'h2EDF;
rom[3] = 16'hFF01;
rom[4] = 16'h3C32;
rom[5] = 16'h1100;
rom[6] = 16'h0902;
rom[7] = 16'h04D8;
rom[8] = 16'h13E5;
rom[9] = 16'h1448;
rom[10] = 16'h2C0C;
rom[11] = 16'h3378;
rom[12] = 16'h3A33;
rom[13] = 16'h3BFB;
rom[14] = 16'h3E00;
rom[15] = 16'h4311;
rom[16] = 16'h1610;
rom[17] = 16'h3992;
rom[18] = 16'h35DA;
rom[19] = 16'h221A;
rom[20] = 16'h37C3;
rom[21] = 16'h2300;
rom[22] = 16'h34C0;
rom[23] = 16'h361A;
rom[24] = 16'h0688;
rom[25] = 16'h07C0;
rom[26] = 16'h0D87;
rom[27] = 16'h0E41;
rom[28] = 16'h4C00;
rom[29] = 16'h4800;
rom[30] = 16'h5B00;
rom[31] = 16'h4203;
rom[32] = 16'h4A81;
rom[33] = 16'h2199;
rom[34] = 16'h2440;
rom[35] = 16'h2538;
rom[36] = 16'h2682;
rom[37] = 16'h5C00;
rom[38] = 16'h6300;
rom[39] = 16'h4600;
rom[40] = 16'h0C3C;
rom[41] = 16'h6170;
rom[42] = 16'h6280;
rom[43] = 16'h7C05;
rom[44] = 16'h2080;
rom[45] = 16'h2830;
rom[46] = 16'h6C00;
rom[47] = 16'h6D80;
rom[48] = 16'h6E00;
rom[49] = 16'h7002;
rom[50] = 16'h7194;
rom[51] = 16'h73C1;
rom[52] = 16'h3D34;
rom[53] = 16'h5A57;
rom[54] = 16'h1200;
rom[55] = 16'h1711;
rom[56] = 16'h1875;
rom[57] = 16'h1901;
rom[58] = 16'h1A97;
rom[59] = 16'h3236;
rom[60] = 16'h030F;
rom[61] = 16'h3740;
rom[62] = 16'h4FCA;
rom[63] = 16'h50A8;
rom[64] = 16'h5A23;
rom[65] = 16'h6D00;
rom[66] = 16'h6D38;
rom[67] = 16'hFF00;
rom[68] = 16'hE57F;
rom[69] = 16'hF9C0;
rom[70] = 16'h4124;
rom[71] = 16'hE014;
rom[72] = 16'h76FF;
rom[73] = 16'h33A0;
rom[74] = 16'h4220;
rom[75] = 16'h4318;
rom[76] = 16'h4C00;
rom[77] = 16'h87D5;
rom[78] = 16'h883F;
rom[79] = 16'hD703;
rom[80] = 16'hD910;
rom[81] = 16'hD382;
rom[82] = 16'hC808;
rom[83] = 16'hC980;
rom[84] = 16'h7C00;
rom[85] = 16'h7D00;
rom[86] = 16'h7C03;
rom[87] = 16'h7D48;
rom[88] = 16'h7D48;
rom[89] = 16'h7C08;
rom[90] = 16'h7D20;
rom[91] = 16'h7D10;
rom[92] = 16'h7D0E;
rom[93] = 16'h9000;
rom[94] = 16'h910E;
rom[95] = 16'h911A;
rom[96] = 16'h9131;
rom[97] = 16'h915A;
rom[98] = 16'h9169;
rom[99] = 16'h9175;
rom[100] = 16'h917E;
rom[101] = 16'h9188;
rom[102] = 16'h918F;
rom[103] = 16'h9196;
rom[104] = 16'h91A3;
rom[105] = 16'h91AF;
rom[106] = 16'h91C4;
rom[107] = 16'h91D7;
rom[108] = 16'h91E8;
rom[109] = 16'h9120;
rom[110] = 16'h9200;
rom[111] = 16'h9306;
rom[112] = 16'h93E3;
rom[113] = 16'h9305;
rom[114] = 16'h9305;
rom[115] = 16'h9300;
rom[116] = 16'h9304;
rom[117] = 16'h9300;
rom[118] = 16'h9300;
rom[119] = 16'h9300;
rom[120] = 16'h9300;
rom[121] = 16'h9300;
rom[122] = 16'h9300;
rom[123] = 16'h9300;
rom[124] = 16'h9600;
rom[125] = 16'h9708;
rom[126] = 16'h9719;
rom[127] = 16'h9702;
rom[128] = 16'h970C;
rom[129] = 16'h9724;
rom[130] = 16'h9730;
rom[131] = 16'h9728;
rom[132] = 16'h9726;
rom[133] = 16'h9702;
rom[134] = 16'h9798;
rom[135] = 16'h9780;
rom[136] = 16'h9700;
rom[137] = 16'h9700;
rom[138] = 16'hC3EF;
rom[139] = 16'hA400;
rom[140] = 16'hA800;
rom[141] = 16'hC511;
rom[142] = 16'hC651;
rom[143] = 16'hBF80;
rom[144] = 16'hC710;
rom[145] = 16'hB666;
rom[146] = 16'hB8A5;
rom[147] = 16'hB764;
rom[148] = 16'hB97C;
rom[149] = 16'hB3AF;
rom[150] = 16'hB497;
rom[151] = 16'hB5FF;
rom[152] = 16'hB0C5;
rom[153] = 16'hB194;
rom[154] = 16'hB20F;
rom[155] = 16'hC45C;
rom[156] = 16'hC0C8;
rom[157] = 16'hC196;
rom[158] = 16'h8C00;
rom[159] = 16'h863D;
rom[160] = 16'h5000;
rom[161] = 16'h5190;
rom[162] = 16'h522C;
rom[163] = 16'h5300;
rom[164] = 16'h5400;
rom[165] = 16'h5588;
rom[166] = 16'h5A90;
rom[167] = 16'h5B2C;
rom[168] = 16'h5C05;
rom[169] = 16'hD302;
rom[170] = 16'hC3ED;
rom[171] = 16'h7F00;
rom[172] = 16'hDA09;
rom[173] = 16'hE51F;
rom[174] = 16'hE167;
rom[175] = 16'hE000;
rom[176] = 16'hDD7F;
rom[177] = 16'h0500;
// yuv422
rom[178] = 16'hFF00; // DSP bank
rom[179] = 16'hDA00; // YUV output
rom[180] = 16'hD703; // YUV422
rom[181] = 16'hDF00; // RGB disabled
rom[182] = 16'hE000; // DSP normal
// Resolução YUV422
rom[183] = 16'h5AA0;
rom[184] = 16'h5B78;
rom[185] = 16'h5C00; 
end

// Registradores da máquina de estados
always @(posedge clk_in, negedge n_rst)
if (~n_rst) begin
    state <= POWER_ON;
    PWDN_reg <= 1'b1;
    RST_reg <= 1'b1;
    clk_cnt <= 0;
    rom_address <= 0;
    sccb_three_phase_reg <= 1'b0;
    sccb_rd_wr_reg <= 1'b1;
    sccb_enable_reg <= 1'b0;
    sccb_address_reg <= 7'd0;
    sccb_wr_data_reg <= 8'd0;
    writting_reg <= 1'b0;
    camera_ready_reg <= 1'b0;
end
else begin
    state <= next_state;
    PWDN_reg <= next_PWDN;
    RST_reg <= next_RST;
    clk_cnt <= next_clk;
    rom_address <= next_rom_address;
    sccb_three_phase_reg <= next_sccb_three_phase;
    sccb_rd_wr_reg <= next_sccb_rd_wr;
    sccb_enable_reg <= next_sccb_enable;
    sccb_address_reg <= next_sccb_address;
    sccb_wr_data_reg <= next_sccb_wr_data;
    writting_reg <= next_writting;
    camera_ready_reg <= next_camera_ready;
end

// Direcionamento dos registradores para as saídas
assign PWDN = PWDN_reg;
assign RST = RST_reg;
assign sccb_three_phase = sccb_three_phase_reg;
assign sccb_rd_wr = sccb_rd_wr_reg;
assign sccb_enable = sccb_enable_reg;
assign sccb_address = sccb_address_reg;
assign sccb_wr_data = sccb_wr_data_reg;
assign camera_ready = ~camera_ready_reg;

// Lógica combinacional para a inicialização da câmera
always @(*) begin
    next_state = state;
    next_PWDN = PWDN_reg;
    next_RST = RST_reg;
    next_clk = clk_cnt;
    next_rom_address = rom_address;
    next_sccb_three_phase = sccb_three_phase_reg;
    next_sccb_rd_wr = sccb_rd_wr_reg;
    next_sccb_enable = sccb_enable_reg;
    next_sccb_address = sccb_address_reg;
    next_sccb_wr_data = sccb_wr_data_reg;
    next_writting = writting_reg;
    next_camera_ready = camera_ready_reg;
    case (state)
    POWER_ON:
    if (clk_cnt == DELAY_100) begin
        next_clk = 0;
        next_state = HW_RESET;
    end
    else begin
        next_camera_ready = 1'b0;
        next_PWDN = (clk_cnt < DELAY_50) ? 1'b1 : 1'b0;
        next_RST = 1'b1;
        next_clk = clk_cnt + 1;
    end
    HW_RESET:
    if (clk_cnt == DELAY_100) begin
        next_sccb_address = OV2640_ADDRESS;
        next_rom_address = 0;
        next_clk = 0;
        next_state = DEV_CTRL_REG;
    end
    else begin
        next_RST = (clk_cnt < DELAY_50) ? 1'b0 : 1'b1;
        next_clk = clk_cnt + 1;
    end
    DEV_CTRL_REG:
    if (sccb_ready_in) begin
        next_sccb_wr_data = rom[rom_address][15:8];
        next_sccb_rd_wr = 1'b0;
        next_sccb_three_phase = 1'b1;
        next_sccb_enable = 1'b1;
        next_writting = 1'b1;
    end
    else if (writting_reg && ~sccb_ready_in) begin
        next_sccb_enable = 1'b0;
        next_writting = 1'b0;
        next_state = CTRL_REG_PARAM;
    end
    CTRL_REG_PARAM:
    if (sccb_wr_valid_in) begin
        next_sccb_wr_data = rom[rom_address][7:0];
        next_state = NEXT_CTRL_REG;
    end
    NEXT_CTRL_REG:
    if (clk_cnt == 0) begin
        if (rom_address == 185)
        next_state = CONFIG_DONE;
        else begin
            next_rom_address = rom_address + 1;
            next_state = DEV_CTRL_REG;
        end
    end
    else
    next_clk = clk_cnt - 1;
    CONFIG_DONE:
    next_camera_ready = 1'b1;
    endcase
end

endmodule