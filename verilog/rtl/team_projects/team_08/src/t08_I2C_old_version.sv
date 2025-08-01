/*
Communicates with the touchscreen via I2C and obtains the coordinates of a touch event whenever a touch event occurs. 
*/

module t08_I2C_old_version(
    input logic clk, nRst, //Clock and active-low reset

    input logic SDAin, //Input on the SDA line from the touchscreen
    output logic SDAout, //Output on the SDA line to the touchscreen
    output logic SDAoeb, //is 1 whenever the SDA pin is an input and is 0 whenver it is an output

    input logic inter, //Interrupt signal from the touchscreen. NOTE: IT IS ACTIVE LOW. 
    output logic scl, //Clock for I2C sent to the touchscreen

    output logic [31:0] data_out, //All of the coordinate data sent to memory
    output logic done, //Done signal also sent to memory, indicating that the module has finished reading coordinate data after a given interrupt signal

    output logic [3:0] state_debug, //TEMPORARY OUTPUT FOR DEBUGGING PURPOSES
    output logic [3:0] state_debug2,
    output logic error_occurred
);

    assign state_debug = mid_step_counter;
    assign state_debug2 = high_step_counter[3:0];

    //logic error_occurred_n;

    logic inter_prev; //For edge detector of interrupt signal
    logic interrupt_received; //So that the edge detector will not cause an effect until the next positive clock edge
    logic interrupt_received_n;
    
    logic [31:0] data_out_n;
    logic done_n;

    logic SDAout_n;
    logic SDAoeb_n;

    logic scl_n;
    logic scl_prev;

    logic scl_wouldbe_n;
    logic scl_wouldbe; //What scl would be if it was always in an oscillating state. To help with the timing of the module even when SCl oscillation is not being outputted.
    logic scl_wouldbe_prev;

    //For edge detectors
    logic scl_negedge;
    logic scl_posedge;
    logic scl_wouldbe_negedge;
    logic scl_wouldbe_posedge;
    logic inter_negedge; //Inter = interrupt

    //Implementing edge detectors
    assign scl_negedge = !scl && scl_prev;
    assign scl_posedge = scl && !scl_prev;
    assign scl_wouldbe_negedge = !scl_wouldbe && scl_wouldbe_prev;
    assign scl_wouldbe_posedge = scl_wouldbe && !scl_wouldbe_prev;
    assign inter_negedge = !inter && inter_prev;

    //For managing timing when sending the stop bit
    logic stop_bit_sent;
    logic stop_bit_sent_n;

    logic ack_bit_received;
    logic ack_bit_received_n;

    typedef enum logic [7:0] {
        XH = 8'h03,        //XH data address from touchscreen
        XL = 8'h04,        //XL data address from touchscreen
        YH = 8'h05,        //YH data address from touchscreen
        YL = 8'h06,        //YL data address from touchscreen
        SL = {7'h38, 1'b0} //Slave address (set to 0C as when only the most significant 7 bits are sent, this will be interpreted as 06)
    } high_steps; 

    /*

    The order of steps (done 4 times, once per data address): 
    THESE CORRESPOND TO MID_STEP_COUNTER

        1.  Idle state (until interrupt)
        2.  Send start bit
        3.  Send slave address
        4.  Send write bit
        5.  Wait for acknowledge bit
        6.  Send data address
        7.  Wait for acknowledge bit
        8.  Send stop bit
        9.  Send start bit
        10. Send slave address
        11. Send read bit
        12. Wait for acknowledge bit
        13. Read data frame
        14. Send acknowledge bit
        15. Send stop bit

    */

    /*
    These correspond to mid_step_state
    */
    typedef enum logic [3:0] {

        IDLE, 

        SEND_START_BIT,

        SEND_ADDRESS,

        SEND_WRITE_BIT,
        SEND_READ_BIT, 

        READ_DATA_FRAME,

        WAIT_ACK_BIT,
        SEND_ACK_BIT,

        SEND_STOP_BIT, 

        ERROR

    } mid_steps;

    //Counters for levels of the state machine
    high_steps high_step_counter; //Counter for which address to request data from the touchscreen from
    high_steps high_step_counter_prev; //Not previous in terms of flip flop states but in terms of what it was before it last changed 
    mid_steps mid_step_state; //Counter for which step in the I2C protocol the module is at (For instance, waiting for an acknowledge bit)
    logic [3:0] mid_step_counter; //Counter for the step in the 15 step process listed above the mid_steps enum (for instance, exactly which acknowledge bit in the process is being waited for)
    logic [2:0] low_step_address_counter; //Counter for which bit within the requested address is currently being sent. 
    logic [4:0] low_step_register_counter; //Counter for where in the output register to put the data that is obtained 

    //Next states for the counters for the levels of the state machine
    high_steps high_step_counter_n; //Counter for which address to request data from the touchscreen from
    high_steps high_step_counter_prev_n; //Not previous in terms of flip flop states but in terms of what it was before it last changed 
    //mid_steps mid_step_state; //Counter for which step in the I2C protocol the module is at (For instance, waiting for an acknowledge bit)
    logic [3:0] mid_step_counter_n; //Counter for the step in the 15 step process listed above the mid_steps enum (for instance, exactly which acknowledge bit in the process is being waited for)
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

            interrupt_received <= 0;

            //Flip flops for SCL
            scl <= 1;
            scl_prev <= 1;
            scl_counter <= 0;
            scl_wouldbe <= 1;
            scl_wouldbe_prev <= 1;
            scl_wouldbe_counter <= 0;

            //Flip flops for state machine
            high_step_counter <= XH;
            // mid_step_state <= IDLE;
            mid_step_counter <= 4'd1; //Corresponds to IDLE state
            low_step_address_counter <= 3'd7; //Counts backwards
            low_step_register_counter <= 5'd7;

            stop_bit_sent <= 0;
            ack_bit_received <= 0;

            //error_occurred <= 0;

        end else begin

            inter_prev <= inter;
            data_out <= data_out_n;
            done <= done_n;
            SDAout <= SDAout_n;

            SDAoeb <= SDAoeb_n;

            interrupt_received <= interrupt_received_n;

            //Flip flops for SCL
            scl <= scl_n;
            scl_counter <= scl_counter_n;
            scl_prev <= scl;
            scl_wouldbe <= scl_wouldbe_n;
            scl_wouldbe_prev <= scl_wouldbe;
            scl_wouldbe_counter <= scl_wouldbe_counter_n;

            //Flip flops for state machine
            high_step_counter <= high_step_counter_n;
            high_step_counter_prev <= high_step_counter_prev_n;
            // mid_step_state <= mid_step_state;
            mid_step_counter <= mid_step_counter_n;
            low_step_address_counter <= low_step_address_counter_n;
            low_step_register_counter <= low_step_register_counter_n;

            stop_bit_sent <= stop_bit_sent_n;
            ack_bit_received <= ack_bit_received_n;

            //error_occurred <= error_occurred_n;

        end

    end

    always_comb begin : SCL_control

        if (scl_wouldbe_counter < 8'd1) begin //So that the process can continue to move forward in a synchronized way even when SCL is not oscillating

            scl_wouldbe_counter_n = scl_wouldbe_counter + 8'd1;
            scl_wouldbe_n = scl_wouldbe;
                
        end else begin

            scl_wouldbe_counter_n = 0;
            scl_wouldbe_n = ~scl_wouldbe;

        end

        if (mid_step_state == IDLE || mid_step_state == SEND_START_BIT) begin //In idle state, SCL remains high. 

            scl_n = 1;
            scl_counter_n = 0;

        end else begin //Otherwise, SCL will oscilllate at a frequency of 2.5 MHz (1/4 of clock frequency). 

            scl_counter_n = scl_wouldbe_counter_n;
            scl_n = scl_wouldbe_n;

        end

    end

    always_comb begin : state_machine

        //To avoid latches
        data_out_n = data_out;
        done_n = done;
        interrupt_received_n = interrupt_received;
        SDAout_n = SDAout;
        SDAoeb_n = SDAoeb;
        high_step_counter_n = high_step_counter;
        high_step_counter_prev_n = high_step_counter_prev;
        mid_step_counter_n = mid_step_counter;
        low_step_address_counter_n = low_step_address_counter;
        low_step_register_counter_n = low_step_register_counter;
        done_n = done;
        stop_bit_sent_n = stop_bit_sent;
        ack_bit_received_n = ack_bit_received;
        error_occurred = 0;
        //error_occurred_n = error_occurred;

        /*
        Throughout all of the steps of the protocol, a lot of actions will repeat multiple times, so the same state can appear for multiple
        values of the step counter. 
        */
        case (mid_step_counter) 

            4'd0: begin
                mid_step_state = ERROR;
            end
            4'd1: begin
                mid_step_state = IDLE;
            end

            4'd2, 4'd9: begin
                mid_step_state = SEND_START_BIT;
            end

            4'd3, 4'd6, 4'd10: begin
                mid_step_state = SEND_ADDRESS;
            end

            4'd4: begin
                mid_step_state = SEND_WRITE_BIT;
            end

            4'd5, 4'd7, 4'd12: begin
                mid_step_state = WAIT_ACK_BIT;
            end

            4'd8, 4'd15: begin
                mid_step_state = SEND_STOP_BIT;
            end

            4'd11: begin
                mid_step_state = SEND_READ_BIT;
            end

            4'd13: begin
                mid_step_state = READ_DATA_FRAME;
            end

            4'd14: begin
                mid_step_state = SEND_ACK_BIT;
            end

        endcase

        /*
        Negative edge detector for SCL (output and sampling of bits synchronized to SCL falling edge)
        */
        if ((scl_wouldbe_negedge) || mid_step_counter == 4'd1 /*(4'd1 = IDLE)*/) begin 

            /*
            This is where the actual steps of the protocol are carried out. 
            */
            case (mid_step_state) 

                ERROR: begin
                    error_occurred = 1;
                end

                IDLE: begin

                    SDAout_n = 1;

                    SDAoeb_n = 1; //SDA line taking input

                    //high_step_counter_n = XH;
                    mid_step_counter_n = 1;
                    low_step_address_counter_n = 3'd7; //Counts backwards
                    low_step_register_counter_n = 5'd7;
                    data_out_n = data_out; //Not changing data_out

                    done_n = 1;

                    stop_bit_sent_n = 0;

                    // if (!inter && inter_prev) begin //Negative edge detector for interrupt signal

                    //     interrupt_received_n = 1;

                    // end

                    if (inter_negedge /*interrupt_received*/) begin //Interrupt won't take effect until positive clock edge (not in effect right now)

                        //Initiate the I2C protocol by moving to state SEND_START_BIT
                        mid_step_counter_n = mid_step_counter + 1;
                        //Output values may now be unstable so done is 0
                        done_n = 0;

                        interrupt_received_n = 0; //Reset interrupt_received

                    end

                end

                SEND_START_BIT: begin

                    //"Start Condition: The SDA line switches from a high voltage level to a low voltage level before the SCL line switches from high to low."

                    SDAoeb_n = 0; //SDA line giving output

                    SDAout_n = 0; //Tell SDAout to go low. 

                    data_out_n = data_out; //Not changing data_out

                    stop_bit_sent_n = 0;

                    if (!SDAout) begin //Wait until SDAout is confirmed to be low. 

                        high_step_counter_n = SL; //The start bit is always followed by sending the slave address.
                        if (high_step_counter_prev != SL) begin
                            high_step_counter_prev_n = high_step_counter_prev; //Preserving what high step counter was at before
                        end else begin
                            high_step_counter_prev_n = high_step_counter;
                        end

                        //Moving to state SEND_ADDRESS, which should cause SCL to start toggling and thus to go low.
                        mid_step_counter_n = mid_step_counter + 1; 

                    end

                end

                SEND_ADDRESS: begin

                    data_out_n = data_out; //Not changing data_out

                    SDAout_n = high_step_counter[low_step_address_counter]; //Output the current bit of the address. 

                    /*
                    Step 6 is sending the data address where all 8 bits should be used. 
                    Steps 3 and 10 are sending the slave address where only the most significant 7 bits should be used. 
                    */
                    if ((mid_step_counter == 4'd6 && low_step_address_counter == 3'd0) || 
                        ((mid_step_counter == 4'd3 || mid_step_counter == 4'd10) && low_step_address_counter == 3'd1)) begin 

                        low_step_address_counter_n = 3'd7; //Reset the low step address counter. 

                        /*
                        Since this was the last bit, move to the next step.
                        (May be SEND_WRITE_BIT, SEND_READ_BIT, or WAIT_ACK_BIT)
                        */
                        mid_step_counter_n = mid_step_counter + 1; 

                    end else begin

                        //Move to the next bit of the address and stay in the SEND_ADDRESS state. 
                        low_step_address_counter_n--; 

                    end

                end

                SEND_WRITE_BIT: begin

                    data_out_n = data_out; //Not changing data_out

                    //Sending data (write) = low voltage level
                    SDAout_n = 0;

                    if (!SDAout) begin

                        //Move to the next state (WAIT_ACK_BIT).
                        mid_step_counter_n = mid_step_counter + 1;

                    end


                end

                SEND_READ_BIT: begin

                    data_out_n = data_out; //Not changing data_out

                    //Requesting data (read) = high voltage level
                    SDAout_n = 1;

                    if (SDAout) begin

                        //Move to the next state (WAIT_ACK_BIT).
                        mid_step_counter_n = mid_step_counter + 1;

                    end

                end

                WAIT_ACK_BIT: begin

                    SDAoeb_n = 1; //SDA line taking input

                    SDAout_n = 1; //Not using the output right now
                    data_out_n = data_out; //Not changing data_out

                    //Should wait for a low voltage
                    // if (!SDAin) begin

                    //     ack_bit_received_n = 1;

                    // end

                    if (!SDAin/*ack_bit_received*/) begin

                        //Moving to the next state (may be SEND_ADDRESS, READ_DATA_FRAME, or SEND_STOP_BIT)
                        mid_step_counter_n = mid_step_counter + 1;

                        //If the next state will be READ_DATA_FRAME, restore the preserved version of high_step_counter. 
                        if (mid_step_counter == 4'd5) begin

                            high_step_counter_n = high_step_counter_prev;

                        end

                        ack_bit_received_n = 0;

                    end

                end

                READ_DATA_FRAME: begin

                    SDAout_n = 1; //Not using the output right now

                    data_out_n = data_out;
                    data_out_n[low_step_register_counter] = SDAin;

                    /*
                    If the end of a byte has been reached, move to the next state (SEND_ACK_BIT).
                    */
                    if (low_step_register_counter == 5'd0 || low_step_register_counter == 5'd8 || 
                        low_step_register_counter == 5'd16 || low_step_register_counter == 5'd24) begin

                        mid_step_counter_n = mid_step_counter + 1;
                        low_step_register_counter_n = low_step_register_counter + 5'd15;

                        /*
                        In a disorganized way, sending the acknowledge bit here
                        */
                        SDAoeb_n = 0; //SDA line giving output

                        //Should send a low voltage
                        SDAout_n = 0;

                        // if (!SDAout) begin

                        //     SDAout_n = 1; //Bring it back to high voltage

                        //     //Go to next state (SEND_STOP_BIT).
                        //     //mid_step_counter_n = mid_step_counter + 1;

                        //  end

                    end else begin

                        //Move to the next bit in the output register. 
                        low_step_register_counter_n = low_step_register_counter - 1;

                    end

                end

                SEND_ACK_BIT: begin

                    //SDAoeb_n = 0; //SDA line giving output

                    data_out_n = data_out; //Not changing data_out

                    //Should send a low voltage
                    //SDAout_n = 0;

                    //SDAout_n = 1;
                    mid_step_counter_n = mid_step_counter + 1;

                    // if (!SDAout) begin

                    //     SDAout_n = 1; //Bring it back to high voltage

                    //     //Go to next state (SEND_STOP_BIT).
                    //     mid_step_counter_n = mid_step_counter + 1;

                    // end

                end

                SEND_STOP_BIT: begin

                    /*
                    stop_bit_sent_n changes on the positive edge of scl_wouldbe. Scroll down a bit to see this. 
                    */
                    if (stop_bit_sent) begin

                        //If this was the last cycle, return to the IDLE state. 
                        if (high_step_counter_prev == YL && mid_step_counter == 4'd15) begin

                            //Resetting the mid step counter. 
                            mid_step_counter_n = 4'd1; 

                        end else begin

                            //If this was not the last cycle but was the last step of this cycle, imcrement the high step counter.
                            if (mid_step_counter == 4'd15) begin

                                high_step_counter_prev_n = high_steps'(int'(high_step_counter_prev) + 1); 
                                //Go to the next state (SEND_START_BIT)
                                mid_step_counter_n = 4'd2;

                            end else begin

                                //Go to the next state (SEND_START_BIT)
                                mid_step_counter_n = 4'd9;

                            end

                        end

                    end

                end

                /*
                Not planning to use default case though ideally would make it display a visible error of some kind
                */
                default: begin end 

            endcase

        end 

        /*
        The only state that should be timed on the positive edge of the SCL line is the SEND_STOP_BIT state. 
        */
        else if ((scl_wouldbe_posedge) && mid_step_state == SEND_STOP_BIT) begin

            //"Stop Condition: The SDA line switches from a low voltage level to a high voltage level after the SCL line switches from low to high."

            SDAout_n = 0;

            data_out_n = data_out; //Not changing data_out

            if (SDAout == 0) begin

                SDAout_n = 1;

                stop_bit_sent_n = 1;

            end

        end

    end

endmodule