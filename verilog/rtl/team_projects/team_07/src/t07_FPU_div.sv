module t07_FPU_div (
    input logic clk, nrst,
    input logic [31:0] inA, inB,
    input logic signA, signB,
    input [4:0] op,
 //r[62:0], 
    output logic [31:0] quotient,
    output logic [63:0] remainder,
    output logic sign, busy
);

    logic [31:0] A, B; //A = dividend, B = divisor
    logic [31:0] next_B, next_quot, curr_B, curr_quot;
    logic [63:0] next_rem, curr_rem, result, next_result; 
    logic workFlag;

    logic [1:0] state, next_state;
    logic [2:0] lowState, next_lowState;

    logic [4:0] counter, next_ctr;

    // assign B = curr_B;
    // assign quotient = curr_quot;
    // assign remainder = curr_rem;

    always_ff @(posedge clk, negedge nrst) begin
        if(~nrst) begin
            state <= 2'b0;
            B <= inB;
            quotient <= '0;
            remainder[31:0] <= inA;
            counter <= 5'b0;
            //busy = 0;
        end
        else begin
            // busy = 1;
            state <= next_state;
            quotient <= next_quot;
            remainder <= next_rem;
            B <= next_B;
            //lower level case statements

            lowState <= next_lowState;
            result <= next_result; //lower level fsm for remainder calculations

            //counter <= next_ctr;
        end
    end    
//set busy back to 0
    always_comb begin
        next_state = state; 
        sign = 0;
        next_rem = remainder;
        next_B = B;
        next_quot = quotient;
        next_ctr = counter;
        busy = 1;
        next_lowState = lowState;
        next_result = result;

        case (state)
            2'b00: begin next_rem[31:0] = inA; next_ctr = 5'b0; next_quot = '0; next_B = inB; busy = 1; next_state = 2'b01; next_lowState = 3'b0; next_result = next_rem; end //load
            2'b01: begin 
                
                //counter = 0;

                if (counter < 5'b11111) begin
                //for (integer i = 0; i < 5'b11111; i++) begin
                    // next_rem = remainder - B;
                    // if (remainder >= B) begin
                    //     next_quot = {quotient[30:0], 1'b0} + 1;
                    //     next_B = {1'b0, B[31:1]};
                    // end else begin
                    //     next_rem = remainder + B;
                    //     next_quot = {quotient[30:0], 1'b0};
                    // end
                    // next_B = {1'b0, B[31:1]};
                    
                    // 3'b001: next_result = {result[62:0], 1'b0};  
                    // 3'b010: next_rem[63:32] = remainder[63:32] - B;
                    // 3'b011: begin if (remainder[63:32] > 32'b0 || remainder[63:32] == 32'b0) begin
                    //     next_rem = {remainder[62:0], 1'b1};
                    // end else if (remainder[63:32] < 32'b0) begin
                    //     next_rem[63:32] = remainder[63:32] + B; 
                    //     next_rem[15:0] = remainder[15:0];
                    //     next_rem = {remainder[62:0], 1'b0};
                    // end
                    // end

                //end
                    next_ctr = counter + 1;
                    next_state = 2'b01;
                end else begin
                    next_rem[31:16] = {1'b0, remainder[31:17]};
                    next_rem[15:0] = remainder[15:0]; 
                    next_state = 2'b10;
                end


                // if (counter < 5'b11111) begin
                //     next_rem = remainder - B;
                //     if (remainder >= B) begin //previously remainder == 0 
                //         next_quot =  (quotient << 1) + 1; 
                //         next_B = B >> 1;
                //     end
                //     else begin  
                //         next_rem = B + remainder;
                //         next_quot = quotient << 1;
                //     end
                //     next_B = B >> 1;
                //     next_ctr = counter + 1; 
                // end else if (counter == 5'b11111) begin
                //     next_state = 2'b10;
                // end

                //determines sign of product
                if (signA == signB) begin
                    sign = 0;
                end else begin
                    sign = 1;
                end
            end //divide
            2'b10: begin next_ctr = '0; if (op == 5'd7) begin next_state = 2'b00; end else begin busy = 0; end end //idle
            default: busy = 0;
        endcase
    end






        

    //assign result = quotient[63:32];


endmodule