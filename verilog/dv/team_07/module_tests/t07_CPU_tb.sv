`timescale 1ns / 1ps
module t07_CPU_tb();
    logic [31:0] inst, memData_in, addr, memData_out;
    logic [2:0] rwi;
    logic FPUFlag;

    task test_instr(); begin
        inst = 'b00000000000000000000000000110011; //add 
        #10
        inst = 'b00000000000000000010000000100011; //sw
        #10
        inst = 'b00000000000000000010000000000011; //lw
        #10
        inst = 'b00000000000000000000000001100011; //beq
    end
    endtask

    initial begin

    end
endmodule