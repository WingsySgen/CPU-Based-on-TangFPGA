/*
2023.02.07 1:21
2.0目标：
        1. 给PC添加硬件栈以支持CALL和RET指令
            2023.02.10 23:11 完成
        2. 使得源寄存器和目标寄存器可以为同一寄存器
            2023.02.15 14:08 完成
        3. 添加ADC指令以支持多字节加法运算
        4. 添加MODC指令以支持多字节取模运算
2023.08.23
2.1目标：
        5. 将寄存器个数加到32个
        6. 添加IO控制器以支持更多IO以及SPI，I2C等协议
        7. 将代码进行重构以便于扩展位宽以及在不同设备上运行
        
*/

/*
寄存器组
0 - 11  通用寄存器
12      片选寄存器
13      输入输出控制器
14      计时器
15      程序计数器
*/

`include "constant.vh"

module CPU
#(
    parameter RNUM = 1
)
(
    input wire clk_in,
    input wire rst,
    output reg led,

    output wire[RNUM - 1:0] en_io,
    output wire[RNUM - 1:0] en_cs,
    output wire[`LEN - 1:0] addr_io,
    inout wire[`LEN - 1:0] io
);

    wire[7:0] bus_A;
    wire[7:0] bus_B;
    wire[7:0] bus_C;
    wire[31:0] bus_OP;
    wire[15:0] en_A;
    wire[15:0] en_B;
    wire[15:0] en_C;
    wire[7:0] pc;
    wire en_ALU;
    wire en_COND;
    wire en_RAM;
    wire cond_o;
    wire[1:0] pc_mode;
    wire[7:0] ram_o;
    wire ram_mode;
    wire[7:0] reg_o[13:0];
    reg clk;
    reg clk_256;

    initial begin
        led <= 1'b0;
    end

    assign en_A = bus_OP[7] ? 16'b0 : (16'h01 << bus_OP[15:8]);
    //总线A上的译码器，接受操作码的第二个字节
    //若第一个参数为立即数那么不启动，否则启动对应的寄存器/IO/PC
    assign en_B = bus_OP[6] ? 16'b0 : (16'h01 << bus_OP[23:16]);
    //总线B上的译码器，接受操作码的第三个字节
    //若第二个参数为立即数那么不启动，否则启动对应的寄存器/IO/PC
    // assign en_C = (en_COND || (en_RAM && bus_OP[0]) || (en_RAM && !bus_OP[0] && !clk)) ? 16'b0 : (16'h01 << bus_OP[31:24]);
    assign en_C = clk ? (en_COND || (en_RAM && bus_OP[0]) ? 16'd0 : (16'h01 << bus_OP[31:24])) : 16'd0;
    //总线C上的译码器，接受操作码的第四个字节
    //若为 条件操作 或 写入内存 那么不启动，否则启动对应的寄存器/IO/PC
    assign bus_A = bus_OP[7] ? bus_OP[15:8] : 8'bz;
    //若第一个参数为立即数，获取操作码第二个字节为立即数，否则为高阻态
    assign bus_B = bus_OP[6] ? bus_OP[23:16] : 8'bz;
    //若第二个参数为立即数，获取操作码第三个字节为立即数，否则为高阻态
    assign bus_C = en_COND ? bus_OP[31:24] : 8'bz;
    assign bus_C = (en_RAM && !bus_OP[0]) ? ram_o : 8'bz;
    //若为条件操作，获取操作码第四个字节为立即数，否则为高阻态
    //若为读取内存，从内存输出读取数据，否则为高阻态
    assign en_ALU = bus_OP[5:4] == 2'b00;
    //指示是否为运算操作，高电平有效
    assign en_COND = bus_OP[5:4] == 2'b10;
    //指示是否为条件操作，高电平有效
    assign en_RAM = bus_OP[5:4] == 2'b01;
    //指示是否为内存操作，高电平有效
    assign pc_mode[0] = en_C[15] || cond_o;
    assign pc_mode[1] = (bus_OP[5:4] == 2'b10 && bus_OP[2:1] == 2'b11);
    //pc_mode控制PC的模式，00 = 步进，01 = 覆写，10 = RET，11 = CALL
    assign ram_mode = en_RAM && bus_OP[0];
    //ram_mode控制RAM的读写，0 = 读取，1 = 写入
    //只有写入时为1，其他均为0
    //仅当读取时bus_C才会从ram_O获取数据，不会影响到其他操作
    assign addr_io = reg_o[12];


    reg[23:0] counter;
    reg[15:0] counter_256;

    initial begin
        clk <= 1'b1;
        clk_256 <= 1'b1;
    end

    always @(posedge clk_in or negedge rst) begin
        if (!rst) counter <= 0;
        else begin
            if (counter < 24'd13499999) counter <= counter + 1'b1;
            else counter <= 0;
        end
    end

    always @(posedge clk_in or negedge rst) begin
        if (!rst) led <= 0;
        else begin
            if (counter == 24'd0) led <= ~led;
        end
    end
    
    always @(posedge clk_in or negedge rst) begin
        if (!rst) clk <= 1'b1;
        else begin
            clk <= ~clk;
        end
    end

    always @(posedge clk_in or negedge rst) begin
        if (!rst) counter_256 <= 16'd0;
        else begin
            if (counter_256 < 16'd52734) counter_256 <= counter_256 + 1'b1;
            else counter_256 <= 16'd0;
        end
    end

    always @(posedge clk_in or negedge rst) begin
        if (!rst) clk_256 <= 1'b1;
        else begin
            if (counter_256 == 16'd0) clk_256 <= ~clk_256;
        end
    end
    
    ALU_my Alu(
        .paraA(bus_A),          //从总线A获取参数A
        .paraB(bus_B),          //从总线B获取参数B
        .opcode(bus_OP[7:0]),   //获取操作码
        .en(en_ALU),            //启用ALU
        .rst(rst),
        .clk(clk),
        .data_o(bus_C)          //ALU输出到bus_C上，在en无效时输出为高阻态
    );

    COND_my Cond(
        .paraA(bus_A),          //从总线A获取参数A
        .paraB(bus_B),          //从总线B获取参数B
        .opcode(bus_OP[7:0]),   //获取操作码
        .en(en_COND),           //启用COND
        .rst(rst),
        .data_o(cond_o)         //COND输出，在en无效时输出为0
    );

    genvar i;
    generate
        for(i = 0; i < 13; i = i + 1) begin : reg_gen
            Register_8bit Register(
                .en_A(en_A[i]), //向总线A输出的使能，高电平有效
                .en_B(en_B[i]), //向总线B输出的使能，高电平有效
                .en_i(en_C[i]), //从总线C获取的使能，高电平有效
                .data_i(bus_C), //从总线C获取的数据
                .rst(rst),      //复位，低电平有效，复位后将data重置为0
                .clk(clk),
                .clk_in(clk_in),
                .data_A(bus_A), //向总线A输出的数据，en_A为高电平时输出，为低电平时为高阻态
                .data_B(bus_B), //向总线B输出的数据，en_B为高电平时输出，为低电平时为高阻态
                .data_o(reg_o[i])
            );
        end
    endgenerate

    IOControl #(
        .RNUM(RNUM)
    )
    IOC(
        .en_A(en_A[13]), //向总线A输出的使能，高电平有效
        .en_B(en_B[13]), //向总线B输出的使能，高电平有效
        .en_w_i(en_C[13]), //从总线C获取的使能，高电平有效
        .data_i(bus_C), //从总线C获取的数据
        .cs_i(reg_o[12]),
        .data_A(bus_A), //向总线A输出的数据，en_A为高电平时输出，为低电平时为高阻态
        .data_B(bus_B), //向总线B输出的数据，en_B为高电平时输出，为低电平时为高阻态
        .data_o(),
        .addr_o(),
        .en_w_o(en_io),
        .en_cs(en_cs),
        .data(io)
    );

    Counter Timer(
        .clk(!clk_256),         //时钟输入
        .mode(en_C[14]),        //控制计时器模式，0 = 步进，1 = 覆写
        .en_A(en_A[14]),        //向总线A输出的使能，高电平有效
        .en_B(en_B[14]),        //向总线B输出的使能，高电平有效
        .data_i(bus_C),         //从总线C获取的数据
        .rst(rst),              //位，低电平有效，复位后将PC重置为0
        .data_A(bus_A),         //向总线A输出的数据，en_A为高电平时输出，为低电平时为高阻态
        .data_B(bus_B),         //向总线B输出的数据，en_B为高电平时输出，为低电平时为高阻态
        .data_o()               //
    );
    Program_Counter Pc(
        .clk(clk),              //时钟输入
        .mode(pc_mode),         //控制PC模式，0 = 步进，1 = 覆写
        .en_A(en_A[15]),        //向总线A输出的使能，高电平有效
        .en_B(en_B[15]),        //向总线B输出的使能，高电平有效
        .data_i(bus_C),         //从总线C获取的数据
        .rst(rst),              //位，低电平有效，复位后将PC重置为0
        .data_A(bus_A),         //向总线A输出的数据，en_A为高电平时输出，为低电平时为高阻态
        .data_B(bus_B),         //向总线B输出的数据，en_B为高电平时输出，为低电平时为高阻态
        .data_o(pc)             //始终输出，用来向ROM提供地址
    );

    ROM_32bit Prog(
        .dout(bus_OP),          //ROM输出到操作码总线上
        .clk(clk_in),              //时钟输入
        .oce(1'b1),             //
        .ce(1'b1),              //
        .reset(1'b0),           //
        .ad(pc)                 //输入由PC提供的地址
    );

    RAM_8bit Ram(
        .dout(ram_o),           //总是输出到ram_o，若为读取内存的操作则被bus_C获取
        .clk(clk_in),              //时钟输入
        .oce(1'b1),             //
        .ce(1'b1),              //
        .reset(1'b0),           //
        .wre(ram_mode),         //1 = 写入，0 = 读出
        .ad(bus_B),             //始终从bus_B获取地址
        .din(bus_A)             //始终从bus_A获取数据
    );

endmodule