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
    input logic memWrite, memRead,
    input logic memSource,          //if we are writing from the FPU or ALU
    input logic [31:0] ALU_address, // Address for memory operations that comes from the ALU
    input logic [31:0] FPU_data,    // Data from the FPU to store in memory
    input logic [31:0] Register_data, // Data from the internal register file to store in memory
    input logic [31:0] ExtData,     // Data from external memory to read/write
    
    //outputs
    output logic [31:0] write_data, // Data to write to external memory
    output logic [31:0] ExtAddress, // Address to write to external memory
    output logic [1:0] rwi          // Read/Write/Idle control signal for external memory operations

);

logic [31:0] memory;

always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        rwi <= 2'b10; // IDLE
        memWrite <= 32'b0;
        memRead <= 32'b0;
    end else begin
        if(memSource) begin
            // If memSource is set, we are writing from the FPU
            write_data <= FPU_data;
            ExtAddress <= ALU_address; // Use ALU address for memory operations
        end else begin
            // Otherwise, we are writing from the Register file
            write_data <= Register_data;
            ExtAddress <= ALU_address; // Use ALU address for memory operations
        end

        if (MemWrite) begin
            rwi <= 2'b01; // Write operation
            write_data <= write_data;
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
