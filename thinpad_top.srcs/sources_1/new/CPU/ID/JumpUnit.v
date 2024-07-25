`include "Header.vh"

module JumpUnit (
    input wire [31:0] ID_pc,
    input wire [31:0] ID_inst,
    input wire [31:0] reg1_data,
    input wire [31:0] reg2_data,
    output reg jump,
    output reg [31:0] jump_addr,
    output reg [31:0] link_addr
);

    wire [5:0] opcode = ID_inst[31:26];
    wire [5:0] shamt = ID_inst[10:6];
    wire [5:0] funct = ID_inst[5:0];
    wire [31:0] imm = {{16{ID_inst[15]}}, ID_inst[15:0]};

    wire [31:0] pc_next = ID_pc + 4;
    wire [31:0] branch_addr = pc_next + {imm[29:0], 2'b00};
    wire [31:0] jumping_addr = {pc_next[31:28], ID_inst[25:0], 2'b00};

    initial begin
        jump = 1'b0;
        jump_addr = 32'b0;
        link_addr = 32'b0;
    end

    always @(*) begin
        case (opcode)
            `OP_R: begin
                if (shamt == 5'b00000) begin
                    case (funct)
                        `FUNCT_R_JR: begin
                            jump = 1'b1;
                            jump_addr = reg1_data;
                        end
                        `FUNCT_R_JALR: begin
                            jump = 1'b1;
                            jump_addr = reg1_data;
                            link_addr = pc_next + 4;
                        end
                        default: begin
                            jump = 1'b0;
                            jump_addr = 32'b0;
                            link_addr = 32'b0;
                        end
                    endcase
                end else begin
                    jump = 1'b0;
                    jump_addr = 32'b0;
                    link_addr = 32'b0;
                end
            end
            `OP_I_BEQ: begin
                if (reg1_data == reg2_data) begin
                    jump = 1'b1;
                    jump_addr = branch_addr;
                end else jump = 1'b0;
            end
            `OP_I_BNE: begin
                if (reg1_data != reg2_data) begin
                    jump = 1'b1;
                    jump_addr = branch_addr;
                end else jump = 1'b0;
            end
            `OP_I_BGTZ: begin
                if ($signed(reg1_data) > 0) begin
                    jump = 1'b1;
                    jump_addr = branch_addr;
                end else jump = 1'b0;
            end
            `OP_J_J: begin
                jump = 1'b1;
                jump_addr = jumping_addr;
            end
            `OP_J_JAL: begin
                jump = 1'b1;
                jump_addr = jumping_addr;
                link_addr = pc_next + 4;
            end
            default: begin
                jump = 1'b0;
                jump_addr = 32'b0;
                link_addr = 32'b0;
            end
        endcase
    end

endmodule