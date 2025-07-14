`default_nettype none

/* CPU Memory Handler for Team 07

-This module handles memory operations for the CPU, including read and write operations.
-It interfaces with the memory and manages the data flow based on control signals.
-Takes in Data from the control unit and ALU, and outputs the read data and memory address.

*/

module t07_cpu_memoryHandler (

    // Inputs
    input logic memWrite, memRead,
    input logic memSource,          //if we are writing from the FPU or ALU
    input logic [31:0] ALU_address, // Address for memory operations that comes from the ALU
    input logic [31:0] FPU_data,    // Data from the FPU to store in memory
    input logic [31:0] Register_dataToMem, // Data from the internal register file to store in memory
    input logic [31:0] ExtData,     // Data from external memory to read/write
    
    //outputs
    output logic [31:0] write_data, // Data to write to external memory
    output logic [31:0] ExtAddress, // Address to write to external memory   
    output logic [31:0] dataToCPU, 
    output logic freeze,            // Freeze signal to pause CPU operations during memory access
    output logic [1:0] rwi          // Read/Write/Idle control signal for external memory operations

);

always_comb begin
    if(memWrite) begin 
        freeze = 1; // Freeze the CPU during memory write operation
        dataToCPU = 32'b0; // No data to return to CPU on write operation
        rwi = 2'b01; // Write operation
        if(memSource) begin
            // If memSource is set, we are writing from the FPU register
            ExtAddress = ALU_address; // Use ALU address for memory operations
            write_data = FPU_data;
        end else begin
            // Otherwise, we are writing from the Register file
            write_data = Register_dataToMem;
            ExtAddress = ALU_address; // Use ALU address for memory operations
        end 
    end else if(memRead) begin
        freeze = 1; // Freeze the CPU during memory read operation
        rwi = 2'b10; //Read operation
        ExtAddress = ALU_address; // Use ALU address for memory operations
        dataToCPU = ExtData; // Read data from external memory
        write_data = 32'b0; // No data to write in read operation
    end else begin
        rwi = 2'b00; // Idle state
        freeze = 0; // CPU is not frozen
        write_data = 32'b0; // No data to write
        ExtAddress = 32'b0; // No address to write to
        dataToCPU = 32'b0; // No data to return to CPU
    end
end
endmodule
