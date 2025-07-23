`timescale 1ps/1ps
module t07_SPI_ESP32_tb;    
    // Testbench signals
    logic [7:0] ESP_in;
    logic clk, nrst;
    logic [31:0] SPI_Address; // Address for the external register
    logic [31:0] dataForExtReg; // Data to write to the external register
    logic SCLK_out; // Clock signal for the ESP32

    // Instantiate the t07_SPI_ESP32 module
    t07_SPI_ESP32 uut (
        .ESP_in(ESP_in),
        .clk(clk),
        .nrst(nrst),
        .SPI_Address(SPI_Address),
        .dataForExtReg(dataForExtReg),
        .SCLK_out(SCLK_out)
    );

    // Clock generation
    always begin 
        clk = 0;
        #5; // Wait for 10 time units
        clk = 1;
        #5; // Wait for 10 time units
    end

    task ESP_in_task; begin
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
        ESP_in = 8'h00; // Reset value
        #10; // Wait for a clock cycle
    end
    endtask

    initial begin
        $dumpfile("t07_SPI_ESP32.vcd");
        $dumpvars(0, t07_SPI_ESP32_tb);

        // Initialize inputs
        nrst = 1'b0; // Reset the system
        ESP_in = 8'h00; // Initial value for ESP input
        #10; // Wait for a few time units
        nrst = 1'b1; // Release reset
        #5;
        ESP_in_task; // Call the task to generate ESP input data
        ESP_in_task; // Call the task again to generate more ESP input data
        #10;
        $finish; // End simulation
    end
endmodule
