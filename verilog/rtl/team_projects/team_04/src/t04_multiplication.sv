module t04_multiplication (
    input logic [31:0] A, B,
    output logic [31:0] product
);

logic [31:0] intermediate_adder;
logic [31:0] internal_product;

always_comb begin
    if (B[0]) begin
        t04_fa32 first (.A(A), .B(B), .Cin(1'b0), .Cout(intermediate_adder[31]), .S(internal_product));
    end
end


endmodule
