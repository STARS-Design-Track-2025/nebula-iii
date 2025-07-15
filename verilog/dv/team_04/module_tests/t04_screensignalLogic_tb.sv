`timescale 1ms/10ps

module t04_screensignalLogic_tb;
  logic clk, rst, customAck;
  logic [22:0] ct;
  logic [31:0] controlBus, xBus, yBus;

  screensignalLogic screenLogic(.clk(clk), .rst(rst), .controlBus(controlBus), .xBus(xBus), .yBus(yBus), .ct(ct));

  always #2 clk = ~clk;

  always begin
    #4;
    if (customAck == 1) begin
      ct = 0;
    end else begin
      ct++;
    end
  end

  initial begin
    $dumpfile("waves/screensignalLogic.vcd");
    $dumpvars(0, screensignalLogic_tb);

    rst = 1;
    clk = 1;
    ct = 0;
    controlBus = 32'b100; //blue
    xBus = 32'b00000000000000100000000000000010; 
    yBus = 32'b00000000000000100000000000000010; 

    customAck = 0;

    #2;
    rst = 0;

    #142;
    customAck = 1;

    #4;
    customAck = 0;
    controlBus = 32'b10; //black
    xBus = 32'b00000000000000110000000000000011; 
    yBus = 32'b00000000000000110000000000000011; 

    #188;
    customAck = 1;

    #4;
    customAck = 0;
    controlBus = 32'b1000; //green
    xBus = 32'b00000000000000010000000000000001; 
    yBus = 32'b00000000000000010000000000000001; 

    #9;
    rst = 1;

    #3;
    rst = 0;

    #5;

    $finish;
  end
endmodule
