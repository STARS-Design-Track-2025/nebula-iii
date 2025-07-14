module CPU(
    input logic [31:0] inst, memData_in, //intruction from data memory, data from extern memory
    output logic [31:0] addr, memData_out,
    output logic [2:0] rwi,
    output logic FPUFlag
);
    logic clk, rst;
    logic [31:0] instruction, externalMemData, externalMemAddr, externalMem_out;
    logic freeze; //to external memory 
    //decoder out
    logic [6:0] Op, funct7;
    logic [2:0] funct3;
    logic [4:0] rs1, rs2, rd;
    //control out
    logic [3:0] ALUOp;
    logic ALUSrc, regWrite, branch, jump, memWrite, memRead, memToReg, FPUSrc, regEnable;
    logic [4:0] FPUOp, FPURnd;
    logic [1:0] FPUWrite;
    logic [2:0] regWriteSrc;
    //PC output
    logic [31:0] pc_out, linkAddress;
    //ALU output
    logic [2:0] ALUFlags;
    logic [31:0] ALUResult;
    //immediate output
    logic [31:0] immediate; //jumpDist in PC
    //register output
    logic [31:0] dataRead1, dataRead2;
    //mux 
    logic memRegSource; //reg and FPU register
    logic ALU_in2;
    logic regData_in;
    //FPU outputs
    logic [31:0] fcsr_out; //FPU register out
    logic [31:0] FPUResult;
    //memory output
    logic intMem_out; 
    

    t07_decoder decoder(.instruction(instruction), .Op(Op), .funct7(funct7), .funct3(funct3), .rs1(rs1), .rs2(rs2), .rd(rd));
    t07_control_unit control(.regWriteSrc(regWriteSrc), .Op(Op), .funct7(funct7), .funct3(funct3), .ALUOp(ALUOp), .ALUSrc(ALUSrc), .regWrite(regWrite), .branch(branch), .jump(jump), .memWrite(memWrite), .memRead(memRead), .memToReg(memToReg), .FPUSrc(FPUSrc), .regEnable(regEnable), .FPUOp(FPUOp), .FPURnd(FPURnd), .FPUWrite(FPUWrite));
    t07_program_counter pc(.clk(clk), .func3(funct3), .rst(rst), .forceJump(jump), .condJump(branch), .ALU_flags(ALUFlags), .JumpDist(immediate), .programCounter(pc_out), .linkAddress(linkAddress), .freeze(freeze));
    t07_immGen immediate0(.clk(clk), .instruction(instruction), .immediate(immediate));
    t07_registers register(.clk(clk), .rst(rst), .read_reg1(rs1), .read_reg2(rs2), .write_reg(rd), .write_data(regData_in), .reg_write(regWrite), .enable(regEnable), .read_data1(dataRead1), .read_data2(dataRead2));
    t07_cpu_memoryHandler internalMem(.memWrite(memWrite), .memRead(memRead), .memSource(memRegSource), .ALU_address(ALUResult), .FPU_data('0), .Register_dataToMem(dataRead2), .ExtData(externalMemData), .write_data(externalMem_out), .ExtAddress(externalMemAddr), .dataToCPU(intMem_out), .freeze(), .rwi(rwi));
    t07_ALU ALU(.valA(dataRead1), .valB(ALU_in2), .result(ALUResult), .ALUflags(ALUFlags), .ALUOp(ALUOp));
    t07_muxes muxFPUReg(.a(fcsr_out), .b(dataRead2), .sel(FPUSrc), .out(memRegSource)); //check
    t07_muxes muxImmReg(.a(dataRead2), .b(immediate), .sel(ALUSrc), .out(ALU_in2)); //check
    t07_MuxWD toReg(.control_in(regWriteSrc), .ALUResult(ALUResult), .PCResult(pc_out), .FPUResult(FPUResult), .memResult(intMem_out), .immResult(immediate), .writeData(regData_in));

endmodule