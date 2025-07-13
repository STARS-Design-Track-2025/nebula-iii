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
        $display("  PC    = %0d", dut.PC);
        instruction = instr;
        i_ack = 1;
        #10;               // 1 cycle
        i_ack = 0;

        if (is_loadstore) begin
            d_ack = 1;
            memload = load_val;
            #10;           // 3rd cycle
            d_ack = 0;
        end

        #10; // 1 more cycle to observe datapath writeback

        $display("  RegD  = x%0d", dut.RegD);
        $display("  WB    = %0d", dut.write_back_data);
        $display("  Freeze= %0b", dut.Freeze);
        $display("is branch taken from pc_module = %0d", dut.pc_module.Branch);
        $display("ALU output of branch condition = %0d", dut.alu.BranchConditionFlag);
        $display("sub result = %0d", dut.alu.sub_result);
        $display("src A = %0d", dut.alu.src_A);
        $display("src B = %0d", dut.alu.src_B);
        $display("ALU SOURCE = %0d", dut.ALUSrc);
        $display("reg1 coming from control= %0d", dut.Reg1);
        $display("reg2 coming from control = %0d", dut.Reg2);
        $display("reg1 coming from regFile= %0d", dut.src_A);
        $display("reg2 coming from regFile = %0d", dut.src_B);
        $display("imm = %0d", dut.Imm);
        $display(" NEXT PC    = %0d", dut.pc_module.n_PC);
    endtask

    task automatic check_pc(input [31:0] expected_pc, input string label = "");
    if (dut.PC !== expected_pc)
        $display("  [FAIL] %s: PC = %0d (expected %0d)", label, dut.PC, expected_pc);
    else
        $display("  [PASS] %s: PC = %0d", label, dut.PC);
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

                // === Extra LW Test: Simulate MMIO-style response ===
        $display("\n--- Simulating Multi-Cycle LW (MMIO-Style) ---");

        // Apply LW instruction: LW x13, 0(x1)
        instruction = 32'b000000000000_00001_010_01101_0000011; // x13 = mem[x1 + 0]
        memload = 32'b000000000000_00001_010_01101_0000011; 
        i_ack = 1;
        #10;
        i_ack = 0;

        // Wait one cycle (datapath computes address)
        #50;

                $display("  [MMIO DEBUG] src_A        = %0d (should be x1 = 10)", dut.src_A);
            $display("  [MMIO DEBUG] ALU_input_B  = %0d (should be imm = 0)", dut.ALU_input_B);
            $display("  [MMIO DEBUG] ALU_result   = %0d", dut.ALU_result);
            $display("  [MMIO DEBUG] ALU_control   = %0d", dut.ALU_control);
            $display("  [MMIO DEBUG] branch_condition   = %0d", dut.alu.BranchConditionFlag);
            $display("  [MMIO DEBUG] funct3   = %b", dut.alu.funct3);
            $display("  [MMIO DEBUG] final_address= %0d", final_address);
        $display("  [MMIO DEBUG] MemRead      = %b", dut.MemRead_O);
        $display("  [MMIO DEBUG] RegD         = x%0d", dut.RegD);
        $display("  [MMIO DEBUG] ALUSrc         = %d", dut.ALUSrc);


        // Now check if final_address is correct (x1 == 10)
        instruction = 32'd42;
        if (final_address == 32'd10) begin
            $display("  final_address matched!!!!!!!!!: %0d", final_address);
            memload = 32'd42;
            d_ack = 1;
            #10;
            d_ack = 0;
        end else begin
            memload = 32'd0;
            $display("  ERROR: Unexpected address: %0d (expected 10)", final_address);
            $display("  ALU_result    = %0d", dut.ALU_result);
        end

        // Wait for writeback
        #10;

                $display("\n--- Simulating Multi-Cycle SW (MMIO-Style) ---");

        // SW x3, 0(x1): Store the value in x3 (30) into memory at address x1 (10)
        instruction = 32'b0000000_00011_00001_010_00000_0100011; // SW x3 → mem[x1 + 0]
        i_ack = 1;
        #10;
        i_ack = 0;

        // Wait for address computation (usually 2 cycles due to Freeze)
        #50;

        // Debug prints for SW
        $display("  [MMIO DEBUG] src_A        = %0d (should be x1 = 10)", dut.src_A);
        $display("  [MMIO DEBUG] ALU_input_B  = %0d (should be imm = 0)", dut.ALU_input_B);
        $display("  [MMIO DEBUG] ALU_result   = %0d", dut.ALU_result);
        $display("  [MMIO DEBUG] ALU_control   = %0d", dut.ALU_control);
        $display("  [MMIO DEBUG] final_address= %0d", final_address);
        $display("  [MMIO DEBUG] MemWrite     = %b", dut.MemWrite_O);
        $display("  [MMIO DEBUG] mem_store    = %0d (should be x3 = 30)", mem_store);

        // Now check if final_address is correct and mem_store has correct value
        if (final_address == 32'd10 && mem_store == 32'd30) begin
            $display("  SW address/data matched correctly!");
        end else begin
            $display("  ERROR: Unexpected SW address or value");
            $display("    final_address = %0d (expected 10)", final_address);
            $display("    mem_store     = %0d (expected 30)", mem_store);
        end

        @(posedge clk);


        // Observe datapath
        $display("  PC    = %0d", dut.PC);
        $display("  memload    = %0d", dut.memload);
        $display("  RegD  = x%0d", dut.RegD);
        $display("  WB    = %0d", dut.write_back_data);
        $display("  x13   = %0d (expect 42)", dut.rf.registers[13]);


        @(posedge clk);

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
        $display("write_back_data = %0d", dut.write_back_data);
        $display("desitination reg = %0d", dut.RegD);





    rst = 1; 
    #10
    rst = 0;

$display("Reset PC = %0d", dut.PC);
#10
$display("Reset PC inside module = %0d", dut.pc_module.PC);
$display("n_PC inside module = %0d", dut.pc_module.n_PC);
        // Initialize registers for comparison

dut.rf.registers[5] = 32'd50;
dut.rf.registers[6] = 32'd50;
dut.rf.registers[7] = 32'd30;
dut.rf.registers[8] = 32'd40;


// === Branch: BEQ x5, x6, +8 (PC should jump ahead by 8) BRANCH
apply_instr(32'b0000000_00110_00101_000_00001_1100011, 0, 0, "BEQ x5 == x6 → PC += 8");
#10;  // Wait a cycle
check_pc(32'h33000000 + 8, "BEQ Taken");

// === Branch: BNE x7, x8, +8 (x7 != x8 so should branch) BRANCH
apply_instr(32'b0000000_01000_00111_001_00010_1100011, 0, 0, "BNE x7 != x8 → PC += 8");
#10;
check_pc(32'h33000000 + 16, "BNE Taken");

// === Branch: BEQ x5, x7, +8 (x5 != x7 so should not branch) NOT BRANCH
apply_instr(32'b0000000_00111_00101_000_00011_1100011, 0, 0, "BEQ x5 != x7 → PC += 4");
#10;
check_pc(32'h33000000 + 20, "BEQ Not Taken");

// === Branch: BNE x5, x6, +8 (x5 == x6 so should NOT branch) NOT BRANCH
apply_instr(32'b0000000_00110_00101_001_00100_1100011, 0, 0, "BNE x5 == x6 → PC += 4");
#10;
check_pc(32'h33000000 + 24, "BNE Not Taken");


$display("\n--- BRANCH INSTRUCTION TESTS COMPLETE ---");
$display("Final PC = %0d", dut.PC);


        #50 $finish;
    end

endmodule
//FIX IMMEDIATE GENERATOR FOR BRANCHES
//WHY DOES IT GO INTO AN INFINITE LOOP IF I PUT #10 on line 33?
//WHY DOES IT GO INTO AN INFINITE LOOP IF I CHANGE FREEZE LOGIC? 
//NOT INCREMENTING PC OR FREEZING PROPERLY