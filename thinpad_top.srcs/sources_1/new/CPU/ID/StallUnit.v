module StallUnit (
    input wire ID_rs1_ren,
    input wire ID_rs2_ren,
    input wire Ex_mem_read,
    input wire [4:0] Ex_rd_addr,
    input wire [4:0] ID_rs1_addr,
    input wire [4:0] ID_rs2_addr,
    output stall
);

    assign stall = Ex_mem_read && ID_reg_write &&
           ((ID_rs1_ren && Ex_rd_addr == ID_rs1_addr) ||
           (ID_rs2_ren && Ex_rd_addr == ID_rs2_addr));

endmodule