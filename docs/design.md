# MIPS SoC 设计报告

> 浙江大学 徐若禺 xuruoyu326@zju.edu.cn

## 设计简介

本项目是第八届“龙芯杯”全国大学生计算机系统能力培养大赛（NSCSCC 2024）个人赛初赛参赛作品。CPU 支持 MIPS-C3 的 22 条指令，采用单发射、经典五级流水线设计，无异常中断；使用流水线暂停、数据前递、延时槽等技术解决流水线冒险问题。项目 CPU 时钟频率为 55MHz，可以通过平台三级评测与性能测试，性能测试成绩为 0.129 + 0.163 + 0.420 = 0.712s。

## 设计方案

### 设计总体思路

项目的顶层 SoC 主要由 CPU 数据通路（`Datapath`）和内存串口（`RAM_ctrl`）两个模块构成。`Datapath` 为五级 MIPS 流水线的数据通路，包含 IF、ID、Ex、Mem、WB 五个阶段，每个阶段的数据通过流水线寄存器传递。`RAM_ctrl` 为内存与串口控制模块，负责接收 CPU 的读写请求，并通过串口与 BaseRAM, ExtRAM 进行数据交互。

### CPU 设计方案

MIPS CPU 采用经典五级流水线（`IF`, `ID`, `Ex`, `Mem`, `WB`）设计。设计亮点如下：
- 将分支跳转指令的条件判断前提到 `ID` 阶段（由 `JumpUnit` 模块进行判断），并将跳转目标直接传递回 `IF` 阶段的 `RegPC` 模块。结合 MIPS 架构的延时槽特性，可以避免运行过程中的控制冒险。
- `Regs` 寄存器堆模块采用组合逻辑进行数据读取，避免了间隔两周期的数据冒险。
- `ForwardingUnit` 模块进行数据前递以解决数据冒险问题。
- 遇到 load-use 的情况，采用停顿流水线一周期的方式规避数据冒险；`Mem` 阶段需要访问 `BaseRAM` 时，同样停顿一周期规避结构冒险。

### 串口设计方案

串口交互与内存映射在 `RAM_ctrl` 模块中实现。串口异步通信参考 `thinpad_top.v` 中 Demo 的设计；同时本项目使用 Vivado IP Repository 中的 FIFO Generator 生成了两个先进先出队列 `RxD_FIFO` 和 `TxD_FIFO`，分别处理串口接收和发送的数据以减少串口通信的等待时间。具体设计见 `RAM_ctrl.v`。

## 设计结果

### 设计交付物说明

项目主要设计源代码位于 `./thinpad_top.srcs/sources_1` 下，主要包含以下文件：
```txt
sources_1
├───ip
│   ├───fifo_generator_0           // FIFO 队列
│   └───pll_example                // PLL 时钟模块
└───new
    ├───CPU
    |   ├───Ex
    |   |   └───ALU.v              // 算术逻辑单元
    |   ├───ID
    |   |   ├───ControllUnit.v     // 控制信号单元
    |   |   ├───ForwardingUnit.v   // 数据前递单元
    |   |   ├───ImmGen.v           // 立即数生成单元
    |   |   ├───JumpUnit.v         // 跳转控制单元
    |   |   ├───Regs.v             // 寄存器堆
    |   |   └───StallUnit.v        // 停顿控制单元
    |   ├───IF
    |   |   └───RegPC.v            // PC 寄存器
    |   ├───lib
    |   |   └───Header.vh          // 包含基本定义的头文件
    |   ├───Mem
    |   |   └───Mem.v              // Mem 阶段
    |   ├───pipeline               // 五级流水线寄存器
    |   |   ├───Ex_Mem.v
    |   |   ├───ID_Ex.v
    |   |   ├───IF_ID.v
    |   |   └───Mem_WB.v
    |   └───Datapath.v             // 数据通路
    ├───async.v
    ├───RAM_ctrl.v                 // RAM 串口控制模块
    ├───SEG7_LUT.v
    ├───thinpad_top.v              // 顶层模块
    └───vga.v
```

### 设计测试结果

**功能测试**：
|   项目  | 得分 |
|  -----  |  -  |
| 一级评测 | 100 |
| 二级评测 | 100 |
| 三级评测 | 100 |
| 性能测试 | 100 |

**性能测试**：
|     项目    |   用时  |
| ----------- | ------ |
|    STREAM   | 0.129s |
|    MATRIX   | 0.163s |
| CRYPTONIGHT | 0.420s |
|     总计    | 0.712s |

## 参考资料

- 雷思磊. 自己动手写CPU. 电子工业出版社, 2014.
- [cpu_for_nscscc2022_single](https://github.com/fluctlight001/cpu_for_nscscc2022_single)
- [XZMIPS](https://github.com/xiazhuo/nscc2022_personal)
- [Step into MIPS](https://github.com/lvyufeng/step_into_mips)