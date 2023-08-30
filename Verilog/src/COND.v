//en高电平有效
module COND_my(
    input wire[7:0] paraA,
    input wire[7:0] paraB,
    input wire[7:0] opcode,
    input wire en,
    input wire rst,
    output wire data_o
);
    reg result;
    initial begin
        result <= 1'b0;
    end
    assign data_o = en ? result : 1'b0;
    always @(*) begin
        if (!rst) result <= 1'b0;
        else begin
            case (opcode[3:0])
                4'h0 : result <= (paraA == paraB);
                4'h1 : result <= (paraA != paraB);
                4'h2 : result <= (paraA < paraB);
                4'h3 : result <= (paraA <= paraB);
                4'h4 : result <= (paraA > paraB);
                4'h5 : result <= (paraA >= paraB);
                4'h6 : result <= 1'b0;
                4'h7 : result <= 1'b1;
            endcase
        end
    end
endmodule