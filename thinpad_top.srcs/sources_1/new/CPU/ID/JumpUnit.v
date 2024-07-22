`include "Header.vh"

module JumpUnit (
    input wire [31:0] ID_pc,
    input wire [31:0] ID_inst,
    input wire [31:0] reg1_data,
    input wire [31:0] reg2_data,
    output reg j_b,
    output reg [31:0] j_b_addr,
    output reg [31:0] link_addr
);

    wire [5:0] opcode = ID_inst[31:26];
    wire [5:0] funct = ID_inst[5:0];
    wire [31:0] imm = {{16{ID_inst[15]}}, ID_inst[15:0]};

    wire [31:0] pc_next = ID_pc + 4;
    wire [31:0] branch_addr = pc_next + {imm[29:0], 2'b00};
    wire [31:0] jump_addr = {pc_next[31:28], ID_inst[25:0], 2'b00};

    initial begin
        j_b = 1'b0;
        j_b_addr = 32'b0;
        link_addr = 32'b0;
    end

    always @(*) begin
        case (opcode)
            `OP_R: begin
                case (funct)
                    `FUNCT_R_JR: begin
                        j_b = 1'b1;
                        j_b_addr = reg1_data;
                    end
                    `FUNCT_R_JALR: begin
                        j_b = 1'b1;
                        j_b_addr = reg1_data;
                        link_addr = pc_next + 4;
                    end
                    default: j_b = 1'b0;
                endcase
            end
            `OP_I_BEQ: begin
                if (reg1_data == reg2_data) begin
                    j_b = 1'b1;
                    j_b_addr = branch_addr;
                end else j_b = 1'b0;
            end
            `OP_I_BNE: begin
                if (reg1_data != reg2_data) begin
                    j_b = 1'b1;
                    j_b_addr = branch_addr;
                end else j_b = 1'b0;
            end
            `OP_I_BGTZ: begin
                if ($signed(reg1_data) > 0) begin
                    j_b = 1'b1;
                    j_b_addr = branch_addr;
                end else j_b = 1'b0;
            end
            `OP_J_J: begin
                j_b = 1'b1;
                j_b_addr = jump_addr;
            end
            `OP_J_JAL: begin
                j_b = 1'b1;
                j_b_addr = jump_addr;
                link_addr = pc_next + 4;
            end
            default: j_b = 1'b0;
        endcase
    end

endmodule