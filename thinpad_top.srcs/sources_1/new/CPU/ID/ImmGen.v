`include "Header.vh"

module ImmGen (
    input wire [31:0] ID_inst,
    output reg [31:0] imm_out
);

    wire [5:0] funct = ID_inst[5:0];
    wire [4:0] shamt = ID_inst[10:6];
    wire [5:0] opcode = ID_inst[31:26];
    wire [31:0] imm_signed = {{16{ID_inst[15]}}, ID_inst[15:0]};
    wire [31:0] imm_unsigned = {{16{1'b0}}, ID_inst[15:0]};

    always @(*) begin
        case (opcode)
            `OP_I_ADDI,
            `OP_I_ADDIU,
            `OP_I_LB,
            `OP_I_LW,
            `OP_I_SB,
            `OP_I_SW: imm_out = imm_signed;
            `OP_I_ANDI,
            `OP_I_ORI,
            `OP_I_XORI: imm_out = imm_unsigned;
            `OP_I_LUI: imm_out = {ID_inst[15:0], {16{1'b0}}};
            `OP_R: begin
                case (funct)
                    `FUNCT_R_SLL,
                    `FUNCT_R_SRL,
                    `FUNCT_R_SRA: imm_out = {{27{1'b0}}, shamt};
                    default: imm_out = 32'b0;
                endcase
            end
            default: imm_out = 32'b0;
        endcase
    end

endmodule