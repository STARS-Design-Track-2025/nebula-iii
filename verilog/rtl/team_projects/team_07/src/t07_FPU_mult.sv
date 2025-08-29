module t07_FPU_mult(
    input logic clk, nrst,
    input logic [31:0] inA, inB,
    input logic busy,
    input logic signA, signB, 
    output logic [31:0] result,
    output logic sign, overflow
);
    logic [31:0] A, B;
    logic [63:0] product;
    logic [31:0] curr_B, next_B;
    logic [63:0] curr_prod, next_prod;


    assign B = curr_B;
    assign product = curr_prod;

    logic [4:0] counter, next_ctr;
    logic next_busy;

    always_ff @(posedge clk, negedge nrst) begin
        if(~nrst) begin
            counter <= 5'b0;
            curr_B <= inB;
            curr_prod <= product;
            // busy <= 0;
        end
        else begin
            counter <= next_ctr;
            curr_B <= next_B;
            curr_prod <= next_prod;
            // busy <= next_busy;
        end
    end    

    always_comb begin
        next_B = B;
        next_prod = product;
        next_ctr = counter;
        sign = 1'b0;
        result = 32'b0;
        overflow = 1'b0;
        next_busy = 1;
        if (counter < 5'b11111 && busy) begin
            if (curr_B[counter[4:0]] == 0) begin 
                next_prod =  curr_prod >> 1; 
                next_B = B >> 1;
            end
            else begin  
                next_prod[63:32] = curr_prod[63:32] + inA;
                next_prod = curr_prod >> 1;
                next_B = B >> 1;
            end
            next_ctr = counter + 1;
            if (counter == '1) next_busy = 0;
        end
        
        //determines sign of product
        if (signA == signB) begin
            sign = 0;
        end else begin
            sign = 1;
        end

        //parsing product to fit 32 bit normalized fixed point form; passes overflow flag
        if (product[63:55] == 9'b0) begin
            result = product[54:23];
            overflow = 0;
        end else begin
            result = 32'b0;
            overflow = 1;
        end

    end

endmodule