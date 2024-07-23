module ForwardingUnit (
    input wire ID_rs1_ren,
    input wire ID_rs2_ren,
    input wire Ex_mem_read,
    input wire Ex_reg_write,
    input wire Mem_reg_write,
    input wire [4:0] ID_rs1_addr,
    input wire [4:0] ID_rs2_addr,
    input wire [4:0] Ex_rd_addr,
    input wire [4:0] Mem_rd_addr,
    input wire [31:0] ID_imm,
    input wire [31:0] ID_rs1_data,
    input wire [31:0] ID_rs2_data,
    input wire [31:0] Ex_ALU_res,
    input wire [31:0] Mem_rd_data,

    output reg [31:0] ID_reg1_data,
    output reg [31:0] ID_reg2_data
);

    always @(*) begin
        if (ID_rs1_ren && Ex_reg_write && ID_rs1_addr == Ex_rd_addr) begin
            ID_reg1_data = Ex_ALU_res; // Ex
        end else if (ID_rs1_ren && Mem_reg_write && ID_rs1_addr == Mem_rd_addr) begin
            ID_reg1_data = Mem_rd_data; // Mem
        end else if (ID_rs1_ren) begin
            ID_reg1_data = ID_rs1_data; // reg
        end else if (!ID_rs1_ren) begin
            ID_reg1_data = ID_imm; // imm
        end else begin
            ID_reg1_data = 32'b0;
        end
    end

    always @(*) begin
        if (ID_rs2_ren && Ex_reg_write && ID_rs2_addr == Ex_rd_addr) begin
            ID_reg2_data = Ex_ALU_res;
        end else if (ID_rs2_ren && Mem_reg_write && ID_rs2_addr == Mem_rd_addr) begin
            ID_reg2_data = Mem_rd_data;
        end else if (ID_rs2_ren) begin
            ID_reg2_data = ID_rs2_data;
        end else if (!ID_rs2_ren) begin
            ID_reg2_data = ID_imm;
        end else begin
            ID_reg2_data = 32'b0;
        end
    end

endmodule