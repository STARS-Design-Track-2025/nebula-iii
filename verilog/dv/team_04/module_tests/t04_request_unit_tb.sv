`timescale 1ns / 1ps
module t04_request_unit_tb;

  logic clk, rst, i_ack, d_ack, freeze, MemRead, MemWrite, expected_freeze;
  logic [31:0] PC, mem_address, stored_data, final_address, mem_store, instruction_out, instruction_in, expected_final_address;

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
    .final_address(final_address),
    .instruction_out(instruction_out),
    .instruction_in(instruction_in),
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

  task testcase(logic [31:0] expected_final_address, logic expected_freeze);
    begin
      compare_values(expected_final_address, final_address);
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
    expected_final_address = 32'b0;
    PC = 32'b0;
    mem_address = 32'b0;
    stored_data = 32'b0;
    instruction_in = 32'b0;
    
    // power on reset
    $display("power on reset test case\n");
    begin_reset();
    testcase(32'b0, 1);
    end_reset();
    #4

    $display("normal operation test case\n");
    instruction_in = {32'b00000000001100010000000010110011};
    testcase(32'b0, 1);
    #2
    instruction_in = {32'b00000000010100010000000010010011};
    testcase(32'b0, 1);
    #2
    instruction_in = {32'b00000000100100101000000111100111};
    testcase(32'b0, 1);
    #1
    i_ack = 0;
    d_ack = 0;
    MemRead = 1;
    MemWrite = 1;
    #1
    instruction_in = {32'b00000000000100000000000011101111};
    testcase(32'b0, 1);
    #1
    i_ack = 1;
    d_ack = 1;
    MemRead = 0;
    MemWrite = 0;
    #2
    instruction_in = {32'b00000000010000010010000010000011};
    testcase(32'b0, 1);
    #2






    // finish the simulation
    #1 
    $finish;
  end

endmodule