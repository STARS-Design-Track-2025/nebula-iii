`timescale 1ns/1ps

module tb;
  logic hwclk, reset;
  logic [20:0] pb;
  logic [7:0] left, right,
         ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0;
  logic red, green, blue;

  // UART ports
  logic [7:0] txdata;
  logic [7:0] rxdata;
  logic txclk, rxclk;
  logic txready, rxready;

    // DUT instance (no .busy connection here)
    t04_top1 dut (.*);

    // Clock generation
    always #10 hwclk = ~hwclk;

    // === Force RAM output into MMIO interface dynamically ===
    // always @(posedge clk) begin

    //     // Debug output
    //     $display("[Cycle %0t] final_address = %h", $time, dut.datapath.final_address);
    //     $display("[Cycle %0t] instruction_in = %h", $time, dut.datapath.ru.instruction_in);
    //     $display("[Cycle %0t] instruction_out = %h", $time, dut.datapath.ru.instruction_out);
    //     $display("[Cycle %0t] instruction_latched = %h", $time, dut.datapath.ru.latched_instruction);
    //     $display("[Cycle %0t] PC = %h", $time, dut.datapath.PC);
    //     $display("[Cycle %0t] FREEZE = %h", $time, dut.datapath.Freeze);
    //     // $display("[Cycle %0t] n_freeze %b", $time, dut.datapath.ru.n_freeze);
    //     // $display("[Cycle %0t] last_freeze %b", $time, dut.datapath.ru.last_freeze);
    //     $display("[Cycle %0t] MemRead = %h", $time, dut.datapath.MemRead_O);
    //     $display("[Cycle %0t] MemWrite = %h", $time, dut.datapath.MemWrite_O);
    //     $display("[Cycle %0t] busy = %b, d_ack = %b", $time, dut.mmio.busy, dut.d_ack);
    //     $display("[Cycle %0t] memload %b", $time, dut.mmio.memload);
    //     $display("[Cycle %0t] datapath memload %b", $time, dut.datapath.memload);
    //     $display("[Cycle %0t] instruction %b", $time, dut.mmio.instruction);
    //     $display("x1  = %0h (expect c)", dut.datapath.rf.registers[1]);
    //     $display("x2  = %0h (expect 1)", dut.datapath.rf.registers[2]);
    //     $display("x3  = %0h (expect cafebabe)", dut.datapath.rf.registers[3]);
    //     $display("x4  = %0h (expect cafebabe)", dut.datapath.rf.registers[4]);
    //     $display("write back  = %0h (expect cafebabe)", dut.datapath.write_back_data);
    //     $display("mem_store from ru = %0h (expect cafebabe)", dut.datapath.ru.mem_store);
    //     $display("mem_store from mmio = %0h (expect cafebabe)", dut.mmio.mem_store);
    //     $display("ram en = %0h (expect cafebabe)", dut.mmio.RAM_en);
    //     $display("WEN = %0h (expect cafebabe)", dut.mmio.WEN);
    //     $display("WEN1 = %0h (expect cafebabe)", dut.mmio.WEN1);
    //     $display("WEN2 = %0h (expect cafebabe)", dut.mmio.WEN2);
    //     $display("Write_I WISHBONE = %0h (expect cafebabe)", dut.mmio.write_I);
    //     $display("READ_I WISHBONE = %0h (expect cafebabe)", dut.mmio.read_I);
    //     $display("Sub Result = %0h (expect cafebabe)", dut.datapath.alu.sub_result);
    //     $display("Src A = %0h (expect cafebabe)", dut.datapath.src_A);
    //     $display("Src B = %0h (expect cafebabe)", dut.datapath.src_B);
    //     $display("ALU INPUT 2 = %0h (expect cafebabe)", dut.datapath.ALU_input_B);
    //     $display("Reg1 = %0h (expect cafebabe)", dut.datapath.Reg1);
    //     $display("Reg2 = %0h (expect cafebabe)", dut.datapath.Reg2);
    // end

    // === Initialize test ===
    initial begin
        //force dut.mmio.RAM_en = 0;
        force dut.mmio.key_data = 0;
        //x2 is multiplier
        //x1 is multicand
        // force dut.datapath.rf.registers[1] = 0;
        // force dut.datapath.rf.registers[2] = 0;        
        $dumpfile("t04_top1.vcd");
        $dumpvars(0, tb);

        hwclk = 0;
        reset = 1;

        // === Release reset ===
        #15 reset = 0;
        #1020;
        #100010000;
        //#100000000;
        $finish;
    end



endmodule
