`timescale 1ms/10ps
module t04_controlUnit_tb;

    logic branchCondition, MemRead, MemWrite, Jal, Jalr;
    logic [31:0] instruction;
    logic [4:0] reg1, reg2, regd;

    t04_control_unit control(
        .BranchConditionFlag(branchCondition), 
        .instruction(instruction), 
        .MemWrite(MemWrite), 
        .MemRead(MemRead), 
        .Jal(Jal),
        .Jalr(Jalr),
        .RegD(regd),
        .Reg2(reg2),
        .Reg1(reg1));

    initial begin
        $dumpfile("t04_controlUnit.vcd");
        $dumpvars(0, t04_controlUnit_tb);

        branchCondition = 0;
        instruction = 32'b0;

        #5;

        //test rtype reg2 = x3 reg1 = x2 regd = x1
        instruction = {32'b00000000001100010000000010110011};
        $display("\nr type instruction. expected: reg2 = x3, reg1 = x2, regd = x1\n\n");
        $display("actual: reg1 = %d, reg2 = %d, regd = %d", reg1, reg2, regd);
        #5;

        //test itype im = 5 reg1 = x2 regd = 1
        instruction = {32'b00000000010100010000000010010011};
        $display("i type instruction, im = 5, reg1 = x2, regd = x1");
        #5;

        //test btype im = 4092 reg2 = 2 reg1 = 1 
        instruction = {32'b11111110001000001000111101100011};
        $display("b type instruction, im = 4092, reg2 = 2, reg1 = 1");
        #5;
        branchCondition = 1'b1;
        #5;

        //test stype im = 8 reg2 = 5 reg1 = 17
        instruction = {32'b00000000010110001010010000100011};
        $display("s type instruction, im = 8, reg2 = 5, reg1 = 17");
        #5;

        //test jalr im = 9 reg1 = 5 regd = 3 
        instruction = {32'b00000000100100101000000111100111};
        $display("jalr, im = 9, reg1 = 5, regd = 3");
        #5;

        //test jal im = 16 regd = 1
        instruction = {32'b00000000000100000000000011101111};
        $display("jal, im = 16, regd = 1");
        #5;

        //test Ltype im = 4 reg1 = 2 regd = 1
        instruction = {32'b00000000010000010010000010000011};
        $display("l type instruction, im = 4, reg1 = 2, regd = 1");
        #5;

        $finish;
    end


endmodule
