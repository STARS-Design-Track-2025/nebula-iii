module t08_spi(
//input logic [31:0] parameters,
input logic [7:0] inputs,
input logic enable, clk, nrst, readwrite, type,
output logic [7:0] outputs,
output logic wrx, rdx, csx, dcx
);

logic [7:0] currentout, nextout;
logic state, nextstate, nextdcx;
//logic [2:0] parcount;

assign outputs = currentout;

always_ff@(posedge clk, negedge nrst) begin
    if (nrst) begin
        currentout <= '0;
        csx <= 1;
        dcx <= 0; 
      //  wrx <=1;
     //   rdx <= 1;
        state <= 0; end
    else if (enable) begin
        currentout <= nextout;
        dcx<=nextdcx;
        state <=nextstate;
        csx <= 0; end
end

//passing read/write clocks
// always_comb begin 
//     if (readwrite) begin wrx = clk; rdx = 1; end
//     else begin rdx = clk; wrx = 1; end
// end





// always_comb begin
//     case (command)
 // 00101010: begin parcount = 4; end //CASET, SC2, SC1, EC2, EC1 
    // 00101011: begin percount = 4; end //PASET SP2 SP1 EP2 EP1
    // //00101100 begin parcount = 1; end 
    // 00101101: begin 

always_comb begin
    wrx = 1;
    rdx = 1;
    case(state)
        0: begin //INIT
            nextstate = 1; 
            nextdcx = 0;
            nextout = 0;

            // nd;extout =comman
        end
        1: begin //send
            nextstate = 2; 
            if (type) begin nextdcx = 0; end //command
            else begin nextdcx = 1; end //parameter


            if (readwrite) begin wrx = 0; end //write mode
            else begin rdx = 0; end //read mode

            nextout = inputs; //getting the output ready
        end

        2: begin //clocks
            if (readwrite) begin wrx = 1; end 
            else begin rdx = 1; end

            nextstate = 0;
        end

        default: begin 
            nextstate = state;
            nextdcx = dcx;
            nextout = 0;
        end
    endcase
end
endmodule

            
            






