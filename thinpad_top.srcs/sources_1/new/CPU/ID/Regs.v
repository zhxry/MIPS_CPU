module Regs (
    input wire clk,
    input wire rst,
    input wire rs1_ren,
    input wire rs2_ren,
    input wire reg_write,
    input wire [4:0] rs1_addr,
    input wire [4:0] rs2_addr,
    input wire [4:0] rd_addr,
    input wire [31:0] rd_data,
    output reg [31:0] rs1_data,
    output reg [31:0] rs2_data
);

    reg [31:0] regs[31:0];
    integer i;

    always @(posedge clk) begin
        if (rst) for (i = 0; i < 32; i = i + 1) regs[i] <= 0;
        else if (reg_write && rd_addr != 0) regs[rd_addr] <= rd_data;
    end

    always @(*) begin
        if (rs1_ren && rs1_addr != 0) begin
            if (rs1_addr == rd_addr && reg_write) rs1_data = rd_data;
            else rs1_data = regs[rs1_addr];
        end else begin
            rs1_data = 32'b0;
        end
    end

    always @(*) begin
        if (rs2_ren && rs2_addr != 0) begin
            if (rs2_addr == rd_addr && reg_write) rs2_data = rd_data;
            else rs2_data = regs[rs2_addr];
        end else begin
            rs2_data = 32'b0;
        end
    end

endmodule