`timescale 1ms/10ps
module t08_CPU_tb;
logic clk = 0, nRst;                  //Clock and active-low reset. 
logic [31:0] data_in;             //memory to memory handler: data in
logic [31:0] instruction;         //memory to CPU: instruction 
logic [31:0] data_out;           //memory handler to mmio: data outputted 
logic [31:0] mem_address;        //memory handler to mmio: address in memory
logic read_out, write_out;        //memory handler to mmio: read and write enable


always #1 clk = ~clk;

t08_CPU t08_CPU1(.clk(clk), .nRst(nRst), .data_in(data_in), .instruction(instruction), 
                 .data_out(data_out), .mem_address(mem_address), .read_out(read_out), .write_out(write_out));

initial begin
    // make sure to dump the signals so we can see them in the waveform
    $dumpfile("t08_CPU.vcd"); //change the vcd vile name to your source file name
    $dumpvars(0, t08_CPU_tb);
    nRst = 0;
    #2;
    nRst = 1;
    data_in = 0;
    //addi 
    @ (posedge clk);
    instruction = 32'b000000000011_00001_000_00010_0010011;
    
    @ (posedge clk);
    //addi
    instruction = 32'b000000000101_00001_000_00100_0010011;
    
    @ (posedge clk);
    //add
    instruction = 32'b0000000_00010_00100_000_00011_0110011;
    #10;
    /*
    //sub
    instruction = 32'b0100000_00000_00001_000_00010_0110011;
    #2;
    //sll
    instruction = 32'b0000000_00000_00001_001_00010_0110011;
    #2;
    //slt
    instruction = 32'b0000000_00000_00001_010_00010_0110011;
    #2;
    //sltu
    instruction = 32'b0000000_00000_00001_011_00010_0110011;
    #2;
    //xor
    instruction = 32'b0000000_00000_00001_100_00010_0110011;
    #2;
    //srl
    instruction = 32'b0000000_00000_00001_101_00010_0110011;
    #2;
    //sra
    instruction = 32'b0100000_00000_00001_101_00010_0110011;
    #2;
    //or
    instruction = 32'b0000000_00000_00001_110_00010_0110011;
    #2;
    //and
    instruction = 32'b0000000_00000_00001_001_00010_0110011;
    #2;
    //I-Type
    //addi
    instruction = 32'b000000000011_00001_000_00010_0010011;
    #2;
    //slti
    instruction = 32'b000000000011_00001_010_00010_0010011;
    #2;
    //sltiu
    instruction = 32'b000000000011_00001_011_00010_0010011;
    #2;
    //xori
    instruction = 32'b000000000011_00001_100_00010_0010011;
    #2;
    //ori
    instruction = 32'b000000000011_00001_110_00010_0010011;
    #2;
    //andi
    instruction = 32'b000000000011_00001_111_00010_0010011;
    #2;
    //slli
    instruction = 32'b0000000_00000_00001_001_00010_0010011;
    #2;
    //srli
    instruction = 32'b0000000_00000_00001_101_00010_0010011;
    #2;
    //srai
    instruction = 32'b0100000_00000_00001_101_00010_0010011;
    #2;
    //lb
    instruction = 32'b000000000011_00001_000_00010_0000011;
    #2;
    //lh
    instruction = 32'b000000000011_00001_001_00010_0000011;
    #2;
    //lw
    instruction = 32'b000000000011_00001_010_00010_0000011;
    #2;
    //lbu
    instruction = 32'b000000000011_00001_100_00010_0000011;
    #2;
    //lhu
    instruction = 32'b000000000011_00001_101_00010_0000011;
    #2;
    //S-TYPE
    //sb
    instruction = 32'b0000100_00000_00001_000_00010_0100011;
    #2;
    //sh
    instruction = 32'b0000100_00000_00001_001_00010_0100011;
    #2;
    //sw
    instruction = 32'b0000100_00000_00001_010_00010_0100011;
    #2;
    //beq
    instruction = 32'b0000100_00000_00001_000_00010_1100011;
    #2;
    //bne
    instruction = 32'b0000100_00000_00001_001_00010_1100011;
    #2;
    //blt
    instruction = 32'b0000100_00000_00001_100_00010_1100011;
    #2;
    //bge
    instruction = 32'b0000100_00000_00001_101_00010_1100011;
    #2;
    //bltu
    instruction = 32'b0000100_00000_00001_110_00010_1100011;
    #2;
    //bgeu
    instruction = 32'b0000100_00000_00001_111_00010_1100011;
    #2;
    //U-TYPE
    //lui
    instruction = 32'b00001000000000001000_00010_0110111;
    #2;
    //auipc
    instruction = 32'b00001000000000001000_00010_0010111;
    #2;
    //J-TYPE
    //jal
    instruction = 32'b00001000000000001000_00010_1101111;
    #2;
    //I-TYPE
    //jalr
    instruction = 32'b00001000000000001000_00010_1100111;
    #2;
    */
    
 #1 $finish;
end
endmodule