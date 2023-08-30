module ROM_32bit (dout, clk, oce, ce, reset, ad);
output [31:0] dout;
input clk;
input oce;
input ce;
input reset;
input [7:0] ad;

wire gw_gnd;

assign gw_gnd = 1'b0;

pROM prom_inst_0 (
    .DO(dout[31:0]),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .AD({gw_gnd,ad[7:0],gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd})
);

defparam prom_inst_0.READ_MODE = 1'b0;
defparam prom_inst_0.BIT_WIDTH = 32;
defparam prom_inst_0.RESET_MODE = "SYNC";

defparam prom_inst_0.INIT_RAM_00 = 256'h0700008606000086050000860400008603000086020000860100008600000086;
defparam prom_inst_0.INIT_RAM_01 = 256'h25000020100000270E0000860C0000860B0000860A0000860900008608000086;
defparam prom_inst_0.INIT_RAM_02 = 256'h13600A610A600D4200000040000000400C001586000000260D0007860C001386;
defparam prom_inst_0.INIT_RAM_03 = 256'h1B010A610A010D4200000040000000400C001586000000260D000B060C001086;
defparam prom_inst_0.INIT_RAM_04 = 256'h25000020130000271B000027000000260B000D0600000040000000400C001086;

endmodule
