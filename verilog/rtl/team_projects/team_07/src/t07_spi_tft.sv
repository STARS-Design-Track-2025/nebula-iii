// spi to tft interface
// This module handles the communication between the SPI interface and the TFT display.
// It manages the data transfer, control signals, and timing required for the TFT display to function
// correctly.

/* functionality
    //rs - register select  0: Data, 1: COMMAND/STATUS
    //rw - read or write   0: WRiTE, 1


*/
typedef enum logic[2:0] {
    BYTE1 = 0,
    BYTE2 = 1,
    BYTE3 = 2,
    BYTE4 = 3,
    DONE = 4
} byteNum;

module t07_spi_tft (
    input logic clk,
    input logic nrst,
    input logic [31:0] data_in, // stream of data
    input logic [31:0] address, // for the registers
    input logic wi, // writing or idling
    
    output logic ack, //acknowledgement signal send to mmio when all 32 bits are in the driver
    output logic chipSelect, //toggling whether we are sending data or not
    output logic MOSI_RA8875_in, // 1 bit of data being sent a time
    output logic sclk, // clk for driver
    output logic protocol
);

//internal registers
logic [31:0] RA8875_in;
logic [7:0] n_RA8875_in;
logic [7:0] f_RA8875_in;

logic [1:0] byte_count;
logic [7:0] address_out; //4 bytes of address data
logic [7:0] data_out; //4 bytes of input data
logic [7:0] protocol_byte;

logic rs; //register select
logic rw; //read write signal

byteNum next_byte, current_byte;

assign sclk = clk;


// handling protocol byte
logic [7:0] n_data_out, n_address_out;

always_ff @(negedge nrst, posedge clk) begin
    if(!nrst) begin
        current_byte <= BYTE1;
    end else begin
        current_byte <= next_byte;
    end
end

always_comb begin

    case(current_byte)
    
        BYTE1:
           begin
            chipSelect = 1;
            ack = 1;
            next_byte = BYTE2;
            data_out = data_in[31:24];
            address_out = address[31:24];
           end
        BYTE2:
           begin
            chipSelect = 1;
            ack = 1;
            next_byte = BYTE3;
            data_out = data_in[23:16];
            address_out = address[23:16];
           end
        BYTE3:
           begin
            chipSelect = 1;
            ack = 1;
            next_byte = BYTE4;
            data_out = data_in[15:8];
            address_out = address[15:8];
           end
        BYTE4:
           begin
            chipSelect = 1;
            ack = 1;
            next_byte = DONE;
            data_out = data_in[7:0];
            address_out = address[7:0];
           end
        DONE:
            begin
            chipSelect = 0;
            ack = 0;
            next_byte = BYTE1;
            data_out = '0;
            address_out = '0;
            end
        default:
            begin
            chipSelect = 0;
            ack = 0;
            next_byte = BYTE1;
            data_out = '0;
            address_out = '0;
            end
         

    endcase

end











































endmodule



