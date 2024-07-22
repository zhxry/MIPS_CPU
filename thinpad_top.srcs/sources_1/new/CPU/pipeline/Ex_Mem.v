module Ex_Mem (
    input wire clk,
    input wire rst,
    input wire Ex_mem_read,
    input wire Ex_mem_write,
    input wire Ex_reg_write,
    input wire Ex_data_width,
    input wire [4:0] Ex_rd_addr,
    input wire [31:0] Ex_ALU_res,
    input wire [31:0] Ex_mem_addr,
    input wire [31:0] Ex_mem_wdata,
    output reg Mem_mem_read,
    output reg Mem_mem_write,
    output reg Mem_reg_write,
    output reg Mem_data_width,
    output reg [4:0] Mem_rd_addr,
    output reg [31:0] Mem_ALU_res,
    output reg [31:0] Mem_mem_addr,
    output reg [31:0] Mem_mem_wdata
);

    always @(posedge clk) begin
        if (rst) begin
            Mem_mem_read <= 1'b0;
            Mem_mem_write <= 1'b0;
            Mem_reg_write <= 1'b0;
            Mem_data_width <= 1'b0;
            Mem_rd_addr <= 5'b0;
            Mem_ALU_res <= 32'b0;
            Mem_mem_addr <= 32'b0;
            Mem_mem_wdata <= 32'b0;
        end else begin
            Mem_mem_read <= Ex_mem_read;
            Mem_mem_write <= Ex_mem_write;
            Mem_reg_write <= Ex_reg_write;
            Mem_data_width <= Ex_data_width;
            Mem_rd_addr <= Ex_rd_addr;
            Mem_ALU_res <= Ex_ALU_res;
            Mem_mem_addr <= Ex_mem_addr;
            Mem_mem_wdata <= Ex_mem_wdata;
        end
    end

endmodule