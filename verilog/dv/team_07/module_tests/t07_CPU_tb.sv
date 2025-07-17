`timescale 1ns / 1ps
module t07_CPU_tb();
    logic [31:0] inst, memData_in, memData_out;
    logic [2:0] rwi;
    logic FPUFlag, clk, rst;

    t07_CPU CPU_test(.inst(inst), .memData_in(memData_in), .memData_out(memData_out), .rwi(rwi), .FPUFlag(FPUFlag));

    task test_instr(); begin
        inst = 'b00000000000000000000000000110011; //add 
        #10
        inst = 'b01000000000000000000000000110011; //sub
        #10
        inst = 'b00000000000000000000000001100011; //beq
        #10
        inst = 'b00000000000000000000000000010011; //addi
        /*#10
        inst = 'b00000000000000000010000000100011; //sw
        #10
        inst = 'b00000000000000000010000000000011; //lw
        */
    end
    endtask

    initial begin
        $dumpfile("t07_CPU.vcd");
        $dumpvars(0, t07_CPU_tb);

        rst = 0;
        test_instr();

        #1
        $finish;
    end
endmodule