module RegPC (
    input wire clk,
    input wire rst,
    input wire jump,
    input wire stall,
    input wire [31:0] jump_addr,
    output reg inst_ce,
    output reg [31:0] pc
);

    reg [31:0] pc_next;

    always @(posedge clk) begin
        if (rst) begin
            pc <= 32'h80000000;
            pc_next <= 32'h80000000;
            inst_ce <= 1'b0;
        end else begin
            if (stall) begin
                pc <= pc;
                pc_next <= pc_next;
                inst_ce <= inst_ce;
            end else if (jump) begin
                pc <= jump_addr;
                pc_next <= jump_addr;
                inst_ce <= 1'b1;
            end else begin
                pc <= pc_next;
                pc_next <= pc + 4;
                inst_ce <= 1'b1;
            end
        end
    end

endmodule