`timescale 1ns / 1ps


module t07_cpu_memoryHandler_tb;

    // Inputs
    logic [3:0] memOp; // Memory operation type
    logic memWrite, memRead, memSource;
    logic [31:0] ALU_address, FPU_data, Register_dataToMem, ExtData;

    // Outputs
    logic [31:0] write_data, ExtAddress, dataToCPU;
    logic freeze;
    logic [1:0] rwi;

    // Instantiate the Unit Under Test (UUT)
    t07_cpu_memoryHandler uut (
        .memOp(memOp),
        .memWrite(memWrite),
        .memRead(memRead),
        .memSource(memSource),
        .ALU_address(ALU_address),
        .FPU_data(FPU_data),
        .Register_dataToMem(Register_dataToMem),
        .ExtData(ExtData),
        .write_data(write_data),
        .ExtAddress(ExtAddress),
        .dataToCPU(dataToCPU),
        .freeze(freeze),
        .rwi(rwi)
    );

    
    initial begin
        $dumpfile("t07_cpu_memoryHandler.vcd");
        $dumpvars(0, t07_cpu_memoryHandler_tb);
        // Initialize Inputs
        memWrite = 0;
        memRead = 0;
        memSource = 0;
        ALU_address = 32'h00000004;
        FPU_data = 32'h12345678;
        Register_dataToMem = 32'h87654321;
        ExtData = 32'b0000_0000_0000_1000_0000_1000_0000; // Example data from external memory
        memOp = 4'd3; // Assume a full word read operation

        // Wait for global reset to finish
        #10;
        
        
        // Test memory write operation
        memWrite = 1;
        memSource = 1; // Writing from FPU
        #10; 
        memWrite = 0; // Clear write signal
        memSource = 0; // Reset memSource
        #10; 
        memWrite = 1;
        #10; 
        memWrite = 0; // Clear write signal
        #10; 

        // Test memory read operation
        memRead = 1; // Test memory read operation
        memOp = 4'd1; // Change to byte signed
        #10;
        memOp = 4'd2; // Change to half-word signed
        #10;
        memOp = 4'd3; // change to full word read
        #10;
        memOp = 4'd4; // Change to byte unsigned
        #10;
        memOp = 4'd5; // Change to half-word unsigned
        #10;
           
        memRead = 0; // Clear read signal
        #10;

        $finish;
    end
endmodule