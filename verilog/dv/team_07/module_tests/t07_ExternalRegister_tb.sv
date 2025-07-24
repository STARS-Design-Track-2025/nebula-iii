`timescale 1ns / 1ps

module t07_ExternalRegister_tb;

    // Inputs
    logic clk;
    logic nrst;
    logic [4:0] ReadRegister;
    logic [31:0] write_data;
    logic ri;
    logic [4:0] SPIAddress; // Address for the SPI TFT

    // Outputs
    logic [31:0] read_data;
    logic ack_REG; // Acknowledge signal to the memory handler
    logic [1:0] rwi_in; // Read/Write/Idle signal from the memory handler
    logic [31:0] ExtData_out; // Data to internal memory
    logic [31:0] addr_in; // Address for the external register
    logic [31:0] inst; // Instruction to fetch module in CPU
    logic [31:0] writeData_outTFT; // Data to write to instruction/Data memory
    logic [31:0] addr_outTFT; // Address to write to SPI TFT
    logic wi_out; // Write or idle to SPI TFT
    logic [1:0] rwi_out; // Read/Write/Idle to instruction/Data memory
    logic [31:0] addr_out; // Address to instruction/Data memory
    logic [31:0] writeData_out; // Data to write to instruction/Data memory
    t07_MMIO mmio (
        .memData_in(32'b0), // Not used in this test
        .rwi_in(rwi_in), // Not used in this test
        .ExtData_in(32'b0), // Not used in this test
        .busy_o(1'b0), // Not used in this test
        .regData_in(read_data),
        .ack_REG(ack_REG),
        .ack_TFT(1'b0), // Not used in this test
        .addr_in(addr_in), //address for the external register
        .ri_out(ri),
        .addr_outREG(ReadRegister), // Address to external register
        .ExtData_out(ExtData_out), 
        .writeInstruction_out(inst), // Not used in this test
        .writeData_outTFT(writeData_outTFT), // Not used in this test
        .addr_outTFT(addr_outTFT), // Not used in this test
        .wi_out(wi_out), // Not used in this test
        .rwi_out(rwi_out), // Not used in this test
        .addr_out(addr_out), // Not used in this test
        .writeData_out(writeData_out) // Not used in this test
    );
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

    logic [7:0] ESP_in; // Input from the ESP32
    logic SCLK_out; // Clock signal for the ESP32
   
    t07_SPI_ESP32 spi (
        .ESP_in(ESP_in), 
        .clk(clk),
        .nrst(nrst),
        .SPI_Address(SPIAddress),
        .dataForExtReg(write_data),
        .SCLK_out(SCLK_out) // Not used in this test
    );

    // Clock generation
    always begin 
        clk = 0;
        #5; // Wait for 10 time units
        clk = 1;
        #5; // Wait for 10 time units
    end

    task ESP_in_task; begin
       // @(posedge clk)
        ESP_in = 8'hAA; // Default value
        #12;
        ESP_in = 8'hBB; // Example data
        #10;
        ESP_in = 8'hCC; // Another example data
        #10;
        ESP_in = 8'hDD; // Reset value
        #10;
        ESP_in = 8'hEE;
        #10;
        ESP_in = 8'hFF; // Final example data
        #10; // Wait for a clock cycle
        ESP_in = 8'h01; // Reset value
        #10; // Wait for a clock cycle
        ESP_in = 8'hAA; // Default value
        #10;
        ESP_in = 8'hBB; // Example data
        #10;
        ESP_in = 8'hCC; // Another example data
        #10;
        ESP_in = 8'hDD; // Reset value
        #10;
        ESP_in = 8'hEE;
        #10;
        ESP_in = 8'hFF; // Final example data
        #10; // Wait for a clock cycle
        ESP_in = 8'h01; // Reset value
        #10; // Wait for a clock cycle
        ESP_in = 8'hAA; // Default value
        #10;
        ESP_in = 8'hBB; // Example data
        #10;
        ESP_in = 8'hCC; // Another example data
            rwi_in =2'b10; // Set to write operation
        #10;
        ESP_in = 8'hDD; // Reset value
        #10;
        ESP_in = 8'hEE;
        #10;
        ESP_in = 8'hFF; // Final example data
        #10; // Wait for a clock cycle
        ESP_in = 8'h01; // Reset value
        #10; // Wait for a clock cycle
        ESP_in = 8'hAA; // Default value
        #10;
        ESP_in = 8'hBB; // Example data
        #10;
        ESP_in = 8'hCC; // Another example data
        #10;
        ESP_in = 8'hDD; // Reset value
        #10;
        ESP_in = 8'hEE;
        #10;
        ESP_in = 8'hFF; // Final example data
        #10; // Wait for a clock cycle
        ESP_in = 8'h01; // Reset value
        #10; // Wait for a clock cycle
    end
    endtask

    // task spiAddress;
    //     SPIAddress = 32'd1; // Default address
    //     write_data = 32'h12345678;
    //     #20;
    //     SPIAddress = 32'd2; // Change address to 2
    //     write_data = 32'h87654321;
    //     #20;
    //     SPIAddress = 32'd3; // Change address to 3
    //     write_data = 32'hAABBCCDD;
    //     #20;
    //     SPIAddress = 32'd4; // Change address to 4
    //     write_data = 32'hFFFFFFFF; // Change data to FFFFFFFF
    //     #20;
    //     SPIAddress = 32'd5; // Change address to 5
    //     write_data = 32'hFF00AABB;
    //     #20;
    // endtask


    // task readRegister;
    //     ReadRegister = 5'd1; // Read from address 1
    //     #20;
    //     ReadRegister = 5'd2; // Read from address 2
    //     #20;
    //     ReadRegister = 5'd3; // Read from address 3
    //     #20;
    //     ReadRegister = 5'd4; // Read from address 4
    //     #20;
    //     ReadRegister = 5'd5; // Read from address 5
    //     #20;
    // endtask

    initial begin
        $dumpfile("t07_ExternalRegister.vcd");
        $dumpvars(0, t07_ExternalRegister_tb);
        
        // Initialize Inputs
        rwi_in = 2'b11; // Idle state for read/write/idle
        addr_in = 32'd8193;
        nrst = 1;
        // ReadRegister = 5'h00000000;
        //write_data = 32'h00000000;
        //SPIAddress = 5'd0; // Initial address for SPI TFT
        // Wait for global reset to finish
        #2;
        nrst = 0; // Release reset
        #1; // Wait for a few clock cycles
        nrst = 1; // Set reset low again 
        // Test writing to a register
        // spiAddress(); // Set SPI address
        
        // Check if the data was written correctly
        ESP_in_task(); // Read from the registers
        #5;

        // readRegister(); // Read from the registers
        #10;
    
        #1; // Wait for a clock cycle
       $finish; // End simulation
    end
endmodule
    