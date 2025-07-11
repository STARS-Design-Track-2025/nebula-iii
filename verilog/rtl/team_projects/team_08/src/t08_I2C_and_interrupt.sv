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
    logic [1:0] high_step_counter; //Counter for which address to request data from the touchscreen from
    mid_steps mid_step_counter; //Counter for which step in the I2C protocol the module is at 
    logic [2:0] low_step_address_counter; //Counter for which bit within the requested address is currently being sent. 
    logic [4:0] low_step_register_counter; //Counter for where in the output register to put the data that is obtained 

    //Next states for the counters for the levels of the state machine
    logic [1:0] high_step_counter_n; //Counter for which address to request data from the touchscreen from
    mid_steps mid_step_counter_n; //Counter for which step in the I2C protocol the module is at 
    logic [2:0] low_step_address_counter_n; //Counter for which bit within the requested address is currently being sent. 
    logic [4:0] low_step_register_counter_n; //Counter for where in the output register to put the data that is obtained 

    //For determining the frequency of the SCL clock
    logic [7:0] scl_counter; 
    logic [7:0] scl_counter_n;

    //logic [7:0] address; //The address in the touchscreen that data is currently being pulled from

    always_ff @ (posedge clk, negedge nRst) begin

        if (!nRst) begin

            inter_prev <= 0;
            data_out <= 0;
            done <= 0;
            SDAout <= 1;

            scl <= 0;
            scl_counter <= 0;

            high_step_counter <= 0;
            mid_step_counter <= IDLE;
            low_step_address_counter <= 0;
            low_step_register_counter <= 0;

        end else begin

            inter_prev <= inter;
            data_out <= data_out_n;
            done <= done_n;
            SDAout <= SDAout_n;

            scl <= scl_n;
            scl_counter <= scl_counter_n;

            high_step_counter <= high_step_counter_n;
            mid_step_counter <= mid_step_counter_n;
            low_step_address_counter <= low_step_address_counter_n;
            low_step_register_counter <= low_step_register_counter_n;

        end

    end

    always_comb begin : SCL_control

        if (mid_step_counter == IDLE || mid_step_counter == STOP) begin //In idle or stop state, SCL remains high. 

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

        case (high_step_counter)

            2'b00: high_step_counter_n = XH;
            2'b01: high_step_counter_n = XL;
            2'b10: high_step_counter_n = YH;
            2'b11: high_step_counter_n = YL;

        endcase

    end

    always_comb begin

        case (mid_step_counter) 

            IDLE: begin

                high_step_counter_n = 0;
                low_step_address_counter_n = 0;
                low_step_register_counter_n = 0;
                done_n = 1;

                if (inter && !inter_prev) begin //Edge detector for interrupt signal

                    //Reset counters
                    mid_step_counter_n = START;
                    high_step_counter_n = 0;
                    low_step_address_counter_n = 0;
                    low_step_register_counter_n = 0;
                    done_n = 0;
                    
                end

            end

            START: begin
                //"Start Condition: The SDA line switches from a high voltage level to a low voltage level before the SCL line switches from high to low."
                SDAout_n = 0;

                mid_step_counter_n = SEND_ADDRESS;

            end

            SEND_ADDRESS: begin

                SDAout_n = address[low_step_address_counter];
                low_step_address_counter++;

                if (low_step_address_counter == 3'd7) begin
                    mid_step_counter = SEND_READ_BIT;
                end else begin
                    mid_step_counter = SEND_ADDRESS;
                end
            end

            SEND_READ_BIT: begin

                //Requesting data (read) = high voltage level
                SDAout_n = 1;

            end

            WAIT_ACK: begin

                //Should wait for a low voltage
                if (SDAin) begin
                    mid_step_counter = WAIT_ACK;
                end else begin
                    mid_step_counter = READ_DATA_FRAME;
                end

            end

            READ_DATA_FRAME: begin

                data_out_n[low_step_register_counter] = SDAin;
                low_step_register_counter++;

                if (low_step_register_counter == 5'd7 || low_step_register_counter == 5'd15 || low_step_register_counter == 5'd23 || low_step_register_counter == 5'd31) begin
                    mid_step_counter = SEND_ACK;
                end else begin
                    mid_step_counter = READ_DATA_FRAME;
                end

            end

            SEND_ACK: begin

                //Should send a low voltage
                SDAout_n = 0;

            end

            STOP: begin

                //"Stop Condition: The SDA line switches from a low voltage level to a high voltage level after the SCL line switches from low to high."
                SDAout_n = 1;

                if (high_step_counter == 2'b11) begin
                    mid_step_counter = IDLE;
                end else begin
                    mid_step_counter = START;
                end

            end

            default: begin

                mid_step_counter = IDLE;

            end

        endcase

    end

endmodule