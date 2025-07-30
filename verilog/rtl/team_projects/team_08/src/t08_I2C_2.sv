module t08_I2C_2(
    input logic clk, nRst, //Clock and active-low reset

    input logic sda_in, //Input on the SDA line from the touchscreen
    output logic sda_out, //Output on the SDA line to the touchscreen
    output logic sda_oeb, //is 1 whenever the SDA pin is an input and is 0 whenver it is an output
    //SDA OEB NOT IMPLEMENTED HERE AT THE MOMENT

    input logic inter, //Interrupt signal from the touchscreen. NOTE: IT IS ACTIVE LOW. 
    output logic scl, //Clock for I2C sent to the touchscreen

    output logic [31:0] data_out, //All of the coordinate data sent to memory
    output logic done //Done signal also sent to memory, indicating that the module has finished reading coordinate data after a given interrupt signal
);

    logic inter_prev;
    logic [31:0] data_out_n;

    logic inter_received, inter_received_n;

    typedef enum logic [7:0] {
        XH = 8'h03, 
        XL = 8'h04, 
        YH = 8'h05, 
        YL = 8'h06
    } data_addresses; 
    data_addresses data_address;
    data_addresses data_address_n;
    logic [6:0] slave_address = 7'h38;

    logic [3:0] address_bit_counter, address_bit_counter_n;

    logic readwrite, readwrite_n; //read = 1, write = 0

    typedef enum logic [3:0] {
        IDLE,
        INITIAL_START,
        INTERMEDIATE_START,
        SEND_SLAVE_ADDRESS, //This includes the readwrite bit at the end. (and "checking" for ack)
        SEND_DATA_ADDRESS, //This includes "checking" for the ack bit at the end. (Not going to truly implement checking at first)
        WAITING, 
        READ_DATA_FRAME, //This includes sending ack bit at the end. 
        INTERMEDIATE_STOP, 
        FINAL_STOP
    } step_states;
    step_states step_state;
    step_states step_state_n, step_state_n_new, step_state_n_new_n;

    always_ff @ (posedge clk, negedge nRst) begin
        if (!nRst) begin
            data_address        <= XH;
            step_state          <= IDLE;
            scl_counter         <= 0;
            inter_prev          <= 1;
            readwrite           <= 0;
            address_bit_counter <= 0;
            step_state_n_new    <= IDLE;
            data_out            <= 0;
            inter_received      <= 0;
        end else begin
            data_address        <= data_address_n;
            step_state          <= step_state_n;
            scl_counter         <= scl_counter_n;
            inter_prev          <= inter;
            readwrite           <= readwrite_n;
            address_bit_counter <= address_bit_counter_n;
            step_state_n_new    <= step_state_n_new_n;
            data_out            <= data_out_n;
            inter_received      <= inter_received_n;
        end
    end

    always_comb begin : state_controller
        //Defaults
        step_state_n_new_n = step_state_n_new;
        readwrite_n = readwrite;

        if (scl_counter == 0) begin //For proper timing

            case (step_state)
                IDLE: begin
                    if (!inter && inter_prev) begin
                        inter_received_n = 1;
                    end
                    if (inter_received) begin
                        step_state_n_new_n = INITIAL_START;
                    end
                end
                INITIAL_START, INTERMEDIATE_START: begin
                    step_state_n_new_n = SEND_SLAVE_ADDRESS;
                    if (step_state == INITIAL_START) begin
                        readwrite_n = 0; //switch to writing
                    end else begin
                        readwrite_n = 1; //switch to writing
                    end
                    address_bit_counter_n = 0;
                    //address_bit_counter_n = 3'd6; //For slave address
                end
                SEND_SLAVE_ADDRESS: begin
                    if (address_bit_counter <= 4'd6) begin
                        sda_out_n_new = slave_address[3'd6 - address_bit_counter[2:0]];
                        address_bit_counter_n = address_bit_counter + 1;
                    end else if (address_bit_counter == 4'd7) begin
                        sda_out_n_new = readwrite;
                        address_bit_counter_n = address_bit_counter + 1;
                    end else begin
                        //Pretending to check for ack bit
                        address_bit_counter_n = 0;
                        step_state_n_new_n = WAITING;
                    end
                end
                WAITING: begin
                    if (readwrite == 1) begin
                        step_state_n_new_n = READ_DATA_FRAME;
                    end else begin
                        step_state_n_new_n = SEND_DATA_ADDRESS;
                    end
                    //step_state_n_new_n = readwrite ? READ_DATA_FRAME : SEND_DATA_ADDRESS;
                end
                SEND_DATA_ADDRESS: begin
                    if (address_bit_counter <= 4'd7) begin
                        sda_out_n_new = data_address[3'd7 - address_bit_counter[2:0]];
                        address_bit_counter_n = address_bit_counter + 1;
                    end else begin
                        //Pretending to check for ack bit
                        address_bit_counter_n = 0;
                        step_state_n_new_n = INTERMEDIATE_STOP;
                    end
                end
                READ_DATA_FRAME: begin
                    sda_out_n_new = 1;
                    if (address_bit_counter <= 4'd7) begin
                        if (data_address == XH) begin
                            data_out_n[5'd7 - {1'b0, address_bit_counter}] = sda_in;
                        end 
                        else if (data_address == XL) begin
                            data_out_n[5'd15 - {1'b0, address_bit_counter}] = sda_in;
                        end
                        else if (data_address == YH) begin
                            data_out_n[5'd23 - {1'b0, address_bit_counter}] = sda_in;
                        end
                        else if (data_address == YL) begin
                            data_out_n[5'd31 - {1'b0, address_bit_counter}] = sda_in;
                        end
                        address_bit_counter_n = address_bit_counter + 1;
                    end else begin
                        //Sending ack bit
                        sda_out_n_new = 0;
                        step_state_n_new_n = FINAL_STOP;
                    end
                end
                INTERMEDIATE_STOP, FINAL_STOP: begin
                    if (step_state == INTERMEDIATE_STOP) begin
                        step_state_n_new_n = INTERMEDIATE_START;
                    end else begin
                        if (data_address == YL) begin
                            step_state_n_new_n = IDLE;
                            inter_received_n = 0;
                        end else begin
                            step_state_n_new_n = INITIAL_START;
                            data_address_n = data_addresses'(int'(data_address) + 1); 
                        end
                    end
                end
                default: begin end
            endcase
        end    
    end

    /*
    ---------------
    Timed from clk
    ---------------
    IDLE: 

    Posedge 1: Update step_state, hold scl at 1, hold sda_out at 1
    Posedge 2: hold scl at 1
    Posedge 3: hold scl at 1

    START: 

    Posedge 1: negedge SDA_out
    Posedge 2: negedge scl
    Posedge 3: hold scl at 0

    STOP: 

    Posedge 1: hold sda at 0
    Posedge 2: posedge scl
    Posedge 3: posedge SDA_out

    WAITING: 

    Posedge 1: Update SDA_out and/or step_state, hold scl at 0
    Posedge 2: hold scl at 0
    Posedge 3: hold scl at 0

    OTHER OPERATION: 

    Posedge 1: Update SDA_out and/or step_state
    Posedge 2: posedge scl
    Posedge 3: negedge scl
    */
    logic [1:0] scl_counter, scl_counter_n;
    logic sda_out_n, sda_out_n_new;
    always_comb begin : timing_controller
        //Defaults
        //sda_out_n = sda_out;
        step_state_n = step_state;
        scl_counter_n = scl_counter;

        if (step_state == IDLE) begin
            case (scl_counter) 
                2'd0: begin
                    
                    sda_out = 1;
                    scl = 1;
                    scl_counter_n = 2'd1;
                end
                2'd1: begin
                    scl = 1;
                    scl_counter_n = 2'd2;
                end
                2'd2: begin
                    scl = 1;
                    scl_counter_n = 2'd0;
                    step_state_n = step_state_n_new;
                end
                default: begin end
            endcase
        end
        else if (step_state == INITIAL_START || step_state == INTERMEDIATE_START) begin
            case (scl_counter) 
                2'd0: begin
                    sda_out = 0;
                    scl_counter_n = 2'd1;
                end
                2'd1: begin
                    scl = 0;
                    scl_counter_n = 2'd2;
                end
                2'd2: begin
                    scl = 0;
                    scl_counter_n = 2'd0;
                end
                default: begin end
            endcase
        end
        else if (step_state == INTERMEDIATE_STOP || step_state == FINAL_STOP) begin
            case (scl_counter) 
                2'd0: begin
                    sda_out = 0;
                    scl_counter_n = 2'd1;
                end
                2'd1: begin
                    scl = 1;
                    scl_counter_n = 2'd2;
                end
                2'd2: begin
                    sda_out_n = 1;
                    scl_counter_n = 2'd0;
                end
                default: begin end
            endcase
        end
        else if (step_state == WAITING) begin
            case (scl_counter) 
                2'd0: begin
                    sda_out = sda_out_n_new;
                    scl = 0;
                    scl_counter_n = 2'd1;
                end
                2'd1: begin
                    scl = 0;
                    scl_counter_n = 2'd2;
                end
                2'd2: begin
                    scl = 0;
                    scl_counter_n = 2'd0;
                    step_state_n = step_state_n_new;
                end
                default: begin end
            endcase
        end
        else begin
            case (scl_counter) 
            2'd0: begin
                sda_out = sda_out_n_new;
                scl_counter_n = 2'd1;
            end
            2'd1: begin
                scl = 1;
                scl_counter_n = 2'd2;
            end
            2'd2: begin
                scl = 0;
                scl_counter_n = 2'd0;
                step_state_n = step_state_n_new;
            end
            default: begin end
        endcase
        end
    end

endmodule