`default_nettype none

/* CPU Memory Handler for Team 07

-This module handles memory operations for the CPU, including read and write operations.
-It interfaces with the memory and manages the data flow based on control signals.
-Takes in Data from the control unit and ALU, and outputs the read data and memory address.

*/

module t07_cpu_memoryHandler (

    // Inputs
    input logic reset,
    input logic clk,
    input logic [31:0]write_data,
    input logic [31:0]address,
    input logic MemWrite,
    input logic MemRead,
    input logic [31:0]memReadData, // Data read from external memory

    // Outputs
    output logic [31:0]readData,
    output logic [31:0]memWriteData,
    output logic [31:0]memAddress,
    output logic [1:0]rwi // 00: Read, 01: Write, 10: IDLE

);

logic [31:0] memory;

always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        rwi <= 2'b10; // IDLE
        readData <= 32'b0;
        memWriteData <= 32'b0;
        memAddress <= 32'b0;
    end else begin
        if (MemWrite) begin
            rwi <= 2'b01; // Write operation
            memWriteData <= write_data;
            memAddress <= address;
        end else if (MemRead) begin
            rwi <= 2'b00; // Read operation
            readData <= memReadData;
            memAddress <= address;
        end else begin
            rwi <= 2'b10; // IDLE
        end
    end
end

endmodule
