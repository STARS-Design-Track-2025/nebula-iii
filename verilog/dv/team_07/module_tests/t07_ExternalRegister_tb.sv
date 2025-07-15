`timescale 1ns / 1ps

module t07_ExternalRegister_tb;

    // Inputs
    logic clk;
    logic rst;
    logic [31:0] ReadRegister;
    logic [31:0] write_data;
    logic [1:0] rwi;

    // Outputs
    logic [31:0] read_data;

    // Instantiate the Unit Under Test (UUT)
    t07_ExternalRegister uut (
        .clk(clk),
        .rst(rst),
        .ReadRegister(ReadRegister),
        .write_data(write_data),
        .rwi(rwi),
        .read_data(read_data)
    );
    // Clock generation
    always begin 
        clk = 1;
        #10; // Wait for 10 time units
        clk = 0;
        #10; // Wait for 10 time units
    end

    initial begin
        $dumpfile("t07_ExternalRegister.vcd");
        $dumpvars(0, t07_ExternalRegister_tb);
        
        // Initialize Inputs
        rst = 1;
        ReadRegister = 32'h00000000;
        write_data = 32'h00000000;
        rwi = 2'b00; // Idle state

        // Wait for global reset to finish
        #10;
        rst = 0; // Release reset

        // Test writing to a register
        ReadRegister = 5; // Register address to write to
        write_data = 32'h12345678; // Data to write
        rwi = 2'b01; // Write operation
        #10; // Wait for a clock cycle

        // Check if the data was written correctly
        rwi = 2'b10; // Read operation
        #10; // Wait for a clock cycle
        if (read_data !== write_data) $display("Write test failed: expected %h, got %h", write_data, read_data);

        // Test reading from a register
        ReadRegister = 5; // Register address to read from
        rwi = 2'b10; // Read operation
        #10; // Wait for a clock cycle

        if (read_data !== write_data) $display("Read test failed: expected %h, got %h", write_data, read_data);

        $finish; // End simulation
    end
endmodule
    