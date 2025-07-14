module t08_spi(
//input logic [31:0] parameters,
input logic [7:0] command,
input logic [31:0] parameters,
input logic enable, clk, nrst, readwrite, 
input logic [3:0] counter,
output logic [7:0] outputs,
output logic wrx, rdx, csx, dcx, busy
);

logic [31:0] paroutput, nextparoutput;
logic [7:0] currentout, nextout;
logic [1:0] state, nextstate; 
logic nextdcx, nextbusy;
logic [3:0] count = 0, percount, nextcount;

assign outputs = currentout;

always_ff@(posedge clk, negedge nrst) begin
    if (!nrst) begin
        currentout <= '0;
        csx <= 1;
        dcx <= 0; 
        state <= 0;
        busy <=0; 
        paroutput <= 0; 
        count <= 0; end
    else if (enable) begin
        currentout <= nextout;
        dcx<=nextdcx;
        state <=nextstate;
        csx <= 0;
        busy <= nextbusy;
        count <= nextcount;
        paroutput <= nextparoutput;

    end
end



always_comb begin
    wrx = 1;
    rdx = 1;
    nextbusy = 1;
    nextout = currentout;
    nextparoutput = paroutput;
    nextcount = count;
    case(state)
        0: begin //command
            nextstate = 1; 
            nextdcx = 0;
            nextparoutput = parameters;
            nextout = command; //getting the output ready
            if (readwrite) wrx = 0; else rdx = 0;
        end

        1: begin //clock
            if (count >= percount) begin 
                nextstate = 3; 
                nextbusy =0;
                end
            else begin nextstate = 2; end
            if (readwrite) wrx = 1; else rdx = 1;
            nextout = paroutput[31:24];
        end


        2: begin //param
            nextparoutput = {paroutput[23:0], 8'b0};
            nextcount = count + 1;
            nextdcx = 1;
            nextstate = 1;
            if (readwrite) wrx = 0; else rdx = 0;
        end

        3: begin //time for finish
            nextstate = 0;
         end

        default: begin 
            nextstate = state;
            nextdcx = dcx;
            nextout = 0;
        end
    endcase
end


always_comb begin
    case (command)
        00101010: begin percount = 4; end //CASET, SC2, SC1, EC2, EC1 
        00101011: begin percount = 4; end //PASET SP2 SP1 EP2 EP1
        //00111010: begin 
        default: begin percount = counter; end 
    endcase
end

endmodule

