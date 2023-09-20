`include "constant.vh"

module SPI_PORT
#(
    IONUM = 1
)
(
    input   wire    en_i,
    input   wire    en_cs,
    input   wire    clk_in,
    input   wire    rst,
    input   wire[`LEN - 1:0]    addr_i,
    inout   wire[`LEN - 1:0]    data,

    input   wire    MISO,
    output  wire    MOSI,
    output  wire    SCLK,
    output  wire[IONUM - 1:0]    CS
);
    wire[`LEN - 1:0] wdata;
    wire[`LEN - 1:0] rdata;
    assign wdata = en_i ? data : `LEN'bz;
    assign data = en_cs ? (en_i ? `LEN'bz : rdata) : `LEN'bz;
    SPI_MASTER_Top SPI_Interface(
		.I_CLK(clk_in), //input I_CLK
		.I_RESETN(rst), //input I_RESETN
		.I_TX_EN(en_i), //input I_TX_EN
		.I_WADDR(addr_i[2:0]), //input [2:0] I_WADDR
		.I_WDATA(wdata), //input [7:0] I_WDATA
		.I_RX_EN(~en_i), //input I_RX_EN
		.I_RADDR(addr_i[2:0]), //input [2:0] I_RADDR
		.O_RDATA(rdata), //output [7:0] O_RDATA
		.O_SPI_INT(), //output O_SPI_INT
		.MISO_MASTER(MISO), //input MISO_MASTER
		.MOSI_MASTER(MOSI), //output MOSI_MASTER
		.SS_N_MASTER(CS), //output [0:0] SS_N_MASTER
		.SCLK_MASTER(SCLK), //output SCLK_MASTER
		.MISO_SLAVE(), //output MISO_SLAVE
		.MOSI_SLAVE(1'b0), //input MOSI_SLAVE
		.SS_N_SLAVE(1'b0), //input SS_N_SLAVE
		.SCLK_SLAVE(1'b0) //input SCLK_SLAVE
	);
endmodule