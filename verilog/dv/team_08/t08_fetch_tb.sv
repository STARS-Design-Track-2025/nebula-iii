`timescale 1ms/10ps
module t08_fetch_tb;
logic  signed [31:0] imm_address = 0;
logic [31:0] ret_address, program_counter;
logic clk =0, nrst = 0, jump =0, branch = 0;
task tfr;
   nrst = 1; #1;
   nrst = 0; #1;
endtask
    
always #1 clk = ~clk;
t08_fetch fetchblk(.clk(clk), .nrst(nrst), .jump(jump), .branch(branch), .imm_address(imm_address), .ret_address(ret_address), .program_counter(program_counter));

initial begin
    $dumpfile("waves/t08_fetch.vcd"); 
    $dumpvars(0, t08_fetch_tb);

    tfr; #2;

    branch = 0; 
    jump = 0;
    #10; //pc counter should be incrementing normally

    branch = 1;
    jump = 0;
    imm_address = 32'd10; 
    #2; // increment by imm_address, return address still 0

    branch = 0; 
    jump = 0;
    #5; //pc counter should be incrementing normally

    branch = 0; 
    jump = 1; 
    imm_address = 32'd10; 
    #2; //  return address saved as previous, pc incremented by imm_address

    branch = 0; 
    jump = 0; 
    #5;

    branch = 0; 
    jump = 1; 
    imm_address = 32'd5; 
    #5;

    branch = 0; 
    jump = 1; 
    imm_address = -10; 
    #5;
    #1; $finish;
    end
endmodule