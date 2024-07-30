/*
I-type: addiu andi ori xori lui lb sb lw sw beq bne bgtz (addi)
J-type: j jal (jalr)
R-type: addu and or xor sll srl jr mul (srav)
*/

/************OPCODE************/

`define OP_R       6'b000000
`define OP_R_MUL   6'b011100
`define OP_I_ADDI  6'b001000
`define OP_I_ADDIU 6'b001001
`define OP_I_ANDI  6'b001100
`define OP_I_ORI   6'b001101
`define OP_I_XORI  6'b001110
`define OP_I_LUI   6'b001111
`define OP_I_LB    6'b100000
`define OP_I_SB    6'b101000
`define OP_I_LW    6'b100011
`define OP_I_SW    6'b101011
`define OP_I_BEQ   6'b000100
`define OP_I_BNE   6'b000101
`define OP_I_BGTZ  6'b000111
`define OP_J_J     6'b000010
`define OP_J_JAL   6'b000011

/************FUNCT************/

`define FUNCT_R_ADD  6'b100000
`define FUNCT_R_ADDU 6'b100001
`define FUNCT_R_SUB  6'b100010
`define FUNCT_R_SUBU 6'b100011
`define FUNCT_R_AND  6'b100100
`define FUNCT_R_OR   6'b100101
`define FUNCT_R_XOR  6'b100110
`define FUNCT_R_SLL  6'b000000
`define FUNCT_R_SRL  6'b000010
`define FUNCT_R_SRA  6'b000011
`define FUNCT_R_JR   6'b001000
`define FUNCT_R_JALR 6'b001001
`define FUNCT_R_SRAV 6'b000111

/************ALU_OP************/

`define ALU_OP_ADD 4'b0000
`define ALU_OP_SUB 4'b0001
`define ALU_OP_AND 4'b0010
`define ALU_OP_OR  4'b0011
`define ALU_OP_XOR 4'b0100
`define ALU_OP_SLL 4'b0101
`define ALU_OP_SRL 4'b0110
`define ALU_OP_SRA 4'b0111
`define ALU_OP_MUL 4'b1000

/************RAM************/

`define SERIAL_STAT 32'hBFD003FC
`define SERIAL_DATA 32'hBFD003F8

`define BASE_ADDR_ST 32'h80000000
`define BASE_ADDR_ED 32'h80400000
`define EXT_ADDR_ST  32'h80400000
`define EXT_ADDR_ED  32'h80800000