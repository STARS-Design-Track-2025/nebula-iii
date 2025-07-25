module t08_spi(
//input logic [31:0] parameters,
//TODO redo for 2 32 bits inputs
//input logic [7:0] command,
input logic [31:0] inputs,
// input logic [31:0] commands
input logic enable_command, enable_parameter, clk, nrst, readwrite, 
//input logic [3:0] counter,
output logic [7:0] outputs,
output logic wrx, rdx, csx, dcx, busy
);
typedef enum logic[2:0] {
    GETCOMMAND, GETPAR, TRANSITION
} registering;
//assign command = [7:0]commands;
//assign counter = [11:8] commands;
logic [31:0] paroutput, nextparoutput, parameters, nextparameters;
logic [7:0] currentout, nextout, command, nextcommand;
logic [1:0] state, nextstate; 
logic nextdcx, nextbusy, nextcsx;
logic [3:0] count = 0, percount, nextpercount,  nextcount, counter, nextcounter;
logic [23:0] delay = 24'd4800000;
logic [23:0] timem, nexttimem;
registering register, nextregister;
assign outputs = currentout;

always_ff@(posedge clk, negedge nrst) begin
    if (!nrst) begin
        currentout <= '0;
        csx <= 1;
        dcx <= 0; 
        state <= 0;
        busy <=0; 
        paroutput <= 0; 
        count <= 0; 
        register <= GETCOMMAND;
        command <= '0;
        parameters <= '0;
        counter <= '0;
        timem <= 0;
    end
    else begin
        currentout <= nextout;
        dcx<=nextdcx;
        state <=nextstate;
        csx <= nextcsx;
        busy <= nextbusy;
        count <= nextcount;
        paroutput <= nextparoutput;
        percount <= nextpercount;
        register <= nextregister;
        command <= nextcommand;
        counter <= nextcounter;
        parameters <=nextparameters;
        timem <= nexttimem;
    end
    // else begin
    //     csx <= 1;
    //     busy <= 0;
    //     count <= 0;
    //     state <= 0;
    //     //percount
    // end
end

always_comb begin
    wrx = 0;
    rdx = 0;
    nextbusy = busy;
    nextout = currentout;
    nextparoutput = paroutput;
    nextcount = count;
    nextpercount = percount;
    nextdcx = dcx;
    nextregister = register;
    nextcsx = csx;
    nextcommand = command;
    nextparameters = parameters;
    nextcounter = counter;
    nextstate = state;
    nexttimem = timem;

    case(register)
        GETCOMMAND: begin
            nextcsx = 1;

            if (enable_command) begin
                nextcommand = inputs[7:0];
                nextcounter = inputs[11:8];
                nextregister = GETPAR;
                nextbusy = 0;
            end
            else begin
                nextregister = GETCOMMAND;
                nextbusy = 0;
            end
        end

        GETPAR: begin
            if(enable_parameter) begin
                nextparameters = inputs;
                nextregister = TRANSITION;
                nextbusy = 1;
                nextcsx = 1;
            end
            else begin
                nextregister = GETPAR;
                nextbusy = 0;
                nextcsx = 1;
            end
        end

        TRANSITION: begin 
            wrx = 0;
            rdx = 0;
            nextbusy = 1;
            nextout = currentout;
            nextparoutput = paroutput;
            nextcount = count;
            nextpercount = percount;
            nextdcx = dcx;
            nextcsx = csx;
            case(state)
                0: begin //command
                    //nextpercount = percount;
                    nextcsx = 0;
                    case (command) 
                        8'b00101010: begin nextpercount = 4; end //CASET, SC2, SC1, EC2, EC1 
                        8'b00101011: begin nextpercount = 4; end //PASET SP2 SP1 EP2 EP1
                        8'b00000001: begin nextpercount = 0; end //software reset, 120 msec delay
                        8'b00101000: begin nextpercount = 0; end //display off;
                        8'b00111010: begin nextpercount = 1; end //pixel format set;
                        8'b00101001: begin nextpercount = 0; end //display on;
                        8'b0:        begin nextpercount = 0; end //no operation
                        8'b00101100: begin nextpercount = 3; end //mem write
                        8'b00101110: begin nextpercount = 3; end //mem read
                        8'h10:       begin nextpercount = 0; end // sleep mode on, 5 ms delay
                        8'h11:       begin nextpercount = 0; end //sleep out
                        default:     begin nextpercount = counter; end 
                    endcase

                    nextstate = 1; 
                    nextdcx = 0;
                    nextparoutput = parameters;
                    nextout = command; //getting the output ready
                    if (readwrite) wrx = 0; else rdx = 0;
                end

                1: begin //clock
                    nextdcx = 1;
                    if (count >= percount) begin 
                        nextstate = 3; 
                        nextbusy = 0;
                        nextcsx = 1;
                        case(command)
                            8'h01, 8'h10, 8'h11: begin
                                nexttimem = timem + 1;
                                nextbusy = 1;
                                if (timem == delay) begin
                                    nexttimem = 0;
                                    nextstate = 3;
                                end
                                else nextstate = 1;
                            end
                        endcase

                     end
                    else begin nextstate = 2; end
                    if (readwrite) wrx = 1; else rdx = 1;
                    nextout = paroutput[31:24];
                end


                2: begin //param
                //reading parameters from left to right. 
                    nextparoutput = {paroutput[23:0], 8'b0};
                    nextcount = count + 1;
                    nextdcx = 1;
                    nextstate = 1;
                    if (readwrite) wrx = 0; else rdx = 0;
                    nextcsx = 0;
                end

                3: begin //time for finish
                    nextstate = 0;
                    nextcount = 0;
                    nextregister = GETCOMMAND;
                    nextcsx = 1;
                    nextdcx = 0;
                    nextbusy = 0;
                    
                end


                default: begin 
                    nextstate = state;
                    nextdcx = dcx;
                    nextout = 0;
                end
            endcase
        end
    endcase
end


endmodule

