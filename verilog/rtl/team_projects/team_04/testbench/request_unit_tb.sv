`timescale 1ns / 1ps
module request_unit_tb;
logic clk, rst, i_ack, d_ack, freeze;
logic [31:0] PC, mem_address, stored_data, i_address, d_address, mem_store;

request_unit r1(.clk(clk),.rst(rst),.i_ack(i_ack),.d_ack(d_ack),.freeze(freeze),.PC(PC),.mem_address(mem_address),.stored_data(stored_data),
.i_address(i_address),.d_address,.mem_store(mem_store));

always #5 clk = ~clk; 







endmodule