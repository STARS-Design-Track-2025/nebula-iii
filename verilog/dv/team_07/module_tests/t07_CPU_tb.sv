`timescale 1ms / 1ps
module t07_CPU_tb();
    logic [31:0] inst, memData_in, memData_out;
    logic [2:0] rwi;
    logic FPUFlag, clk, nrst;

    t07_CPU CPU_test(.exInst(inst), .memData_in(memData_in), .memData_out(memData_out), .rwi(rwi), .FPUFlag(FPUFlag), .clk(clk), .nrst(nrst));
    
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
        @(posedge clk) begin
        inst = 'b00000000000000000000000000110011; //add 
        
        #8
        inst = 'b01000000000000000000000000110011; //sub
        #8
        inst = 'b00000000001000001000110001100011; //beq
        #8
        inst = 'b00000001100000000000000011101111; //jal
        //ALU result
        #8
        inst = 'b00000000010100010010000010010011; //slt
        #4
        inst = 'b00000000010100010011000010010011; //sltiu
        #4
        inst = 'b00000000010100010100000010010011; //xori
        #4
        inst = 'b00000000010100010110000010010011; //ori
        #4
        inst = 'b00000000010100010111000010010011; //andi
        #8
        inst = 'b00000000010100010000000010010011; //addi
    
        /*#10
        inst = 'b00000000000000000010000000100011; //sw
        #10
        inst = 'b00000000000000000010000000000011; //lw
        */
        end
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