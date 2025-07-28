`timescale 1ms / 1ps
module t07_top_tb();
    logic clk, nrst;
    logic FPUFlag, invalError;

    t07_top top0(.clk(clk), .nrst(nrst), .FPUFlag(FPUFlag), .invalError(invalError));

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

    initial begin
        $dumpfile("t07_top.vcd");
        $dumpvars(0, t07_top_tb);
        clk = 0;
        nrst = 1;
        reset();

        #100
        $finish;
    end

endmodule