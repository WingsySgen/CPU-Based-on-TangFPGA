### 基于Sipeed Tang Nano 9k/20k的简易CPU v1

**-----Coming Soon-----**

#### 简介

基于Tang Nano 9k/20k的简易CPU。定长指令，哈佛结构，单周期设计。目前仅支持8bit。

可接任意IO，所有IO都被连接到一块IO控制模块上映射到一个寄存器中。已支持UART。SPI和I2C正在测试。

使用Verilog在Tang FPGA上实现CPU。使用任意文本编辑器写适用于该CPU的汇编命令，然后使用C++进行从汇编到比特流的映射，写到Verilog的Gowin IP核初始化文件中烧入FPGA。

请注意到目前为止该CPU尚未实装中断系统，会尽快实装。



#### 使用方法

前置知识：C++、数字电子技术、Verilog、计算机组成（微机原理、接口技术）等。

如果你只需要需要一个能工作在FPGA上，但可以不像RISC-V那样专业的软核，作为一个简易的实现，你可以仅仅了解如何通过**指令集**让这块CPU工作即可。

你需要高云云源IDE来开发Sipeed Tang，以及一个C++11以上的开发环境。

将Verilog和Cpp下载下来，并且分别修改`\Cpp\main.cpp`中**SOURCE**和**TARGET**为你**汇编代码文本的路径**以及`\Verilog\src\ROM_32bit\ROM_32bit.v`的路径。之后运行main.cpp，当弹出来的cmd显示Done的时候说明映射完毕，如果显示Wrong说明在代码中发现了错误。成功之后在高云云源中综合并烧录，烧录至你的FPGA即可。



#### 文档结构



#### CPU结构简介

见 `\Verilog\CPU结构简介.md`



#### 常量与指令集

见 `\指令集_ISA\常量与指令集.md`



#### 其它

推荐游戏《Turing Complete》，steam在售。教玩家从一个与非门开始搓出一整套计算机并使用汇编实现一些功能，贯穿了从数电基础开始到计算机组成的知识点。

实际上该项目最初的实现就是由我在《Turing Complete》中实现的CPU发展而来。并用在了2023年年初西南科技大学开设的处理器项目设计中。

