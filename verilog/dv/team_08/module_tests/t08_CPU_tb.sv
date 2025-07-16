`timescale 1ms/10ps
module t08_CPU_tb;
    logic clk = 0, nRst;                  //Clock and active-low reset. 
    logic [31:0] data_in;             //memory to memory handler: data in
    logic [31:0] instruction;         //memory to CPU: instruction 
    logic [31:0] data_out;           //memory handler to mmio: data outputted 
    logic [31:0] mem_address;        //memory handler to mmio: address in memory
    logic read_out, write_out;        //memory handler to mmio: read and write enable


    always #1 clk = ~clk;

    t08_CPU t08_CPU1(.clk(clk), .nRst(nRst), .data_in(data_in), .instruction(instruction), 
                    .data_out(data_out), .mem_address(mem_address), .read_out(read_out), .write_out(write_out));

    typedef enum logic [2:0] {
        SETUP,
        R_TYPE,
        I_TYPE,
        S_TYPE,
        B_TYPE,
        U_TYPE,
        J_TYPE
    } instruction_types;

    //To help keep track of which test is being done in the waveforms. 
    instruction_types test_phase = SETUP; 
    int subtestNumber = 0; 

    task do_branch_instruction(logic [2:0] func3, logic [4:0] rs2, logic [4:0] rs1, logic [12:0] imm);

        instruction = {imm[12], imm[10:5], rs2, rs1, func3, imm[4:1], imm[11], 7'b1100011};

    endtask

    task do_jump_instruction(logic [20:0] imm, logic [4:0] rd);

        instruction = {imm[20], imm[10:1], imm[11], imm[19:12], rd, 7'b1101111};

    endtask

    initial begin

        $dumpfile("t08_CPU.vcd"); 
        $dumpvars(0, t08_CPU_tb);

        nRst = 0; #1;
        nRst = 1;
        data_in = 0;

        /*
        Setup
        */

        @ (negedge clk);
        test_phase = SETUP;

        //ADDI: store (3 + r1) in r2
        //r2 should now be 3
        subtestNumber = 1;
        instruction = 32'b000000000011_00001_000_00010_0010011;
        
        //addi: immediate(5) + r1(0) => r4, r4 = 5
        @ (negedge clk);
        //ADDI: store (5 + r1) in r4
        //r4 should now be 5
        subtestNumber = 2;
        instruction = 32'b000000000101_00001_000_00100_0010011;

        /*
        Register command tests
        */
        
        @ (negedge clk);
        test_phase = R_TYPE;

        //ADD: store (r2 + r4) in r3
        //r3 should now be 8
        subtestNumber = 1;
        instruction = 32'b0000000_00010_00100_000_00011_0110011;
        
        @ (negedge clk);
        //SUB: store (r2 - r3) in r5
        //r5 should now be -5
        subtestNumber = 2;
        instruction = 32'b0100000_00011_00010_000_00101_0110011;
        
        @ (negedge clk);
        //SLL: store (r3 << (r2[4:0])) in r6
        //r6 should now be 64
        subtestNumber = 3;
        instruction = 32'b0000000_00010_00011_001_00110_0110011;

        @ (negedge clk);
        //SLT: determine whether r5 is less than r4, store result in r7
        //r7 should now be 1
        subtestNumber = 4;
        instruction = 32'b0000000_00100_00101_010_00111_0110011;

        @ (negedge clk);
        //SLTU: determine whether r5 is less than r4 (unsigned), store result in r8
        //r8 should now be 0
        subtestNumber = 5;
        instruction = 32'b0000000_00100_00101_011_01000_0110011;

        @ (negedge clk);
        //XOR: store (r4 ^ r7) in r9
        //r9 should now be 4
        subtestNumber = 6;
        instruction = 32'b0000000_00111_00100_100_01001_0110011; 

        @ (negedge clk);
        //SRL: store (r5 >> r7) in r10
        //r10 should now be 2147483645
        subtestNumber = 7;
        instruction = 32'b0000000_00111_00101_101_01010_0110011; 

        @ (negedge clk);
        //SRA: store (r5 >>> r7) in r11
        //r11 should now be -3
        subtestNumber = 8;
        instruction = 32'b0100000_00111_00101_101_01011_0110011; 

        @ (negedge clk);
        //OR: store (r2 | r4) in r12
        //r12 should now be 7
        subtestNumber = 9;
        instruction = 32'b0000000_00100_00010_110_01100_0110011; 

        @ (negedge clk);
        //AND: store (r5 & r12) in r13
        //r13 should now be 3
        subtestNumber = 10;
        instruction = 32'b0000000_01100_00101_111_01101_0110011; 

        /*
        Immediate command tests
        */

        @ (negedge clk);
        test_phase = I_TYPE;

        //ADDI: store (50 + r11 (-3)) in r14
        //r14 should now be 47
        subtestNumber = 1;
        instruction = 32'b000000110010_01011_000_01110_0010011; 

        @ (negedge clk);
        //SLTI: determine whether r7 (1) is less than -2, store result in r15
        //r15 should now be 0
        subtestNumber = 2;
        instruction = 32'b111111111110_00111_010_01111_0010011; 

        @ (negedge clk);
        //SLTIU: determine whether r7 (1) is less than -2 (unsigned), store result in r16
        //r16 should now be 1
        subtestNumber = 3;
        instruction = 32'b111111111110_00111_011_10000_0010011; 

        @ (negedge clk);
        //XORI: store (r12 (7) ^ 30) in r17
        //r17 should now be 25
        subtestNumber = 4;
        instruction = 32'b000000011110_01100_100_10001_0010011; 

        @ (negedge clk);
        //ORI: store (r12 (7) ^ 17) in r18
        //r18 should now be 23
        subtestNumber = 5;
        instruction = 32'b000000010001_01100_110_10010_0010011; 

        @ (negedge clk);
        //ANDI: store (r12 (7) ^ 17) in r19
        //r19 should now be 1
        subtestNumber = 6;
        instruction = 32'b000000010001_01100_111_10011_0010011; 

        @ (negedge clk);
        //SLLI: store (r18 (23) << 10) in r20
        //r20 should now be 23552
        subtestNumber = 7;
        instruction = 32'b0000000_01010_10010_001_10100_0010011; 

        @ (negedge clk);
        //SRLI: store (r5 (-5) >> 2) in r21
        //r21 should now be 1073741822
        subtestNumber = 8;
        instruction = 32'b0000000_00010_00101_101_10101_0010011; 

        @ (negedge clk);
        //SRAI: store (r5 (-5) >>> 2) in r22
        //r22 should now be -2
        subtestNumber = 9;
        instruction = 32'b0100000_00010_00101_101_10110_0010011;

        /*
        Load command tests
        */

        /*
        @ (negedge clk);
        //LB: 
        instruction = 32'b000000000011_00001_000_01111_0000011; //

        @ (negedge clk);
        //lh
        instruction = 32'b000000000011_00001_001_00010_0000011; //

        @ (negedge clk);
        //lw
        instruction = 32'b000000000011_00001_010_00010_0000011; //

        @ (negedge clk);
        //lbu
        instruction = 32'b000000000011_00001_100_00010_0000011; //

        @ (negedge clk);
        //lhu
        instruction = 32'b000000000011_00001_101_00010_0000011; //
        */
    
        /*
        Store command types
        */
    
        /*
        @ (negedge clk);
        //sb
        instruction = 32'b0000100_00000_00001_000_00010_0100011; //

        @ (negedge clk);
        //sh
        instruction = 32'b0000100_00000_00001_001_00010_0100011; //

        @ (negedge clk);
        //sw
        instruction = 32'b0000100_00000_00001_010_00010_0100011; //
        */

        /*
        Branch command tests
        */

        @ (negedge clk);
        test_phase = B_TYPE;
        
        //BEQ test 1: Test if registers 2 (3) and 13 (3) are equal and if so, increase the program counter by 20 on the next instruction.
        //The condition is true so the program counter should increase by 20. 
        subtestNumber = 1;
        do_branch_instruction(3'b000, 5'b00010, 5'b01101, 13'd20);

        @ (negedge clk);
        //BEQ test 2: Test if registers 4 (5) and 5 (-5) are equal and if so, increase the program counter by 20 on the next instruction.
        //The condition is false so the program counter should only increase by 4. 
        subtestNumber = 2;
        do_branch_instruction(3'b000, 5'b00100, 5'b00101, 13'd20); 

        @ (negedge clk);
        //BNE test 1: Test if registers 2 (3) and 13 (3) are NOT equal and if so, increase the program counter by 20 on the next instruction.
        //The condition is false so the program counter should only increase by 4. 
        subtestNumber = 3;
        do_branch_instruction(3'b001, 5'b00010, 5'b01101, 13'd20);

        @ (negedge clk);
        //BNE test 2: Test if registers 4 (5) and 5 (-5) are NOT equal and if so, increase the program counter by 20 on the next instruction.
        //The condition is true so the program counter should increase by 20. 
        subtestNumber = 4;
        do_branch_instruction(3'b001, 5'b00100, 5'b00101, 13'd20); 

        @ (negedge clk);
        //BLT test 1: Test if register 5 (-5) is less than register 4 (5) and if so, increase the program counter by -8 on the next instruction.
        //The condition is true so the program counter should decrease by 8. 
        subtestNumber = 5;
        do_branch_instruction(3'b100, 5'b00100, 5'b00101, $signed(-13'd8)); 

        @ (negedge clk);
        //BLT test 2: Test if register 5 (-5) is less than register 5 (-5) and if so, increase the program counter by -8 on the next instruction.
        //The condition is false so the program counter should increase by 4. 
        subtestNumber = 6;
        do_branch_instruction(3'b100, 5'b00101, 5'b00101, -13'd8); 

        @ (negedge clk);
        //BLT test 3: Test if register 4 (5) is less than register 5 (-5) and if so, increase the program counter by -8 on the next instruction.
        //The condition is false so the program counter should increase by 4. 
        subtestNumber = 7;
        do_branch_instruction(3'b100, 5'b00101, 5'b00100, -13'd8); 

        @ (negedge clk);
        //BGE test 1: Test if register 5 (-5) is greater than or equal to register 4 (5) and if so, increase the program counter by -8 on the next instruction.
        //The condition is false so the program counter should increase by 4. 
        subtestNumber = 8;
        do_branch_instruction(3'b101, 5'b00100, 5'b00101, -13'd8); 

        @ (negedge clk);
        //BGE test 2: Test if register 5 (-5) is greater than or equal to register 5 (-5) and if so, increase the program counter by -8 on the next instruction.
        //The condition is true so the program counter should decrease by 8. 
        subtestNumber = 9;
        do_branch_instruction(3'b101, 5'b00101, 5'b00101, -13'd8); 

        @ (negedge clk);
        //BGE test 3: Test if register 4 (5) is greater than or equal to register 5 (-5) and if so, increase the program counter by -8 on the next instruction.
        //The condition is true so the program counter should decrease by 8. 
        subtestNumber = 10;
        do_branch_instruction(3'b101, 5'b00101, 5'b00100, -13'd8); 
    
        @ (negedge clk);
        //BLTU test 1: Test if register 4 (5) is less than register 5 (-5 = 4294967291) and if so, increase the program counter by 0 on the next instruction.
        //The condition is true so the program counter should be unchanged. 
        subtestNumber = 11;
        do_branch_instruction(3'b110, 5'b00101, 5'b00100, 13'd0); 

        @ (negedge clk);
        //BLTU test 2: Test if register 5 (-5 = 4294967291) is less than register 5 (-5 = 4294967291) and if so, increase the program counter by 0 on the next instruction.
        //The condition is false so the program counter should increase by 4. 
        subtestNumber = 12;
        do_branch_instruction(3'b110, 5'b00101, 5'b00101, 13'd0); 

        @ (negedge clk);
        //BLTU test 3: Test if register 5 (-5 = 4294967291) is less than register 4 (5) and if so, increase the program counter by 0 on the next instruction.
        //The condition is false so the program counter should increase by 4. 
        subtestNumber = 13;
        do_branch_instruction(3'b110, 5'b00100, 5'b00101, 13'd0); 

        @ (negedge clk);
        //BGEU test 1: Test if register 4 (5) is greater than or equal to register 5 (-5 = 4294967291) and if so, increase the program counter by 0 on the next instruction.
        //The condition is false so the program counter should increase by 4. 
        subtestNumber = 14;
        do_branch_instruction(3'b111, 5'b00101, 5'b00100, 13'd0); 

        @ (negedge clk);
        //BGEU test 2: Test if register 5 (-5 = 4294967291) is greater than or equal to register 5 (-5 = 4294967291) and if so, increase the program counter by 0 on the next instruction.
        //The condition is true so the program counter should be unchanged. 
        subtestNumber = 15;
        do_branch_instruction(3'b111, 5'b00101, 5'b00101, 13'd0); 

        @ (negedge clk);
        //BGEU test 3: Test if register 5 (-5 = 4294967291) is greater than or equal to register 4 (5) and if so, increase the program counter by 0 on the next instruction.
        //The condition is true so the program counter should be unchanged. 
        subtestNumber = 16;
        do_branch_instruction(3'b111, 5'b00100, 5'b00101, 13'd0); 

        /*
        Upper immediate command tests
        */

        @ (negedge clk);
        test_phase = U_TYPE;

        //AUIPC: store (PC + 285245440) in r31
        //r31 should now be 285245576
        subtestNumber = 1;
        instruction = 32'b0010001000000001000_11111_0010111; 

        // @ (negedge clk);
        // //lui
        // instruction = 32'b00001000000000001000_00010_0110111; //

        /*
        Jump command tests
        */

        @ (negedge clk);
        test_phase = J_TYPE;

        //JAL: store (PC + 4) in r30, then add 32776 to the program counter
        //TODO: The correct result goes to r30 on the posedge but then on the negedge it increases by 4. 
        //TODO: When an error was made in the do_jump_instruction function earlier (have imm be 20 bits instead of 21) it caused the PC to go metastable. 
        subtestNumber = 1;
        do_jump_instruction(21'b00001000000000001000, 5'b11110);

        @ (negedge clk);
        //JALR: store (PC + 4) in r31, then set the program counter to (r22 (-2) + 316)
        //r31 should now hold 4 more than the previous pc
        //The program counter should now be 314
        //TODO: Neither of the parts of the instruction are working right now. Does the ALU need to have JALR added to it? 
        subtestNumber = 2;
        instruction = 32'b000100111100_10110_000_11111_1100111; 
    
        @ (negedge clk);
        //invalid command, all bits to 0;
        subtestNumber = 1;
        instruction = 32'd0;

        @ (negedge clk);
        //invalid command, all bits to 1;
        subtestNumber = 2;
        instruction = 32'd1;
        #2 $finish;

    end

endmodule