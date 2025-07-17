module t07_FPU_mult(
    input logic clk, rst,
    input logic [31:0] inA, inB,
    input logic signA, signB,
    output logic [31:0] result,
    output logic sign
);
    logic [31:0] A, B;
    logic [63:0] product;
    logic [31:0] curr_B, next_B;
    logic [63:0] curr_prod, next_prod;

    assign B = curr_B;
    assign product = curr_prod;

    always_ff @(posedge clk, negedge ~rst) begin
        if(rst) begin
            curr_B <= inB;
        end
        else begin
            curr_B <= next_B;
        end
    end    

    always_comb begin
        next_B = B;
        next_prod = product;
        for(integer i = 0; i < 32; i++) begin
            if (curr_B[i] == 0) begin 
                next_prod =  curr_prod >> 1; 
                next_B= B >> 1;
            end
            else begin  
                next_prod[63:32] = curr_prod[63:32] + inA;
                next_prod = curr_prod >> 1;
                next_B = B >> 1;
            end
        end

        if (signA == signB) begin
            sign = 0;
        end else begin
            sign = 1;
        end
    end

    assign result = product[63:32];

endmodule