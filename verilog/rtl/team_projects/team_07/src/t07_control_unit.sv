module t07_control_unit (
input logic [6:0] Op, //from decoder
input logic [2:0] funct3, //from decoder
input logic [6:0] funct7, //from decoder
output logic [2:0] ALUOp, //to ALU
output logic ALUSrc, regWrite, branch, jump, memWrite, memRead, memToReg, FPUSrc, regEnable, FPUWrite,
output logic [4:0] FPUOp, FPURnd //to FPU
//outputs:
//to register: regWrite (register read/write), regEnable
//pc: branch (condJump), jump (forceJump)
//memory: memRead, memWrite, memToReg
//ALU: ALUOp, ALUSrc
//FPU: FPUOp, FPUSrc, FPURnd
//FPU Reg: FPUWrite
);

always_comb begin
    case(Op)
        7'b0110011: begin /*(R-type)*/
            ALUSrc = 0;
            regWrite = 1;
            branch = 0;
            memWrite = 0;
            memRead = 0;
            memToReg = 0;
            jump = 0;
            reg_enable = 1;
            FPUOp = '0;
            FPUSrc = 0;
            FPURnd = '0;
        end

        7'b 0000011: begin /*(I-Type)*/
            ALUSrc = 1;
            regWrite = 1;
            branch = 0;
            memWrite = 0;
            memRead = 1;
            memToReg = 1;
            jump = 0;
            reg_enable = 1;
            FPUOp = '0;
            FPUSrc = 0;
            FPURnd = '0;
        end

        7'b0100011: begin /*(S-Type)*/
            ALUSrc = 1;
            regWrite = 0;
            branch = 0;
            memWrite = 1;
            memRead = 0;
MemToReg = X
jump = 0
reg_enable = 1
        end
Op == 7'b1100011 (B-Type):
ALUSrc = 0
RegWrite = 0
Branch = 1
MemWrite = 0
MemRead = 0
MemToReg = X
jump = 0
reg_enable = 1
    endcase
end


endmodule