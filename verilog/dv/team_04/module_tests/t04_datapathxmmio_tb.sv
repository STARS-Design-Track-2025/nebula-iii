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

    // DUT instance
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
        if (dut.final_address !== 32'bx) begin
            force dut.mmio.instruction = ram[dut.final_address[9:2]];
            force dut.mmio.memload     = ram[dut.final_address[9:2]];
        end else begin
            // Avoid x by forcing instruction/memload to safe value
            force dut.mmio.instruction = 32'h00000013; // NOP: addi x0, x0, 0
            force dut.mmio.memload     = 32'h00000000;
        end

        // Print final_address every cycle for debugging
        $display("[Cycle %0t] final_address = %h", $time, dut.final_address);

        // Optional: hardcode initial value if it's X at time 0
        if ($time == 0 && dut.final_address === 32'bx)
            force dut.final_address = 32'h33000000;
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
