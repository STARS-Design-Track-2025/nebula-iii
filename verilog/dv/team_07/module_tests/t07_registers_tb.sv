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
   rst = 0;
   read_reg1 = 0;
   read_reg2 = 0;
   write_reg = 0;
   write_data = 0;
   reg_write = 0;
   enable = 0;


   //apply rst
   #10
   rst = 1;


   // testcases
   // test 1: write to register 5
   write_reg = 5;
   write_data = 32'hA5A5A5A5;
   reg_write = 1;
   enable = 1;
   #10;
   #10;
   
   // test 2: read from register 5
   read_reg1 = 5;
   read_reg2 = 0; // read from zero register
   reg_write = 0; // disable write
   #10;
   #10;
   
   // test 3: enable off, but try to write to register 6
   write_reg = 6; // write to register
   write_data = 32'hFFFFFFFF; // try to write a value
   reg_write = 1; // enable write
   enable = 0;
   #10;
   #10

   //test 4: read from register 0
   read_reg1 = 0;
   read_reg2 = 0;
   reg_write = 0; // disable write
    #10;
    #10;


   //disable writing
   write_reg = 10;
   write_data = 32'hDEADBEEF; // new data to write
   reg_write = 1; // enable write
   enable = 0; // disable writing
   #10;
   read_reg1 = 10; // read from register 10
   #10;
  

   $display("all tests passed");
   $finish;


end


endmodule
// 