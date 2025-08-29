`timescale 1ns/1ps

module t04_mmio_tb;

    // DUT I/O
    logic clk, reset;

    logic [31:0] final_address;
    logic [31:0] mem_store;
    logic MemRead, MemWrite;
    logic i_ack, d_ack;
    logic [31:0] instruction;
    logic [31:0] memload;

    logic [4:0] button_pressed;
    logic [1:0] app;
    logic rising;

    logic [31:0] display_address;
    logic [31:0] mem_store_display;
    logic d_ack_display;
    logic WEN;

    // DUT instance
    t04_mmio dut (
        .clk(clk),
        .reset(reset),
        .final_address(final_address),
        .mem_store(mem_store),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .i_ack(i_ack),
        .d_ack(d_ack),
        .instruction(instruction),
        .memload(memload),
        .button_pressed(button_pressed),
        .app(app),
        .rising(rising),
        .display_address(display_address),
        .mem_store_display(mem_store_display),
        .d_ack_display(d_ack_display),
        .WEN(WEN)
    );

    // Clock
    always #5 clk = ~clk;

    // Internal test signals to force internal MMIO signals
    logic [31:0] mock_mem_data;
    logic mock_busy;

    initial begin
        $dumpfile("t04_mmio.vcd");
        $dumpvars(0, t04_mmio_tb);

        // Force internal wires
        force dut.memload_or_instruction = mock_mem_data;
        force dut.busy = mock_busy;

        // === Init ===
        clk = 0;
        reset = 1;
        final_address = 0;
        mem_store = 32'hCAFEBABE;
        MemRead = 0;
        MemWrite = 0;
        button_pressed = 5'b00000;
        app = 2'b00;
        rising = 0;
        d_ack_display = 0;
        mock_mem_data = 32'h12345678;
        mock_busy = 0;

        #10 reset = 0;

        // === 1. RAM Read ===
        final_address = 32'h33000000; // RAM range
        MemRead = 1;
        mock_mem_data = 32'hAABBCCDD;
        #10;
        $display("\n[RAM READ] memload = %h (expect AABBCCDD)", memload);
        MemRead = 0;

        // === 2. RAM Write ===
        final_address = 32'h33000004;
        mem_store = 32'hDEADBEEF;
        MemWrite = 1;
        mock_busy = 1;
        #10;
        $display("[RAM WRITE] mem_store_display = %h (expect DEADBEEF)", mem_store_display);
        MemWrite = 0;

        // === 3. Keypad Read ===
        final_address = 32'h0000000C;  // keypad addr
        MemRead = 1;
        button_pressed = 5'b10110;
        app = 2'b00;
        rising = 1;
        #10;
        $display("\n[KEYPAD READ] memload = %h (should reflect 00000016)", memload);
        MemRead = 0;

        // === 4. Display Write 1 ===
        final_address = 32'h00000008;
        mem_store = 32'hFACE1234;
        MemWrite = 1;
        mock_busy = 0;
        #10;
        $display("\n[DISPLAY WRITE 1] WEN = %b (expect 1)", WEN);
        $display("  mem_store_display = %h (expect FACE1234)", mem_store_display);
        MemWrite = 0;

        // === 5. Display Write 2 ===
        final_address = 32'h40000004;
        mem_store = 32'hBABE9999;
        MemWrite = 1;
        #10;
        $display("\n[DISPLAY WRITE 2] WEN = %b (expect 1)", WEN);
        $display("  mem_store_display = %h (expect BABE9999)", mem_store_display);
        MemWrite = 0;

        // === 6. Ack Test ===
        MemRead = 1;
        final_address = 32'h33000000; // RAM
        d_ack_display = 1;
        mock_busy = 0;
        #10;
        $display("\n[ACK CHECK] i_ack = %b | d_ack = %b", i_ack, d_ack);

        #20;
        $display("\n--- FINAL SIGNAL STATE ---");
        $display("memload  = %h", memload);
        $display("display_address = %h", display_address);
        $display("mem_store_display = %h", mem_store_display);

        $finish;
    end

endmodule
