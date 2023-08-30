//Copyright (C)2014-2022 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//GOWIN Version: GowinSynthesis V1.9.8.09 Education
//Part Number: GW1NR-LV9QN88PC6/I5
//Device: GW1NR-9C
//Created Time: Tue Aug 22 16:29:50 2023

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

	SPI_MASTER_Top your_instance_name(
		.I_CLK(I_CLK_i), //input I_CLK
		.I_RESETN(I_RESETN_i), //input I_RESETN
		.I_TX_EN(I_TX_EN_i), //input I_TX_EN
		.I_WADDR(I_WADDR_i), //input [2:0] I_WADDR
		.I_WDATA(I_WDATA_i), //input [7:0] I_WDATA
		.I_RX_EN(I_RX_EN_i), //input I_RX_EN
		.I_RADDR(I_RADDR_i), //input [2:0] I_RADDR
		.O_RDATA(O_RDATA_o), //output [7:0] O_RDATA
		.O_SPI_INT(O_SPI_INT_o), //output O_SPI_INT
		.MISO_MASTER(MISO_MASTER_i), //input MISO_MASTER
		.MOSI_MASTER(MOSI_MASTER_o), //output MOSI_MASTER
		.SS_N_MASTER(SS_N_MASTER_o), //output [0:0] SS_N_MASTER
		.SCLK_MASTER(SCLK_MASTER_o), //output SCLK_MASTER
		.MISO_SLAVE(MISO_SLAVE_o), //output MISO_SLAVE
		.MOSI_SLAVE(MOSI_SLAVE_i), //input MOSI_SLAVE
		.SS_N_SLAVE(SS_N_SLAVE_i), //input SS_N_SLAVE
		.SCLK_SLAVE(SCLK_SLAVE_i) //input SCLK_SLAVE
	);

//--------Copy end-------------------
