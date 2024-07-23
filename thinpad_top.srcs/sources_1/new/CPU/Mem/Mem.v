module Mem (
    input wire mem_read,
    input wire mem_write,
    input wire data_width, // 0: lb/sb, 1: lw/sw
    input wire [31:0] ALU_res,
    input wire [31:0] mem_addr,
    input wire [31:0] mem_rdata,
    input wire [31:0] mem_wdata_in,
    output reg mem_ce,
    output reg mem_we,
    output reg [3:0] mem_be,
    output reg [31:0] rd_data,
    output reg [31:0] mem_wdata_out
);

    always @(*) begin
        if (mem_read) begin
            mem_ce = 1'b1;
            mem_we = 1'b1;
            rd_data = mem_rdata;
            mem_wdata_out = 32'b0;
            if (data_width) begin // lw
                mem_be = 4'b0000;
            end else begin // lb
                case (mem_addr[1:0])
                    2'b00: mem_be = 4'b1110;
                    2'b01: mem_be = 4'b1101;
                    2'b10: mem_be = 4'b1011;
                    2'b11: mem_be = 4'b0111;
                endcase
            end
        end else if (mem_write) begin
            mem_ce = 1'b1;
            mem_we = 1'b0;
            rd_data = 32'b0;
            if (data_width) begin // sw
                mem_wdata_out = mem_wdata_in;
                mem_be = 4'b0000;
            end else begin // sb
                mem_wdata_out = {4{mem_wdata_in[7:0]}};
                case (mem_addr[1:0])
                    2'b00: mem_be = 4'b1110;
                    2'b01: mem_be = 4'b1101;
                    2'b10: mem_be = 4'b1011;
                    2'b11: mem_be = 4'b0111;
                endcase
            end
        end else begin
            mem_ce = 1'b0;
            mem_we = 1'b1;
            mem_be = 4'b1111;
            rd_data = ALU_res;
            mem_wdata_out = 32'b0;
        end
    end

endmodule