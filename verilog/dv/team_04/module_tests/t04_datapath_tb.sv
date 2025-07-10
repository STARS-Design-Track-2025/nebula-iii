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

    // DUT instance
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

    // Clock: 10ns period
    always #5 clk = ~clk;

    // Task to apply instruction
    task automatic apply_instr(input [31:0] instr, input bit is_loadstore = 0, input [31:0] load_val = 0, input string label = "");
        $display("\n[Cycle %0t] --- %s ---", $time, label);
        instruction = instr;
        i_ack = 1;
        #10;               // 1 cycle
        i_ack = 0;

        if (is_loadstore) begin
            // Stall 2 cycles for memory wait
            #20;
            d_ack = 1;
            memload = load_val;
            #10;           // 3rd cycle
            d_ack = 0;
        end

        #10; // 1 more cycle to observe datapath writeback

        $display("  PC    = %0d", dut.PC);
        $display("  RegD  = x%0d", dut.RegD);
        $display("  WB    = %0d", dut.write_back_data);
        $display("  Freeze= %0b", dut.Freeze);
    endtask

    initial begin
        $dumpfile("t04_datapath.vcd");
        $dumpvars(0, t04_datapath_tb);

        // Init
        clk = 0;
        rst = 1;
        i_ack = 0;
        d_ack = 0;
        instruction = 32'd0;
        memload = 32'd0;

        #10 rst = 0;

        // Init register file
        dut.rf.registers[1] = 32'd10;
        dut.rf.registers[2] = 32'd20;

        // === Instruction Stream ===
        apply_instr(32'b0000000_00010_00001_000_00011_0110011, 0, 0, "ADD x3 = x1 + x2");
        apply_instr(32'b0100000_00001_00010_000_00110_0110011, 0, 0, "SUB x6 = x2 - x1");
        apply_instr(32'b0000000_00010_00001_111_00111_0110011, 0, 0, "AND x7 = x1 & x2");
        apply_instr(32'b0000000_00010_00001_110_01000_0110011, 0, 0, "OR x8 = x1 | x2");
        apply_instr(32'b000000000101_00001_000_01001_0010011, 0, 0, "ADDI x9 = x1 + 5");
        apply_instr(32'b0000000_00010_00001_010_01010_0110011, 0, 0, "SLT x10 = (x1 < x2)");
        apply_instr(32'b0000000_00010_00001_011_01011_0110011, 0, 0, "SLTU x11 = (x1 < x2 unsigned)");

        // === MEM ops take 3 cycles ===
        apply_instr(32'b0000000_00011_00000_010_00000_0100011, 1, 0, "SW x3 → mem[0]");
        apply_instr(32'b000000000000_00000_010_00100_0000011, 1, 32'd30, "LW x4 ← mem[0]");

        apply_instr(32'h004002ef, 0, 0, "JAL x5, 4");
        apply_instr(32'h00828667, 0, 0, "JALR x12, x5, 8");

        // === Final Register Dump ===
        $display("\n--- FINAL REGISTER FILE CHECKS ---");
        $display("x3  = %0d (expect 30)", dut.rf.registers[3]);
        $display("x4  = %0d (expect 30)", dut.rf.registers[4]);
        $display("x5  = %0d (expect PC + 4)", dut.rf.registers[5]);
        $display("x6  = %0d (expect 10)", dut.rf.registers[6]);
        $display("x7  = %0d (expect 0)", dut.rf.registers[7]);
        $display("x8  = %0d (expect 30)", dut.rf.registers[8]);
        $display("x9  = %0d (expect 15)", dut.rf.registers[9]);
        $display("x10 = %0d (expect 1)", dut.rf.registers[10]);
        $display("x11 = %0d (expect 1)", dut.rf.registers[11]);
        $display("x12 = %0d (expect PC + 4 from jalr)", dut.rf.registers[12]);

        $display("\n--- DATAPATH OUTPUTS ---");
        $display("final_address = %0d", final_address);
        $display("mem_store     = %0d", mem_store);
        $display("Freeze        = %0b", dut.Freeze);

        #50 $finish;
    end

endmodule
