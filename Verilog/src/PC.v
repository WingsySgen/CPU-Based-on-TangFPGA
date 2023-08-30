module Program_Counter(
    input wire clk,
    input wire[1:0] mode,//00 = 步进   01 = 覆写   10 = 从栈中读取   11 = 保存至栈中
    input wire en_A,
    input wire en_B,
    input wire[7:0] data_i,
    input wire rst,
    output wire[7:0] data_o,
    output wire[7:0] data_A,
    output wire[7:0] data_B
);
    wire[7:0] stk_o;
    reg[7:0] data;
    initial begin
        data <= 8'h00;
    end

    Stack_32Bytes stack(
        .data_i(data_o + 1'b1),
        .en(mode[1]),
        .mode(mode[0]),
        .rst(rst),
        .clk(clk),
        .data_o(stk_o)
    );

    always @(posedge clk, negedge rst) begin
        if(!rst) data <= 8'h00; 
        else begin
            case (mode)
                2'b00 : data <= data + 1'b1;
                2'b01 : data <= data_i;
                2'b10 : data <= stk_o;
                2'b11 : data <= data_i;
            endcase
        end
    end
    assign data_o = data;
    assign data_A = (en_A ? data : 8'bz);
    assign data_B = (en_B ? data : 8'bz);
endmodule