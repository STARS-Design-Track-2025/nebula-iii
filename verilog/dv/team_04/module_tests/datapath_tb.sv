`timescale 1ns/1ps

module datapath_tb;

    logic clk;
    logic rst;
    logic i_ack;
    logic d_ack;
    logic [31:0] instruction;
    logic [31:0] memload;
    logic [31:0] i_address;
    logic [31:0] d_address;
    logic [31:0] mem_store;

    datapath dut (
        .clk(clk),
        .rst(rst),
        .i_ack(i_ack),
        .d_ack(d_ack),
        .instruction(instruction),
        .memload(memload),
        .i_address(i_address),
        .d_address(d_address),
        .mem_store(mem_store)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        i_ack = 0;
        d_ack = 0;
        instruction = 32'b0;
        memload = 32'b0;

        #10;
        rst = 0;

        // Test 1: ADD x3, x1, x2
        // x1 = 10, x2 = 20 => x3 = 30
        force dut.rf.registers[1] = 32'd10;
        force dut.rf.registers[2] = 32'd20;
        instruction = 32'b0000000_00010_00001_000_00011_0110011; // funct7 | rs2 | rs1 | funct3 | rd | opcode
        #10;

        // Test 2: SW x3, 0(x0)
        // Store value from x3 (30) into mem[0]
        i_ack = 1;
        d_ack = 1;
        instruction = 32'b0000000_00011_00000_010_00000_0100011; // funct7 | rs2 | rs1 | funct3 | imm | opcode
        #10;

        // Test 3: LW x4, 0(x0)
        // Load value from mem[0] into x4
        instruction = 32'b000000000000_00000_010_00100_0000011; // imm | rs1 | funct3 | rd | opcode
        memload = 32'd30;
        #10;

        // Test 4: BEQ x1, x2, offset
        // x1=10, x2=20 → not equal → no branch
        instruction = 32'b0000000_00010_00001_000_00001_1100011; // funct7 | rs2 | rs1 | funct3 | offset | opcode
        #10;

        // Test 5: JAL x5, 4
        instruction = 32'b00000000010000000000000110101111; // imm[20|10:1|11|19:12] | rd | opcode
        #10;

        $display("x3 = %0d", dut.rf.registers[3]); // Should be 30
        $display("x4 = %0d", dut.rf.registers[4]); // Should be 30
        $display("x5 = %0d", dut.rf.registers[5]); // Should be PC+4

        #50 $finish;
    end
endmodule
