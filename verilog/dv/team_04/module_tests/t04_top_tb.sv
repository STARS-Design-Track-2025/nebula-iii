`timescale 1ns/1ps

module t04_top_tb;

    logic clk, rst;
    logic [3:0] row;

    logic screenCsx;
    logic screenDcx;
    logic screenWrx;
    logic [7:0] screenData;

    // DUT instance (no .busy connection here)
    t04_top dut (
        .clk(clk),
        .rst(rst),
        .row(row),
        .screenCsx(screenCsx),
        .screenDcx(screenDcx),
        .screenWrx(screenWrx),
        .screenData(screenData)
    );


    // Clock generation
    always #10 clk = ~clk;


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
        force dut.row = 4'b1000;
        //x2 is multiplier
        //x1 is multicand
        // force dut.datapath.rf.registers[1] = 0;
        // force dut.datapath.rf.registers[2] = 0;        
        $dumpfile("t04_top.vcd");
        $dumpvars(0, t04_top_tb);

        clk = 0;
        rst = 1;
        row = 0;


        // === Release reset ===
        #15 rst = 0;
        #1020;
        #1220;
        #100000000;
        #10000;

       $display("=== Register File Dump ===");
$display("x0  = %0h ", dut.datapath.rf.registers[0]);
$display("x1  = %0h ", dut.datapath.rf.registers[1]);
$display("x2  = %0h ", dut.datapath.rf.registers[2]);
$display("x3  = %0h ", dut.datapath.rf.registers[3]);
$display("x4  = %0h ", dut.datapath.rf.registers[4]);
$display("x5  = %0h ", dut.datapath.rf.registers[5]);
$display("x6  = %0h ", dut.datapath.rf.registers[6]);
$display("x7  = %0h ", dut.datapath.rf.registers[7]);
$display("x8  = %0h ", dut.datapath.rf.registers[8]);
$display("x9  = %0h ", dut.datapath.rf.registers[9]);
$display("x10 = %0h ", dut.datapath.rf.registers[10]);
$display("x11 = %0h ", dut.datapath.rf.registers[11]);
$display("x12 = %0h ", dut.datapath.rf.registers[12]);
$display("x13 = %0h ", dut.datapath.rf.registers[13]);
$display("x14 = %0h ", dut.datapath.rf.registers[14]);
$display("x15 = %0h ", dut.datapath.rf.registers[15]);
$display("x16 = %0h ", dut.datapath.rf.registers[16]);
$display("x17 = %0h ", dut.datapath.rf.registers[17]);
$display("x18 = %0h ", dut.datapath.rf.registers[18]);
$display("x19 = %0h ", dut.datapath.rf.registers[19]);
$display("x20 = %0h ", dut.datapath.rf.registers[20]);
$display("x21 = %0h ", dut.datapath.rf.registers[21]);
$display("x22 = %0h ", dut.datapath.rf.registers[22]);
$display("x23 = %0h ", dut.datapath.rf.registers[23]);
$display("x24 = %0h ", dut.datapath.rf.registers[24]);
$display("x25 = %0h ", dut.datapath.rf.registers[25]);
$display("x26 = %0h ", dut.datapath.rf.registers[26]);
$display("x27 = %0h ", dut.datapath.rf.registers[27]);
$display("x28 = %0h ", dut.datapath.rf.registers[28]);
$display("x29 = %0h ", dut.datapath.rf.registers[29]);
$display("x30 = %0h ", dut.datapath.rf.registers[30]);
$display("x31 = %0h ", dut.datapath.rf.registers[31]);
$display("==========================");
$finish;

    end



endmodule
