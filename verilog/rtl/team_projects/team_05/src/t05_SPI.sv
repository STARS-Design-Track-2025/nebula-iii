`default_nettype none
module t05_SPI (
    input   logic           miso,                       // Read
    input   logic           rst,                        // Reset
    input   logic           clk,                        //Clock
    input   logic           serial_clk,                 //Serial Clock
    input   logic           writebit,                   //Bit that needs to be written
    input   logic           read_en,                    //Determines when to start reading
    input   logic           write_en,                   //Determines when to start writing
    input   logic           read_stop,                  //Determines when to stop reading
    input   logic           write_stop,                 //Determines when to stop writing
    input   logic           nextCharEn,     
    output  logic           slave_select,               //CS
    output  logic           reading,                    //Reading active
    output  logic           read_output,                //Goes to bytecount
    output  logic           finish,                     //Finish Signal
    output  logic           freq_flag,                  //Clock Frequency Flag
    output  logic           mosi                        // Write
);

typedef enum logic [3:0] {
    WARMUP = 1,
    CMD_CHOOSE = 2,
    CMD_INPUT = 3,
    CMD_RESPONSE = 4,
    IDLE = 5,
    READ_PREP = 6,
    READING = 7,
    READ_STOP = 8,
    WRITE_TOKEN = 9,
    WRITING = 10,
    WRITE_CRC = 11
} state_t;

localparam
    CMD0 = 48'b010000000000000000000000000000000000000010010101,                // To go into IDLE STATE
    CMD58 = 48'b011110100000000000000000000000000000000001110101,               // OCR Conditions
    CMD55 = 48'b011101110000000000000000000000000000000001100101,               // Prepares the SD Card for the next command
    ACMD41 = 48'b011010010100000000000000000000000000000000000001,              // Exits initialization mode and begn the data transfer
    CMD12 = 48'b010011000000000000000000000000000000000000000001,               // Stop reading 
    CMD8 =  48'b010010000000000000000000000000011010101010000111;               // Check the voltage range and if the card is compatible

logic [47:0] cmd18;
assign cmd18 = {8'b01010010, address, 8'b00000001};                     // Read multiple blocks until termination code
logic [47:0] cmd24; 
assign cmd24 = {8'b01011000, address, 8'b00000001};                     // Write single 
logic [47:0] cmd25; 
assign cmd25 = {8'b01011001, address, 8'b00000001};                     // Write Multiple

// Logic declarations
state_t         state, state_n;
logic [47:0]    cmd_line, cmd_line_n;                                   //CMD being written
logic           freq_flag_n;
//WARMUP
logic [6:0]     warmup_counter, warmup_counter_n;                       // Used to stabilize the SD before data transfer begin
//CMD_CHOOSE
logic           redo_init, redo_init_n;                                 //Control the repeat in sd initialization
//CMD_INPUT
logic [5:0]     cmd_counter, cmd_counter_n;                             // Used to count the number of bits received
//CMD_RESPONSE 
logic [6:0]     read_48, read_48_n;                                     //Reading in response timer
//IDLE
logic [31:0]    address, address_n;                                     //Address for writing/reading
//WRITE_TOKEN
logic [2:0]     counter_token, counter_token_n;                         //Counter for writing data token to SD
//WRITING
logic [7:0]     data_token, data_token_n;                               //Enable for Data Token writing
logic [12:0]    counter_512, counter_512_n;                             //Counter for 512 blocks;
//WRITE_CRC
logic [5:0]     counter_crc, counter_crc_n;                             //Counter for writing CRC at the end of 512 bytes

always_ff @(posedge clk, posedge rst) begin
    if (rst) begin  
        //GENERAL
        state <= WARMUP;   
        cmd_line <= '0;
        freq_flag <= 0;
        //WARMUP
        warmup_counter <= '0;  
        //CMD_CHOOSE
        redo_init <= 1;
        //CMD_INPUT
        cmd_counter <= '0;
        //CMD_RESPONSE
        read_48 <= '0;
        //IDLE
        address <= '0;
        //WRITE_TOKEN
        counter_token <= 0;
        //WRITING
        data_token <= 8'hFC;
        counter_512 <= '0;
        //WRITE_CRC
        counter_crc <= '0;
    end else if (serial_clk) begin
        //GENERAL
        state <= state_n;
        cmd_line <= cmd_line_n;
        freq_flag <= freq_flag_n;
        //WARMUP
        warmup_counter <= warmup_counter_n; // Counter for the warmup
        //CMD_CHOOSE
        redo_init <= redo_init_n;
        //CMD_INPUT
        cmd_counter <= cmd_counter_n; // Counter for the number of bits received
        //CMD_RESPONSE
        read_48 <= read_48_n;
        //IDLE
        address <= address_n;
        //WRITE_TOKEN
        counter_token <= counter_token_n;
        //WRITING
        data_token <= data_token_n;
        counter_512 <= counter_512_n;
        //WRITE_CRC
        counter_crc <= counter_crc_n;
    end
end

// INIT Logic Block
always_comb begin
    //GENERAL
    state_n = state;
    cmd_line_n = cmd_line;
    freq_flag_n = freq_flag;
    slave_select = 0;
    mosi = 1;
    //WARMUP
    warmup_counter_n = warmup_counter;
    //CMD_CHOOSE
    redo_init_n = redo_init;
    //CMD_INPUT
    cmd_counter_n = cmd_counter;
    //CMD_RESPONSE
    read_48_n = read_48;
    //IDLE
    address_n = address;
    //READING
    reading = 0;
    read_output = 0;
    //WRITE_TOKEN
    counter_token_n = counter_token;
    //WRITING
    data_token_n = data_token;
    counter_512_n = counter_512;
    //WRITE_CRC
    counter_crc_n = counter_crc;

    case (state)
        WARMUP: begin
            slave_select = 1;
            freq_flag_n = 0;
            if (warmup_counter < 75) begin
                warmup_counter_n = warmup_counter + 1; // Warmup counter to stabilize the SD
                mosi = 1;
                //slave_select = 1;
            end 
            else begin
                state_n = CMD_INPUT;
                cmd_line_n = CMD0;
                warmup_counter_n = 0;
                //slave_select = 1; 
            end
        end
        CMD_CHOOSE: begin
            case(cmd_line[45:40])
                '0: begin //CMD_0
                    cmd_line_n= CMD8;
                    state_n = CMD_INPUT;
                end
                8: begin //CMD_8
                    cmd_line_n = CMD55;
                    state_n = CMD_INPUT;
                end
                55: begin //CMD_55
                    cmd_line_n = ACMD41;
                    state_n = CMD_INPUT;
                end
                41: begin //ACMD_41
                    if(redo_init) begin
                        cmd_line_n = CMD8;
                        state_n = CMD_CHOOSE;
                        redo_init_n = 0;
                    end
                    else begin
                        cmd_line_n = CMD58;
                        state_n = CMD_INPUT;
                    end
                end
                58: begin //CMD_58
                    cmd_line_n = '0;
                    state_n = IDLE;
                end
                18: begin //CMD_18
                    cmd_line_n = '0;
                    state_n = READING;
                end
                12: begin //CMD_12
                    cmd_line_n = '0;
                    state_n = IDLE;
                end
                25: begin //CMD_25
                    cmd_line_n = '0;
                    data_token_n = 8'hFC;
                    state_n = WRITE_TOKEN;
                    mosi = 1;
                end
            endcase
        end
        CMD_INPUT: begin
            slave_select = 0;
            if (cmd_counter == 47) begin
                cmd_counter_n = 0;                      // Reset the index counter after sending the command
                state_n = CMD_RESPONSE;
            end
            else if (cmd_counter < 47) begin
                cmd_counter_n = cmd_counter + 1;        // Increment the index counter for each bit
            end
            mosi = cmd_line[47 - cmd_counter];          // Shift out the command bit
        end
        CMD_RESPONSE: begin
            if(read_48 < 48) begin
                read_48_n = read_48 + 1;
            // end else if (write_en) begin
            //     read_48_n = 0;
            //     state_n = CMD_RESPONSE;
            end else begin
                read_48_n = '0;
                state_n = CMD_CHOOSE;
            end
        end
        IDLE: begin
            slave_select = 1;
            freq_flag_n = 0; //Make ONE later
            if(read_en) begin
                cmd_line_n = cmd18;
                address_n = '0;
                state_n = CMD_INPUT;
            end
            else if(write_en) begin
                cmd_line_n = cmd25;
                address_n = '0;
                state_n = CMD_INPUT;
            end
        end
        READING: begin
            slave_select = 1;
            if(read_stop) begin
                cmd_line_n = CMD12;
                state_n = CMD_INPUT;
            end
            else begin
                state_n = READING;
                read_output = miso;
                reading = 1;
            end
        end
        WRITE_TOKEN: begin
            if(counter_token < 7) begin
                if(counter_token < 6) begin
                    counter_token_n = counter_token + 1;
                end
                mosi = data_token[6 - counter_token];
            end 
            if(counter_token == 6) begin
                //mosi = writebit;
                counter_token_n = '0;
                state_n = WRITING;
            end
        end
        WRITING: begin
            slave_select = 1;
            if(counter_512 == 512 * 8) begin
                state_n = WRITE_CRC;
                //mosi = 1;
                counter_512_n = '0;
            end
            if (counter_512 < 512 * 8) begin
                mosi = writebit;
                counter_512_n = counter_512 + 1;
            end
            if(write_stop) begin
                data_token_n = 8'hFD;
            end
        end
        WRITE_CRC: begin
            if(counter_crc <= 7) begin
                counter_crc_n = counter_crc + 1;
                mosi = 1;
            end else if (counter_crc < 30) begin
                counter_crc_n = counter_crc + 1;
            end else if (counter_crc == 30) begin
                state_n = WRITE_TOKEN;
            end
        end
        default: state_n = IDLE;
    endcase
end
endmodule
