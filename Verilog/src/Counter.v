module Counter(
    input wire clk,
    input wire mode,
    input wire en_A,
    input wire en_B,
    input wire[7:0] data_i,
    input wire rst,
    output wire[7:0] data_o,
    output wire[7:0] data_A,
    output wire[7:0] data_B
);
    // parameter STEP = 4;
    reg[7:0] data;
    initial begin
        data <= 8'h00;
    end
    always @(posedge clk, negedge rst) begin
        if(!rst) data <= 8'h00; 
        else begin
            if (!mode) data <= data + 8'h01;
            else data <= data_i;
        end
    end
    assign data_o = data;
    assign data_A = (en_A ? data : 8'bz);
    assign data_B = (en_B ? data : 8'bz);
endmodule