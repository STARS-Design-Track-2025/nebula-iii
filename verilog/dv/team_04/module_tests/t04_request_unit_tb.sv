`timescale 1ns / 1ps
module t04_request_unit_tb;

  logic clk, rst, i_ack, d_ack, freeze, MemRead, MemWrite;
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
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .i_address(i_address),
    .d_address(d_address),
    .mem_store(mem_store));

  always begin
    #1
    clk = ~clk;
  end

  task begin_reset();
    rst = 1; #1;
  endtask

  task end_reset();
    rst = 0; #1;
  endtask

  task compare_values(int expected, int actual); 
  begin
    if (expected == actual) begin
      $display("PASSED test case (expected = actual = %d)", expected);
    end else begin
      $display("FAILED test case \n expected = %d, actual = %d", expected, actual);
    end
  end
  endtask

  task testcase(logic [31:0] expected_addr, logic [31:0] expected_store, logic expected_freeze);
    begin
      compare_values(expected_i, i_address);
      compare_values(expected_d, d_address);
      compare_values(expected_store, mem_store);
      compare_values(expected_freeze, freeze);
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
    expected_i_address = 32'b0;
    expected_d_address = 32'b0;
    expected_mem_store = 32'b0;
    PC = 32'b0;
    mem_address = 32'b0;
    stored_data = 32'b0;
    
    // power on reset
    $display("power on reset test case\n");
    begin_reset();
    testcase(32'b0, 32'b0, 32'b0, 1);
    end_reset();

    // finish the simulation
    #1 
    $finish;
  end

endmodule