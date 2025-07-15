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

    nRst = 0; #1;
    nRst = 1;
    data_in = 0;

    @ (posedge clk);
    //ADDI: store (3 + r1) in r2
    //r2 should now be 3
    instruction = 32'b000000000011_00001_000_00010_0010011;
    
    //addi: immediate(5) + r1(0) => r4, r4 = 5
    @ (posedge clk);
    //ADDI: store (5 + r1) in r4
    //r4 should now be 5
    instruction = 32'b000000000101_00001_000_00100_0010011;
    
    @ (posedge clk);
    //ADD: store (r2 + r4) in r3
    //r3 should now be 8
    instruction = 32'b0000000_00010_00100_000_00011_0110011;
    
    @ (posedge clk);
    //SUB: store (r2 - r3) in r5
    //r5 should now be -5
    instruction = 32'b0100000_00011_00010_000_00101_0110011;
    
    @ (posedge clk);
    //SLL: store (r3 << (r2[4:0])) in r6
    //r6 should now be 64
    instruction = 32'b0000000_00010_00011_001_00110_0110011;

    @ (posedge clk);
    //SLT: determine whether r5 is less than r4, store result in r7
    //r7 should now be 1
    instruction = 32'b0000000_00100_00101_010_00111_0110011;

    @ (posedge clk);
    //SLTU: determine whether r5 is less than r4 (unsigned), store result in r8
    //r8 should now be 0
    instruction = 32'b0000000_00100_00101_011_00010_0110011;

    @ (posedge clk);
    //XOR: store (r4 ^ r7) in r9
    //r9 should now be 4
    instruction = 32'b0000000_00111_00100_100_01001_0110011; 

    @ (posedge clk);
    //SRL: store (r5 >> r7) in r10
    //r10 should now be 1073741821
    instruction = 32'b0000000_00111_00101_101_01010_0110011; //PROBLEM IDENTIFIED: This appears to be behaving as SRA

    @ (posedge clk);
    //SRA: store (r5 >>> r7) in r11
    //r11 should now be 2147483645
    instruction = 32'b0100000_00111_00101_101_01011_0110011; 

    /*
    @ (posedge clk);
    //or
    instruction = 32'b0000000_00000_00001_110_00010_0110011; //

    @ (posedge clk);
    //and
    instruction = 32'b0000000_00000_00001_001_00010_0110011; //

    //I-Type

    @ (posedge clk);
    //addi
    instruction = 32'b000000000011_00001_000_00010_0010011; //

    @ (posedge clk);
    //slti
    instruction = 32'b000000000011_00001_010_00010_0010011; //

    @ (posedge clk);
    //sltiu 
    instruction = 32'b000000000011_00001_011_00010_0010011; //

    @ (posedge clk);
    //xori
    instruction = 32'b000000000011_00001_100_00010_0010011; //

    @ (posedge clk);
    //ori
    instruction = 32'b000000000011_00001_110_00010_0010011; //

    @ (posedge clk);
    //andi
    instruction = 32'b000000000011_00001_111_00010_0010011; //

    @ (posedge clk);
    //slli
    instruction = 32'b0000000_00000_00001_001_00010_0010011; //

    @ (posedge clk);
    //srli
    instruction = 32'b0000000_00000_00001_101_00010_0010011; //

    @ (posedge clk);
    //srai
    instruction = 32'b0100000_00000_00001_101_00010_0010011; //

    @ (posedge clk);
    //lb
    instruction = 32'b000000000011_00001_000_00010_0000011; //

    @ (posedge clk);
    //lh
    instruction = 32'b000000000011_00001_001_00010_0000011; //

    @ (posedge clk);
    //lw
    instruction = 32'b000000000011_00001_010_00010_0000011; //

    @ (posedge clk);
    //lbu
    instruction = 32'b000000000011_00001_100_00010_0000011; //

    @ (posedge clk);
    //lhu
    instruction = 32'b000000000011_00001_101_00010_0000011; //
 
    //S-TYPE
    @ (posedge clk);
    //sb
    instruction = 32'b0000100_00000_00001_000_00010_0100011; //

    @ (posedge clk);
    //sh
    instruction = 32'b0000100_00000_00001_001_00010_0100011; //

    @ (posedge clk);
    //sw
    instruction = 32'b0000100_00000_00001_010_00010_0100011; //

    @ (posedge clk);
    //beq
    instruction = 32'b0000100_00000_00001_000_00010_1100011; //

    @ (posedge clk);
    //bne
    instruction = 32'b0000100_00000_00001_001_00010_1100011; //

    @ (posedge clk);
    //blt
    instruction = 32'b0000100_00000_00001_100_00010_1100011; //

    @ (posedge clk);
    //bge
    instruction = 32'b0000100_00000_00001_101_00010_1100011; //
 
     @ (posedge clk);
    //bltu
    instruction = 32'b0000100_00000_00001_110_00010_1100011; //

    @ (posedge clk);
    //bgeu
    instruction = 32'b0000100_00000_00001_111_00010_1100011; //

    //U-TYPE
    @ (posedge clk);
    //lui
    instruction = 32'b00001000000000001000_00010_0110111; //

    @ (posedge clk);
    //auipc
    instruction = 32'b00001000000000001000_00010_0010111; //

    //J-TYPE
    @ (posedge clk);
    //jal
    instruction = 32'b00001000000000001000_00010_1101111; //
 
    //I-TYPE
    @ (posedge clk);
    //jalr
    instruction = 32'b00001000000000001000_00010_1100111; //
    */
 
    
 #1 $finish;
end
endmodule