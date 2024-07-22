`include "Header.vh"

module ALU (
    input wire jump,
    input wire mem_read,
    input wire mem_write,
    input wire [2:0] ALU_opt,
    input wire [31:0] reg1,
    input wire [31:0] reg2,
    input wire [31:0] imm,
    input wire [31:0] link_addr,
    output reg zero,
    output reg [31:0] ALU_res
);

    wire [31:0] A = reg1;
    wire [31:0] B = (mem_read || mem_write) ? imm : reg2;

    always @(*) begin
        if (jump) begin
            ALU_res = link_addr;
        end else begin
            case (ALU_opt)
                `ALU_OP_ADD: ALU_res = A + B;
                `ALU_OP_SUB: ALU_res = A - B;
                `ALU_OP_AND: ALU_res = A & B;
                `ALU_OP_OR:  ALU_res = A | B;
                `ALU_OP_XOR: ALU_res = A ^ B;
                `ALU_OP_SLL: ALU_res = B << A[4:0];
                `ALU_OP_SRL: ALU_res = B >> A[4:0];
                `ALU_OP_SRA: ALU_res = $signed(B) >>> A[4:0];
                default: ALU_res = 32'b0;
            endcase
        end
        zero = (ALU_res == 32'b0) ? 1 : 0;
    end

endmodule
