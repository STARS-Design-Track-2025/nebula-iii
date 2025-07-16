`timescale 1ns/100ps
module t07_program_counter_tb;
    // Inputs
    logic clk;
    logic rst;
    logic freeze;
    logic forceJump;
    logic [2:0] func3; // Function code for the jump operation
    logic condJump;
    logic [6:0] ALU_flags;
    logic [31:0] JumpDist;

    // Outputs
    logic [31:0] programCounter;
    logic [31:0] linkAddress;

    // Instantiate the Unit Under Test (UUT)
    t07_program_counter pc(
        .clk(clk), 
        .rst(rst), 
        .freeze(freeze),
        .forceJump(forceJump), 
        .condJump(condJump), 
        .ALU_flags(ALU_flags), 
        .JumpDist(JumpDist), 
        .programCounter(programCounter), 
        .linkAddress(linkAddress),
        .func3(func3)
    );
    // Clock generation
    always begin 
        clk = 0;
        #5; // Wait for 10 time units
        clk = 1;
        #5; // Wait for 10 time units
    end

    initial begin
        $dumpfile("t07_program_counter.vcd");
        $dumpvars(0, t07_program_counter_tb);
        // Initialize Inputs
        rst = 1; // Start with reset high
        freeze = 0;
        forceJump = 0;
        condJump = 0;
        ALU_flags = 7'b000000; // No flags set
        JumpDist = 32'h00000008;
        func3 = 3'b000; // Default function code

        // Wait for global reset to finish
        #10;
        
        // Release reset
        rst = 0;

        #10; // Wait for a clock cycle
        #15; // Wait for a clock cycle
        // Test case: Force jump
        forceJump = 1;
        #5;
        forceJump = 0; // Clear force jump
        #15;

        // Test case: Conditional jump
        condJump = 1;
        ALU_flags = 7'b1000000; // Set condition met flag
        #5;
        condJump = 0; // Clear conditional jump
        ALU_flags = 7'b0000000; // Reset flags
        #15;

        freeze = 1;
        #5;
        freeze = 0; // Release freeze
        #10;
         #1; $finish;
    end

endmodule

