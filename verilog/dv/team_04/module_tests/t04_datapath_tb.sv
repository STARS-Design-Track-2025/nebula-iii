`timescale 1ns/1ps

module t04_datapath_tb;

    logic clk;
    logic rst;
    logic i_ack;
    logic d_ack;
    logic [31:0] instruction;
    logic [31:0] memload;
    logic [31:0] final_address;
    logic [31:0] mem_store;

    // Instantiate DUT
    t04_datapath dut (
        .clk(clk),
        .rst(rst),
        .i_ack(i_ack),
        .d_ack(d_ack),
        .instruction(instruction),
        .memload(memload),
        .final_address(final_address),
        .mem_store(mem_store)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        $dumpfile("t04_datapath.vcd");
        $dumpvars(0, t04_datapath_tb);
        clk = 0;
        rst = 1;
        i_ack = 0;
        d_ack = 0;
        instruction = 32'b0;
        memload = 32'b0;

        #10 rst = 0;

        // Init register file
        dut.rf.registers[1] = 32'd10;
        dut.rf.registers[2] = 32'd20;

        // === TEST 1: ADD x3, x1, x2 ===
        instruction = 32'b0000000_00010_00001_000_00011_0110011;
        i_ack = 1;
        #10;
        $display("PC = %0d", dut.PC);

        // === TEST 2: SUB x6, x2, x1 ===
        instruction = 32'b0100000_00001_00010_000_00110_0110011;
        #10;
        $display("PC = %0d", dut.PC);

        // === TEST 3: AND x7, x1, x2 ===
        instruction = 32'b0000000_00010_00001_111_00111_0110011;
        #10;
        $display("PC = %0d", dut.PC);

        // === TEST 4: OR x8, x1, x2 ===
        instruction = 32'b0000000_00010_00001_110_01000_0110011;
        #10;
        $display("PC = %0d", dut.PC);

        // === TEST 5: ADDI x9, x1, 5 ===
        instruction = 32'b000000000101_00001_000_01001_0010011;
        #10;
        $display("PC = %0d", dut.PC);

        // === TEST 6: SLT x10, x1, x2 ===
        instruction = 32'b0000000_00010_00001_010_01010_0110011;
        #10;
        $display("PC = %0d", dut.PC);

        // === TEST 7: SLTU x11, x1, x2 ===
        instruction = 32'b0000000_00010_00001_011_01011_0110011;
        #10;
        $display("PC = %0d", dut.PC);

        // === TEST 8: SW x3, 0(x0) ===
        instruction = 32'b0000000_00011_00000_010_00000_0100011;
        #10;
        $display("PC = %0d", dut.PC);

        // === TEST 9: LW x4, 0(x0) ===
        instruction = 32'b000000000000_00000_010_00100_0000011;
        memload = 32'd30;
        d_ack = 1;
        #10;
        $display("PC = %0d", dut.PC);

        // === TEST 10: BEQ x1, x2 (should not branch) ===
        instruction = 32'b0000000_00010_00001_000_00000_1100011;
        #10;
        $display("PC = %0d", dut.PC);

        // === TEST 11: BEQ x1, x1 (should branch) ===
        instruction = 32'b0000000_00001_00001_000_00000_1100011;
        #10;
        $display("PC = %0d", dut.PC);

        // === TEST 12: JAL x5, 4 ===
        instruction = 32'b000000000100_00000_000_00101_1101111;
        #10;
        $display("PC = %0d", dut.PC);

        // === TEST 13: JALR x12, x1, 8 ===
        instruction = 32'b000000001000_00001_000_01100_1100111;
        #10;
        $display("PC = %0d", dut.PC);

        // === Display Final Results ===
        $display("\n--- REGISTER FILE CHECKS ---");
        $display("x3  = %0d (expect 30)", dut.rf.registers[3]);
        $display("x4  = %0d (expect 30)", dut.rf.registers[4]);
        $display("x5  = %0d (expect PC + 4)", dut.rf.registers[5]);
        $display("x6  = %0d (expect 10)", dut.rf.registers[6]);
        $display("x7  = %0d (expect 0)", dut.rf.registers[7]);
        $display("x8  = %0d (expect 30)", dut.rf.registers[8]);
        $display("x9  = %0d (expect 15)", dut.rf.registers[9]);
        $display("x10 = %0d (expect 1)", dut.rf.registers[10]);
        $display("x11 = %0d (expect 1)", dut.rf.registers[11]);
        $display("x12 = %0d (expect previous PC + 4)", dut.rf.registers[12]);

        $display("\n--- DATAPATH OUTPUTS ---");
        $display("final_address = %0d", final_address);
        $display("mem_store     = %0d", mem_store);
        $display("Freeze        = %0b", dut.Freeze);

        #50 $finish;
    end

endmodule
