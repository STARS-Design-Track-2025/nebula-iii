`timescale 1ms/10ps
module t08_control_unit_tb;
  logic [31:0] instruction;
  logic read, write;
  logic [2:0] funct3;
  logic [1:0] data_in_control;
  logic [4:0] reg1, reg2, regd;
  logic en_read_1, en_read_2, en_write;
  logic [31:0] immediate;
  logic [5:0] alu_control;
  logic jump;
  
  t08_control_unit control_unit(.instruction(instruction), .read(read), .write(write), 
        .funct3(funct3), .data_in_control(data_in_control), .reg1(reg1), .reg2(reg2), .regd(regd), .en_read_1(en_read_1), 
        .en_read_2(en_read_2), .en_write(en_write), .immediate(immediate), .alu_control(alu_control), .jump(jump));

  initial begin
    // make sure to dump the signals so we can see them in the waveform
    $dumpfile("t08_control_unit.vcd"); //change the vcd vile name to your source file name
    $dumpvars(0, t08_control_unit_tb);
    //test all possible and some impossible inputs
    //R-Type
    //add
    instruction = 32'b0000000_00000_00001_000_00010_0110011;
    #2;
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
    //Invalid commands
    instruction = 32'd0;
    #2;
    //$display("read=\%b, write=\%b, funct3=\%b, data_in_control=\%b, reg1=\%b, reg2 = \%b, regd = \%b, en_read_1, en_read_2", A, B, Cin, Cout, S);
      
  #1 $finish;
  end
endmodule