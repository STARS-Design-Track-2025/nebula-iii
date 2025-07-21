module tb;
  logic hz100, reset;
  logic [20:0] pb;
  logic [7:0] left, right,
      ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0;
  logic red, green, blue;

  logic [7:0] txdata;
  logic [7:0] rxdata;
  logic txclk, rxclk;
  logic txready, rxready;

  top dut (.*);

  always #5 hz100 = ~hz100;

  initial begin
    $dumpfile("waves/displayTop.vcd");
    $dumpvars(0, tb);

    pb = 0;
    hz100 = 0;
    reset = 1;
    #20 reset = 0;

    pb[18] = 1; pb[10] = 1; //y
    #5;
    pb[16] = 1;
    #20 pb[18] = 0; pb[16] = 0;
    pb[10] = 0;

    #10; //x
    pb[17] = 1; pb[10] = 1;
    #5;
    pb[16] = 1;
    #20 pb[17] = 0; pb[16] = 0;
    pb[10] = 0;

    #10; //control
    pb[19] = 1; pb[8] = 1;
    #5
    pb[16] = 1;
    #20 pb[19] = 0; pb[16] = 0;
    pb[8] = 0;

    #4000500;
    $finish;
  end
endmodule