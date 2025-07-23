`timescale 1ms / 1ps
module t07_CPU_tb();
    logic [31:0] inst, memData_in, memData_out;
    logic [2:0] rwi;
    logic FPUFlag, clk, nrst, invalError;

    t07_CPU CPU_test(.exInst(inst), .memData_in(memData_in), .exMemData_out(memData_out), 
    .rwi(rwi), .FPUFlag(FPUFlag), .clk(clk), .nrst(nrst), .invalError(invalError));
    
    task reset(); begin
        #1
        nrst = ~nrst;        
        #1
        nrst = ~nrst;
    end
    endtask

    always begin
        #2
        clk = ~clk;
    end

    task test_instr(); begin
        @(posedge clk); 
        inst = 'b00000000001100010000000010110011; //add x1. x2, x3
       
        #10
        inst = 'b01000000001100010000000010110011; //sub x1, x2, x3
    
        #10
        inst = 'b00000000001000001000001001100011; //beq, x1, x2, 5

        #10
        inst = 'b00000000010000000000000011101111; //jal x1, 5

        //ALU result
        #10
        inst = 'b00000000001100010010000010110011; //slt x1, x2

        #10
        inst = 'b00000000011000010011000010010011; //sltiu x1, x2, 6

        #10
        inst = 'b00000000011000010100000010010011; //xori x1, x2, 6
     
        #10
        inst = 'b00000000100100010110000010010011; //ori x1, x2, 9
   
        #10
        inst = 'b00000000100100010111000010010011; //andi x1, x2, 9
     
        #10
        inst = 'b00000000100100010000000010010011; //addi x1, x2, 9

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
        clk = 0;
        nrst = 1;
        reset();
        #1
        test_instr();
        #10


        #1
        $finish;
    end
endmodule