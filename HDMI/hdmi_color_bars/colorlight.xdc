## System clock (xtal 25 MHz)
set_property -dict {PACKAGE_PIN K4 IOSTANDARD LVCMOS33} [get_ports dev_clk]; # IO_L13P_T2_MRCC_35 - xtal_25_MHz
#create_clock -name dev_clk -period 40.000 [get_ports dev_clk]

## Board LED D2
set_property -dict {PACKAGE_PIN A18 IOSTANDARD LVCMOS33} [get_ports led_D2]; # IO_L17P_T2_16 - active low i9+_LED_D2

## UART
#set_property -dict {PACKAGE_PIN M3 IOSTANDARD LVCMOS33} [get_ports rx]; # IO_L16P_T2_35 - P5_15
#set_property -dict {PACKAGE_PIN R3 IOSTANDARD LVCMOS33} [get_ports tx]; # IO_L3P_T0_DQS_34 - P5_16

# HDMI
set_property -dict {PACKAGE_PIN AA4 IOSTANDARD LVCMOS33} [get_ports HCK_N]; #IO_L11N_T1_SRCC_34 - HCK_N
set_property -dict {PACKAGE_PIN AB5 IOSTANDARD LVCMOS33} [get_ports HCK_P]; #IO_L10N_T1_34 - HCK_P
set_property -dict {PACKAGE_PIN AA5 IOSTANDARD LVCMOS33} [get_ports HD0_N]; #IO_L10P_T1_34 - HD0_N
set_property -dict {PACKAGE_PIN AB6 IOSTANDARD LVCMOS33} [get_ports HD0_P]; #IO_L20N_T3_34 - HD0_P
set_property -dict {PACKAGE_PIN Y7 IOSTANDARD LVCMOS33} [get_ports HD1_N]; #IO_L23N_T3_34 - HD1_N
set_property -dict {PACKAGE_PIN AB7 IOSTANDARD LVCMOS33} [get_ports HD1_P]; #IO_L20P_T3_34 - HD1_P
set_property -dict {PACKAGE_PIN Y8 IOSTANDARD LVCMOS33} [get_ports HD2_N]; #IO_L23P_T3_34 - HD2_N
set_property -dict {PACKAGE_PIN W7 IOSTANDARD LVCMOS33} [get_ports HD2_P]; #IO_L19N_T3_VREF_34 - HD2_P

# Header P4
set_property -dict {PACKAGE_PIN AB21 IOSTANDARD LVCMOS33} [get_ports n_rst]; #IO_L10P_T1_D14_14 - P4_3
set_property -dict {PACKAGE_PIN U17 IOSTANDARD LVCMOS33} [get_ports n_btn]; #IO_L18P_T2_A12_D28_14 - P4_4