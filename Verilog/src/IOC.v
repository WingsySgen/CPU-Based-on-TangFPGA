`include "src/constant.vh"
module IOControl
#(
    parameter RNUM = 1
)
(
    input   wire        en_A,
    input   wire        en_B,
    input   wire        en_w_i,
    input   wire[`LEN - 1:0]    data_i,
    input   wire[`LEN - 1:0]    cs_i,
    output  wire[`LEN - 1:0]    data_A,
    output  wire[`LEN - 1:0]    data_B,
    output  wire[`LEN - 1:0]    data_o,
    output  wire[`LEN - 1:0]    addr_o,
    output  wire[RNUM - 1:0]    en_w_o,
    output  wire[RNUM - 1:0]    en_cs,
    inout   wire[`LEN - 1:0]    data
);
    assign en_cs = 16'b1 << cs_i[`LEN - 1 : 4];
    assign en_w_o = en_w_i << cs_i[`LEN - 1 : 4];
    assign data = (en_w_i ? data_i : 'dz);
    assign addr_o = {0, cs_i[3:0]};
    //data[`LEN * cs_i[`LEN - 1 : 4] +: `LEN]
    assign data_A = (en_A ? data : `LEN'bz);
    assign data_B = (en_B ? data : `LEN'bz);
    assign data_o = data;
endmodule