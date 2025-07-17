`default_nettype none

/* CPU Memory Handler for Team 07

-This module handles memory operations for the CPU, including read and write operations.
-It interfaces with the memory and manages the data flow based on control signals.
-Takes in Data from the control unit and ALU, and outputs the read data and memory address.

*/

module t07_cpu_memoryHandler (

    // Inputs
    input logic busy, // Busy signal to indicate if the memory handler is currently processing
    input logic [3:0] memOp,
    input logic memWrite, memRead,
    input logic memSource,          //if we are writing from the FPU or ALU
    input logic [31:0] ALU_address, // Address for memory operations that comes from the ALU
    input logic [31:0] FPU_data,    // Data from the FPU register to store in memory
    input logic [31:0] Register_dataToMem, // Data from the internal register file to store in memory
    input logic [31:0] ExtData,     // Data from external memory to read/write
    
    //outputs
    output logic [31:0] write_data, // Data to write to external memory
    output logic [31:0] ExtAddress, // Address to write to external memory   
    output logic [31:0] dataToCPU,  // Data to the register
    output logic freeze,            // Freeze signal to pause CPU operations during memory access
    output logic [1:0] rwi          // Read/Write/Idle control signal for external memory operations

);

always_comb begin
    if (busy) begin
        freeze = 1;
        write_data = 32'b0; // No data to write when busy
        ExtAddress = 32'b0; // No address to write to when busy
        dataToCPU = 32'b0; // No data to return to CPU when busy
        rwi = 2'b00; // Idle state when busy
    end else begin
        freeze = 0;
    if(memWrite) begin 
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
        rwi = 2'b10; //Read operation
        ExtAddress = ALU_address; // Use ALU address for memory operations
        write_data = 32'b0; // No data to write in read operation
        if (memOp == 4'd1) begin //
            dataToCPU = {{24{ExtData[7]}}, ExtData[7:0]}; // Read data from external memory
        end else if (memOp == 4'd2) begin
            dataToCPU = {{16{ExtData[15]}}, ExtData[15:0]}; // Read half-word from external memory
        end else if (memOp == 4'd3) begin // Read full word from external memory
            dataToCPU = ExtData; 
        end else if (memOp == 4'd4) begin // Read byte unsigned
            dataToCPU = {24'b0, ExtData[7:0]}; 
        end else if (memOp == 4'd5) begin // Read half-word unsigned
            dataToCPU = {16'b0, ExtData[15:0]};
        end else begin
            dataToCPU = 32'b0; // Default case, no valid operation
        end
    end else begin
        rwi = 2'b00; // Idle state
        write_data = 32'b0; // No data to write
        ExtAddress = 32'b0; // No address to write to
        dataToCPU = 32'b0; // No data to return to CPU
    end
    end
end
endmodule
