`timescale 1ns / 1ps
module t04_request_unit_tb;

  logic clk, rst, i_ack, d_ack, freeze;
  logic [31:0] PC, mem_address, stored_data, i_address, d_address, mem_store;

  t04_request_unit r1(
    .clk(clk),
    .rst(rst),
    .i_ack(i_ack),
    .d_ack(d_ack),
    .freeze(freeze),
    .PC(PC),
    .mem_address(mem_address),
    .stored_data(stored_data),
    .i_address(i_address),
    .d_address(),
    .mem_store(mem_store));

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
    // dump signals to see them in waveform
    $dumpfile("t04_request_unit.vcd");
    $dumpvars(0, t04_request_unit_tb);

    // initialize signals
    clk = 0;
    rst = 0;
    MemRead = 0;
    MemWrite = 0;
    i_ack = 1;
    d_ack = 1;
    
    

    // finish the simulation
    #1 
    $finish;
  end

endmodule