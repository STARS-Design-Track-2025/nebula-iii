// // spi to tft interface
// // This module handles the communication between the SPI interface and the TFT display.
// // It manages the data transfer, control signals, and timing required for the TFT display to function
// // correctly.

// /* functionality
//     take in 32 bit of data
//     take in 32 bit of address
//     divide each into bytes
//     transfer put each bit of each byte per clock cycle
//     one transfer is 16 clock cycles
//     8 bit of address sent and then 8 bits of data send 
// */

<<<<<<< HEAD
// typedef enum logic [2:0] {
//     IDLE = 0,
//     LOAD = 1,
//     SHIFT = 2,
//     CS_HIGH = 3,
//     DONE = 4
// } spi_state;

// spi_state state, next_state;

// module t07_spi_tft (
=======
module t07_spi_tft (
>>>>>>> 1547289101454f7c499da60d41d66a006666ece7

//     input logic [31:0] data,
//     input logic [31:0] address,
//     input logic clk,
//     input logic nrst,
//     input logic wi,

//     output logic ack, // to memory handler
    
//     // to ra8875
//     output logic bitData,
//     output logic sclk,
//     output logic chipSelect // chip select

<<<<<<< HEAD
// );
// assign sclk = clk; // synchronous with driver
=======
);

typedef enum logic [2:0] {
    IDLE = 0,
    LOAD = 1,
    SHIFT = 2,
    CS_HIGH = 3,
    DONE = 4
} spi_state;

spi_state state, next_state;


assign sclk = clk; // synchronous with driver
>>>>>>> 1547289101454f7c499da60d41d66a006666ece7

// logic [15:0] shiftReg, n_shiftReg;
// logic [63:0] dataforOutput;
// logic [3:0] bit_count, n_bit_count;
// logic [1:0] chunk_count, n_chunk;


// assign dataforOutput = {address[31:24], data[31:24], 
// address[23:16], data[23:16], 
// address[15:8], data[15:8],
// address[7:0], data[7:0]};

// always_ff @(negedge nrst, posedge clk) begin
//     if(~nrst) begin
//          state <= IDLE;
//     end else begin
//         state <= next_state;
//     end
// end

// always_comb begin

//     chipSelect = 1;
//     bitData = 0;
//     ack = 0;
//     n_shiftReg = shiftReg;
//     n_bit_count = bit_count;
//     n_chunk = chunk_count;
//     next_state = state;

//     if (wi == 1) begin
//         next_state = LOAD;
//     end else begin
//         next_state = IDLE;
//     end
    
//     case (state)
//         IDLE: begin
//             if (wi) begin
//                 next_state = LOAD;
//             end
//         end

//         LOAD: begin
//             chipSelect = 0;
//             n_shiftReg = dataforOutput[63 -: 16];
//             next_state = SHIFT;
//         end

//         SHIFT: begin
//             chipSelect = 0;
//             bitData = shiftReg[15];
//             n_shiftReg = {shiftReg[14:0], 1'b0};
//             n_bit_count = bit_count + 1;

//             if (bit_count == 15) begin
//                 next_state = CS_HIGH;
//             end

            
//         end

//         CS_HIGH: begin
//             chipSelect = 1;
//             n_bit_count = 0;

//             if(chunk_count == 3) begin
//                 next_state = DONE;
//             end else begin
//                 n_chunk = chunk_count + 1;
//                 n_shiftReg = dataforOutput[63 - (chunk_count +1)*16 -: 16];
//                 next_state = SHIFT;
//             end
//         end

//         DONE: begin
//             chipSelect = 1;
//             ack = 1;
//             next_state = IDLE;
//         end

//         default: next_state = IDLE;
//     endcase
// end

// always_ff @(posedge clk or negedge nrst) begin
//     if(!nrst) begin
//         shiftReg <= 16'd0;
//         bit_count <= 4'd0;
//         chunk_count <= 2'd0;
//     end else begin
//         shiftReg <= n_shiftReg;
//         bit_count <= n_bit_count;
//         chunk_count <= n_chunk;
//     end
// end
    
// //     if (wi == 1) begin
// //         next_state = LOAD;
// //     end else begin
// //         chipSelect = 1;
// //     end

// //     next_data = dataforOutput;
// //     if (wi == 1 && curr_data != '0) begin
// //         chipSelect = 0;
// //         bitData = curr_data[63];
// //         next_data = curr_data << 1; 
// //         ack = 1;
// //     end else if (wi == 0) begin
// //         chipSelect = 1;
// //         bitData = 0;
// //         ack = 1;
// //     end else begin
// //         chipSelect = 1;
// //         bitData = '0;
// //         ack = 0;
// //     end
// // end


// endmodule

