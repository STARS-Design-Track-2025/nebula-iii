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
        clk = 1;
        #10; // Wait for 10 time units
        clk = 0;
        #10; // Wait for 10 time units
    end

    initial begin
        $dumpfile("t07_program_counter.vcd");
        $dumpvars(0, t07_program_counter_tb);
        // Initialize Inputs
        clk = 0;
        rst = 1; // Start with reset high
        freeze = 0;
        forceJump = 0;
        condJump = 0;
        ALU_flags = 7'b000000; // No flags set
        JumpDist = 32'b0;
        func3 = 3'b000; // Default function code

        // Wait for global reset to finish
        #100;
        
        // Release reset
        rst = 0;

        freeze = 1; // Freeze the CPU operations
        #10; // Wait for a clock cycle
        freeze = 0; // Unfreeze the CPU operations  
        #10; // Wait for a clock cycle

        // Test case: Normal operation
        #10;
        clk = 1; // Rising edge
        #10;
        clk = 0; // Falling edge

        // Test case: Force jump
        forceJump = 1;
        JumpDist = 32'h00000008; // Jump to next instruction
        #10;
        clk = 1; // Rising edge
        #10;
        clk = 0; // Falling edge
        forceJump = 0; // Clear force jump
        #20;

        // Test case: Conditional jump
        condJump = 1;
        ALU_flags = 7'b1000000; // Set condition met flag
        #10;
        JumpDist = 32'h00000008; // Jump to instruction at offset 8    
        clk = 1; // Rising edge
        #10;
        clk = 0; // Falling edge
        // condJump = 0; // Clear conditional jump
        // ALU_flags = '0; // Reset flags
        #10;
         #1; $finish;
    end

endmodule

