//Copyright (C)2014-2022 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//GOWIN Version: V1.9.8.09 Education
//Part Number: GW1NR-LV9QN88PC6/I5
//Device: GW1NR-9C
//Created Time: Tue Jan 31 21:45:40 2023

module RAM_32bit (dout, clk, oce, ce, reset, wre, ad, din);

output [31:0] dout;
input clk;
input oce;
input ce;
input reset;
input wre;
input [7:0] ad;
input [31:0] din;

wire gw_vcc;
wire gw_gnd;

assign gw_vcc = 1'b1;
assign gw_gnd = 1'b0;

SP sp_inst_0 (
   .DO(dout[31:0]),
   .CLK(clk),
   .OCE(oce),
   .CE(ce),
   .RESET(reset),
   .WRE(wre),
   .BLKSEL({gw_gnd,gw_gnd,gw_gnd}),
   .AD({gw_gnd,ad[7:0],gw_gnd,gw_vcc,gw_vcc,gw_vcc,gw_vcc}),
   .DI(din[31:0])
);

defparam sp_inst_0.READ_MODE = 1'b0;
defparam sp_inst_0.WRITE_MODE = 2'b00;
defparam sp_inst_0.BIT_WIDTH = 32;
defparam sp_inst_0.BLK_SEL = 3'b000;
defparam sp_inst_0.RESET_MODE = "SYNC";

endmodule //RAM_32bit
