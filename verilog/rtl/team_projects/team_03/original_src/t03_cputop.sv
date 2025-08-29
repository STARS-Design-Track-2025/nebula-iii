`default_nettype none
`timescale 1ps/1ps
// Empty top module

module t03_cputop (
  // I/O ports
  input  logic clk, rst,
  input  logic ack,
  input logic [31:0] dataOut,
  output logic [31:0] data,
  output logic [31:0] address,
  output logic write,
  output logic read,
  output logic ALUsrc,
  output logic freezePc
);

    logic memRead, memWrite, freezeInstr, addressSrc, memToReg, auipc, regWrite, zero, //MAKE SURE TO ADD BACK ALUSrc
    negative, overflow, lui;
    logic [31:0] offset, ALUResult, currentPc, toMemory, instruction, read_data1, read_data2, immediate;
    logic [1:0] pcControl, jump;
    logic [2:0] branch, dataWidth;
    logic [3:0] ALUOp;

    assign data = read_data2;


    t03_pc pc(.clk(clk), .rst(rst), .freezePc(freezePc), .offset(immediate), .ALUResult(ALUResult), .control(pcControl), .currentPc(currentPc), .toMemory(toMemory));

    t03_requestUnit requestUnit(.clk(clk), .rst(rst), .ack(ack), .memRead(memRead), .memWrite(memWrite), .pcMemory(toMemory), .resultALU(ALUResult),
    .read(read), .write(write), .freezePC(freezePc), .freezeInstr(freezeInstr), .addressSrc(addressSrc), .address(address));

    t03_instrHolder instrHolder(.clk(clk), .rst(rst), .dataOut(dataOut), .freezeInstr(freezeInstr), .instruction(instruction));

    t03_control control(.opcode(instruction[6:0]), .funct3(instruction[14:12]), .funct7bit6(instruction[30]), .branch(branch), .jump(jump), .memRead(memRead),
    .memToReg(memToReg), .ALUOp(ALUOp), .auipc(auipc), .memWrite(memWrite), .dataWidth(dataWidth), .ALUsrc(ALUsrc), .regWrite(regWrite), .lui(lui));

    t03_registerFile registerFile(.clk(clk), .regwrite(regWrite & (~freezePc)), .reset(rst), .memToReg(memToReg), .jal(|jump), .instruction(instruction), 
    .result_ALU(ALUResult), .data_out(dataOut), .pc(currentPc), .read_data1(read_data1), .read_data2(read_data2));

    t03_imm_gen imm_gen(.instruction(instruction), .immediate(immediate));

    t03_alu alu(.control(ALUOp), .pc(currentPc), .immediate(immediate), .rd1(read_data1), .rd2(read_data2), .ALUSrc(ALUsrc), .Auipc(auipc),
    .result(ALUResult), .zero(zero), .negative(negative), .overflow(overflow), .lui(lui));

    t03_branchControl branchControl(.branch(branch), .jump(jump), .zero(zero), .negative(negative), .overflow(overflow), .control(pcControl));


endmodule