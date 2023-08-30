`include "constant.vh"

module TOP
#(
    SPI_IONUM = 1,
    CPU_IOC_IONUM = 3
)
(
    input   wire    rst,
    input   wire    clk_sys,
    output  wire    led,
    
    input   wire    MISO,
    output  wire    MOSI,
    output  wire[SPI_IONUM - 1:0]   CS,
    output  wire    SCLK,

    input   wire    RX,
    output  wire    TX,

    output  wire    tft_D_CX

);

wire[CPU_IOC_IONUM - 1:0] en_io;
wire[CPU_IOC_IONUM - 1:0] en_cs;
wire[`LEN - 1:0] bus_io;
wire[`LEN - 1:0] addr;

wire clk_1M;
reg[3:0] cnt_1M = 4'b0;
assign clk_1M = cnt_1M[3];
always @(posedge clk_sys, `RSTEDGE rst) begin
    if (!rst) cnt_1M <= 4'b0;
    else cnt_1M <= cnt_1M + 1'b1;
end


CPU 
#(
    .RNUM(CPU_IOC_IONUM)
)
cpu
(
    .clk_in(clk_sys),
    .rst(rst),
    .led(led),
    .en_io(en_io),
    .en_cs(en_cs),
    .addr_io(addr),
    .io(bus_io)
);

SPI_PORT 
#(
    .IONUM(SPI_IONUM)
)
spi
(
    .en_i(en_io[0]),
    .en_cs(en_cs[0]),
    .clk_in(clk_1M),
    .rst(rst),
    .addr_i(addr),
    .data(bus_io),
    .MISO(MISO),
    .MOSI(MOSI),
    .SCLK(SCLK),
    .CS(CS)
);

UART_PORT uart(
    .en_i(en_io[1]),
    .en_cs(en_cs[1]),
    .clk_in(clk_sys),
    .rst(rst),
    .addr_i(addr),
    .data(bus_io),
    .TX(TX),
    .RX(RX)
);

endmodule