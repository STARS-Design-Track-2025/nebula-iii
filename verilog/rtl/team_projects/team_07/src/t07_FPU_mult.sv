module t07_FPU_mult(
    input logic clk,
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

    always_ff @(posedge clk) begin
        A <= inA;
        B = inB;

        for(integer i = 0; i < 32; i++) begin
            if (inB[i] == 0) begin 
                product =  product >> 1; 
                B = B >> 1;
            end
            else begin  
                product[63:32] <= product[63:32] + inA;
                product = product >> 1;
                B = B >> 1;
            end
        end
    end

    assign result = product[63:32];

endmodule