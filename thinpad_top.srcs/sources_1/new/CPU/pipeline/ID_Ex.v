module ID_Ex (
    input wire clk,
    input wire rst,
    input wire stall,
    input wire ID_jump,
    input wire ID_mem_read,
    input wire ID_mem_write,
    input wire ID_reg_write,
    input wire ID_data_width,
    input wire [1:0] ID_mem_to_reg,
    input wire [2:0] ID_ALU_opt,
    input wire [4:0] ID_rd_addr,
    input wire [31:0] ID_pc,
    input wire [31:0] ID_inst,
    input wire [31:0] ID_reg1_data,
    input wire [31:0] ID_reg2_data,
    input wire [31:0] ID_link_addr,
    input wire [31:0] ID_imm,
    output reg Ex_jump,
    output reg Ex_mem_read,
    output reg Ex_mem_write,
    output reg Ex_reg_write,
    output reg Ex_data_width,
    output reg [1:0] Ex_mem_to_reg,
    output reg [2:0] Ex_ALU_opt,
    output reg [4:0] Ex_rd_addr,
    output reg [31:0] Ex_pc,
    output reg [31:0] Ex_inst,
    output reg [31:0] Ex_reg1_data,
    output reg [31:0] Ex_reg2_data,
    output reg [31:0] Ex_link_addr,
    output reg [31:0] Ex_imm
);

    always @(posedge clk) begin
        if (rst || stall) begin
            Ex_jump <= 1'b0;
            Ex_mem_read <= 1'b0;
            Ex_mem_write <= 1'b0;
            Ex_reg_write <= 1'b0;
            Ex_data_width <= 1'b0;
            Ex_mem_to_reg <= 2'b0;
            Ex_ALU_opt <= 3'b0;
            Ex_rd_addr <= 5'b0;
            Ex_pc <= 32'b0;
            Ex_inst <= 32'b0;
            Ex_reg1_data <= 32'b0;
            Ex_reg2_data <= 32'b0;
            Ex_link_addr <= 32'b0;
            Ex_imm <= 32'b0;
        end else begin
            Ex_jump <= ID_jump;
            Ex_mem_read <= ID_mem_read;
            Ex_mem_write <= ID_mem_write;
            Ex_reg_write <= ID_reg_write;
            Ex_data_width <= ID_data_width;
            Ex_mem_to_reg <= ID_mem_to_reg;
            Ex_ALU_opt <= ID_ALU_opt;
            Ex_rd_addr <= ID_rd_addr;
            Ex_pc <= ID_pc;
            Ex_inst <= ID_inst;
            Ex_reg1_data <= ID_reg1_data;
            Ex_reg2_data <= ID_reg2_data;
            Ex_link_addr <= ID_link_addr;
            Ex_imm <= ID_imm;
        end
    end

endmodule