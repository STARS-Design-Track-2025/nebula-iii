`timescale 1ns / 1ps
module t07_fetch_tb;

    // Testbench signals
    logic clk;
    logic nrst;
    logic [31:0] ExtInstruction;
    logic [31:0] programCounter;
    logic [31:0] Instruction;
    logic [31:0] PC_out;

    // Instantiate the t07_fetch module
    t07_fetch uut (
        .clk(clk),
        .nrst(nrst),
        .ExtInstruction(ExtInstruction),
        .programCounter(programCounter),
        .Instruction(Instruction),
        .PC_out(PC_out)
    );

    // Clock generation
    always begin 
        clk = 1;
        #5; // Wait for 10 time units
        clk = 0;
        #5; // Wait for 10 time units
    end

    // Test stimulus
    initial begin
        $dumpfile("t07_fetch.vcd");
        $dumpvars(0, t07_fetch_tb);
        
        ExtInstruction = 32'h12345678; // Example instruction
        programCounter = 32'h00000000; // Initial program counter value
        nrst = 1; // Reset the module
        #10; // Wait for a few clock cycles
        nrst = 0; // Release reset
        #10; // Wait for a few clock cycles

        // Change the instruction and program counter
        ExtInstruction = 32'h87654321;
        programCounter = 32'h00000004;

        #10; // Wait for a few more clock cycles
        #1;
        $finish; // End simulation
    end

endmodule