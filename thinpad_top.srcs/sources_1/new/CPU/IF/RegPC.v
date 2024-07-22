module RegPC (
    input wire clk,
    input wire rst,
    input wire j_b,
    input wire stall,
    input wire [31:0] j_b_addr,
    output reg inst_en,
    output reg [31:0] pc
);

    reg [31:0] pc_next;

    always @(posedge clk) begin
        if (rst) begin
            pc <= 32'h80000000;
            pc_next <= 32'h80000000;
            inst_en <= 1'b0;
        end else begin
            if (stall) begin
                pc <= pc;
                pc_next <= pc_next;
                inst_en <= inst_en;
            end else if (j_b) begin
                pc <= j_b_addr;
                pc_next <= j_b_addr + 4;
                inst_en <= 1'b1;
            end else begin
                pc <= pc_next;
                pc_next <= pc + 4;
                inst_en <= 1'b1;
            end
        end
    end

endmodule