`timescale 1ms/10ps

module t07_ALU_tb;
    logic [31:0] valA, valB;
    logic [3:0] op;
    logic [31:0] out;
    logic [6:0] flags;
    
    t07_ALU alu (.valA(valA), .valB(valB), .ALUOp(op), .result(out), .ALUflags(flags));

    initial begin

        $dumpfile("t07_ALU.vcd");
        $dumpvars(0, t07_ALU_tb);

        valA = 32'b11111111111111111111111111111111;
        valB = 32'd4;

        op = 4'd0;
        #2
        op = 4'd1;
        #2
        op = 4'd2;
        #2
        op = 4'd3;
        #2
        op = 4'd4;
        #2
        op = 4'd5;
        #2
        op = 4'd6;
        #2
        op = 4'd7;
        #2
        op = 4'd8;
        #2
        op = 4'd9;

        valA = 32'b01111111111111111111111111111111;
        valB = 32'b01111111111111111111111111111111;

        op = 4'd0;
        #2
        op = 4'd1;
        #2
        op = 4'd2;
        #2
        op = 4'd3;
        #2
        op = 4'd4;
        #2
        op = 4'd5;
        #2
        op = 4'd6;
        #2
        op = 4'd7;
        #2
        op = 4'd8;
        #2
        op = 4'd9;


        #1 $finish;
    end
endmodule