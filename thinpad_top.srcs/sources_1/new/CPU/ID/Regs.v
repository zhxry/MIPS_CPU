module Regs (
    input wire clk,
    input wire rst,
    input wire reg_write,
    input wire [4:0] rs1_addr,
    input wire [4:0] rs2_addr,
    input wire [4:0] rd_addr,
    input wire [31:0] rd_data,
    output wire [31:0] rs1_data,
    output wire [31:0] rs2_data,
    output wire [31:0] reg00,
    output wire [31:0] reg01,
    output wire [31:0] reg02,
    output wire [31:0] reg03,
    output wire [31:0] reg04,
    output wire [31:0] reg05,
    output wire [31:0] reg06,
    output wire [31:0] reg07,
    output wire [31:0] reg08,
    output wire [31:0] reg09,
    output wire [31:0] reg10,
    output wire [31:0] reg11,
    output wire [31:0] reg12,
    output wire [31:0] reg13,
    output wire [31:0] reg14,
    output wire [31:0] reg15,
    output wire [31:0] reg16,
    output wire [31:0] reg17,
    output wire [31:0] reg18,
    output wire [31:0] reg19,
    output wire [31:0] reg20,
    output wire [31:0] reg21,
    output wire [31:0] reg22,
    output wire [31:0] reg23,
    output wire [31:0] reg24,
    output wire [31:0] reg25,
    output wire [31:0] reg26,
    output wire [31:0] reg27,
    output wire [31:0] reg28,
    output wire [31:0] reg29,
    output wire [31:0] reg30,
    output wire [31:0] reg31
);

    reg [31:0] regs[31:0];
    integer i;

    assign reg00 = regs[0];
    assign reg01 = regs[1];
    assign reg02 = regs[2];
    assign reg03 = regs[3];
    assign reg04 = regs[4];
    assign reg05 = regs[5];
    assign reg06 = regs[6];
    assign reg07 = regs[7];
    assign reg08 = regs[8];
    assign reg09 = regs[9];
    assign reg10 = regs[10];
    assign reg11 = regs[11];
    assign reg12 = regs[12];
    assign reg13 = regs[13];
    assign reg14 = regs[14];
    assign reg15 = regs[15];
    assign reg16 = regs[16];
    assign reg17 = regs[17];
    assign reg18 = regs[18];
    assign reg19 = regs[19];
    assign reg20 = regs[20];
    assign reg21 = regs[21];
    assign reg22 = regs[22];
    assign reg23 = regs[23];
    assign reg24 = regs[24];
    assign reg25 = regs[25];
    assign reg26 = regs[26];
    assign reg27 = regs[27];
    assign reg28 = regs[28];
    assign reg29 = regs[29];
    assign reg30 = regs[30];
    assign reg31 = regs[31];

    assign rs1_data = (rs1_addr == 0) ? 0 : regs[rs1_addr];
    assign rs2_data = (rs2_addr == 0) ? 0 : regs[rs2_addr];

    always @(negedge clk or posedge rst) begin
        if (rst) for (i = 0; i < 32; i = i + 1) regs[i] <= 0;
        else if (reg_write && rd_addr != 0) regs[rd_addr] <= rd_data;
    end

endmodule