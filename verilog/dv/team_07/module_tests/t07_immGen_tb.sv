module t07_immGen_tb;

    logic [31:0] instruction;
    logic [31:0] immediate;
    logic [6:0] opcode;
    logic [2:0] func3;
    logic [31:0] expected_immediate;

    // Instantiate DUT
    t07_immGen dut (
        .func3(func3),
        .instruction(instruction),
        .immediate(immediate)
    );

    initial begin
        $dumpfile("t07_immGen.vcd");
        $dumpvars(0, t07_immGen_tb);

        //i type

        //lb
        instruction = 32'b0000_1100_1000_0000_0000_0001_1000_0011; 
        expected_immediate = 200;
        #10;

        //jalr x1, 4(x5)
        func3 = 3'b000; // Set func3 for jalr
        instruction = 32'b00000000010000101000000011100111;
        expected_immediate = 4; //decimal
        #10;

        //jalr x1, -4(x5)
        func3 = 3'b000; // Set func3 for jalr
        instruction = 32'b11111111110000101000000011100111;
        expected_immediate = -4; //decimal
        #10;

        //addi
        func3 = 3'b000; // Set func3 for addi
        instruction = 32'b0000_0100_1011_0001_1000_0001_0001_0011; //addi so immediate should be 75
        expected_immediate = 75;
        #10;

        //test addi negative number
        func3 = 3'b000; // Set func3 for addi
        instruction = 32'b1111_1111_0100_00110_000_00101_0010011;
        expected_immediate = -12; //decimal
        #10;

        // slli //cannot be negative shifting to the left
        func3 = 3'b001; // Set func3 for slli
        instruction = 32'b0000_0000_0011_0001_1001_0001_0001_0011; //slli so immediate should be 3
        expected_immediate = 3;
        #10;

        //srli
        func3 = 3'b101; // Set func3 for srli
        instruction = 32'b0000_0000_0011_0001_1001_0001_0001_0011; //srli so immediate should be 3
        expected_immediate = 3;
        #10;

        //srai x7, x9, 4
        func3 = 3'b101; // Set func3 for srai
        instruction = 32'b0100_0000_0100_0100_1101_0011_1001_0011;
        expected_immediate = 4;
        #10;

        
        //xori x10, x5, 40
        func3 = 3'b100; // Set func3 for xori
        instruction = 32'b0000_0010_1000_0010_1100_0101_0001_0011;
        expected_immediate = 40; 
        #10;

        //xori negative number
        func3 = 3'b100; // Set func3 for xori
        instruction = 32'b11111101100000101100010100010011;
        expected_immediate = -40; //decimal
        #10;

        //ori x10, x10, 6
        func3 = 3'b110; // Set func3 for ori
        instruction = 32'b0000_0000_0110_0101_0110_0101_0001_0011;
        expected_immediate = 6; //decimal
        #10;

        //ori x10, x10, -6
        func3 = 3'b110; // Set func3 for ori
        instruction = 32'b11111111101001010110010100010011;
        expected_immediate = -6;
        #10;

        //andi x10, x8, 70
        func3 = 3'b111; // Set func3 for andi
        instruction = 32'b0000_0100_0110_0100_0111_0101_0001_0011; 
        expected_immediate =
        #10;

        //andi x10, x8, -70
        func3 = 3'b111; // Set func3 for andi
        instruction = 32'b11111011101001000111010100010011;
        expected_immediate = -70; //decimal
        #10;

        //sltiu x7, x8, 100
        func3 = 3'b011; // Set func3 for sltiu
        instruction = 32'b0000_0110_0100_0100_0011_0011_1001_0011;
        expected_immediate = 100;
        #10;

        //sltiu x7, x8, -100
        func3 = 3'b011;
        instruction = 32'b11111001110001000011001110010011;
        expected_immediate = -100;
        #10;

        //slti x8, x4, 50
        func3 = 3'b010; // Set func3 for slti
        instruction = 32'b00000011001000100010010000010011;
        expected_immediate = 50;
        #10;

        //slti negative number
        func3 = 3'b010; // Set func3 for slti
        instruction = 32'b11111100111000100010010000010011;
        expected_immediate = -50;
        #10;


        //s type
        instruction = 32'b0000_1000_0011_0000_0000_1011_0010_0011; //sb so immediate should be 150
        expected_immediate = 150;
        #10;

        //b type
        instruction = 32'b0000_0110_0011_0001_0000_0010_0110_0011; //beq so immediate should be 100
        expected_immediate = 100;
        #10;

        //j type
        instruction = 32'b0000_0011_0010_0000_0000_0001_0110_1111; //jal so immediate should be 50
        expected_immediate = 50;
        #10;

        //u type
        instruction = 32'b0000_0000_0000_0001_1001_0001_0011_0111; //lui so immediate should be 25
        expected_immediate = 25;
        #10;

        $finish;
    end
endmodule
