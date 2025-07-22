`timescale 1ns/100ps
module t07_program_counter_tb;
    // Inputs
    logic clk;
    logic nrst;
    logic freeze;
    logic forceJump;
    logic [2:0] func3; // Function code for the jump operation
    logic condJump;
    logic [6:0] ALU_flags;
    logic [31:0] JumpDist;

    // Outputs
    logic [31:0] programCounter;
    logic [31:0] linkAddress;

    //fetch
    logic busy_o;
    logic [31:0] Instr_out, PC_out, inst;

    // Instantiate the Unit Under Test (UUT)
    t07_program_counter pc(
        .clk(clk), 
        .nrst(nrst), 
        .freeze(busy_o),
        .forceJump(forceJump), 
        .condJump(condJump), 
        .ALU_flags(ALU_flags), 
        .JumpDist(JumpDist), 
        .programCounter(programCounter), 
        .linkAddress(linkAddress),
        .func3(func3)
    );

    t07_fetch fetch0(.clk(clk), .nrst(nrst), .busy_o(busy_o), .ExtInstruction(inst), .programCounter(programCounter), .Instruction(Instr_out), .PC_out(PC_out));

    // Clock generation
    always begin 
        clk = 0;
        #5; // Wait for 10 time units
        clk = 1;
        #5; // Wait for 10 time units
    end

    //test busy signal (coming in from MMIO)
    always begin
        #20
        busy_o = ~busy_o;
    end

    task reset(); begin
        nrst = '1;
        #1
        nrst = '0;
        #3
        nrst = '1;
    end
    endtask

    /*
    task JumpDist_task; begin
        JumpDist = 32'd00000004; // Default jump distance
        #10;
        JumpDist = 32'b1111_1111_1111_1111_1111_1111_1111_1100; // Set jump distance to negative 4
        #10;
        JumpDist = 32'd00000008; // Set jump distance to 8
        #10;
        JumpDist = 32'b1111_1111_1111_1111_1111_1111_1111_1000; // Set jump distance to negative 8
        #10;
        JumpDist = 32'd00000012; // Set jump distance to 12
        #10;
        JumpDist = 32'b1111_1111_1111_1111_1111_1111_1111_0100; // Set jump distance to negative 12
        #10;
        JumpDist = 32'd00000016; // Set jump distance to 16
        #10;
        JumpDist = 32'b1111_1111_1111_1111_1111_1111_1111_0000; // Set jump distance to negative 16
        #10;
        JumpDist = 32'd0; // Reset jump distance
        #10; // Wait for a clock cycle
    end
    endtask */

    // Task to set ALU flags for different conditions
    /*
    task ALU_flags_task; begin
        ALU_flags = 7'b0000000; // No flags set
        funct3_task();
        #10;
        ALU_flags = 7'b1000000; // Set condition met flag
        funct3_task();
        #10;
        ALU_flags = 7'b0100000; // Set condition for not equal
        funct3_task();
        #10;
        ALU_flags = 7'b0010000; // Set condition for less than
        funct3_task();
        #10;
        ALU_flags = 7'b0001000; // Set condition for less than or equal
        funct3_task();
        #10;
        ALU_flags = 7'b0000100; // Set condition for greater than
        funct3_task();
        #10;
        ALU_flags = 7'b0000010; // Set condition for greater than or equal
        funct3_task();
        #10;
        ALU_flags = 7'b0000001; // Set condition for unsigned less than
        funct3_task();
        #10;
        ALU_flags = 7'b0000000; // Reset flags
        func3 = 3'b000; // Reset function code
        condJump = 0; // Reset conditional jump
        #10; // Wait for a clock cycle
    end
    endtask
    */

    /*
    // Task to set funct3 values for different operations
    task funct3_task; begin
        func3 = 'b000;
        JumpDist_task(); // Set jump distance for each funct3
        #10;
        func3 = 'b001;
        JumpDist_task(); // Set jump distance for each funct3
        #10;
        func3 = 'b010;
        JumpDist_task(); // Set jump distance for each funct3
        #10;
        func3 = 'b011;
        JumpDist_task(); // Set jump distance for each funct3
        #10;
        func3 = 'b100;
        JumpDist_task(); // Set jump distance for each funct3
        #10;
        func3 = 'b101;
        JumpDist_task(); // Set jump distance for each funct3
        #10;
        func3 = 'b110;
        JumpDist_task(); // Set jump distance for each funct3
        #10;
        func3 = 'b111;
        JumpDist_task(); // Set jump distance for each funct3
    end
    endtask */

    always begin
        @(posedge clk); 
        inst = 'b00000000001100010000000010110011; //add x1. x2, x3
        JumpDist = '0;
        condJump = '0;
        forceJump = 0;
        #30
        inst = 'b01000000001100010000000010110011; //sub x1, x2, x3
        JumpDist = '0;
        condJump = '0;
        forceJump = 0;
        #30
        inst = 'b00000000001000001000001001100011; //beq, x1, x2, 5
        JumpDist = '0;
        condJump = '1;
        forceJump = 0;
        #30
        inst = 'b00000000010000000000000011101111; //jal x1, 5
        JumpDist = 32'd5;
        forceJump = 1;
        forceJump = 0;
        //ALU result
        #30
        inst = 'b00000000001100010010000010110011; //slt x1, x2
        JumpDist = '0;
        condJump = '0;
        forceJump = 0;
        #30
        inst = 'b00000000011000010011000010010011; //sltiu x1, x2, 6
        JumpDist = '0;
        condJump = '0;
        forceJump = 0;
        #30
        inst = 'b00000000011000010100000010010011; //xori x1, x2, 6
        JumpDist = '0;
        condJump = '0;
        forceJump = 0;
        #30
        inst = 'b00000000100100010110000010010011; //ori x1, x2, 9
        JumpDist = '0;
        condJump = '0;
        forceJump = 0;
        #30
        inst = 'b00000000100100010111000010010011; //andi x1, x2, 9
        JumpDist = '0;
        condJump = '0;
        forceJump = 0;
        #30
        inst = 'b00000000100100010000000010010011; //addi x1, x2, 9
        JumpDist = '0;
        condJump = '0;
        forceJump = 0;
    end


    initial begin
        $dumpfile("t07_program_counter.vcd");
        $dumpvars(0, t07_program_counter_tb);
        // Initialize Inputs
        /*nrst = 1; // Start with reset high
        forceJump = 0;
        condJump = 0;
        ALU_flags = 7'b000000; // No flags set
        JumpDist = 32'h00000000;
        func3 = 3'b000; // Default function code */

        //testing pc & fetch together
        busy_o = 0;
        reset();



        /*
        // Wait for global reset to finish
        #10;
        
        // Release reset
        nrst = 0;
        #10; // Wait for a few clock cycles
        nrst = 1; // Set reset high again
        #10; // Wait for a few clock cycles
        #10; // Wait for a clock cycle
        #15; // Wait for a clock cycle
        
        // Test case: Force jump
        forceJump = 1;
        JumpDist_task(); // Set jump distance
        #10;
        forceJump = 0; // Clear force jump
        #10;
        */
        // // Test case: Conditional jump with branch for beq
        // condJump = 1;
        // ALU_flags = 7'b1000000; // Set condition met flag
        // #5;
        // #5;
        // condJump = 0; // Clear conditional jump
        // ALU_flags = 7'b0000000; // Reset flags
        // #10;

        // Test case: Conditional jump with branch for bne
        //condJump = 1; // Set conditional jump again
        //ALU_flags_task(); // Set flags and func3 for different condition

        //#10;
        #1; 
        $finish;
    end

endmodule

