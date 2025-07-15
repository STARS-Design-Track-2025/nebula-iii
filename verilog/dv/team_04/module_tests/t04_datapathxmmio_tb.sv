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

    // === Busy simulation ===
    logic [1:0] busy_counter;

    always_ff @(posedge clk) begin
        if (rst) begin
            force dut.mmio.busy = 0;
            busy_counter <= 0;
        end else if (dut.datapath.MemRead_O || dut.datapath.MemWrite_O) begin
            if (busy_counter == 0) begin
                force dut.mmio.busy = 1;
                busy_counter <= 2;
            end else if (busy_counter == 1) begin
                force dut.mmio.busy = 0;
                busy_counter <= 0;
            end else begin
                busy_counter <= busy_counter - 1;
            end
        end else begin
            force dut.mmio.busy = 0;
            busy_counter <= 0;
        end
    end

    // === Force RAM output into MMIO interface dynamically ===
    always @(posedge clk) begin
        force dut.mmio.RAM_en = 1;
        if (dut.final_address !== 32'bx) begin
            force dut.mmio.instruction = ram[dut.final_address[9:2]];
            force dut.mmio.memload     = ram[dut.final_address[9:2]];
        end else begin
            // Avoid x by forcing instruction/memload to safe value
            force dut.mmio.instruction = 32'h00000013; // NOP: addi x0, x0, 0
            force dut.mmio.memload     = 32'h00000000;
        end

        // Debug prints
        $display("[Cycle %0t] final_address = %h", $time, dut.datapath.final_address);
        $display("[Cycle %0t] instruction_in = %b", $time, dut.datapath.ru.instruction_in);
        $display("[Cycle %0t] instruction_out = %h", $time, dut.datapath.ru.instruction_out);
        $display("[Cycle %0t] PC = %h", $time, dut.datapath.PC);
        $display("[Cycle %0t] FREEZE = %h", $time, dut.datapath.Freeze);
        $display("[Cycle %0t] MemRead = %h", $time, dut.datapath.MemRead_O);
        $display("[Cycle %0t] MemWrite = %h", $time, dut.datapath.MemWrite_O);
        $display("[Cycle %0t] busy = %b, d_ack = %b", $time, dut.mmio.busy, dut.d_ack);
        $display("[Cycle %0t] memload %b", $time, dut.mmio.memload);
        $display("[Cycle %0t] instruction %b", $time, dut.mmio.instruction);
        $display("x4  = %0h (expect cafebabe)", dut.datapath.rf.registers[4]);
    end

    // === Initialize test ===
    initial begin
        $dumpfile("t04_datapathxmmio_tb.vcd");
        $dumpvars(0, t04_datapathxmmio_tb);

        clk = 0;
        rst = 1;
        button_pressed = 0;
        app = 0;
        rising = 0;
        d_ack_display = 0;

        // === Preload instructions ===
        ram[0] = 32'b000000000000_00001_010_00100_0000011;   // lw x4, 0(x1)
        ram[1] = 32'hCAFEBABE;                               // data loaded by lw
        ram[2] = 32'b0000000_00100_00001_010_00100_0100011;  // sw x4, 4(x1)
        ram[3] = 32'b0000000_00101_00000_010_01000_0100011;  // sw x5, 8(x0)

        // === Release reset ===
        #10 rst = 0;

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

        // === Dump final RAM ===
        $display("\n[RAM STATE]");
        $display("  ram[0] = %h", ram[0]);
        $display("  ram[1] = %h", ram[1]);
        $display("  ram[2] = %h", ram[2]);
        $display("  ram[3] = %h", ram[3]);

        #50;
        $finish;
    end

endmodule
