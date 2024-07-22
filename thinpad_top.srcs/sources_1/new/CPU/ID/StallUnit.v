module StallUnit (
    input wire Ex_mem_read,
    input wire ID_reg_write,
    input wire [4:0] Ex_rd_addr,
    input wire [4:0] ID_rs1_addr,
    input wire [4:0] ID_rs2_addr,
    output stall
);

    assign stall = Ex_mem_read && ID_reg_write &&
           (Ex_rd_addr == ID_rs1_addr || Ex_rd_addr == ID_rs2_addr);

endmodule