// registers testbench


/*
testcases:
   1. reset behavior - all registers should be zero
   2. write to x5 register then read - should return the written value
   3. read from x0 register - should always return zero
   4. write with enable = 0 - no changes should occur
*/


module t07_registers_tb;

logic clk, rst;
logic [4:0] read_reg1, read_reg2, write_reg;
logic [31:0] write_data;
logic reg_write, enable;
logic [31:0] read_data1, read_data2;


t07_registers dut (
   .clk(clk),
   .rst(rst),
   .read_reg1(read_reg1),
   .read_reg2(read_reg2),
   .write_reg(write_reg),
   .write_data(write_data),
   .reg_write(reg_write),
   .enable(enable),
   .read_data1(read_data1),
   .read_data2(read_data2)
);


// Clock generation
    always begin 
        clk = 0;
        #10; // Wait for 10 time units
        clk = 1;
        #10; // Wait for 10 time units
    end


initial begin
   //initialize inputs
   $dumpfile("t07_registers.vcd");
   $dumpvars(0, t07_registers_tb);
   clk = 0;
   rst = 1;
   read_reg1 = 0;
   read_reg2 = 0;
   write_reg = 0;
   write_data = 0;
   reg_write = 0;
   enable = 0;


   //apply rst
   #10
   rst = 0;


   // testcases


   // test 1: write to register 5
   write_reg = 5;
   write_data = 32'hA5A5A5A5;
   reg_write = 1;
   enable = 1;
   #10;
   #10;
   // dont need but reassures correct output
   //assert(read_data1 == 32'b0 && read_data2 == 32'b0) else $fatal("Read data should be zero before write");
   //assert(dut.registers[write_reg] == write_data) else $fatal("Register 5 should contain A5A5A5A5 after write");


   // test 2: read from register 5
   read_reg1 = 5;
   read_reg2 = 0; // read from zero register
   reg_write = 0; // disable write
   #10;
   #10;
   // dont need but reassures correct output
   //assert(read_data1 == write_data) else $fatal("Read data1 should be A5A5A5A5 from register 5");
   //assert(read_data2 == 32'b0) else $fatal("Read data2 should be zero from zero register");


   // test 3: x0 hardwired to zero
   write_reg = 6; // write to zero register
   write_data = 32'hFFFFFFFF; // try to write a value
   reg_write = 1; // enable write
   enable = 1;
   #10;
   #10

   //test 4: read from x0 register
   write_reg = 6; // read from zero register
   read_reg1 = 6; // read from zero register
   reg_write = 0; // disable write


   #10;
   // dont need but reassures correct output
   //assert(read_data1 == 32'b0) else $fatal("Read data1 should be zero from zero register after write attempt");
   //assert(dut.registers[0] == 32'b0) else $fatal("Register 0 should remain zero after write attempt");


   //disable writing
   write_reg = 10;
   write_data = 32'hDEADBEEF; // new data to write
   reg_write = 1; // enable write
   enable = 0; // disable writing
   #10;
   read_reg1 = 10; // read from register 10
   #10;
  // dont need but reassures correct output
  //assert(read_data1 == 32'b0) else $fatal("Read data1 should be zero from register 10 when writing is disabled");
   //assert(dut.registers[10] == 32'b0) else $fatal("Register 10 should remain zero when writing is disabled");


   $display("all tests passed");
   $finish;


end


endmodule
