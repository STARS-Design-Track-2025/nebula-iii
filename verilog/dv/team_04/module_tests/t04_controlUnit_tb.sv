`timescale 1ms/10ps
module t04_controlUnit_tb;

    logic branchCondition;
    logic [31:0] instruction;

    t04_control_unit control(.BranchConditionFlag(branchCondition), .instruction(instruction));

    initial begin
        $dumpfile("t04_controlUnit.vcd");
        $dumpvars(0, t04_controlUnit_tb);

        branchCondition = 0;
        instruction = 32'b0;

        #5;

        //test rtype reg2 = x3 reg1 = x2 regd = x1
        instruction = {32'b00000000001100010000000010110011};
        #5;

        //test itype im = 5 reg1 = x2 regd = 1
        instruction = {32'b00000000010100010000000010010011};
        #5;

        //test btype im = 4092 reg2 = 2 reg1 = 1 
        instruction = {32'b11111110001000001000111101100011};
        #5;
        branchCondition = 1'b1;
        #5;

        //test stype im = 8 reg2 = 5 reg1 = 17
        instruction = {32'b00000000010110001010010000100011};
        #5;

        //test jalr im = 9 reg1 = 5 regd = 3 
        instruction = {32'b00000000100100101000000111100111};
        #5;

        //test jal im = 16 regd = 1
        instruction = {32'b00000000000100000000000011101111};
        #5;

        //test Ltype im = 4 reg1 = 2 regd = 1
        instruction = {32'b00000000010000010010000010000011};
        #5;

        $finish;
    end


endmodule
