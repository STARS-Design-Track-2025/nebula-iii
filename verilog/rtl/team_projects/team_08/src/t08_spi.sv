module t08_spi(
input logic [31:0] inputs,
input logic enable_command, enable_parameter, clk, nrst, readwrite, 
output logic [7:0] outputs,
output logic wrx, rdx, csx, dcx, busy
);
typedef enum logic[2:0] {
    GETCOMMAND, GETPAR, TRANSITION
} registering;

logic [31:0] paroutput, nextparoutput, parameters, nextparameters;
logic [7:0] currentout, nextout, command, nextcommand;
logic [2:0] state, nextstate; 
logic nextdcx, nextbusy, nextcsx, nextwrx;
logic [3:0] count = 0, percount, nextpercount,  nextcount, counter, nextcounter;
logic [23:0] delay = 24'd48;
logic [23:0] timem, nexttimem;
registering register, nextregister;
logic nextcontrol, control;

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
        control <= 0;
        wrx <= 0;
    end
    else begin
        wrx <= nextwrx;
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
        control <= nextcontrol;
    end
end

always_comb begin
    nextcontrol = control;
    nextwrx = 0;
    rdx = 1;
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
            nextwrx = 0;
            nextbusy = 1;
            nextout = currentout;
            nextparoutput = paroutput;
            nextcount = count;
            nextpercount = percount;
            nextdcx = dcx;
            nextcsx = csx;
            case(state)
                0: begin //command

                    
                    case (command) 
                        8'b00101010: begin nextpercount = 4; end //CASET, SC2, SC1, EC2, EC1 
                        8'b00101011: begin nextpercount = 4; end //PASET SP2 SP1 EP2 EP1
                        8'b00000001: begin nextpercount = 0; end //software reset, 120 msec delay
                        8'b00101000: begin nextpercount = 0; end //display off;
                        8'b00111010: begin nextpercount = 1; end //pixel format set;
                        8'b00101001: begin nextpercount = 0; end //display on;
                        8'b0:        begin nextpercount = 0; end //no operation
                        8'b00101100: begin nextpercount = 2; end //mem write
                        8'b00101110: begin nextpercount = 2; end //mem read
                        8'h10:       begin nextpercount = 0; end // sleep mode on, 5 ms delay
                        8'h11:       begin nextpercount = 0; end //sleep out
                        8'h36:       begin nextpercount = 1; end // memory access control
                        default:     begin nextpercount = counter; end 
                    endcase

                    nextstate = 4; 
                    nextcsx = 0;
                    nextdcx = 0;
                    nextparoutput = parameters;
                    nextout = command; //getting the output ready
                end

                1: begin //clock
                    if (count >= percount) begin 
                           nextstate = 3; 
                           nextbusy = 1;
                           nextcsx = 0;
                        case(command)
                            8'h01, 8'h10, 8'h11: begin
                                nextstate = 5;
                            end
                            default:;
                        endcase
                      end
                    else begin nextstate = 2; end
                   nextwrx = 1;
                end


                2: begin //param
                //reading parameters from left to right. 
                    nextparoutput = {paroutput[23:0], 8'b0};
                    nextout = paroutput[31:24];                    
                    nextcount = count + 1;
                    nextdcx = 1;
                    nextcsx = 0;
                    nextstate = 4;

                    
                end

                3: begin //time for finish
                    nextstate = 0;
                    nextcount = 0;
                    nextregister = GETCOMMAND;
                    nextcsx = 1;
                    nextdcx = 0;
                    nextbusy = 0;
                    
                    
                end

                4: begin //getting everyting together 
                    nextstate = 1; //go to clock
                    nextcsx = 0;
                end
                   
                5: begin
                        nextcontrol = 1;
                        nexttimem = timem + 1;

                        nextcsx = 1;
                         if (count >= percount) begin 
                             nextstate = 3; 
                            if (timem == delay) begin
                                nexttimem = 0;
                                nextstate = 3;
                                nextcontrol = 0;
                                nextcsx = 0;
                            end
                            else nextstate = 5; 
                        end
                        else begin nextstate = 2; end
                    end

                default: begin 
                    nextout = 0;
                end
            endcase
        end
    endcase
end


endmodule

