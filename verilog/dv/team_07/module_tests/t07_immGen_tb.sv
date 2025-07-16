module t07_immGen_tb;

    logic [31:0] instruction;
    logic [31:0] immediate;
    logic [6:0] opcode;
    logic [2:0] func3;

    // Instantiate DUT
    t07_immGen dut (
        .func3(func3),
        .instruction(instruction),
        .immediate(immediate)
    );

    initial begin
        $dumpfile("t07_immGen.vcd");
        $dumpvars(0, t07_immGen_tb);

        // i type
        instruction = 32'b0000_1100_1000_0000_0000_0001_1000_0011; //lb so immediate should be 200
        #10;

        //addi
        func3 = 3'b000; // Set func3 for addi
        instruction = 32'b0000_0100_1011_0001_1000_0001_0001_0011; //addi so immediate should be 75
        #10;

        // slli
        func3 = 3'b001; // Set func3 for slli
        instruction = 32'b0000_0000_0011_0001_1001_0001_0001_0011; //slli so immediate should be 3
        #10;

        //srli
        func3 = 3'b101; // Set func3 for srli
        instruction = 32'b0000_0000_0011_0001_1001_0001_0001_0011; //srli so immediate should be 3
        #10;

        //s type
        instruction = 32'b0000_1000_0011_0000_0000_1011_0010_0011; //sb so immediate should be 150
        #10;

        //b type
        instruction = 32'b0000_0110_0011_0001_0000_0010_0110_0011; //beq so immediate should be 100
        #10;

        //j type
        instruction = 32'b0000_0011_0010_0000_0000_0001_0110_1111; //jal so immediate should be 50
        #10;

        //u type
        instruction = 32'b0000_0000_0000_0001_1001_0001_0011_0111; //lui so immediate should be 25
        #10;

        $finish;
    end
endmodule
