module MUX2T1_32 (
    input [31:0] I0,
    input [31:0] I1,
    input S,
    output [31:0] O
);

    assign O = S ? I1 : I0;

endmodule