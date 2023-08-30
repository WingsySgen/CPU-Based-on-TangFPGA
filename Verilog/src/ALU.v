//en高电平有效
module ALU_my(
    input wire[7:0] paraA,
    input wire[7:0] paraB,
    input wire[7:0] opcode,
    input wire en,
    input wire rst,
    input wire clk,
    output wire[7:0] data_o
);
    reg[15:0] result;
    initial begin
        result <= 16'd0;
    end
    assign data_o = en ? (opcode[3:0] == 4'h8 ? result[15:8] : result[7:0]) : 8'bz;
    always @(*) begin
        if(!rst) result <= 16'd0;
        else if (!clk) begin
            case (opcode[3:0])
                4'h0 : result[7:0] <= paraA + paraB;
                4'h1 : result[7:0] <= paraA - paraB;
                4'h2 : result[7:0] <= paraA & paraB;
                4'h3 : result[7:0] <= paraA | paraB;
                4'h4 : result[7:0] <= ~paraA;
                4'h5 : result[7:0] <= paraA ^ paraB;
                4'h6 : result[7:0] <= paraA;
                4'h7 : result[15:0] <= paraA * paraB;
                4'h8 : result[15:0] <= paraA * paraB;
                4'h9 : result[15:0] <= paraA << paraB;
                4'ha : result[7:0] <= paraA >> paraB;
                4'hb : result[15:0] <= paraB > paraA ? 15'd0 : (paraA / (paraB == 0 ? 8'h01 : paraB));
                4'hc : result[15:0] <= paraB > paraA ? paraA : (paraA % (paraB == 0 ? 8'h01 : paraB));
                4'hd : result[7:0] <= {7'b0, result[8]};
            endcase
        end
    end
endmodule