`include "Header.vh"

module Ex (
    input wire jump,
    input wire [2:0] ALU_opt,
    input wire [31:0] reg1,
    input wire [31:0] reg2,
    input wire [31:0] imm,
    input wire [31:0] link_addr,
    output reg [31:0] ALU_res,
    output reg [31:0] mem_addr,
    output reg zero
);

    always @(*) begin
        if (jump) begin
            ALU_res = link_addr;
        end else begin
            case (ALU_opt)
                `ALU_OP_ADD: ALU_res = reg1 + reg2;
                `ALU_OP_SUB: ALU_res = reg1 - reg2;
                `ALU_OP_AND: ALU_res = reg1 & reg2;
                `ALU_OP_OR:  ALU_res = reg1 | reg2;
                `ALU_OP_XOR: ALU_res = reg1 ^ reg2;
                `ALU_OP_SLL: ALU_res = reg2 << reg1[4:0];
                `ALU_OP_SRL: ALU_res = reg2 >> reg1[4:0];
                `ALU_OP_SRA: ALU_res = $signed(reg2) >>> reg1[4:0]; // SRAV!!!
                default: ALU_res = 32'b0;
            endcase
        end
        zero = (ALU_res == 32'b0) ? 1 : 0;
    end

endmodule
