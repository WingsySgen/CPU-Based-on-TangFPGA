module Register_8bit(
    input wire en_A,
    input wire en_B,
    input wire en_i,
    input wire[7:0] data_i,
    input wire rst,
    input wire clk,
    input wire clk_in,
    output wire[7:0] data_A,
    output wire[7:0] data_B,
    output wire[7:0] data_o
);
    reg[7:0] data;
    initial begin
        data <= 8'b0;
    end
    assign data_A = (en_A ? data : 8'bz);
    assign data_B = (en_B ? data : 8'bz);
    assign data_o = data;
    always @(negedge clk_in, negedge rst) begin
        if(!rst) data <= 8'b0;
        else if(en_i && clk) data <= data_i;
    end
endmodule