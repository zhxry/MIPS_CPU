module Datapath (
    input wire clk,
    input wire rst,

    input wire [31:0] inst_sram_rdata,
    output wire inst_sram_en,
    output wire [31:0] inst_sram_addr,

    input wire [31:0] data_sram_rdata,
    output wire data_sram_en,
    output wire [3:0] data_sram_wen,
    output wire [31:0] data_sram_addr,
    output wire [31:0] data_sram_wdata
);

    wire stall;
    wire [31:0] pc_addr;

    wire ID_jump, ID_rs1_ren, ID_rs2_ren;
    wire ID_mem_read, ID_mem_write, ID_reg_write, ID_data_width;
    wire [1:0] ID_mem_to_reg;
    wire [2:0] ID_ALU_opt;
    wire [4:0] ID_rd_addr;
    wire [31:0] ID_pc, ID_inst, ID_jump_addr;
    wire [31:0] ID_rs1_addr, ID_rs2_addr, ID_rd_addr;
    wire [31:0] ID_imm, ID_rs1_data, ID_rs2_data;
    wire [31:0] ID_reg1_data, ID_reg2_data, ID_link_addr;

    wire Ex_jump, Ex_mem_read, Ex_mem_write, Ex_reg_write, Ex_data_width;
    wire [1:0] Ex_mem_to_reg;
    wire [2:0] Ex_ALU_opt;
    wire [4:0] Ex_rd_addr;
    wire [31:0] Ex_pc, Ex_inst, Ex_imm, Ex_reg1_data, Ex_reg2_data, Ex_link_addr;
    wire [31:0] Ex_ALU_res, Ex_mem_addr, Ex_mem_wdata;

    wire Mem_mem_read, Mem_mem_write, Mem_reg_write, Mem_data_width;
    wire [31:0] Mem_rd_addr, Mem_rd_data;
    wire [31:0] Mem_mem_addr, Mem_mem_wdata;

    wire WB_reg_write;
    wire [4:0] WB_rd_addr;
    wire [31:0] WB_rd_data;

    /***************IF***************/

    assign inst_sram_addr = pc_addr;

    RegPC Reg_PC (
        .clk(clk),
        .rst(rst),
        .jump(ID_jump),
        .stall(stall),
        .jump_addr(ID_jump_addr),
        .inst_en(inst_sram_en),
        .pc(pc_addr)
    );

    IF_ID Reg_IF_ID (
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .IF_pc(pc_addr),
        .IF_inst(inst_sram_rdata),
        .ID_pc(ID_pc),
        .ID_inst(ID_inst)
    );

    /***************ID***************/

    assign rs1_addr = ID_inst[25:21];
    assign rs2_addr = ID_inst[20:16];

    ControlUnit ControlUnit (
        .ID_inst(ID_inst),
        .rs1_ren(ID_rs1_ren),
        .rs2_ren(ID_rs2_ren),
        .mem_read(ID_mem_read),
        .mem_write(ID_mem_write),
        .reg_write(ID_reg_write),
        .data_width(ID_data_width),
        .mem_to_reg(ID_mem_to_reg),
        .ALU_opt(ID_ALU_opt),
        .rd_addr(ID_rd_addr)
    );

    Regs Regs (
        .clk(clk),
        .rst(rst),
        .reg_write(WB_reg_write),
        .rs1_addr(ID_rs1_addr),
        .rs2_addr(ID_rs2_addr),
        .rd_addr(WB_rd_addr),
        .rd_data(WB_rd_data),
        .rs1_data(ID_rs1_data),
        .rs2_data(ID_rs2_data)
    );

    StallUnit StallUnit (
        .Ex_mem_read(Ex_mem_read),
        .ID_reg_write(ID_reg_write),
        .Ex_rd_addr(Ex_rd_addr),
        .ID_rs1_addr(ID_rs1_addr),
        .ID_rs2_addr(ID_rs2_addr),
        .stall(stall)
    );

    ImmGen ImmGen (
        .ID_inst(ID_inst),
        .imm_out(ID_imm)
    );

    ForwardingUnit ForwardingUnit (
        .ID_rs1_ren(ID_rs1_ren),
        .ID_rs2_ren(ID_rs2_ren),
        .ID_reg_write(ID_reg_write),
        .Ex_mem_read(Ex_mem_read),
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
        .ID_reg1_data(ID_reg1_data),
        .ID_reg2_data(ID_reg2_data),
        .j_b(ID_jump),
        .j_b_addr(ID_jump_addr),
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
        .ID_mem_to_reg(ID_mem_to_reg),
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
        .Ex_mem_to_reg(Ex_mem_to_reg),
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

    Ex Ex (
        .jump(Ex_jump),
        .ALU_opt(Ex_ALU_opt),
        .reg1(Ex_reg1_data),
        .reg2(Ex_reg2_data),
        .imm(Ex_imm),
        .link_addr(Ex_link_addr),
        .ALU_out(Ex_ALU_res)
    );

endmodule