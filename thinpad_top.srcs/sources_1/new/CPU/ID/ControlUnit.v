`include "Header.vh"

module ControlUnit (
    input wire [31:0] ID_inst,
    output wire rs1_ren,
    output wire rs2_ren,
    output wire mem_read, // 0: no, 1: lb/lw
    output wire mem_write, // 0: no, 1: sb/sw
    output wire reg_write, // 0: no, 1: yes
    output wire data_width, // 0: lb/sb, 1: lw/sw
    output wire [3:0] ALU_opt,
    output reg [4:0] rd_addr
);

    wire [5:0] funct = ID_inst[5:0];
    wire [4:0] shamt = ID_inst[10:6];
    wire [5:0] opcode = ID_inst[31:26];

    reg [9:0] controls;
    assign {rs1_ren, rs2_ren, reg_write, data_width,
            mem_read, mem_write, ALU_opt} = controls;

    always @(*) begin
        case (opcode)
            `OP_R: begin
                if (shamt != 5'b00000) begin
                    case (funct)
                        `FUNCT_R_SLL: controls = 10'b011000_0101;
                        `FUNCT_R_SRL: controls = 10'b011000_0110;
                        `FUNCT_R_SRA: controls = 10'b011000_0111;
                        default:      controls = 10'b000000_0000;
                    endcase
                end else begin
                    case (funct)
                        `FUNCT_R_ADD,
                        `FUNCT_R_ADDU: controls = 10'b111000_0000;
                        `FUNCT_R_SUB,
                        `FUNCT_R_SUBU: controls = 10'b111000_0001;
                        `FUNCT_R_AND:  controls = 10'b111000_0010;
                        `FUNCT_R_OR:   controls = 10'b111000_0011;
                        `FUNCT_R_XOR:  controls = 10'b111000_0100;
                        `FUNCT_R_JR:   controls = 10'b100000_0000;
                        `FUNCT_R_JALR: controls = 10'b101000_0000;
                        `FUNCT_R_SRAV: controls = 10'b111000_0111;
                        default:       controls = 10'b000000_0000;
                    endcase
                end
            end
            `OP_I_ADDI,
            `OP_I_ADDIU: controls = 10'b101000_0000;
            `OP_I_ANDI:  controls = 10'b101000_0010;
            `OP_I_ORI:   controls = 10'b101000_0011;
            `OP_I_XORI:  controls = 10'b101000_0100;
            `OP_I_BEQ,
            `OP_I_BNE:   controls = 10'b110000_0000;
            `OP_I_BGTZ:  controls = 10'b100000_0000;
            `OP_I_LUI:   controls = 10'b101000_0000;
            `OP_I_LB:    controls = 10'b111010_0000;
            `OP_I_SB:    controls = 10'b110001_0000;
            `OP_I_LW:    controls = 10'b111110_0000;
            `OP_I_SW:    controls = 10'b110101_0000;
            `OP_J_J:     controls = 10'b000000_0000;
            `OP_J_JAL:   controls = 10'b001000_0000;
            `OP_R_MUL:   controls = 10'b111000_1000;
            default:     controls = 10'b000000_0000;
        endcase
    end

    wire [4:0] rs = ID_inst[25:21];
    wire [4:0] rt = ID_inst[20:16];
    wire [4:0] rd = ID_inst[15:11];

    always @(*) begin
        case (opcode)
            `OP_R,
            `OP_R_MUL: rd_addr = rd;
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