module Mem_WB (
    input wire clk,
    input wire rst,
    input wire Mem_reg_write,
    input wire [4:0] Mem_rd_addr,
    input wire [31:0] Mem_rd_data,
    output reg WB_reg_write,
    output reg [4:0] WB_rd_addr,
    output reg [31:0] WB_rd_data
);

    always @(posedge clk) begin
        if (rst) begin
            WB_reg_write <= 1'b0;
            WB_rd_addr <= 5'b0;
            WB_rd_data <= 32'b0;
        end else begin
            WB_reg_write <= Mem_reg_write;
            WB_rd_addr <= Mem_rd_addr;
            WB_rd_data <= Mem_rd_data;
        end
    end

endmodule