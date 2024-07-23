`include "Header.vh"

module ControlUnit (
    input wire [31:0] ID_inst,
    // output reg is_lui,
    // output reg is_mul,
    // output reg ALU_src_B, // 0: reg, 1: imm
    output wire rs1_ren,
    output wire rs2_ren,
    output wire mem_read, // 0: no, 1: lb/lw
    output wire mem_write, // 0: no, 1: sb/sw
    output wire reg_write, // 0: no, 1: yes
    output wire data_width, // 0: lb/sb, 1: lw/sw
    // output reg [1:0] jump, // 00: no, 01: j, 10: jal, 11: jalr
    // output reg [1:0] branch, // 00: no, 01: beq, 10: bne, 11: bgtz
    output wire [1:0] mem_to_reg, // 00: ALU, 01: mem, 10: pc, 11: imm
    output wire [2:0] ALU_opt,
    output reg [4:0] rd_addr
);

    wire [5:0] funct = ID_inst[5:0];
    wire [4:0] shamt = ID_inst[10:6];
    wire [5:0] opcode = ID_inst[31:26];

    reg [10:0] controls;
    assign {rs1_ren, rs2_ren, reg_write, data_width,
            mem_read, mem_write, mem_to_reg, ALU_opt} = controls;

    always @(*) begin
        case (opcode)
            `OP_R: begin
                if (shamt != 5'b00000) begin
                    case (funct)
                        `FUNCT_R_SLL: controls = 11'b011000_00_101;
                        `FUNCT_R_SRL: controls = 11'b011000_00_110;
                        `FUNCT_R_SRA: controls = 11'b011000_00_111;
                        default:      controls = 11'b000000_00_000;
                    endcase
                end else begin
                    case (funct)
                        `FUNCT_R_ADD,
                        `FUNCT_R_ADDU: controls = 11'b111000_00_000;
                        `FUNCT_R_SUB,
                        `FUNCT_R_SUBU: controls = 11'b111000_00_001;
                        `FUNCT_R_AND:  controls = 11'b111000_00_010;
                        `FUNCT_R_OR:   controls = 11'b111000_00_011;
                        `FUNCT_R_XOR:  controls = 11'b111000_00_100;
                        `FUNCT_R_JR:   controls = 11'b100001_00_000;
                        `FUNCT_R_JALR: controls = 11'b101001_00_001;
                        `FUNCT_R_SRAV: controls = 11'b111000_00_111;
                        default:       controls = 11'b000000_00_000;
                    endcase
                end
            end
            `OP_I_ADDI,
            `OP_I_ADDIU: controls = 11'b101000_00_000;
            `OP_I_ANDI:  controls = 11'b101000_00_010;
            `OP_I_ORI:   controls = 11'b101000_00_011;
            `OP_I_XORI:  controls = 11'b101000_00_100;
            `OP_I_BEQ,
            `OP_I_BNE:   controls = 11'b110000_00_000;
            `OP_I_BGTZ:  controls = 11'b100000_00_000;
            `OP_I_LUI:   controls = 11'b101000_11_000;
            `OP_I_LB:    controls = 11'b101010_00_000;
            `OP_I_SB:    controls = 11'b110001_01_000;
            `OP_I_LW:    controls = 11'b101110_00_001;
            `OP_I_SW:    controls = 11'b110101_01_001;
            `OP_J_J:     controls = 11'b000000_00_000;
            `OP_J_JAL:   controls = 11'b001000_00_000;
            default:     controls = 11'b000000_00_000;
        endcase
    end

    assign rs = ID_inst[25:21];
    assign rt = ID_inst[20:16];
    assign rd = ID_inst[15:11];

    always @(*) begin
        case (opcode)
            `OP_R: rd_addr = rd;
            `OP_I_ADDI,
            `OP_I_ADDIU,
            `OP_I_ANDI,
            `OP_I_ORI,
            `OP_I_XORI,
            `OP_I_LUI,
            `OP_I_LB,
            `OP_I_LW: rd_addr = rt;
            `OP_J_JAL: rd_addr = 5'b11111;
            default: rd_addr = 5'b00000;
        endcase
    end

    // check mul
    // always @(*) begin
    //     case (opcode)
    //         `OP_R: begin
    //             case (funct)
    //                 `FUNCT_R_MUL: begin
    //                     is_mul <= 1'b1;
    //                 end
    //                 default: begin
    //                     is_mul <= 1'b0;
    //                 end
    //             endcase
    //         end
    //         default: begin
    //             is_mul <= 1'b0;
    //         end
    //     endcase
    // end

endmodule
/*
I-type: addiu andi ori xori beq bne bgtz lb sb lw sw lui (addi)
J-type: j jal (jalr)
R-type: addu and or xor sll srl jr mul (srav)
*/