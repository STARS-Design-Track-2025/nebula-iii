module t07_FPU_div (
    input logic clk, nrst,
    input logic [31:0] inA, inB,
    input logic signA, signB,
    output logic [31:0] result,
    output logic sign
);

    logic [31:0] A, B;
    logic [63:0] product;

    always_comb begin
        if (signA == signB) begin
            sign = 0;
        end else begin
            sign = 1;
        end
    end

    always_ff @(posedge clk, negedge nrst) begin
        A = inA;
        B = inB;

        

    end


endmodule