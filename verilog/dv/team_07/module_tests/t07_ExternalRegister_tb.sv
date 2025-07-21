`timescale 1ns / 1ps

module t07_ExternalRegister_tb;

    // Inputs
    logic clk;
    logic nrst;
    logic [31:0] ReadRegister;
    logic [31:0] write_data;
    logic ri;
    logic [31:0] SPIAddress; // Address for the SPI TFT

    // Outputs
    logic [31:0] read_data;
    logic ack_REG; // Acknowledge signal to the memory handler

    // Instantiate the Unit Under Test (UUT)
    t07_ExternalRegister uut (
        .clk(clk),
        .nrst(nrst),
        .ReadRegister(ReadRegister),
        .SPIAddress(SPIAddress),
        .write_data(write_data),
        .ri(ri),
        .read_data(read_data),
        .ack_REG(ack_REG)
    );
    // Clock generation
    always begin 
        clk = 0;
        #10; // Wait for 10 time units
        clk = 1;
        #10; // Wait for 10 time units
    end

    task spiAddress;
    
        SPIAddress = 32'd1; // Default address
        writeData();
        #10;
        SPIAddress = 32'd2; // Change address to 2
        writeData();
        #10;
        SPIAddress = 32'd3; // Change address to 3
        writeData();
        #10;
        SPIAddress = 32'd4; // Change address to 4
        writeData();
        #10;
        SPIAddress = 32'd5; // Change address to 5
        writeData();
        #10;
    endtask

    task writeData;
        write_data = 32'h12345678; // Change data to 12345678
        #20;
        write_data = 32'h87654321; // Change data to 87654321
        #20;
        write_data = 32'hAABBCCDD; // Change data to AABBCCDD
        #20;
        write_data = 32'hFFFFFFFF; // Change data to FFFFFFFF
        #10;
    endtask

    task readRegister;
        ReadRegister = 32'd1; // Read from address 1
        #20;
        ReadRegister = 32'd2; // Read from address 2
        #20;
        ReadRegister = 32'd3; // Read from address 3
        #20;
        ReadRegister = 32'd4; // Read from address 4
        #20;
        ReadRegister = 32'd5; // Read from address 5
        #20;
    endtask
    initial begin
        $dumpfile("t07_ExternalRegister.vcd");
        $dumpvars(0, t07_ExternalRegister_tb);
        
        // Initialize Inputs
        nrst = 0;
        ReadRegister = 32'h00000000;
        write_data = 32'h00000000;
        ri = 1'b0; // Idle state
        SPIAddress = 32'd0; // Initial address for SPI TFT
        // Wait for global reset to finish
        #10;
        nrst = 1; // Release reset
        #10; // Wait for a few clock cycles
        nrst = 0; // Set reset low again
        #10; // Wait for a few clock cycles
        // Test writing to a register
        spiAddress(); // Set SPI address
        
    
        // Check if the data was written correctly
        ri = 1'b1; // Read operation
        readRegister(); // Read from the registers
        #1; // Wait for a clock cycle
       $finish; // End simulation
    end
endmodule
    