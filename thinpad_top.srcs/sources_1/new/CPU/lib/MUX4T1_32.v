module MUX4T1_32 (
    input [31:0] I0,
    input [31:0] I1,
    input [31:0] I2,
    input [31:0] I3,
    input [1:0] S,
    output [31:0] O
);

    assign O = S[1] ? (S[0] ? I3 : I2) : (S[0] ? I1 : I0);

endmodule