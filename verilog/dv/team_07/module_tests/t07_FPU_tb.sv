`timescale 1ms/10ps

module t07_FPU_tb () ;
    logic clk, nrst, overflow, carryout, busy;
    logic [31:0] valA, valB, valC, fcsr, result;
    logic [4:0] op;
    logic [31:0] out;
    logic [6:0] flags;
    
    t07_FPU fpu (.clk(clk), .nrst(nrst), .valA(valA), .valB(valB), .valC(valC), .fcsr_in(fcsr), .FPUOp(op), .result(result), .FPUflags(flags), .overflowFlag(overflow), .carryout(carryout), .busy(busy));

    initial begin
        $dumpfile("t07_FPU.vcd");
        $dumpvars(0, t07_FPU_tb);

        //#1 clk = ~clk;;

        valA = 32'b10000011001000000000000000000000; //-6.25
        valB = 32'b00000010100010000000000000000000; //5.0625
        valC = 32'b00001001000011000000000000000000; //-9.046875

        //valA = 32'b11111111111111111111111100000000;
        //valA = 32'b00000000000000000000000100000000;
        //valA = 32'd256;
        #5
        fcsr = 32'b00000000000000000000000001000000; //round towards zero

        //fix 0, 1, 2, 3, 6, 7

        // op = 5'd0;
        // #2
        // op = 5'd1;
        // #2
        // // op = 5'd2;
        // #2
        // op = 5'd3; 
        #2
        op = 5'd4;
        #2
        op = 5'd5;
        #2
        // op = 5'd6;
        // #2
        // op = 5'd7;
        // #2
        op = 5'd8;
        #2
        op = 5'd9;
        #2
        op = 5'd10;
        #2
        op = 5'd11;
        #2
        op = 5'd12;
        #2
        op = 5'd13;
        #2
        op = 5'd14;
        #2;
        op = 5'd15;
        #2;
        op = 5'd16;
        #2
        op = 5'd17;
        #2
        op = 5'd18;
        #2
        op = 5'd19;
        #2
        op = 5'd20;
        #2
        op = 5'd21;
        #2
        op = 5'd22;
        #2
        op = 5'd23;

        #1; 
        $finish;
    end
endmodule