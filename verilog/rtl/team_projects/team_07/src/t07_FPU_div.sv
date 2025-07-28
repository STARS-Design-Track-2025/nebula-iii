module t07_FPU_div (
    input logic clk, nrst,
    input logic [31:0] inA, inB,
    input logic signA, signB,
    input logic busy,
    output logic [31:0] quotient, remainder,
    output logic sign
);

    logic [31:0] A, B; //A = dividend, B = divisor
    logic [31:0] curr_B, next_B, curr_quot, next_quot, curr_rem, next_rem;

    logic [4:0] counter, next_ctr;

    assign B = curr_B;
    assign quotient = curr_quot;
    assign remainder = curr_rem;

    always_ff @(posedge clk, negedge nrst) begin
        if(~nrst) begin
            curr_B <= inB;
            curr_quot <= quotient;
            curr_rem <= remainder;
            counter <= 5'b0;
            //busy = 0;
        end
        else begin
            //busy = 1;
            curr_quot <= next_quot;
            curr_rem <= next_rem;
            curr_B <= next_B;
            counter <= next_ctr;
        end
    end    
//set busy back to 0
    always_comb begin
        sign = 0;
        next_rem = remainder;
        next_B = B;
        next_quot = quotient;
        next_ctr = counter;
        if (counter < 5'b11111 && busy) begin
            next_rem = curr_rem - curr_B;

            if (curr_rem == 0) begin 
                next_quot =  (curr_quot << 1) + 1; 
                next_B = B >> 1;
            end
            else begin  
                next_rem = curr_B + curr_rem;
                next_quot = curr_quot << 1;
            end
            next_B = curr_B >> 1;
            next_ctr = counter + 1; 
        end

        //determines sign of product
        if (signA == signB) begin
            sign = 0;
        end else begin
            sign = 1;
        end
    end

    //assign result = quotient[63:32];


endmodule