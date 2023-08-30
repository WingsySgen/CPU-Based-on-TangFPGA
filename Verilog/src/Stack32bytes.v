module Stack_32Bytes(
    input wire[7:0] data_i,
    input wire en,          //使能
    input wire mode,        //1 = 写入   0 = 读取
    input wire rst,
    input wire clk,
    output wire[7:0] data_o
);
    genvar i;
    wire[31:0] status;
    generate
        for (i = 1; i < 31; i = i + 1) begin : stack_gen
            Stack_Unit Stack(
                .above(status[i + 1]),
                .below(status[i - 1]),
                .data_i(data_i),
                .en(en),
                .mode(mode),
                .rst(rst),
                .clk(clk),
                .status_o(status[i]),
                .data_o(data_o)
            );
        end
    endgenerate

    Stack_Unit Bottom(
        .above(status[1]),
        .below(1'b1),
        .data_i(data_i),
        .en(en),
        .mode(mode),
        .rst(rst),
        .clk(clk),
        .status_o(status[0]),
        .data_o(data_o)
    );
    Stack_Unit Top(
        .above(1'b0),
        .below(status[30]),
        .data_i(data_i),
        .en(en),
        .mode(mode),
        .rst(rst),
        .clk(clk),
        .status_o(status[31]),
        .data_o(data_o)
    );

endmodule

module Stack_Unit(
    input wire above,
    input wire below,
    input wire[7:0] data_i,
    input wire en,
    input wire mode,
    input wire rst,
    input wire clk,
    output wire status_o,
    output wire[7:0] data_o
);
    reg status;
    reg[7:0] data;
    initial begin
        data <= 8'd0;
        status <= 1'b0;
    end
    assign status_o = status;
    assign data_o = (status && !above) ? data : 8'bz;

    always @(posedge clk, negedge rst) begin
        if (!rst) begin
            data <= 8'd0;
            status <= 1'b0;
        end
        else if (en) begin
            if (mode && !status && below) begin
                status <= 1'b1;
                data <= data_i;
            end
            else if (!mode && status && !above) begin
                status <= 1'b0;
            end
        end
    end
endmodule