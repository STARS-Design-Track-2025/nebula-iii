`timescale 1ms/10ps

module t03_control(
input logic [6:0] opcode,
input logic [2:0] funct3,
input logic funct7bit6, //Bit 6 from funct 7
output logic [2:0] branch, //Defined in verilog code
output logic [1:0] jump, //Defined in verilog code
output logic memRead, //0 = We are not reading from memory, 1 = We are reading from memory
output logic memToReg, //0 = Register File gets ALU result, 1 = Register File gets Data Memory Output
output logic [3:0] ALUOp, //What ALU Operation we are performing
output logic auipc, lui, //0 = ALU gets Read Data 1, 1 = ALU gets Program Counter
output logic memWrite, //0 = Not writing to memory, 1 = Writing to memory
output logic [2:0] dataWidth, //Defined in verilog code
output logic ALUsrc, //0 = From Read Data 2, 1 = From Immidiate Generator
output logic regWrite //0 = Not writing to register, 1 = Writing to register
);
typedef enum logic [6:0] {
NOP = 7'b0,
RTYPE = 7'b0110011,
ITYPER = 7'b0010011,
ITYPEL = 7'b0000011,
STYPE = 7'b0100011,
BTYPE = 7'b1100011,
JTYPE = 7'b1101111,
IJTYPE = 7'b1100111,
UTYPE = 7'b0110111,
AUIPC = 7'b0010111,
SYSTYPE = 7'b1110011} OPCODE; //I am going to hopefully implement ecall and ebreak at some point?

typedef enum logic [3:0] {
ADD = 4'b0000,
SUB = 4'b1000,
XOR = 4'b0100,
OR = 4'b0110,
AND = 4'b0111,
SLL = 4'b0001,
SRL = 4'b0101,
SRA = 4'b1101,
SLT = 4'b0010,
SLTU = 4'b0011
} ALUOPERATION;
typedef enum logic [2:0] { //NONE = 3'b011
BEQ = 3'b000,
BNE = 3'b001,
BLT = 3'b100,
BGE = 3'b101,
BLTU = 3'b110,
BGEU = 3'b111
} BRANCHTYPE;
typedef enum logic [1:0] { //NONE = 2'b00
JAL = 2'b01,
JALR = 2'b10
} JUMPTYPE;

typedef enum logic [2:0] {
BYTE = 3'b000,
HALF = 3'b001,
WORD = 3'b010,
UBYTE = 3'b100,
UHALF = 3'b101
} DATAWIDTH;


always_comb begin
dataWidth = funct3; //It's either dont care
//or equal to funct3 for every instruction
//type

case(opcode)
RTYPE: begin
branch = 3'b011;
jump = 2'b0;
memRead = 1'b0;
memToReg = 1'b0;
ALUOp = {funct7bit6, funct3};
memWrite = 1'b0;
ALUsrc = 1'b0;
regWrite = 1'b1;
auipc = 1'b0;
lui = 0;
end
ITYPER: begin
branch = 3'b011;
jump = 2'b0;
memRead = 1'b0;
memToReg = 1'b0;
if(funct3 == 3'h5) begin
ALUOp = {funct7bit6, funct3};
end else begin
ALUOp = {1'b0, funct3};
end
memWrite = 1'b0;
ALUsrc = 1'b1;
regWrite = 1'b1;
auipc = 1'b0;
lui = 0;
end
ITYPEL: begin
branch = 3'b011;
jump = 2'b0;
memRead = 1'b1;
memToReg = 1'b1;
ALUOp = ADD;
memWrite = 1'b0;
ALUsrc = 1'b1;
regWrite = 1'b1;
auipc = 1'b0;
lui = 0;
end
STYPE: begin
branch = 3'b011;
jump = 2'b0;
memRead = 1'b0;
memToReg = 1'b0; //Don't care
ALUOp = ADD;
memWrite = 1'b1;
ALUsrc = 1'b1;
regWrite = 1'b0;
auipc = 1'b0;
lui = 0;
end
BTYPE: begin
branch = funct3;
jump = 2'b0;
memRead = 1'b0;
memToReg = 1'b0;
ALUOp = SUB;
memWrite = 1'b0;
ALUsrc = 1'b0;
regWrite = 1'b0;
auipc = 1'b0;
lui = 0;
end
JTYPE: begin
branch = 3'b011;
jump = JAL;
memRead = 1'b0; //Don't care
memToReg = 1'b0;
ALUOp = 4'b0; //Don't care
memWrite = 1'b0;
ALUsrc = 1'b0; //Don't care
regWrite = 1'b1;
auipc = 1'b0; //Don't care
lui = 0;
end
IJTYPE: begin
branch = 3'b011;
jump = JALR;
memRead = 1'b0; //Don't care
memToReg = 1'b0;
ALUOp = ADD;
memWrite = 1'b0;
ALUsrc = 1'b1;
regWrite = 1'b1;
auipc = 1'b0; //Don't care
lui = 0;
end
UTYPE: begin
branch = 3'b011;
jump = 2'b0;
memRead = 1'b0;
memToReg = 1'b0;
ALUOp = ADD; //With x0 in one of the registers
memWrite = 1'b0;
ALUsrc = 1'b1;
regWrite = 1'b1;
auipc = 1'b0;
lui = 1;
end
AUIPC: begin
branch = 3'b011;
jump = 2'b0;
memRead = 1'b0;
memToReg = 1'b0;
ALUOp = ADD;
memWrite = 1'b0;
ALUsrc = 1'b1;
regWrite = 1'b1;
auipc = 1'b1;
lui = 0;
end
NOP: begin
branch = 3'b011;
jump = 2'b0;
memRead = 1'b0;
memToReg = 1'b0;
ALUOp = ADD;
memWrite = 1'b0;
ALUsrc = 1'b0;
regWrite = 1'b0;
auipc = 1'b0;
lui = 0;
end
default: begin //Basically a NOP instruction
branch = 3'b011;
jump = 2'b0;
memRead = 1'b0;
memToReg = 1'b0;
ALUOp = ADD;
memWrite = 1'b0;
ALUsrc = 1'b0;
regWrite = 1'b0;
auipc = 1'b0;
lui = 0;
end
endcase
end

endmodule