`timescale 1ns / 1ps
module t07_CPU_tb();
    logic [31:0] inst, memData_in, addr, memData_out;
    logic [2:0] rwi;
    logic FPUFlag;

    task test_instr(); begin
        inst = 00000000000000000000000000110011; //add rd, rs1, rs2
        #5
        inst = 00000000000000000010000000100011; //sw
    end
    endtask

    initial begin

    end
endmodule