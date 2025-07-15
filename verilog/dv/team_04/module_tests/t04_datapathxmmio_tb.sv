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
    always #5 clk = ~clk;


    // === Force RAM output into MMIO interface dynamically ===
    always @(posedge clk) begin
        force dut.mmio.RAM_en = 1;
        force dut.mmio.instruction = ram[(dut.final_address - 32'h33000000) >> 2];
        force dut.mmio.memload     = ram[(dut.final_address - 32'h33000000) >> 2];


        // Debug output
        $display("[Cycle %0t] final_address = %h", $time, dut.datapath.final_address);
        $display("[Cycle %0t] instruction_in = %h", $time, dut.datapath.ru.instruction_in);
        $display("[Cycle %0t] instruction_out = %h", $time, dut.datapath.ru.instruction_out);
        $display("[Cycle %0t] PC = %h", $time, dut.datapath.PC);
        $display("[Cycle %0t] FREEZE = %h", $time, dut.datapath.Freeze);
        $display("[Cycle %0t] n_freeze %b", $time, dut.datapath.ru.n_freeze);
        $display("[Cycle %0t] last_freeze %b", $time, dut.datapath.ru.last_freeze);
        $display("[Cycle %0t] MemRead = %h", $time, dut.datapath.MemRead_O);
        $display("[Cycle %0t] MemWrite = %h", $time, dut.datapath.MemWrite_O);
        $display("[Cycle %0t] busy = %b, d_ack = %b", $time, dut.mmio.busy, dut.d_ack);
        $display("[Cycle %0t] memload %b", $time, dut.mmio.memload);
        $display("[Cycle %0t] datapath memload %b", $time, dut.datapath.memload);
        $display("[Cycle %0t] instruction %b", $time, dut.mmio.instruction);
        $display("x4  = %0h (expect cafebabe)", dut.datapath.rf.registers[4]);
        $display("write back  = %0h (expect cafebabe)", dut.datapath.write_back_data);
        $display("mem_store from ru = %0h (expect cafebabe)", dut.datapath.ru.mem_store);
        $display("mem_store from mmio = %0h (expect cafebabe)", dut.mmio.mem_store);
    end

    // === Initialize test ===
    initial begin
        force dut.mmio.RAM_en = 1;
        force dut.mmio.busy = 1;
        $dumpfile("t04_datapathxmmio.vcd");
        $dumpvars(0, t04_datapathxmmio_tb);

        clk = 0;
        rst = 1;
        button_pressed = 0;
        app = 0;
        rising = 0;
        d_ack_display = 0;

                // === Preload instructions ===
        ram[0] = 32'b000000000000_00001_010_00100_0000011;   // lw x4, 0(x1)        → 0x0000A203
        ram[1] = 32'b0000000_00100_00001_010_00100_0100011;  // sw x4, 4(x1)        → 0x0040A223
        //ram[2] = 32'b0000000_00100_00001_010_00100_0100011;  // sw x4, 4(x1)        → 0x0040A223
        //ram[3] = 32'b00000000000000000000000001101111;       // jal x0, 0           → 0x0000006F
        //ram[4] = 32'b1;

        // === Put CAFEBABE far in memory at address 0x33000100 ===
        // index = (0x33000100 - 0x33000000) >> 2 = 0x100 >> 2 = 0x40 = 64
        ram[64] = 32'hCAFEBABE;  // actual data to be loaded

        // === After sw x4, 4(x1), it should write here:
        // 0x33000104 → index = 0x104 >> 2 = 65


        // === Release reset ===
        #10 rst = 0;

        // x1 should point to 0x33000100, which is RAM[64]
        dut.datapath.rf.registers[1] = 32'h33000100;


        #10;
        force dut.mmio.busy = 0;
        #10;
        force dut.mmio.busy = 1;


        // === Simulate keypad input ===
        #20;
        button_pressed = 5'b10101;
        app = 2'b00;
        rising = 1;
        #10 rising = 0;

        // === Simulate display ack ===
        #100;
        d_ack_display = 1;
        #10 d_ack_display = 0;

        // === Observe display write ===
        #20;
        $display("\n[DISPLAY OUTPUT]");
        $display("  WEN = %b", WEN);
        $display("  display_address = %h", display_address);
        $display("  mem_store_display = %h", mem_store_display);

        $display("\n[RAM STATE]");
        $display("  ram[0]  = %h (lw)", ram[0]);
        $display("  ram[1]  = %h (sw)", ram[1]);
        $display("  ram[2]  = %h (sw)", ram[2]);
        $display("  ram[64] = %h (CAFEBABE data)", ram[64]);
        $display("  ram[65] = %h (should get cafebabe from sw)", ram[65]);


        #50;
        $finish;
    end

endmodule
