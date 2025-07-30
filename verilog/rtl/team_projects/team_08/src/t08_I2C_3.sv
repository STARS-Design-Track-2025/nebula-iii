module t08_I2C_3(
    input logic clk, nRst, //Clock and active-low reset

    input logic sda_in, //Input on the SDA line from the touchscreen
    output logic sda_out, //Output on the SDA line to the touchscreen
    output logic sda_oeb, //is 1 whenever the SDA pin is an input and is 0 whenver it is an output
    //SDA OEB NOT IMPLEMENTED HERE AT THE MOMENT

    input logic inter, //Interrupt signal from the touchscreen. NOTE: IT IS ACTIVE LOW. 
    input logic scl_in,
    output logic scl_out, //Clock for I2C sent to the touchscreen

    output logic [31:0] data_out, //All of the coordinate data sent to memory
    output logic done //Done signal also sent to memory, indicating that the module has finished reading coordinate data after a given interrupt signal
);

    /*
    Section for bit timer
    */

    typedef enum logic [1:0] {
        TIMER_IDLE,
        TIMER_COUNTING,
        TIMER_DONE
    } timer_states;

    timer_states bit_timer_state, bit_timer_state_n;
    logic [6:0] bit_timer_counter, bit_timer_counter_n;
    logic start_bit_timer;
    logic start_bit_timer_acknowledged;
    logic bit_timer_done;
    logic bit_timer_done_acknowledged;

    always_ff @ (posedge clk, negedge nRst) begin : timer_flip_flops
        if (!nRst) begin
           bit_timer_state     <= TIMER_IDLE; 
           bit_timer_counter   <= 0;
        end else begin
            bit_timer_state     <= bit_timer_state_n;
            bit_timer_counter   <= bit_timer_counter_n;
        end
    end

    always_comb begin : bit_timer_state_machine

        //Defaults
        bit_timer_state_n = bit_timer_state;
        bit_timer_done = 0;
        start_bit_timer_acknowledged = 0;

        //$assert(start_bit_timer && bit_timer_state == TIMER_IDLE);

        case (bit_timer_state)

            TIMER_IDLE: begin

                bit_timer_counter_n = 0;

                if (start_bit_timer) begin
                    bit_timer_state_n = TIMER_COUNTING;
                    start_bit_timer_acknowledged = 1;
                end

            end

            TIMER_COUNTING: begin

                bit_timer_counter_n = bit_timer_counter + 1;

                if (bit_timer_counter == 7'd127) begin
                    bit_timer_state_n = TIMER_DONE;
                end

            end

            TIMER_DONE: begin

                bit_timer_counter_n = 0;
                bit_timer_done = 1;

                if (bit_timer_done_acknowledged) begin
                    bit_timer_state_n = TIMER_IDLE;
                end

            end

            default: begin 
                bit_timer_state_n = TIMER_IDLE;
            end

        endcase

    end
    
    /*
    Section for output state machine
    */

    typedef enum logic [4:0] {
        OUTPUT_IDLE, 

        OUTPUT_START_START,
        OUTPUT_START_WAIT_1,
        OUTPUT_START_SCL,
        OUTPUT_START_WAIT_2, 
        OUTPUT_START_DONE,

        OUTPUT_SEND_BIT_START,
        OUTPUT_SEND_BIT_WAIT_1,
        OUTPUT_SEND_BIT_SCL_HIGH,
        OUTPUT_SEND_BIT_WAIT_2, 
        OUTPUT_SEND_BIT_SCL_LOW,
        OUTPUT_SEND_BIT_WAIT_3,
        OUTPUT_SEND_BIT_DONE,

        OUTPUT_STOP_START,
        OUTPUT_STOP_WAIT_1, 
        OUTPUT_STOP_SDA,
        OUTPUT_STOP_WAIT_2,
        OUTPUT_STOP_DONE
    } output_states;

    output_states output_state, output_state_n;
    logic sda_out_n;
    logic scl_out_n;

    logic start_done, send_bit_done, stop_done; 

    always_ff @ (posedge clk, negedge nRst) begin : output_state_machine_flip_flops
        if (!nRst) begin
            output_state <= OUTPUT_IDLE;
            sda_out      <= 1;
            scl_out      <= 1;
        end else begin
            output_state <= output_state_n;
            sda_out     <= sda_out_n;
            scl_out     <= scl_out_n;
        end
    end

    //assign bit_timer_done_acknowledged = start_done || send_bit_done || stop_done;

    always_comb begin: output_state_machine_state_transitions

        //Defaults
        output_state_n = output_state;

        case (output_state)

            /*Idle*/

            OUTPUT_IDLE: begin

                if (initiate_start) begin
                    output_state_n = OUTPUT_START_START;
                end else if (initiate_send_bit) begin
                    output_state_n = OUTPUT_SEND_BIT_START;
                end else if (initiate_stop) begin
                    output_state_n = OUTPUT_STOP_START;
                end

            end

            /*Start*/

            OUTPUT_START_START: begin
                if (start_bit_timer_acknowledged) begin
                    output_state_n = OUTPUT_START_WAIT_1;
                end
            end

            OUTPUT_START_WAIT_1: begin
                if (bit_timer_done) begin
                    output_state_n = OUTPUT_START_SCL;
                end
            end

            OUTPUT_START_SCL: begin
                if (start_bit_timer_acknowledged) begin
                    output_state_n = OUTPUT_START_WAIT_2;
                end
            end

            OUTPUT_START_WAIT_2: begin
                if (bit_timer_done) begin
                    output_state_n = OUTPUT_START_DONE;
                end
            end

            OUTPUT_START_DONE: begin
                output_state_n = OUTPUT_IDLE;
            end

            /*Send bit*/

            OUTPUT_SEND_BIT_START: begin
                if (start_bit_timer_acknowledged) begin
                    output_state_n = OUTPUT_SEND_BIT_WAIT_1;
                end
            end

            OUTPUT_SEND_BIT_WAIT_1: begin
                if (bit_timer_done) begin
                    output_state_n = OUTPUT_SEND_BIT_SCL_HIGH;
                end
            end
            
            OUTPUT_SEND_BIT_SCL_HIGH: begin
                if (start_bit_timer_acknowledged) begin
                    output_state_n = OUTPUT_SEND_BIT_WAIT_2;
                end
            end

            OUTPUT_SEND_BIT_WAIT_2: begin
                if (bit_timer_done) begin
                    output_state_n = OUTPUT_SEND_BIT_SCL_LOW;
                end
            end

            OUTPUT_SEND_BIT_SCL_LOW: begin
                if (start_bit_timer_acknowledged) begin
                    output_state_n = OUTPUT_SEND_BIT_WAIT_3;
                end
            end

            OUTPUT_SEND_BIT_WAIT_3: begin
                if (bit_timer_done) begin
                    output_state_n = OUTPUT_SEND_BIT_DONE;
                end
            end

            OUTPUT_SEND_BIT_DONE: begin
                output_state_n = OUTPUT_IDLE;
            end

            /*Stop*/

            OUTPUT_STOP_START: begin
                if (start_bit_timer_acknowledged) begin
                    output_state_n = OUTPUT_STOP_WAIT_1;
                end
            end

            OUTPUT_STOP_WAIT_1: begin
                if (bit_timer_done) begin
                    output_state_n = OUTPUT_STOP_SDA;
                end
            end

            OUTPUT_STOP_SDA: begin
                if (start_bit_timer_acknowledged) begin
                    output_state_n = OUTPUT_STOP_WAIT_2;
                end
            end

            OUTPUT_STOP_WAIT_2: begin
                if (bit_timer_done) begin
                    output_state_n = OUTPUT_STOP_DONE;
                end
            end

            OUTPUT_STOP_DONE: begin
                output_state_n = OUTPUT_IDLE;
            end

            default: begin end

        endcase

    end

    always_comb begin : output_state_machine_output_logic

        //Defaults
        sda_out_n = sda_out;
        scl_out_n = scl_out;
        start_bit_timer = 0;
        start_done = 0;
        send_bit_done = 0; //TODO: For some reason the testbench breaks when this is used instead of setting it in the states. 
        stop_done = 0;
        bit_timer_done_acknowledged = 0;

        case (output_state)

            /*Idle*/

            OUTPUT_IDLE: begin
                //Nothing besides the defaults

                send_bit_done = 0;
            end

            /*Start*/

            OUTPUT_START_START: begin
                sda_out_n = 0;
                start_bit_timer = 1;

                send_bit_done = 0; 
            end

            OUTPUT_START_WAIT_1: begin
                //Nothing besides the defaults
            end

            OUTPUT_START_SCL: begin
                scl_out_n = 0;
                bit_timer_done_acknowledged = 1;
                start_bit_timer = 1;
            end

            OUTPUT_START_WAIT_2: begin
                //Nothing besides the defaults
            end

            OUTPUT_START_DONE: begin
                start_done = 1;
                bit_timer_done_acknowledged = 1; 
            end

            /*Send bit*/

            OUTPUT_SEND_BIT_START: begin
                sda_out_n = bit_to_send;
                start_bit_timer = 1;
            end

            OUTPUT_SEND_BIT_WAIT_1: begin
                //Nothing besides the defaults
            end
            
            OUTPUT_SEND_BIT_SCL_HIGH: begin
                scl_out_n = 1;
                bit_timer_done_acknowledged = 1;
                start_bit_timer = 1;
            end

            OUTPUT_SEND_BIT_WAIT_2: begin
                //Nothing besides the defaults
            end

            OUTPUT_SEND_BIT_SCL_LOW: begin
                scl_out_n = 0;
                bit_timer_done_acknowledged = 1;
                start_bit_timer = 1;
            end

            OUTPUT_SEND_BIT_WAIT_3: begin
                //Nothing besides the defaults
            end

            OUTPUT_SEND_BIT_DONE: begin
                send_bit_done = 1;
                bit_timer_done_acknowledged = 1;
            end

            /*Stop*/

            OUTPUT_STOP_START: begin
                scl_out_n = 1;
                //start_bit_timer = 1;

                send_bit_done = 0;
            end

            OUTPUT_STOP_WAIT_1: begin
                //Nothing besides the defaults
            end

            OUTPUT_STOP_SDA: begin
                sda_out_n = 1;
                bit_timer_done_acknowledged = 1;
                //start_bit_timer = 1;
            end

            OUTPUT_STOP_WAIT_2: begin
                //Nothing besides the defaults
            end

            OUTPUT_STOP_DONE: begin
                stop_done = 1;
                bit_timer_done_acknowledged = 1;
            end

            default: begin end

        endcase

    end

    /*
    Section for I2C brain
    */

    typedef enum logic [3:0] {
        I2C_WAITING_INTER,

        I2C_START_1, 
        I2C_START_1_WAIT,

        I2C_SEND_SLAVE_ADDRESS_WRITE,
        I2C_SEND_SLAVE_ADDRESS_WRITE_WAIT,

        I2C_SEND_DATA_ADDRESS,
        I2C_SEND_DATA_ADDRESS_WAIT,

        I2C_STOP_1, 
        I2C_STOP_1_WAIT,

        I2C_START_2, 
        I2C_START_2_WAIT,

        I2C_SEND_SLAVE_ADDRESS_READ,
        I2C_SEND_SLAVE_ADDRESS_READ_WAIT,

        //May later add READ_DATA
        I2C_IDLE,

        I2C_STOP_2, 
        I2C_STOP_2_WAIT
        
    } I2C_states;

    typedef enum logic [7:0] {
        XH = 8'h03, 
        XL = 8'h04, 
        YH = 8'h05, 
        YL = 8'h06
    } data_addresses; //TODO: incrementing this

    typedef enum logic [7:0] {
        SL_WRITE = {7'h38, 1'b0},
        SL_READ = {7'h38, 1'b1}
    } slave_addresses;

    I2C_states I2C_state, I2C_state_n;
    data_addresses which_data_address, which_data_address_n;
    logic [7:0] byte_to_send;
    logic initiate_start, initiate_send_byte, initiate_stop;
    logic reading_done; //TODO: make something to determine this

    always_ff @ (posedge clk, negedge nRst) begin
        if (!nRst) begin
            I2C_state          <= I2C_WAITING_INTER;
            which_data_address <= XH;
        end else begin
            I2C_state          <= I2C_state_n;
            which_data_address <= which_data_address_n;
        end
    end

    always_comb begin : I2C_state_machine_next_states

        //Defaults
        I2C_state_n = I2C_state;

        case (I2C_state) 

            I2C_WAITING_INTER: begin
                if (inter_received) begin
                    I2C_state_n = I2C_START_1;
                end
            end

            I2C_START_1: begin
                I2C_state_n = I2C_START_1_WAIT;
            end

            I2C_START_1_WAIT: begin
                if (start_done) begin
                    I2C_state_n = I2C_SEND_SLAVE_ADDRESS_WRITE;
                end
            end

            I2C_SEND_SLAVE_ADDRESS_WRITE: begin
                I2C_state_n = I2C_SEND_SLAVE_ADDRESS_WRITE_WAIT;
            end

            I2C_SEND_SLAVE_ADDRESS_WRITE_WAIT: begin
                if (byte_manager_done) begin
                    I2C_state_n = I2C_SEND_DATA_ADDRESS;
                end
            end

            I2C_SEND_DATA_ADDRESS: begin
                I2C_state_n = I2C_SEND_DATA_ADDRESS_WAIT;
            end

            I2C_SEND_DATA_ADDRESS_WAIT: begin
                if (byte_manager_done) begin
                    I2C_state_n = I2C_STOP_1;
                end
            end

            I2C_STOP_1: begin
                I2C_state_n = I2C_STOP_1_WAIT;
            end

            I2C_STOP_1_WAIT: begin
                if (stop_done) begin
                    I2C_state_n = I2C_START_2;
                end
            end

            I2C_START_2: begin
                I2C_state_n = I2C_START_2_WAIT;
            end

            I2C_START_2_WAIT: begin
                if (start_done) begin
                    I2C_state_n = I2C_SEND_SLAVE_ADDRESS_READ;
                end
            end

            I2C_SEND_SLAVE_ADDRESS_READ: begin
                I2C_state_n = I2C_SEND_SLAVE_ADDRESS_READ_WAIT;
            end

            I2C_SEND_SLAVE_ADDRESS_READ_WAIT: begin
                if (byte_manager_done) begin
                    I2C_state_n = I2C_IDLE;
                end
            end

            I2C_IDLE: begin
                if (reading_done) begin
                    I2C_state_n = I2C_STOP_2;
                end
            end

            I2C_STOP_2: begin
                I2C_state_n = I2C_STOP_2_WAIT;
            end

            I2C_STOP_2_WAIT: begin
                if (stop_done) begin
                    I2C_state_n = I2C_WAITING_INTER;
                end
            end

        endcase

    end

    always_comb begin : I2C_state_machine_outputs

        //Defaults
        initiate_start = 0;
        initiate_send_byte = 0;
        initiate_stop = 0;
        byte_to_send = '1;
        inter_received_acknowledged = 0;
        which_data_address_n = which_data_address; //TODO: give this the ability to change

        case (I2C_state)

            I2C_START_1: begin
                initiate_start = 1;
                inter_received_acknowledged = 1;
            end

            I2C_SEND_SLAVE_ADDRESS_WRITE: begin
                initiate_send_byte = 1;
                byte_to_send = SL_WRITE;
            end

            I2C_SEND_SLAVE_ADDRESS_WRITE_WAIT: begin
                byte_to_send = SL_WRITE;
            end

            I2C_SEND_DATA_ADDRESS: begin 
                initiate_send_byte = 1;
                byte_to_send = which_data_address;
            end

            I2C_SEND_DATA_ADDRESS_WAIT: begin 
                byte_to_send = which_data_address;
            end

            I2C_START_2: begin
                initiate_start = 1;
            end

            I2C_SEND_SLAVE_ADDRESS_READ: begin
                initiate_send_byte = 1;
                byte_to_send = SL_READ;
            end

            I2C_SEND_SLAVE_ADDRESS_READ_WAIT: begin
                byte_to_send = SL_READ;
            end

            I2C_STOP_1: begin
                initiate_stop = 1;
            end

            I2C_STOP_2: begin
                initiate_stop = 1;
            end

            default: begin end

        endcase

    end

    /*
    Section for byte manager
    */

    typedef enum logic [1:0] {
        BYTE_MANAGER_IDLE,
        BYTE_MANAGER_SENDING, 
        BYTE_MANAGER_DONE
    } byte_manager_states;

    byte_manager_states byte_manager_state, byte_manager_state_n;
    logic [2:0] within_byte_counter, within_byte_counter_n;
    logic bit_to_send;
    logic initiate_send_bit;
    logic byte_manager_done;

    always_ff @ (posedge clk, negedge nRst) begin : byte_manager_flip_flops
        if (!nRst) begin
            byte_manager_state  <= BYTE_MANAGER_IDLE;
            within_byte_counter <= 0;
        end else begin
            byte_manager_state  <= byte_manager_state_n;
            within_byte_counter <= within_byte_counter_n;
        end
    end

    always_comb begin : byte_manager_next_state

        //Defaults
        byte_manager_state_n = byte_manager_state;

        case (byte_manager_state)

            BYTE_MANAGER_IDLE: begin
                if (initiate_send_byte) begin
                    byte_manager_state_n = BYTE_MANAGER_SENDING;
                end
            end

            BYTE_MANAGER_SENDING: begin
                if (within_byte_counter == 3'd7 && send_bit_done) begin
                    byte_manager_state_n = BYTE_MANAGER_DONE;
                end
            end

            BYTE_MANAGER_DONE: begin
                byte_manager_state_n = BYTE_MANAGER_IDLE;
            end

            default: begin end

        endcase

    end

    always_comb begin : byte_manager_outputs

        //Defaults
        initiate_send_bit = 0;
        byte_manager_done = 0;
        bit_to_send = 1;
        within_byte_counter_n = within_byte_counter;

        case (byte_manager_state)

            BYTE_MANAGER_IDLE: begin
                within_byte_counter_n = 0;
            end

            BYTE_MANAGER_SENDING: begin
                initiate_send_bit = 1;
                bit_to_send = byte_to_send[7 - within_byte_counter]; //Sending bits in reverse order
                if (send_bit_done) begin
                    within_byte_counter_n = within_byte_counter + 1;
                end
            end

            BYTE_MANAGER_DONE: begin
                within_byte_counter_n = 0;
                byte_manager_done = 1;
            end

            default: begin end

        endcase

    end

    /*
    Section for interrupt receiver
    */

    logic inter_received, inter_received_n; 
    logic inter_received_acknowledged;

    always_ff @ (posedge clk, negedge nRst) begin : interrupt_receiver_flip_flops
        if (!nRst) begin
            inter_received <= 0;
        end else begin
            inter_received <= inter_received_n;
        end
    end

    always_comb begin : interrupt_receiver

        //Defaults
        inter_received_n = 0;

        if (!inter && ~inter_received_acknowledged) begin
            inter_received_n = 1;
        end

    end

endmodule