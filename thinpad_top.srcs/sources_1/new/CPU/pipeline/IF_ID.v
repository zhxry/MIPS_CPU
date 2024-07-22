module IF_ID (
    input wire clk,
    input wire rst,
    input wire stall,
    input wire [31:0] IF_pc,
    input wire [31:0] IF_inst,
    output reg [31:0] ID_pc,
    output reg [31:0] ID_inst
);

    always @(posedge clk) begin
        if (rst) begin
            ID_pc <= 32'h00000000;
            ID_inst <= 32'h00000000;
        end else if (!stall) begin
            ID_pc <= IF_pc;
            ID_inst <= IF_inst;
        end
    end

endmodule