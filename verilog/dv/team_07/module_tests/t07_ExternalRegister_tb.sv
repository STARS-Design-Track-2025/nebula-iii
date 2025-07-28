`timescale 1ns / 1ps

module t07_ExternalRegister_tb;

    // Inputs
    logic clk;
    logic nrst;
    logic [4:0] ReadRegister;
    logic [31:0] write_data;
    logic ri;
    logic [4:0] SPIAddress; // Address for the SPI TFT
    logic busy;
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
    logic read, write; // Read/Write/Idle to instruction/Data memory
    logic [31:0] addr_out; // Address to instruction/Data memory
    logic [31:0] writeData_out; // Data to write to instruction/Data memory
    logic fetchRead_out, addrControl_out, fetchRead_in, addrControl_in;
    logic ChipSelectIn, ChipSelectOut;
    t07_MMIO mmio (
        .memData_in(32'b0), // Not used in this test
        .rwi_in(rwi_in), // Not used in this test
        .ExtData_in(32'b0), // Not used in this test
        .busy_o(1'b0), // Not used in this test
        .fetchRead_in(fetchRead_in),
        .addrControl_in(addrControl_in),
        .regData_in(read_data),
        .ack_REG(ack_REG),
        .ChipSelReg(ChipSelectIn),
        .ack_TFT(1'b0), // Not used in this test
        .addr_in(addr_in), //address for the external register
        .ri_out(ri),
        .addr_outREG(ReadRegister), // Address to external register
        .ExtData_out(ExtData_out),
        .busy(busy), 
        .writeInstruction_out(inst), // Not used in this test
        .writeData_outTFT(writeData_outTFT), // Not used in this test
        .addr_outTFT(addr_outTFT), // Not used in this test
        .wi_out(wi_out), // Not used in this test
        .read(),
        .write(),
        .addr_out(addr_out), // Not used in this test
        .fetchRead_out(fetchRead_out),
        .addrControl_out(addrControl_out),
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
        .ChipSelect(ChipSelectIn),
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
        .ChipSelectIn(ChipSelectIn),
        .ChipSelectOut(ChipSelectOut),
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
        ESP_in = 8'h01; // Reset value // Wait for a clock cycle
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
        #10; // Wait for a clock cycle // Wait for a clock cycle
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
         // Wait for a clock cycle
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
        ESP_in = 8'h00;
        addr_in = 32'd1024;
        #10;
        #10;
        #10
        rwi_in = 2'b10;
        addr_in = 32'd1025;
            #10;
            #10;
            rwi_in = 2'b01;
        #10
        rwi_in = 2'b10;
            addr_in = 32'd1026;
            #10;
            #10;
            rwi_in = 2'b01;
        #10
        rwi_in = 2'b10;
            addr_in = 32'd1027;
            #10;
            #10;
            rwi_in = 2'b01;
        #10
        rwi_in = 2'b10;
            addr_in = 32'd1028;
            #10;
            #10;
            rwi_in = 2'b01;
        #10
        rwi_in = 2'b10;
            addr_in = 32'd1029;
            #10;
            #10;
            rwi_in = 2'b01;
        #10
        rwi_in = 2'b10;
            addr_in = 32'd1030;
            #10;
            #10;
            rwi_in = 2'b01;
        #10
        rwi_in = 2'b10;
            addr_in = 32'd1031;
            #10;
            #10;
            rwi_in = 2'b01;
        #10
        rwi_in = 2'b10;
            addr_in = 32'd1032;
            #10;
            #10;
            rwi_in = 2'b01;
        #10
        rwi_in = 2'b10;
            addr_in = 32'd1033;
            #10;
            #10;
            rwi_in = 2'b01;
        #10
        rwi_in = 2'b10;
            addr_in = 32'd1034;
            #10;
            #10;
            rwi_in = 2'b01;
        #10
        rwi_in = 2'b10;
            addr_in = 32'd1035;
            #10;
            #10;
            rwi_in = 2'b01;
        #10
        rwi_in = 2'b10;
            addr_in = 32'd1036;
            #10;
            #10;
            rwi_in = 2'b01;
        #10
        rwi_in = 2'b10;
            addr_in = 32'd1037;
            #10;
            #10;
            rwi_in = 2'b01;
        #10
        rwi_in = 2'b10;
            addr_in = 32'd1038;
            #10;
            #10;
            rwi_in = 2'b01;
        #10
        rwi_in = 2'b10;
            addr_in = 32'd1039;
            #10;
            #10;
            rwi_in = 2'b01;
        #10
        rwi_in = 2'b10;
            addr_in = 32'd1040;
            #10;
            #10;
            rwi_in = 2'b01;
        #10
        rwi_in = 2'b10;
            addr_in = 32'd1041;
            #10;
            #10;
            rwi_in = 2'b01;
        #10
        rwi_in = 2'b10;
            addr_in = 32'd1042;
            #10;
            #10;
            rwi_in = 2'b01;
        #10
        rwi_in = 2'b10;
            addr_in = 32'd1043;
            #10;
            #10;
            rwi_in = 2'b01;
        #10
        rwi_in = 2'b10;
            addr_in = 32'd1044;
            #10;
            #10;
            rwi_in = 2'b01;
        #10
        rwi_in = 2'b10;
            addr_in = 32'd1045;
            #10;
            #10;
            rwi_in = 2'b01;
        #10
        rwi_in = 2'b10;
            addr_in = 32'd1046;
            #10;
            #10;
            rwi_in = 2'b01;
        #10
        rwi_in = 2'b10;
            addr_in = 32'd1047;
            #10;
            #10;
            rwi_in = 2'b01;
        #10
        rwi_in = 2'b10;
            addr_in = 32'd1048;
            #10;
            #10;
            rwi_in = 2'b01;
        #10
        rwi_in = 2'b10;
            addr_in = 32'd1049;
            #10;
            #10;
            rwi_in = 2'b01;
        #10
        rwi_in = 2'b10;
            addr_in = 32'd1050;
            #10;
            #10;
            rwi_in = 2'b01;
        #10
        rwi_in = 2'b10;
            addr_in = 32'd1051;
            #10;
            #10;
            rwi_in = 2'b01;
        #10
        rwi_in = 2'b10;
            addr_in = 32'd1052;
            #10;
            #10;
            rwi_in = 2'b01;
        #10
        rwi_in = 2'b10;
            addr_in = 32'd1053;
            #10;
            #10;
            rwi_in = 2'b01;
        #10
        rwi_in = 2'b10;
            addr_in = 32'd1054;
            #10;
            #10;
            rwi_in = 2'b01;
        #10
        rwi_in = 2'b10;
            addr_in = 32'd1055;
            #10;
            #10;
            rwi_in = 2'b01;
            ESP_in = 8'hFF; // Final example data
        #10
        rwi_in = 2'b10;
            addr_in = 32'd1056;        
        
        
        ESP_in = 8'h01; // Reset value // Wait for a clock cycle
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
        #10; // Wait for a clock cycle // Wait for a clock cycle
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
         // Wait for a clock cycle
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
        #10; // Wait for a clock cycleESP_in = 8'hAA; // Default value
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
        ESP_in = 8'h01; // Reset value // Wait for a clock cycle
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
        #10; // Wait for a clock cycle // Wait for a clock cycle
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
         // Wait for a clock cycle
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
        ESP_in = 8'h01; // Reset value // Wait for a clock cycle
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
        #10; // Wait for a clock cycle // Wait for a clock cycle
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
         // Wait for a clock cycle
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
        ESP_in = 8'h01; // Reset value // Wait for a clock cycle
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
        #10; // Wait for a clock cycle // Wait for a clock cycle
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
         // Wait for a clock cycle
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
        ESP_in = 8'h01; // Reset value // Wait for a clock cycle
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
        #10; // Wait for a clock cycle // Wait for a clock cycle
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
         // Wait for a clock cycle
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
        ESP_in = 8'h01; // Reset value // Wait for a clock cycle
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
        #10; // Wait for a clock cycle // Wait for a clock cycle
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
         // Wait for a clock cycle
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
        ESP_in = 8'h01; // Reset value // Wait for a clock cycle
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
        #10; // Wait for a clock cycle // Wait for a clock cycle
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
         // Wait for a clock cycle
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
        ESP_in = 8'h01; // Reset value // Wait for a clock cycle
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
        #10; // Wait for a clock cycle // Wait for a clock cycle
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
         // Wait for a clock cycle
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
        ESP_in = 8'h01; // Reset value // Wait for a clock cycle
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
        #10; // Wait for a clock cycle // Wait for a clock cycle
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
         // Wait for a clock cycle
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
        rwi_in = 2'b00; // Idle state for read/write/idle
        addr_in = 32'd1024;
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
    