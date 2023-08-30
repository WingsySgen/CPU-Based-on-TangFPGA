`include "constant.vh"

module UART_PORT
(
    input   wire    en_i,
    input   wire    en_cs,
    input   wire    clk_in,
    input   wire    rst,
    input   wire[`LEN - 1:0]    addr_i,
    inout   wire[`LEN - 1:0]    data,
    input   wire    RX,
    output  wire    TX
);
    wire[`LEN - 1:0] wdata;
    wire[`LEN - 1:0] rdata;
    assign wdata = en_i ? data : `LEN'bz;
    assign data = en_cs ? (en_i ? `LEN'bz : rdata) : `LEN'bz;

    UART_MASTER_Top UART_Interface(
		.I_CLK(clk_in), //input I_CLK
		.I_RESETN(rst), //input I_RESETN
		.I_TX_EN(en_i), //input I_TX_EN
		.I_WADDR(addr_i[2:0]), //input [2:0] I_WADDR
		.I_WDATA(wdata), //input [7:0] I_WDATA
		.I_RX_EN(~en_i), //input I_RX_EN
		.I_RADDR(addr_i[2:0]), //input [2:0] I_RADDR
		.O_RDATA(rdata), //output [7:0] O_RDATA
		.SIN(RX), //input SIN
		.RxRDYn(), //output RxRDYn
		.SOUT(TX), //output SOUT
		.TxRDYn(), //output TxRDYn
		.DDIS(), //output DDIS
		.INTR(), //output INTR
		.DCDn(), //input DCDn
		.CTSn(), //input CTSn
		.DSRn(), //input DSRn
		.RIn(), //input RIn
		.DTRn(), //output DTRn
		.RTSn() //output RTSn
	);
endmodule