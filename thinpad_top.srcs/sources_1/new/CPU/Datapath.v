module Datapath (
    input wire clk,
    input wire rst,

    input  wire [31:0] inst_sram_rdata,
    output wire        inst_sram_ce,
    output wire [31:0] inst_sram_addr,

    input  wire [31:0] data_sram_rdata,
    output wire        data_sram_ce,
    output wire        data_sram_we,
    output wire [3:0]  data_sram_be,
    output wire [31:0] data_sram_addr,
    output wire [31:0] data_sram_wdata
);

    wire stall;

    wire ID_jump, ID_rs1_ren, ID_rs2_ren, ID_stall;
    wire ID_mem_read, ID_mem_write, ID_reg_write, ID_data_width;
    wire [2:0] ID_ALU_opt;
    wire [4:0] ID_rs1_addr, ID_rs2_addr, ID_rd_addr;
    wire [31:0] ID_pc, ID_inst, ID_jump_addr;
    wire [31:0] ID_imm, ID_rs1_data, ID_rs2_data;
    wire [31:0] ID_reg1_data, ID_reg2_data, ID_link_addr;

    wire Ex_jump, Ex_mem_read, Ex_mem_write, Ex_reg_write, Ex_data_width;
    wire [2:0] Ex_ALU_opt;
    wire [4:0] Ex_rd_addr;
    wire [31:0] Ex_pc, Ex_inst, Ex_imm, Ex_reg1_data, Ex_reg2_data, Ex_link_addr;
    wire [31:0] Ex_ALU_res, Ex_mem_addr, Ex_mem_wdata;

    wire Mem_mem_read, Mem_mem_write, Mem_reg_write, Mem_data_width, Mem_stall;
    wire [4:0] Mem_rd_addr;
    wire [31:0] Mem_ALU_res, Mem_rd_data;
    wire [31:0] Mem_mem_addr, Mem_mem_wdata;

    wire WB_reg_write;
    wire [4:0] WB_rd_addr;
    wire [31:0] WB_rd_data;

    /***************IF***************/

    assign stall = ID_stall | Mem_stall;

    RegPC Reg_PC (
        .clk(clk),
        .rst(rst),
        .jump(ID_jump),
        .stall(stall),
        .jump_addr(ID_jump_addr),
        .inst_ce(inst_sram_ce),
        .pc(inst_sram_addr)
    );

    IF_ID Reg_IF_ID (
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .IF_pc(inst_sram_addr),
        .IF_inst(inst_sram_rdata),
        .ID_pc(ID_pc),
        .ID_inst(ID_inst)
    );

    /***************ID***************/

    assign ID_rs1_addr = ID_inst[25:21];
    assign ID_rs2_addr = ID_inst[20:16];

    ControlUnit ControlUnit (
        .ID_inst(ID_inst),
        .rs1_ren(ID_rs1_ren),
        .rs2_ren(ID_rs2_ren),
        .mem_read(ID_mem_read),
        .mem_write(ID_mem_write),
        .reg_write(ID_reg_write),
        .data_width(ID_data_width),
        .ALU_opt(ID_ALU_opt),
        .rd_addr(ID_rd_addr)
    );

    Regs Regs (
        .clk(clk),
        .rst(rst),
        .rs1_ren(ID_rs1_ren),
        .rs2_ren(ID_rs2_ren),
        .reg_write(WB_reg_write),
        .rs1_addr(ID_rs1_addr),
        .rs2_addr(ID_rs2_addr),
        .rd_addr(WB_rd_addr),
        .rd_data(WB_rd_data),
        .rs1_data(ID_rs1_data),
        .rs2_data(ID_rs2_data)
    );

    StallUnit StallUnit (
        .ID_rs1_ren(ID_rs1_ren),
        .ID_rs2_ren(ID_rs2_ren),
        .Ex_mem_read(Ex_mem_read),
        .ID_reg_write(ID_reg_write),
        .Ex_rd_addr(Ex_rd_addr),
        .ID_rs1_addr(ID_rs1_addr),
        .ID_rs2_addr(ID_rs2_addr),
        .stall(ID_stall)
    );

    ImmGen ImmGen (
        .ID_inst(ID_inst),
        .imm_out(ID_imm)
    );

    ForwardingUnit ForwardingUnit (
        .ID_rs1_ren(ID_rs1_ren),
        .ID_rs2_ren(ID_rs2_ren),
        .Ex_mem_read(Ex_mem_read),
        .Ex_reg_write(Ex_reg_write),
        .Mem_reg_write(Mem_reg_write),
        .ID_rs1_addr(ID_rs1_addr),
        .ID_rs2_addr(ID_rs2_addr),
        .Ex_rd_addr(Ex_rd_addr),
        .Mem_rd_addr(Mem_rd_addr),
        .ID_imm(ID_imm),
        .ID_rs1_data(ID_rs1_data),
        .ID_rs2_data(ID_rs2_data),
        .Ex_ALU_res(Ex_ALU_res),
        .Mem_rd_data(Mem_rd_data),
        .ID_reg1_data(ID_reg1_data),
        .ID_reg2_data(ID_reg2_data)
    );

    JumpUnit JumpUnit (
        .ID_pc(ID_pc),
        .ID_inst(ID_inst),
        .reg1_data(ID_reg1_data),
        .reg2_data(ID_reg2_data),
        .jump(ID_jump),
        .jump_addr(ID_jump_addr),
        .link_addr(ID_link_addr)
    );

    ID_Ex Reg_ID_Ex (
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .ID_jump(ID_jump),
        .ID_mem_read(ID_mem_read),
        .ID_mem_write(ID_mem_write),
        .ID_reg_write(ID_reg_write),
        .ID_data_width(ID_data_width),
        .ID_ALU_opt(ID_ALU_opt),
        .ID_rd_addr(ID_rd_addr),
        .ID_pc(ID_pc),
        .ID_inst(ID_inst),
        .ID_reg1_data(ID_reg1_data),
        .ID_reg2_data(ID_reg2_data),
        .ID_link_addr(ID_link_addr),
        .ID_imm(ID_imm),
        .Ex_jump(Ex_jump),
        .Ex_mem_read(Ex_mem_read),
        .Ex_mem_write(Ex_mem_write),
        .Ex_reg_write(Ex_reg_write),
        .Ex_data_width(Ex_data_width),
        .Ex_ALU_opt(Ex_ALU_opt),
        .Ex_rd_addr(Ex_rd_addr),
        .Ex_pc(Ex_pc),
        .Ex_inst(Ex_inst),
        .Ex_reg1_data(Ex_reg1_data),
        .Ex_reg2_data(Ex_reg2_data),
        .Ex_link_addr(Ex_link_addr),
        .Ex_imm(Ex_imm)
    );

    /***************Ex***************/

    assign Ex_mem_addr = Ex_ALU_res;
    assign Ex_mem_wdata = Ex_reg2_data;

    ALU ALU (
        .jump(Ex_jump),
        .mem_read(Ex_mem_read),
        .mem_write(Ex_mem_write),
        .ALU_opt(Ex_ALU_opt),
        .reg1(Ex_reg1_data),
        .reg2(Ex_reg2_data),
        .imm(Ex_imm),
        .link_addr(Ex_link_addr),
        .ALU_res(Ex_ALU_res)
    );

    Ex_Mem Ex_Mem (
        .clk(clk),
        .rst(rst),
        .Ex_mem_read(Ex_mem_read),
        .Ex_mem_write(Ex_mem_write),
        .Ex_reg_write(Ex_reg_write),
        .Ex_data_width(Ex_data_width),
        .Ex_rd_addr(Ex_rd_addr),
        .Ex_ALU_res(Ex_ALU_res),
        .Ex_mem_addr(Ex_mem_addr),
        .Ex_mem_wdata(Ex_mem_wdata),
        .Mem_mem_read(Mem_mem_read),
        .Mem_mem_write(Mem_mem_write),
        .Mem_reg_write(Mem_reg_write),
        .Mem_data_width(Mem_data_width),
        .Mem_rd_addr(Mem_rd_addr),
        .Mem_ALU_res(Mem_ALU_res),
        .Mem_mem_addr(Mem_mem_addr),
        .Mem_mem_wdata(Mem_mem_wdata)
    );

    /***************Mem***************/

    assign data_sram_addr = Mem_mem_addr;

    Mem Mem (
        .mem_read(Mem_mem_read),
        .mem_write(Mem_mem_write),
        .data_width(Mem_data_width),
        .ALU_res(Mem_ALU_res),
        .mem_addr(Mem_mem_addr),
        .mem_rdata(data_sram_rdata),
        .mem_wdata_in(Mem_mem_wdata),
        .stall(Mem_stall),
        .mem_ce(data_sram_ce),
        .mem_we(data_sram_we),
        .mem_be(data_sram_be),
        .rd_data(Mem_rd_data),
        .mem_wdata_out(data_sram_wdata)
    );

    Mem_WB Mem_WB (
        .clk(clk),
        .rst(rst),
        .Mem_reg_write(Mem_reg_write),
        .Mem_rd_addr(Mem_rd_addr),
        .Mem_rd_data(Mem_rd_data),
        .WB_reg_write(WB_reg_write),
        .WB_rd_addr(WB_rd_addr),
        .WB_rd_data(WB_rd_data)
    );

endmodule