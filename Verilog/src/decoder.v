module Decoder_Display(in, rst, out);
    input wire[7:0] in;
    input wire rst;
    output reg[7:0] out;
//    10  9  7  6  1  2  4  5
//     G  F  A  B  E  D  C  DP
//     9 10  7  6  2  5  4  1
//     F  G  A  B  D DP  C  E

    always @(*) begin
        if (!rst) out <= 8'b00000000;
        else begin
            case (in)
                8'h00 : out <= 8'b01011111;
                8'h01 : out <= 8'b00001010;
                8'h02 : out <= 8'b00111101;
                8'h03 : out <= 8'b00111110;
                8'h04 : out <= 8'b01101010;
                8'h05 : out <= 8'b01110110;
                8'h06 : out <= 8'b01110111;
                8'h07 : out <= 8'b00011010;
                8'h08 : out <= 8'b01111111;
                8'h09 : out <= 8'b01111110;
                8'h0a : out <= 8'b00100000;
                8'h14 : out <= 8'b00000000;
                8'h15 : out <= 8'b10000000;
                default : out <= 8'b00000000;
            endcase
        end
    end
    
endmodule