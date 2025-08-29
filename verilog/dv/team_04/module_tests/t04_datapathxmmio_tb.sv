`timescale 1ns/1ps

module t04_datapathxmmio_tb;

    logic clk, rst;

    // Inputs to MMIO (simulated peripherals)
    logic [4:0] button_pressed;
    logic [1:0] app;
    logic rising;
    logic d_ack_display;

    // Outputs from MMIO
    logic [31:0] display_address;
    logic [31:0] mem_store_display;
    logic WEN;  

    // DUT instance (no .busy connection here)
    t04_datapathxmmio dut (
        .clk(clk),
        .rst(rst),
        .button_pressed(button_pressed),
        .app(app),
        .rising(rising),
        .d_ack_display(d_ack_display),
        .display_address(display_address),
        .mem_store_display(mem_store_display),
        .WEN(WEN)
    );

    // Simulated RAM
    logic [31:0] ram [0:255];

    // Clock generation
    always #10 clk = ~clk;


    // === Force RAM output into MMIO interface dynamically ===
    always @(posedge clk) begin

        // Debug output
        $display("[Cycle %0t] final_address = %h", $time, dut.datapath.final_address);
        $display("[Cycle %0t] instruction_in = %h", $time, dut.datapath.ru.instruction_in);
        $display("[Cycle %0t] instruction_out = %h", $time, dut.datapath.ru.instruction_out);
        $display("[Cycle %0t] instruction_latched = %h", $time, dut.datapath.ru.latched_instruction);
        $display("[Cycle %0t] PC = %h", $time, dut.datapath.PC);
        $display("[Cycle %0t] FREEZE = %h", $time, dut.datapath.Freeze);
        // $display("[Cycle %0t] n_freeze %b", $time, dut.datapath.ru.n_freeze);
        // $display("[Cycle %0t] last_freeze %b", $time, dut.datapath.ru.last_freeze);
        $display("[Cycle %0t] MemRead = %h", $time, dut.datapath.MemRead_O);
        $display("[Cycle %0t] MemWrite = %h", $time, dut.datapath.MemWrite_O);
        $display("[Cycle %0t] busy = %b, d_ack = %b", $time, dut.mmio.busy, dut.d_ack);
        $display("[Cycle %0t] memload %b", $time, dut.mmio.memload);
        $display("[Cycle %0t] datapath memload %b", $time, dut.datapath.memload);
        $display("[Cycle %0t] instruction %b", $time, dut.mmio.instruction);
        $display("x1  = %0h (expect c)", dut.datapath.rf.registers[1]);
        $display("x2  = %0h (expect 1)", dut.datapath.rf.registers[2]);
        $display("x4  = %0h (expect cafebabe)", dut.datapath.rf.registers[4]);
        $display("write back  = %0h (expect cafebabe)", dut.datapath.write_back_data);
        $display("mem_store from ru = %0h (expect cafebabe)", dut.datapath.ru.mem_store);
        $display("mem_store from mmio = %0h (expect cafebabe)", dut.mmio.mem_store);
    end

    // === Initialize test ===
    initial begin
        //force dut.mmio.RAM_en = 1;
        $dumpfile("t04_datapathxmmio.vcd");
        $dumpvars(0, t04_datapathxmmio_tb);

        clk = 0;
        rst = 1;
        button_pressed = 0;
        app = 0;
        rising = 0;
        d_ack_display = 0;


        // === Release reset ===
        #15 rst = 0;

        #1000;

       $display("\nFINAL REGISTER VALUES");
        $display("----------------------");
        $display("x1  = %0h (expect 00000024)", dut.datapath.rf.registers[1]);   // address of data start
        $display("x2  = %0h (expect cafebabe)", dut.datapath.rf.registers[2]);   // loaded from 0x24
        $display("x3  = %0h (expect deadbeef)", dut.datapath.rf.registers[3]);   // loaded from 0x28
        $display("x4  = %0h (expect 00ff00ff)", dut.datapath.rf.registers[4]);   // loaded from 0x2C
        $display("x5  = %0h (expect 12345678)", dut.datapath.rf.registers[5]);   // hardcoded value (set manually in CPU or TB)
        $display("x10 = %0h (expect ec531ecf)", dut.datapath.rf.registers[10]);  // x2 - x3
        $display("x11 = %0h (expect 00340078)", dut.datapath.rf.registers[11]);  // x4 & x5
        $display("x12 = %0h (expect dafebefe)", dut.datapath.rf.registers[12]);  // x5 | x2
        $display("x13 = %0h (expect 00000001)", dut.datapath.rf.registers[13]);  // x2 < x4 (signed)
        $display("x14 = %0h (expect 80000000)", dut.datapath.rf.registers[14]);  // x3 << (x4 & 0x1F)
        $finish;
    end

endmodule
