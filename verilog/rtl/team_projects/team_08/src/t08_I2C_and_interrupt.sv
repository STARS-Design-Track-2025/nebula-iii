/*
Communicates with the touchscreen via I2C and obtains the coordinates of a touch event whenever a touch event occurs. 
THIS MODULE IS STILL UNFINISHED. 
*/

module t08_I2C_and_interrupt(
    input logic clk, nRst, //Clock and active-low reset

    input logic SDAin, //Input on the SDA line from the touchscreen
    output logic SDAout, //Output on the SDA line to the touchscreen

    input logic inter, //Interrupt signal from the touchscreen
    output logic scl, //Clock for I2C sent to the touchscreen

    output logic [31:0] data_out, //All of the coordinate data sent to memory
    output logic done //Done signal also sent to memory, indicating that the module has finished reading coordinate data after a given interrupt signal
);

    logic inter_prev; //For edge detector of interrupt signal
    
    logic [31:0] data_out_n;
    logic done_n;

    logic SDAout_n;
    logic scl_n;

    typedef enum logic [2:0] {
        IDLE, 
        START,
        SEND_ADDRESS,
        SEND_READ_BIT,
        WAIT_ACK,
        READ_DATA_FRAME,
        SEND_ACK,
        STOP
    } steps;

    steps step_counter; //Counter for which step in the process of reading from an address the module is at 

    logic [2:0] within_address_counter; //Counter for which bit within the requested address is currently being sent. 
    logic [1:0] which_address_counter; //Counter for which address to request data from the touchscreen from
    logic [4:0] register_counter; //Counter for where in the output register to put the data that is obtained 

    logic [7:0] scl_counter; //For determining the frequency of the SCL clock
    logic [7:0] scl_counter_n;

    logic [7:0] address; //The address in the touchscreen that data is currently being pulled from

    always_ff @ (posedge clk, negedge nRst) begin
        if (!nRst) begin

            inter_prev <= 0;
            data_out <= 0;
            done <= 0;
            SDAout <= 1;
            scl <= 0;
            scl_counter <= 0;

        end else begin

            inter_prev <= inter;
            data_out <= data_out_n;
            done <= done_n;
            SDAout <= SDAout_n;
            scl <= scl_n;
            scl_counter <= scl_counter_n;

        end

    end

    always_comb begin : SCL_control

        if (step_counter == IDLE || step_counter == STOP) begin //In idle or stop state, SCL remains high. 

            scl_n = 1;
            scl_counter_n = 0;

        end else begin //Otherwise, SCL will oscilllate at a frequency of ___ Hz. 

            if (scl_counter < 8'd50) begin //50 is just a placeholder. Change to what it should actually be. 

                scl_counter_n++;
                scl_n = scl;
                
            end else begin

                scl_counter_n = 0;
                scl_n = ~scl;

            end

        end

    end

    always_comb begin : determine_address

        case (which_address_counter)

            2'b00: address = 8'h03;
            2'b01: address = 8'h04;
            2'b10: address = 8'h05;
            2'b11: address = 8'h06;

        endcase

    end

    always_comb begin

        case (step_counter) 

            IDLE: begin

                which_address_counter = 0;
                within_address_counter = 0;
                register_counter = 0;
                done_n = 1;

                if (inter && !inter_prev) begin //Edge detector for interrupt signal

                    //Reset counters
                    step_counter = START;
                    which_address_counter = 0;
                    within_address_counter = 0;
                    register_counter = 0;
                    done_n = 0;
                    
                end

            end

            START: begin
                //"Start Condition: The SDA line switches from a high voltage level to a low voltage level before the SCL line switches from high to low."
                SDAout_n = 0;

                step_counter = SEND_ADDRESS;

            end

            SEND_ADDRESS: begin

                SDAout_n = address[within_address_counter];
                within_address_counter++;

                if (within_address_counter == 3'd7) begin
                    step_counter = SEND_READ_BIT;
                end else begin
                    step_counter = SEND_ADDRESS;
                end
            end

            SEND_READ_BIT: begin

                //Requesting data (read) = high voltage level
                SDAout_n = 1;

            end

            WAIT_ACK: begin

                //Should wait for a low voltage
                if (SDAin) begin
                    step_counter = WAIT_ACK;
                end else begin
                    step_counter = READ_DATA_FRAME;
                end

            end

            READ_DATA_FRAME: begin

                data_out_n[register_counter] = SDAin;
                register_counter++;

                if (register_counter == 5'd7 || register_counter == 5'd15 || register_counter == 5'd23 || register_counter == 5'd31) begin
                    step_counter = SEND_ACK;
                end else begin
                    step_counter = READ_DATA_FRAME;
                end

            end

            SEND_ACK: begin

                //Should send a low voltage
                SDAout_n = 0;

            end

            STOP: begin

                //"Stop Condition: The SDA line switches from a low voltage level to a high voltage level after the SCL line switches from low to high."
                SDAout_n = 1;

                if (which_address_counter == 2'b11) begin
                    step_counter = IDLE;
                end else begin
                    step_counter = START;
                end

            end

            default: begin

                step_counter = IDLE;

            end

        endcase

    end

endmodule