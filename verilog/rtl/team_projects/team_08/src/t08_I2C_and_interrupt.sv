/*
Communicates with the touchscreen via I2C and obtains the coordinates of a touch event whenever a touch event occurs. 
THIS MODULE IS STILL UNFINISHED. 
*/

module t08_I2C_and_interrupt(
    input logic clk, nRst, //Clock and active-low reset

    input logic SDAin, //Input on the SDA line from the touchscreen
    output logic SDAout, //Output on the SDA line to the touchscreen
    output logic SDAoeb, //is 1 whenever the SDA pin is an input and is 0 whenver it is an output

    input logic inter, //Interrupt signal from the touchscreen. NOTE: IT IS ACTIVE LOW. 
    output logic scl, //Clock for I2C sent to the touchscreen

    output logic [31:0] data_out, //All of the coordinate data sent to memory
    output logic done //Done signal also sent to memory, indicating that the module has finished reading coordinate data after a given interrupt signal
);

    logic inter_prev; //For edge detector of interrupt signal
    
    logic [31:0] data_out_n;
    logic done_n;

    logic SDAout_n;
    logic SDAoeb_n;

    logic scl_n;
    logic scl_prev;

    logic scl_wouldbe_n;
    logic scl_wouldbe; //What scl would be if it was always in an oscillating state. To help with the timing of the module even when SCl oscillation is not being outputted.
    logic scl_wouldbe_prev;

    typedef enum logic [7:0] {
        XH = 8'h03,
        XL = 8'h04,
        YH = 8'h05,
        YL = 8'd06
    } high_steps; //I AM NOT SURE IF IT IS REALLY 8 BITS OR 7 BITS OR 10 BITS THOUGH

    typedef enum logic [2:0] {
        IDLE, 
        START,
        SEND_ADDRESS,
        SEND_READ_BIT,
        WAIT_ACK,
        READ_DATA_FRAME,
        SEND_ACK,
        STOP
    } mid_steps;

    //Counters for levels of the state machine
    high_steps high_step_counter; //Counter for which address to request data from the touchscreen from
    mid_steps mid_step_counter; //Counter for which step in the I2C protocol the module is at 
    logic [2:0] low_step_address_counter; //Counter for which bit within the requested address is currently being sent. 
    logic [4:0] low_step_register_counter; //Counter for where in the output register to put the data that is obtained 

    //Next states for the counters for the levels of the state machine
    high_steps high_step_counter_n; //Counter for which address to request data from the touchscreen from
    mid_steps mid_step_counter_n; //Counter for which step in the I2C protocol the module is at 
    logic [2:0] low_step_address_counter_n; //Counter for which bit within the requested address is currently being sent. 
    logic [4:0] low_step_register_counter_n; //Counter for where in the output register to put the data that is obtained 

    //For determining the frequency of the SCL clock
    logic [7:0] scl_counter; 
    logic [7:0] scl_counter_n;

    logic [7:0] scl_wouldbe_counter;
    logic [7:0] scl_wouldbe_counter_n;

    always_ff @ (posedge clk, negedge nRst) begin

        if (!nRst) begin

            inter_prev <= 0;
            data_out <= 0;
            done <= 0;
            SDAout <= 1;

            SDAoeb <= 1; //Acts as an input by default

            scl <= 1;
            scl_prev <= 1;
            scl_counter <= 0;

            scl_wouldbe <= 1;
            scl_wouldbe_prev <= 1;
            scl_wouldbe_counter <= 0;

            high_step_counter <= XH;
            mid_step_counter <= IDLE;
            low_step_address_counter <= 3'd7; //Counts backwards
            low_step_register_counter <= 0;

        end else begin

            inter_prev <= inter;
            data_out <= data_out_n;
            done <= done_n;
            SDAout <= SDAout_n;

            SDAoeb <= SDAoeb_n;

            scl <= scl_n;
            scl_counter <= scl_counter_n;
            scl_prev <= scl;

            scl_wouldbe <= scl_wouldbe_n;
            scl_wouldbe_prev <= scl_wouldbe;
            scl_wouldbe_counter <= scl_wouldbe_counter_n;

            high_step_counter <= high_step_counter_n;
            mid_step_counter <= mid_step_counter_n;
            low_step_address_counter <= low_step_address_counter_n;
            low_step_register_counter <= low_step_register_counter_n;

        end

    end

    always_comb begin : SCL_control

        if (scl_wouldbe_counter < 8'd2) begin //So that the process can continue to move forward in a synchronized way even when SCL is not oscillating

            scl_wouldbe_counter_n = scl_wouldbe_counter + 8'd1;
            scl_wouldbe_n = scl_wouldbe;
                
        end else begin

            scl_wouldbe_counter_n = 0;
            scl_wouldbe_n = ~scl_wouldbe;

        end

        if (mid_step_counter == IDLE || mid_step_counter == START) begin //In idle state, SCL remains high. 

            scl_n = 1;
            scl_counter_n = 0;

        end else begin //Otherwise, SCL will oscilllate at a frequency of 2.5 MHz (1/4 of clock frequency). 

            // if (scl_counter < 8'd2) begin //Dividing by 4 is just a placeholder until the optimal frequency is figured out. 

            //     scl_counter_n = scl_counter + 8'd1;
            //     scl_n = scl;
                
            // end else begin

            //     scl_counter_n = 0;
            //     scl_n = ~scl;

            // end

            scl_counter_n = scl_wouldbe_counter_n;
            scl_n = scl_wouldbe_n;

        end

    end

    always_comb begin : state_machine

        if ((!scl_wouldbe && scl_wouldbe_prev) || mid_step_counter == IDLE) begin //Negative edge detector for SCL (output and sampling of bits synchronized to SCL falling edge)

            //To avoid latches
            SDAoeb_n = SDAoeb;
            high_step_counter_n = high_step_counter;
            mid_step_counter_n = mid_step_counter;
            low_step_address_counter_n = low_step_address_counter;
            low_step_register_counter_n = low_step_register_counter;
            done_n = done;

            case (mid_step_counter) 

                IDLE: begin

                    SDAout_n = 1;

                    SDAoeb_n = 1; //SDA line taking input

                    high_step_counter_n = XH;
                    low_step_address_counter_n = 3'd7; //Counts backwards
                    low_step_register_counter_n = 0;
                    data_out_n = data_out; //Not changing data_out

                    done_n = 1;

                    if (!inter && inter_prev) begin //Negative edge detector for interrupt signal

                        //Initiate the I2C protocol
                        mid_step_counter_n = START;
                        done_n = 0;

                    end

                end

                START: begin

                    //"Start Condition: The SDA line switches from a high voltage level to a low voltage level before the SCL line switches from high to low."

                    SDAoeb_n = 0; //SDA line giving output

                    SDAout_n = 0; //Tell SDAout to go low. 

                    data_out_n = data_out; //Not changing data_out

                    if (!SDAout) begin //Wait until SDAout is confirmed to be low. 

                        mid_step_counter_n = SEND_ADDRESS; //This shuld cause SCL to start toggling and thus to go low. 

                    end

                end

                SEND_ADDRESS: begin

                    data_out_n = data_out; //Not changing data_out

                    SDAout_n = high_step_counter[low_step_address_counter]; //Output the current bit of the address. 

                    if (low_step_address_counter == 3'd0) begin 

                        low_step_address_counter_n = 3'd7;
                        mid_step_counter_n = SEND_READ_BIT; //If this was the last bit, move to the next state. 

                    end else begin

                        low_step_address_counter_n--; //Move to the next bit. 
                        mid_step_counter_n = SEND_ADDRESS; //Continue sending the address. 

                    end

                end

                SEND_READ_BIT: begin

                    data_out_n = data_out; //Not changing data_out

                    //Requesting data (read) = high voltage level
                    SDAout_n = 1;

                    if (SDAout) begin

                        mid_step_counter_n = WAIT_ACK; //Move to the next state. 

                    end

                end

                WAIT_ACK: begin

                    SDAoeb_n = 1; //SDA line taking input

                    SDAout_n = 1; //Not using the output right now
                    data_out_n = data_out; //Not changing data_out

                    //Should wait for a low voltage
                    if (SDAin) begin

                        mid_step_counter_n = WAIT_ACK;

                    end else begin

                        mid_step_counter_n = READ_DATA_FRAME;

                    end

                end

                READ_DATA_FRAME: begin

                    SDAout_n = 1; //Not using the output right now

                    data_out_n = data_out;
                    data_out_n[low_step_register_counter] = SDAin;

                    if (low_step_register_counter == 5'd7 || low_step_register_counter == 5'd15 || low_step_register_counter == 5'd23 || low_step_register_counter == 5'd31) begin

                        mid_step_counter_n = SEND_ACK;

                    end else begin

                        mid_step_counter_n = READ_DATA_FRAME;

                    end

                    low_step_register_counter_n++;

                end

                SEND_ACK: begin

                    SDAoeb_n = 0; //SDA line giving output

                    data_out_n = data_out; //Not changing data_out

                    //Should send a low voltage
                    SDAout_n = 0;

                    if (SDAout) begin
                        SDAout_n = 1; //Bring it back to high voltage
                        mid_step_counter_n = STOP; //Go to stop condition
                    end

                end

                STOP: begin

                    //"Stop Condition: The SDA line switches from a low voltage level to a high voltage level after the SCL line switches from low to high."
                    SDAout_n = 1;

                    data_out_n = data_out; //Not changing data_out

                    if (high_step_counter == YL) begin

                        mid_step_counter_n = IDLE; //The process has been finished so return to idle state

                    end else begin

                        high_step_counter_n = high_steps'(int'(high_step_counter) + 1); //Increment high step counter
                        mid_step_counter_n = START; //Return to start state

                    end

                end

                default: begin

                    mid_step_counter_n = IDLE;

                    SDAout_n = 1;

                    high_step_counter_n = XH;
                    low_step_address_counter_n = 3'd7;
                    low_step_register_counter_n = 0;

                    data_out_n = data_out; 

                    done_n = 1;

                end

            endcase

        end else begin //If it isn't a rising edge of SCL, don't change any outputs or states. 

            data_out_n = data_out;
            done_n = done;
            SDAout_n = SDAout;
            SDAoeb_n = SDAoeb;

            high_step_counter_n = high_step_counter;
            mid_step_counter_n = mid_step_counter;
            low_step_address_counter_n = low_step_address_counter;
            low_step_register_counter_n = low_step_register_counter;

        end

    end

endmodule