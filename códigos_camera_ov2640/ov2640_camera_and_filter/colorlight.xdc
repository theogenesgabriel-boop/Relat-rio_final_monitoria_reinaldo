## System clock (xtal 25 MHz)
set_property -dict {PACKAGE_PIN K4 IOSTANDARD LVCMOS33} [get_ports dev_clk]; # IO_L13P_T2_MRCC_35 - xtal_25_MHz
#create_clock -name dev_clk -period 40.000 [get_ports dev_clk]

## Board LED D2
set_property -dict {PACKAGE_PIN A18 IOSTANDARD LVCMOS33} [get_ports led_D2]; # IO_L17P_T2_16 - active low i9+_LED_D2

## UART
#set_property -dict {PACKAGE_PIN M3 IOSTANDARD LVCMOS33} [get_ports rx]; # IO_L16P_T2_35 - P5_15
#set_property -dict {PACKAGE_PIN R3 IOSTANDARD LVCMOS33} [get_ports tx]; # IO_L3P_T0_DQS_34 - P5_16

## HDMI
set_property -dict {PACKAGE_PIN AA4 IOSTANDARD LVCMOS33} [get_ports HCK_N]; #IO_L11N_T1_SRCC_34 - HCK_N
set_property -dict {PACKAGE_PIN AB5 IOSTANDARD LVCMOS33} [get_ports HCK_P]; #IO_L10N_T1_34 - HCK_P
set_property -dict {PACKAGE_PIN AA5 IOSTANDARD LVCMOS33} [get_ports HD0_N]; #IO_L10P_T1_34 - HD0_N
set_property -dict {PACKAGE_PIN AB6 IOSTANDARD LVCMOS33} [get_ports HD0_P]; #IO_L20N_T3_34 - HD0_P
set_property -dict {PACKAGE_PIN Y7 IOSTANDARD LVCMOS33} [get_ports HD1_N]; #IO_L23N_T3_34 - HD1_N
set_property -dict {PACKAGE_PIN AB7 IOSTANDARD LVCMOS33} [get_ports HD1_P]; #IO_L20P_T3_34 - HD1_P
set_property -dict {PACKAGE_PIN Y8 IOSTANDARD LVCMOS33} [get_ports HD2_N]; #IO_L23P_T3_34 - HD2_N
set_property -dict {PACKAGE_PIN W7 IOSTANDARD LVCMOS33} [get_ports HD2_P]; #IO_L19N_T3_VREF_34 - HD2_P

## Header P2
#set_property -dict {PACKAGE_PIN T3 IOSTANDARD LVCMOS33} [get_ports P2_3]; #IO_0_34 - P2_3
#set_property -dict {PACKAGE_PIN U2 IOSTANDARD LVCMOS33} [get_ports P2_4]; #IO_L2P_T0_34 - P2_4
#set_property -dict {PACKAGE_PIN V2 IOSTANDARD LVCMOS33} [get_ports P2_5]; #IO_L2N_T0_34 - P2_5
#set_property -dict {PACKAGE_PIN W1 IOSTANDARD LVCMOS33} [get_ports P2_6]; #IO_L5P_T0_34 - P2_6
#set_property -dict {PACKAGE_PIN AA1 IOSTANDARD LVCMOS33} [get_ports P2_7]; #IO_L7P_T1_34 - P2_7
#set_property -dict {PACKAGE_PIN W2 IOSTANDARD LVCMOS33} [get_ports P2_9]; #IO_L4P_T0_34 - P2_9
#set_property -dict {PACKAGE_PIN AB2 IOSTANDARD LVCMOS33} [get_ports P2_12]; #IO_L8N_T1_34 - P2_12
#set_property -dict {PACKAGE_PIN AB3 IOSTANDARD LVCMOS33} [get_ports P2_13]; #IO_L8P_T1_34 - P2_13
#set_property -dict {PACKAGE_PIN W4 IOSTANDARD LVCMOS33} [get_ports P2_14]; #IO_L12N_T1_MRCC_34 - P2_14
#set_property -dict {PACKAGE_PIN Y6 IOSTANDARD LVCMOS33} [get_ports P2_15]; #IO_L18P_T2_34 - P2_15
#set_property -dict {PACKAGE_PIN Y4 IOSTANDARD LVCMOS33} [get_ports P2_16]; #IO_L11P_T1_SRCC_34 - P2_16
#set_property -dict {PACKAGE_PIN Y3 IOSTANDARD LVCMOS33} [get_ports P2_17]; #IO_L9P_T1_DQS_34 - P2_17
#set_property -dict {PACKAGE_PIN AA3 IOSTANDARD LVCMOS33} [get_ports P2_18]; #IO_L9N_T1_DQS_34 - P2_18
#set_property -dict {PACKAGE_PIN Y2 IOSTANDARD LVCMOS33} [get_ports P2_19]; #IO_L4N_T0_34 - P2_19
#set_property -dict {PACKAGE_PIN AB1 IOSTANDARD LVCMOS33} [get_ports P2_22]; #IO_L7N_T1_34 - P2_22
#set_property -dict {PACKAGE_PIN Y1 IOSTANDARD LVCMOS33} [get_ports P2_24]; #IO_L5N_T0_34 - P2_24
#set_property -dict {PACKAGE_PIN V3 IOSTANDARD LVCMOS33} [get_ports P2_25]; #IO_L6N_T0_VREF_34 - P2_25
#set_property -dict {PACKAGE_PIN U3 IOSTANDARD LVCMOS33} [get_ports P2_26]; #IO_L6P_T0_34 - P2_26
#set_property -dict {PACKAGE_PIN T4 IOSTANDARD LVCMOS33} [get_ports P2_27]; #IO_L13N_T2_MRCC_34 - P2_27
#set_property -dict {PACKAGE_PIN R2 IOSTANDARD LVCMOS33} [get_ports P2_28]; #IO_L3N_T0_DQS_34 - P2_28

## Header P3
#set_property -dict {PACKAGE_PIN AB8 IOSTANDARD LVCMOS33} [get_ports P3_3]; #IO_L22N_T3_34 - P3_3
#set_property -dict {PACKAGE_PIN V8 IOSTANDARD LVCMOS33} [get_ports P3_4]; #IO_L21N_T3_DQS_34 - P3_4
#set_property -dict {PACKAGE_PIN V9 IOSTANDARD LVCMOS33} [get_ports P3_5]; #IO_L21P_T3_DQS_34 - P3_5
#set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports P3_6]; #IO_L19P_T3_A10_D26_14 - P3_6
#set_property -dict {PACKAGE_PIN Y18 IOSTANDARD LVCMOS33} [get_ports P3_7]; #IO_L13P_T2_MRCC_14 - P3_7
#set_property -dict {PACKAGE_PIN W19 IOSTANDARD LVCMOS33} [get_ports P3_9]; #IO_L12P_T1_MRCC_14 - P3_9
#set_property -dict {PACKAGE_PIN Y19 IOSTANDARD LVCMOS33} [get_ports P3_12]; #IO_L13N_T2_MRCC_14 - P3_12
#set_property -dict {PACKAGE_PIN V18 IOSTANDARD LVCMOS33} [get_ports P3_13]; #IO_L14P_T2_SRCC_14 - P3_13
#set_property -dict {PACKAGE_PIN AB20 IOSTANDARD LVCMOS33} [get_ports P3_14]; #IO_L15N_T2_DQS_DOUT_CSO_B_14 - P3_14
#set_property -dict {PACKAGE_PIN AA21 IOSTANDARD LVCMOS33} [get_ports P3_15]; #IO_L8N_T1_D12_14 - P3_15
#set_property -dict {PACKAGE_PIN AA20 IOSTANDARD LVCMOS33} [get_ports P3_16]; #IO_L8P_T1_D11_14 - P3_16
#set_property -dict {PACKAGE_PIN V19 IOSTANDARD LVCMOS33} [get_ports P3_17]; #IO_L14N_T2_SRCC_14 - P3_17
#set_property -dict {PACKAGE_PIN AA19 IOSTANDARD LVCMOS33} [get_ports P3_18]; #IO_L15P_T2_DQS_RDWR_B_14 - P3_18
#set_property -dict {PACKAGE_PIN AB18 IOSTANDARD LVCMOS33} [get_ports P3_19]; #IO_L17N_T2_A13_D29_14 - P3_19
#set_property -dict {PACKAGE_PIN AA18 IOSTANDARD LVCMOS33} [get_ports P3_22]; #IO_L17P_T2_A14_D30_14 - P3_22
#set_property -dict {PACKAGE_PIN W17 IOSTANDARD LVCMOS33} [get_ports P3_24]; #IO_L16N_T2_A15_D31_14 - P3_24
#set_property -dict {PACKAGE_PIN R14 IOSTANDARD LVCMOS33} [get_ports P3_25]; #IO_L19N_T3_A09_D25_VREF_14 - P3_25
#set_property -dict {PACKAGE_PIN W9 IOSTANDARD LVCMOS33} [get_ports P3_26]; #IO_L24P_T3_34 - P3_26
#set_property -dict {PACKAGE_PIN Y9 IOSTANDARD LVCMOS33} [get_ports P3_27]; #IO_L24N_T3_34 - P3_27
#set_property -dict {PACKAGE_PIN AA6 IOSTANDARD LVCMOS33} [get_ports P3_28]; #IO_L18N_T2_34 - P3_28

## Header P4
set_property -dict {PACKAGE_PIN AB21 IOSTANDARD LVCMOS33} [get_ports n_rst]; #IO_L10P_T1_D14_14 - P4_3
set_property -dict {PACKAGE_PIN U17 IOSTANDARD LVCMOS33} [get_ports n_btn]; #IO_L18P_T2_A12_D28_14 - P4_4
#set_property -dict {PACKAGE_PIN R17 IOSTANDARD LVCMOS33} [get_ports P4_5]; #IO_L24N_T3_A00_D16_14 - P4_5
#set_property -dict {PACKAGE_PIN R18 IOSTANDARD LVCMOS33} [get_ports P4_6]; #IO_L20P_T3_A08_D24_14 - P4_6
#set_property -dict {PACKAGE_PIN R19 IOSTANDARD LVCMOS33} [get_ports P4_7]; #IO_L5N_T0_D07_14 - P4_7
#set_property -dict {PACKAGE_PIN N15 IOSTANDARD LVCMOS33} [get_ports P4_9]; #IO_25_14 - P4_9
#set_property -dict {PACKAGE_PIN K14 IOSTANDARD LVCMOS33} [get_ports P4_12]; #IO_L19N_T3_A21_VREF_15 - P4_12
#set_property -dict {PACKAGE_PIN M15 IOSTANDARD LVCMOS33} [get_ports P4_13]; #IO_L24P_T3_RS1_15 - P4_13
#set_property -dict {PACKAGE_PIN N22 IOSTANDARD LVCMOS33} [get_ports P4_14]; #IO_L15P_T2_DQS_15 - P4_14
#set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS33} [get_ports P4_15]; #IO_L5P_T0_AD9P_15 - P4_15
#set_property -dict {PACKAGE_PIN J14 IOSTANDARD LVCMOS33} [get_ports P4_16]; #IO_L3P_T0_DQS_AD1P_15 - P4_16
#set_property -dict {PACKAGE_PIN AA8 IOSTANDARD LVCMOS33} [get_ports P4_17]; #IO_L22P_T3_34 - P4_17
#set_property -dict {PACKAGE_PIN L16 IOSTANDARD LVCMOS33} [get_ports P4_18]; #IO_L23P_T3_FOE_B_15 - P4_18
#set_property -dict {PACKAGE_PIN L15 IOSTANDARD LVCMOS33} [get_ports P4_19]; #IO_L22N_T3_A16_15 - P4_19
#set_property -dict {PACKAGE_PIN M16 IOSTANDARD LVCMOS33} [get_ports P4_22]; #IO_L24N_T3_RS0_15 - P4_22
#set_property -dict {PACKAGE_PIN N19 IOSTANDARD LVCMOS33} [get_ports P4_24]; #IO_L17N_T2_A25_15 - P4_24
#set_property -dict {PACKAGE_PIN N18 IOSTANDARD LVCMOS33} [get_ports P4_25]; #IO_L17P_T2_A26_15 - P4_25
#set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports P4_26]; #IO_L18N_T2_A11_D27_14 - P4_26
#set_property -dict {PACKAGE_PIN T18 IOSTANDARD LVCMOS33} [get_ports P4_27]; #IO_L20N_T3_A07_D23_14 - P4_27
#set_property -dict {PACKAGE_PIN Y21 IOSTANDARD LVCMOS33} [get_ports P4_28]; #IO_L9P_T1_DQS_14 - P4_28

## Header P5
#set_property -dict {PACKAGE_PIN P17 IOSTANDARD LVCMOS33} [get_ports P5_3]; # IO_L21N_T3_DQS_A06_D22_14 - P5_3
#set_property -dict {PACKAGE_PIN N17 IOSTANDARD LVCMOS33} [get_ports P5_4]; # IO_L21P_T3_DQS_14 - P5_4
#set_property -dict {PACKAGE_PIN P16 IOSTANDARD LVCMOS33} [get_ports P5_5]; # IO_L24P_T3_A01_D17_14 - P5_5
#set_property -dict {PACKAGE_PIN N14 IOSTANDARD LVCMOS33} [get_ports P5_6]; # IO_L23N_T3_A02_D18_14 - P5_6
#set_property -dict {PACKAGE_PIN V7 IOSTANDARD LVCMOS33} [get_ports P5_7]; # IO_L19P_T3_34 - P5_7
#set_property -dict {PACKAGE_PIN L6 IOSTANDARD LVCMOS33} [get_ports P5_9]; #IO_25_35 - P5_9
#set_property -dict {PACKAGE_PIN W5 IOSTANDARD LVCMOS33} [get_ports P5_12]; #IO_L15N_T2_DQS_34 - P5_12
#set_property -dict {PACKAGE_PIN J5 IOSTANDARD LVCMOS33} [get_ports P5_13]; #IO_L10P_T1_AD15P_35 - P5_13
#set_property -dict {PACKAGE_PIN R4 IOSTANDARD LVCMOS33} [get_ports P5_14]; #IO_L13P_T2_MRCC_34 - P5_14
#set_property -dict {PACKAGE_PIN V4 IOSTANDARD LVCMOS33} [get_ports P5_17]; #IO_L12P_T1_MRCC_34 - P5_17
#set_property -dict {PACKAGE_PIN T5 IOSTANDARD LVCMOS33} [get_ports P5_18]; #IO_L14P_T2_SRCC_34 - P5_18
#set_property -dict {PACKAGE_PIN J6 IOSTANDARD LVCMOS33} [get_ports P5_19]; #IO_L17N_T2_35 - P5_19
#set_property -dict {PACKAGE_PIN L5 IOSTANDARD LVCMOS33} [get_ports P5_22]; #IO_L18P_T2_35 - P5_22
#set_property -dict {PACKAGE_PIN W6 IOSTANDARD LVCMOS33} [get_ports P5_24]; #IO_L15P_T2_DQS_34 - P5_24
#set_property -dict {PACKAGE_PIN N13 IOSTANDARD LVCMOS33} [get_ports P5_25]; #IO_L23P_T3_A03_D19_14 - P5_25
#set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33} [get_ports P5_26]; #IO_L22P_T3_A05_D21_14 - P5_26
#set_property -dict {PACKAGE_PIN R16 IOSTANDARD LVCMOS33} [get_ports P5_27]; #IO_L22N_T3_A04_D20_14 - P5_27
#set_property -dict {PACKAGE_PIN V17 IOSTANDARD LVCMOS33} [get_ports P5_28]; #IO_L16P_T2_CSI_B_14 - P5_28

## Header P6
set_property -dict {PACKAGE_PIN L4 IOSTANDARD LVCMOS33} [get_ports SCL]; #IO_L18N_T2_35 - P6_3
set_property PULLUP TRUE [get_ports SCL];
set_property -dict {PACKAGE_PIN G4 IOSTANDARD LVCMOS33} [get_ports VSYNC]; #IO_L12N_T1_MRCC_35 - P6_4
set_property -dict {PACKAGE_PIN G3 IOSTANDARD LVCMOS33} [get_ports SDA]; #IO_L11N_T1_SRCC_35 - P6_5
set_property PULLUP TRUE [get_ports SDA];
set_property -dict {PACKAGE_PIN K2 IOSTANDARD LVCMOS33} [get_ports HREF]; #IO_L9P_T1_DQS_AD7P_35 - P6_6
set_property -dict {PACKAGE_PIN M1 IOSTANDARD LVCMOS33} [get_ports RST]; #IO_L15P_T2_DQS_35 - P6_7
set_property -dict {PACKAGE_PIN K1 IOSTANDARD LVCMOS33} [get_ports DCLK]; #IO_L7P_T1_AD6P_35 - P6_9
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets -hierarchical *DCLK*]
set_property -dict {PACKAGE_PIN H3 IOSTANDARD LVCMOS33} [get_ports DATA[0]]; #IO_L11P_T1_SRCC_35 - P6_12
set_property -dict {PACKAGE_PIN V5 IOSTANDARD LVCMOS33} [get_ports DATA[1]]; #IO_L16N_T2_34 - P6_13
set_property -dict {PACKAGE_PIN U6 IOSTANDARD LVCMOS33} [get_ports DATA[2]]; #IO_L16P_T2_34 - P6_14
set_property -dict {PACKAGE_PIN T6 IOSTANDARD LVCMOS33} [get_ports DATA[3]]; #IO_L17N_T2_34 - P6_15
set_property -dict {PACKAGE_PIN P5 IOSTANDARD LVCMOS33} [get_ports DATA[4]]; #IO_L21P_T3_DQS_35 - P6_16
set_property -dict {PACKAGE_PIN U7 IOSTANDARD LVCMOS33} [get_ports DATA[5]]; #IO_25_34 - P6_17
set_property -dict {PACKAGE_PIN U5 IOSTANDARD LVCMOS33} [get_ports DATA[6]]; #IO_L14N_T2_SRCC_34 - P6_18
set_property -dict {PACKAGE_PIN U1 IOSTANDARD LVCMOS33} [get_ports DATA[7]]; #IO_L1N_T0_34 - P6_19
set_property -dict {PACKAGE_PIN J1 IOSTANDARD LVCMOS33} [get_ports PWDN]; #IO_L7N_T1_AD6N_35 - P6_22
#set_property -dict {PACKAGE_PIN L1 IOSTANDARD LVCMOS33} [get_ports P6_24]; #IO_L15N_T2_DQS_35 - P6_24
#set_property -dict {PACKAGE_PIN J2 IOSTANDARD LVCMOS33} [get_ports P6_25]; #IO_L9N_T1_DQS_AD7N_35 - P6_25
#set_property -dict {PACKAGE_PIN K3 IOSTANDARD LVCMOS33} [get_ports P6_26]; #IO_L14N_T2_SRCC_35 - P6_26
#set_property -dict {PACKAGE_PIN J4 IOSTANDARD LVCMOS33} [get_ports P6_27]; #IO_L13N_T2_MRCC_35 - P6_27
#set_property -dict {PACKAGE_PIN F4 IOSTANDARD LVCMOS33} [get_ports P6_28]; #IO_0_35 - P6_28