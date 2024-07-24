`include "Header.vh"

module ControlUnit (
    input wire [31:0] ID_inst,
    output wire rs1_ren,
    output wire rs2_ren,
    output wire mem_read, // 0: no, 1: lb/lw
    output wire mem_write, // 0: no, 1: sb/sw
    output wire reg_write, // 0: no, 1: yes
    output wire data_width, // 0: lb/sb, 1: lw/sw
    output wire [2:0] ALU_opt,
    output reg [4:0] rd_addr
);

    wire [5:0] funct = ID_inst[5:0];
    wire [4:0] shamt = ID_inst[10:6];
    wire [5:0] opcode = ID_inst[31:26];

    reg [8:0] controls;
    assign {rs1_ren, rs2_ren, reg_write, data_width,
            mem_read, mem_write, ALU_opt} = controls;

    always @(*) begin
        case (opcode)
            `OP_R: begin
                if (shamt != 5'b00000) begin
                    case (funct)
                        `FUNCT_R_SLL: controls = 9'b011000_101;
                        `FUNCT_R_SRL: controls = 9'b011000_110;
                        `FUNCT_R_SRA: controls = 9'b011000_111;
                        default:      controls = 9'b000000_000;
                    endcase
                end else begin
                    case (funct)
                        `FUNCT_R_ADD,
                        `FUNCT_R_ADDU: controls = 9'b111000_000;
                        `FUNCT_R_SUB,
                        `FUNCT_R_SUBU: controls = 9'b111000_001;
                        `FUNCT_R_AND:  controls = 9'b111000_010;
                        `FUNCT_R_OR:   controls = 9'b111000_011;
                        `FUNCT_R_XOR:  controls = 9'b111000_100;
                        `FUNCT_R_JR:   controls = 9'b100001_000;
                        `FUNCT_R_JALR: controls = 9'b101001_001;
                        `FUNCT_R_SRAV: controls = 9'b111000_111;
                        default:       controls = 9'b000000_000;
                    endcase
                end
            end
            `OP_I_ADDI,
            `OP_I_ADDIU: controls = 9'b101000_000;
            `OP_I_ANDI:  controls = 9'b101000_010;
            `OP_I_ORI:   controls = 9'b101000_011;
            `OP_I_XORI:  controls = 9'b101000_100;
            `OP_I_BEQ,
            `OP_I_BNE:   controls = 9'b110000_000;
            `OP_I_BGTZ:  controls = 9'b100000_000;
            `OP_I_LUI:   controls = 9'b101000_000;
            `OP_I_LB:    controls = 9'b101010_000;
            `OP_I_SB:    controls = 9'b110001_000;
            `OP_I_LW:    controls = 9'b101110_001;
            `OP_I_SW:    controls = 9'b110101_001;
            `OP_J_J:     controls = 9'b000000_000;
            `OP_J_JAL:   controls = 9'b001000_000;
            default:     controls = 9'b000000_000;
        endcase
    end

    wire [4:0] rs = ID_inst[25:21];
    wire [4:0] rt = ID_inst[20:16];
    wire [4:0] rd = ID_inst[15:11];

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

endmodule
/*
I-type: addiu andi ori xori beq bne bgtz lb sb lw sw lui (addi)
J-type: j jal (jalr)
R-type: addu and or xor sll srl jr mul (srav)
*/