`timescale 1ms/10ps
module t04_program_counter_tb;
  
  logic clk, rst, Jalr, Jal, Branch, Freeze;
  logic [31:0] PC_Jalr, imm, PC_out, expected_PC_out;

  t04_program_counter DUT (.clk(clk), .rst(rst), .PC_Jalr(PC_Jalr), .Jalr(Jalr), .Jal(Jal), .Branch(Branch), .Freeze(Freeze), .imm(imm), .PC_out(PC_out));

  always begin
    #1
    clk = ~clk;
  end

  task reset();
    rst = 1; #1;
    rst = 0; #1;
  endtask

  task compare(int expected, int actual); 
  begin
    if (expected == actual) begin
      $display("PASSED test case (expected = actual = %d)", expected);
    end else begin
      $display("FAILED test case \n expected = %d, actual = %d", expected, actual);
    end
  end
  endtask  

  initial begin
    // make sure to dump the signals so we can see them in the waveform
    $dumpfile("t04_program_counter.vcd"); //change the vcd vile name to your source file name
    $dumpvars(0, t04_program_counter_tb);

    // initializze variables
    clk = 0;
    rst = 0;
    Jalr = 0;
    Jal = 0;
    Branch = 0;
    Freeze = 0;
    PC_Jalr = '0;
    imm = '0;
    expected_PC_out = 0;
    
    // power on reset
    $display("power on reset\n");
    #1
    reset();
    compare(expected_PC_out, PC_out);

    // normal operation
    $display("\n\nnormal operation\n");
    #12
    expected_PC_out = 28;
    @(negedge clk);
    compare(expected_PC_out, PC_out);
    @(posedge clk);
  
    // freeze
    $display("\n\nfreeze\n");
    @(negedge clk);
    Freeze = 1;
    @(posedge clk);
    expected_PC_out = 32;
    compare(expected_PC_out, PC_out);
    #3
    Freeze = 0;
    @(posedge clk);
    #3
    expected_PC_out = 40;
    compare(expected_PC_out, PC_out);
    @(posedge clk);
    #3

    // branch
    $display("\n\nbranch\n");
    imm = 8;
    Branch = 1;
    #2
    expected_PC_out = 60;
    Branch = 0;
    compare(expected_PC_out, PC_out);
    #4

    // jal and jalr
    $display("\n\njal and jalr\n");
    Jal = 1;
    #2
    expected_PC_out = 80;
    Jal = 0;
    compare(expected_PC_out, PC_out);
    #2
    Jalr = 1;
    #2
    expected_PC_out = 0;
    Jalr = 0;
    compare(expected_PC_out, PC_out);
    #12
    
  // finish the simulation
  #1 $finish;
  end
endmodule