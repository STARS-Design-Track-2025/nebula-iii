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

    // Instantiate DUT
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
        $dumpfile("datapath_tb.vcd");
        $dumpvars(0, datapath_tb);
        clk = 0;
        rst = 1;
        i_ack = 0;
        d_ack = 0;
        instruction = 32'b0;
        memload = 32'b0;

        // Reset pulse
        #10 rst = 0;

        // ---- TEST 1: ADD x3, x1, x2 (x1 = 10, x2 = 20 → x3 = 30) ----
        // Use direct register assignment instead of force
        // Must match your datapath's register file name exactly
        dut.rf.registers[1] = 32'd10;
        dut.rf.registers[2] = 32'd20;
        instruction = 32'b0000000_00010_00001_000_00011_0110011; // ADD x3, x1, x2
        i_ack = 1;
        #10;

        // ---- TEST 2: SW x3, 0(x0) ----
        // Store 30 into mem[0]
        instruction = 32'b0000000_00011_00000_010_00000_0100011; // SW x3 → mem[x0 + 0]
        #10;

        // ---- TEST 3: LW x4, 0(x0) ----
        // Load 30 from mem[0] into x4
        instruction = 32'b000000000000_00000_010_00100_0000011; // LW x4 ← mem[x0 + 0]
        memload = 32'd30;
        #10;

        // ---- TEST 4: BEQ x1, x2 (should NOT branch) ----
        // x1 = 10, x2 = 20
        instruction = 32'b0000000_00010_00001_000_00001_1100011; // BEQ x1, x2, +offset
        #10;

        // ---- TEST 5: JAL x5, 4 (x5 = PC + 4) ----
        instruction = 32'b000000000100_00000_000_00101_1101111; // JAL x5, 4
        #10;

        // ---- Display register values ----
        $display("x3 = %0d (expect 30)", dut.rf.registers[3]);
        $display("x4 = %0d (expect 30)", dut.rf.registers[4]);
        $display("x5 = %0d (expect PC + 4)", dut.rf.registers[5]);

        #50 $finish;
    end

endmodule
