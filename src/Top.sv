module Top (
    input A,
    input B,
    output var C,
    output var D
);
    AnotherTest another_test(
        .A(A),
        .B(B),
        .C(C)
    );

    assign D = A | B;

endmodule