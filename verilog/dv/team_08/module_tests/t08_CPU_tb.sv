`timescale 1ms/10ps
module t08_CPU_tb;
    logic clk = 0, nRst;                  //Clock and active-low reset. 
    logic [31:0] data_in;             //memory to memory handler: data in
    logic [31:0] instruction;         //memory to CPU: instruction 
    logic [31:0] data_out;           //memory handler to mmio: data outputted 
    logic [31:0] mem_address;        //memory handler to mmio: address in memory
    logic read_out, write_out;        //memory handler to mmio: read and write enable


    always #1 clk = ~clk;

    int testNumber = 0; //To help keep track of which test is being done in the waveforms. 

    t08_CPU t08_CPU1(.clk(clk), .nRst(nRst), .data_in(data_in), .instruction(instruction), 
                    .data_out(data_out), .mem_address(mem_address), .read_out(read_out), .write_out(write_out));

    task do_branch_instruction(logic [2:0] func3, logic [4:0] rs1, logic [4:0] rs2, logic [12:0] imm);

        instruction = {imm[12], imm[10:5], rs2, rs1, func3, imm[4:1], imm[11], 7'b1100011};

    endtask

    initial begin
        // make sure to dump the signals so we can see them in the waveform
        $dumpfile("t08_CPU.vcd"); //change the vcd vile name to your source file name
        $dumpvars(0, t08_CPU_tb);

        nRst = 0; #1;
        nRst = 1;
        data_in = 0;

        @ (posedge clk);
        //ADDI: store (3 + r1) in r2
        //r2 should now be 3
        testNumber = 1;
        instruction = 32'b000000000011_00001_000_00010_0010011;
        
        //addi: immediate(5) + r1(0) => r4, r4 = 5
        @ (posedge clk);
        //ADDI: store (5 + r1) in r4
        //r4 should now be 5
        testNumber = 2;
        instruction = 32'b000000000101_00001_000_00100_0010011;
        
        @ (posedge clk);
        //ADD: store (r2 + r4) in r3
        //r3 should now be 8
        testNumber = 3;
        instruction = 32'b0000000_00010_00100_000_00011_0110011;
        
        @ (posedge clk);
        //SUB: store (r2 - r3) in r5
        //r5 should now be -5
        testNumber = 4;
        instruction = 32'b0100000_00011_00010_000_00101_0110011;
        
        @ (posedge clk);
        //SLL: store (r3 << (r2[4:0])) in r6
        //r6 should now be 64
        testNumber = 5;
        instruction = 32'b0000000_00010_00011_001_00110_0110011;

        @ (posedge clk);
        //SLT: determine whether r5 is less than r4, store result in r7
        //r7 should now be 1
        testNumber = 6;
        instruction = 32'b0000000_00100_00101_010_00111_0110011;

        @ (posedge clk);
        //SLTU: determine whether r5 is less than r4 (unsigned), store result in r8
        //r8 should now be 0
        testNumber = 7;
        instruction = 32'b0000000_00100_00101_011_01000_0110011;

        @ (posedge clk);
        //XOR: store (r4 ^ r7) in r9
        //r9 should now be 4
        testNumber = 8;
        instruction = 32'b0000000_00111_00100_100_01001_0110011; 

        @ (posedge clk);
        //SRL: store (r5 >> r7) in r10
        //r10 should now be 2147483645
        testNumber = 9;
        instruction = 32'b0000000_00111_00101_101_01010_0110011; 

        @ (posedge clk);
        //SRA: store (r5 >>> r7) in r11
        //r11 should now be -3
        testNumber = 10;
        instruction = 32'b0100000_00111_00101_101_01011_0110011; 

        @ (posedge clk);
        //OR: store (r2 | r4) in r12
        //r12 should now be 7
        testNumber = 11;
        instruction = 32'b0000000_00100_00010_110_01100_0110011; 

        @ (posedge clk);
        //AND: store (r5 & r12) in r13
        //r13 should now be 3
        testNumber = 12;
        instruction = 32'b0000000_01100_00101_111_01101_0110011; 

        //I-Type

        @ (posedge clk);
        //ADDI: store (50 + r11) in r14
        //r14 should now be 47
        testNumber = 13;
        instruction = 32'b000000110010_01011_000_01110_0010011; 

        /*
        @ (posedge clk);
        //slti
        instruction = 32'b000000000011_00001_010_00010_0010011; //

        @ (posedge clk);
        //sltiu 
        instruction = 32'b000000000011_00001_011_00010_0010011; //

        @ (posedge clk);
        //xori
        instruction = 32'b000000000011_00001_100_00010_0010011; //

        @ (posedge clk);
        //ori
        instruction = 32'b000000000011_00001_110_00010_0010011; //

        @ (posedge clk);
        //andi
        instruction = 32'b000000000011_00001_111_00010_0010011; //

        @ (posedge clk);
        //slli
        instruction = 32'b0000000_00000_00001_001_00010_0010011; //

        @ (posedge clk);
        //srli
        instruction = 32'b0000000_00000_00001_101_00010_0010011; //

        @ (posedge clk);
        //srai
        instruction = 32'b0100000_00000_00001_101_00010_0010011; //

        @ (posedge clk);
        //LB: 
        instruction = 32'b000000000011_00001_000_01111_0000011; //

        @ (posedge clk);
        //lh
        instruction = 32'b000000000011_00001_001_00010_0000011; //

        @ (posedge clk);
        //lw
        instruction = 32'b000000000011_00001_010_00010_0000011; //

        @ (posedge clk);
        //lbu
        instruction = 32'b000000000011_00001_100_00010_0000011; //

        @ (posedge clk);
        //lhu
        instruction = 32'b000000000011_00001_101_00010_0000011; //
    
        //S-TYPE
        @ (posedge clk);
        //sb
        instruction = 32'b0000100_00000_00001_000_00010_0100011; //

        @ (posedge clk);
        //sh
        instruction = 32'b0000100_00000_00001_001_00010_0100011; //

        @ (posedge clk);
        //sw
        instruction = 32'b0000100_00000_00001_010_00010_0100011; //
        */

        /*
        Branch command tests
        */

        @ (posedge clk);
        //BEQ test 1: Test if registers 2 (3) and 13 (3) are equal and if so, increase the program counter by 20 on the next instruction.
        //The condition is true so the program counter should increase by 20. 
        testNumber = 14;
        do_branch_instruction(3'b000, 5'b00010, 5'b01101, 13'd20);

        @ (posedge clk);
        //BEQ test 2: Test if registers 4 (5) and 5 (-5) are equal and if so, increase the program counter by 20 on the next instruction.
        //The condition is false so the program counter should only increase by 4. 
        testNumber = 15;
        do_branch_instruction(3'b000, 5'b00100, 5'b00101, 13'd20); 

        @ (posedge clk);
        //BNE test 1: Test if registers 2 (3) and 13 (3) are NOT equal and if so, increase the program counter by 20 on the next instruction.
        //The condition is false so the program counter should only increase by 4. 
        testNumber = 16;
        do_branch_instruction(3'b001, 5'b00010, 5'b01101, 13'd20);

        @ (posedge clk);
        //BNE test 2: Test if registers 4 (5) and 5 (-5) are NOT equal and if so, increase the program counter by 20 on the next instruction.
        //The condition is true so the program counter should increase by 20. 
        testNumber = 17;
        do_branch_instruction(3'b001, 5'b00100, 5'b00101, 13'd20); 

        @ (posedge clk);
        //BLT test 1: Test if register 5 (-5) is less than register 4 (5) and if so, increase the program counter by -8 on the next instruction.
        //The condition is true so the program counter should decrease by 8. 
        testNumber = 18;
        do_branch_instruction(3'b100, 5'b00100, 5'b00101, -13'd8); 

        @ (posedge clk);
        //BLT test 2: Test if register 5 (-5) is less than register 5 (-5) and if so, increase the program counter by -8 on the next instruction.
        //The condition is false so the program counter should increase by 4. 
        testNumber = 19;
        do_branch_instruction(3'b100, 5'b00101, 5'b00101, -13'd8); 

        @ (posedge clk);
        //BLT test 3: Test if register 4 (5) is less than register 5 (-5) and if so, increase the program counter by -8 on the next instruction.
        //The condition is false so the program counter should increase by 4. 
        testNumber = 20;
        do_branch_instruction(3'b100, 5'b00101, 5'b00100, -13'd8); 

        @ (posedge clk);
        //BGE test 1: Test if register 5 (-5) is greater than or equal to register 4 (5) and if so, increase the program counter by -8 on the next instruction.
        //The condition is false so the program counter should increase by 4. 
        testNumber = 21;
        do_branch_instruction(3'b101, 5'b00100, 5'b00101, -13'd8); 

        @ (posedge clk);
        //BGE test 2: Test if register 5 (-5) is greater than or equal to register 5 (-5) and if so, increase the program counter by -8 on the next instruction.
        //The condition is true so the program counter should decrease by 8. 
        testNumber = 22;
        do_branch_instruction(3'b101, 5'b00101, 5'b00101, -13'd8); 

        @ (posedge clk);
        //BGE test 3: Test if register 4 (5) is greater than or equal to register 5 (-5) and if so, increase the program counter by -8 on the next instruction.
        //The condition is true so the program counter should decrease by 8. 
        testNumber = 23;
        do_branch_instruction(3'b101, 5'b00101, 5'b00100, -13'd8); 
    
        @ (posedge clk);
        //BLTU test 1: Test if register 4 (5) is less than register 5 (-5 = 4294967291) and if so, increase the program counter by 0 on the next instruction.
        //The condition is true so the program counter should be unchanged. 
        testNumber = 24;
        do_branch_instruction(3'b110, 5'b00101, 5'b00100, 13'd0); 

        @ (posedge clk);
        //BLTU test 2: Test if register 5 (-5 = 4294967291) is less than register 5 (-5 = 4294967291) and if so, increase the program counter by 0 on the next instruction.
        //The condition is false so the program counter should increase by 4. 
        testNumber = 25;
        do_branch_instruction(3'b110, 5'b00101, 5'b00101, 13'd0); 

        @ (posedge clk);
        //BLTU test 3: Test if register 5 (-5 = 4294967291) is less than register 4 (5) and if so, increase the program counter by 0 on the next instruction.
        //The condition is false so the program counter should increase by 4. 
        testNumber = 26;
        do_branch_instruction(3'b110, 5'b00100, 5'b00101, 13'd0); 

        @ (posedge clk);
        //BGEU test 1: Test if register 4 (5) is greater than or equal to register 5 (-5 = 4294967291) and if so, increase the program counter by 0 on the next instruction.
        //The condition is false so the program counter should increase by 4. 
        testNumber = 27;
        do_branch_instruction(3'b111, 5'b00101, 5'b00100, 13'd0); 

        @ (posedge clk);
        //BGEU test 2: Test if register 5 (-5 = 4294967291) is greater than or equal to register 5 (-5 = 4294967291) and if so, increase the program counter by 0 on the next instruction.
        //The condition is true so the program counter should be unchanged. 
        testNumber = 28;
        do_branch_instruction(3'b111, 5'b00101, 5'b00101, 13'd0); 

        @ (posedge clk);
        //BGEU test 3: Test if register 5 (-5 = 4294967291) is greater than or equal to register 4 (5) and if so, increase the program counter by 0 on the next instruction.
        //The condition is true so the program counter should be unchanged. 
        testNumber = 29;
        do_branch_instruction(3'b111, 5'b00100, 5'b00101, 13'd0); 
        
        /*
        //U-TYPE
        @ (posedge clk);
        //lui
        instruction = 32'b00001000000000001000_00010_0110111; //

        @ (posedge clk);
        //auipc
        instruction = 32'b00001000000000001000_00010_0010111; //

        //J-TYPE
        @ (posedge clk);
        //jal
        instruction = 32'b00001000000000001000_00010_1101111; //
    
        //I-TYPE
        @ (posedge clk);
        //jalr
        instruction = 32'b00001000000000001000_00010_1100111; //
        */
    
        #1 $finish;

    end

endmodule