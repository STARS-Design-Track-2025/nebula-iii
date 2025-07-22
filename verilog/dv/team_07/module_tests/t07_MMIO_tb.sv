`timescale 1ps/1ps
module t07_MMIO_tb;
    // Testbench signals
    logic [31:0] memData_in;
    logic [1:0] rwi_in;
    logic [31:0] inst;
    logic [31:0] ExtData_in;
    logic busy_o;
    logic [31:0] regData_in;
    logic ack_REG;
    logic ack_TFT;
    logic [31:0] addr_in;

    // Outputs
    logic ri_out;
    logic [31:0] addr_outREG;
    logic [31:0] ExtData_out;
    logic busy;
    logic [31:0] writeInstruction_out;
    logic [31:0] writeData_outTFT;
    logic [31:0] addr_outTFT;
    logic wi_out;
    logic [1:0] rwi_out;
    logic [31:0] addr_out;
    logic [31:0] writeData_out;

    // Instantiate the t07_MMIO module
    t07_MMIO uut (
        .memData_in(memData_in),
        .rwi_in(rwi_in),
        .ExtData_in(ExtData_in),
        .busy_o(busy_o),
        .regData_in(regData_in),
        .ack_REG(ack_REG),
        .ack_TFT(ack_TFT),
        .addr_in(addr_in),
        .ri_out(ri_out),
        .addr_outREG(addr_outREG),
        .ExtData_out(ExtData_out),
        .busy(busy),
        .writeInstruction_out(writeInstruction_out),
        .writeData_outTFT(writeData_outTFT),
        .addr_outTFT(addr_outTFT),
        .wi_out(wi_out),
        .rwi_out(rwi_out),
        .addr_out(addr_out),
        .writeData_out(writeData_out)
    );


    // Test stimulus
    initial begin
        $dumpfile("t07_MMIO.vcd");
        $dumpvars(0, t07_MMIO_tb);

        // Initialize inputs
        memData_in = 32'h00000000; // Example data
        rwi_in = 2'b11; // Idle state
        inst = 32'h00000000; // Example instruction
        ExtData_in = 32'h00000000; // Example external data
        busy_o = 1'b0; // Not busy
        regData_in = 32'h00000000; // Example register data
        ack_REG = 1'b0; // Not acknowledged
        ack_TFT = 1'b0; // Not acknowledged
        addr_in = 32'h00000000; // Example address

        #10; // Wait for a few time units

        // Test 1: Write to SPI TFT
        addr_in = 32'd2000; // Address for SPI TFT
        rwi_in = 2'b01; // Write operation
        memData_in = 32'hAABBCCDD; // Example data to write
        ack_TFT = 1'b1; // Acknowledge write
        #10; // Wait for a few time units
        ack_TFT = 1'b0; // Clear acknowledge
        #5;
        
        //test 2: Write to instruction/Data memory
        addr_in = 32'd3000; // Address for instruction/Data memory
        rwi_in = 2'b01; // Write operation
        memData_in = 32'h11223344; // Example data to write
        busy_o = 1'b1; // Set busy signal
        #10; // Wait for a few time units
        busy_o = 1'b0; // Clear busy signal
        #5;

        //test 3: read from external register
        addr_in = 32'd500; // Address for external register
        rwi_in = 2'b10; // Read operation
        regData_in = 32'h55667788; // Example data from external register
        ack_REG = 1'b1; // Acknowledge read
        #10; // Wait for a few time units
        ack_REG = 1'b0; // Clear acknowledge
        #5;

        //test 4: read from Data memory
        addr_in = 32'd6000; // Address for Data memory
        rwi_in = 2'b10; // Read operation
        ExtData_in = 32'h99AABBCC; // Example data from Data memory
        busy_o = 1'b1; // Set busy signal
        #10; // Wait for a few time units   
        busy_o = 1'b0; // Clear busy signal
        #5;

        //test 5: write instruction to fetch module
        addr_in = 32'd9000; // Address for instruction to fetch module
        rwi_in = 2'b11; // Idle state
        inst = 32'hDEADBEEF; // Example instruction
        busy_o = 1'b1; // Set busy signal
        #10; // Wait for a few time units
        busy_o = 1'b0; // Clear busy signal
        #5;
    end
endmodule
