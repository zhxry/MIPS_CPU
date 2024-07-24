module RegPC (
    input wire clk,
    input wire rst,
    input wire jump,
    input wire stall,
    input wire [31:0] jump_addr,
    output reg inst_ce,
    output reg [31:0] pc
);

    always @(posedge clk) begin
        if (rst) inst_ce <= 1'b0;
        else inst_ce <= 1'b1;
    end

    always @(posedge clk) begin
        if (!inst_ce) begin
            pc <= 32'h80000000;
        end else if (!stall) begin
            if (jump) pc <= jump_addr;
            else pc <= pc + 4;
        end
    end

endmodule