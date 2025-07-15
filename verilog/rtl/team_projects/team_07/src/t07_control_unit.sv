module t07_control_unit (
input logic [6:0] Op, //from decoder
input logic [2:0] funct3, //from decoder
input logic [6:0] funct7, //from decoder
input logic [4:0] rs2, //from decoder, for differentiating FPU convert functions
output logic [3:0] ALUOp, //to ALU
output logic ALUSrc, regWrite, branch, jump, memWrite, memRead, memToReg, FPUSrc, regEnable, 
output logic [2:0] regWriteSrc, //regWriteSrc goes to mux outside PC/memory handler/ALU/FPU/ImmGen -> registers, 000 = PC, 001 = MH, 010 = ALU, 011 = FPU, 100 = ImmGen
output logic [4:0] FPUOp, 
output logic [2:0] FPURnd, //to FPU
output logic [1:0] FPUWrite, //to FPUReg
output logic [4:0] rs3 //to FPU registers
//outputs:
//to register: regWrite (register read/write), regEnable
//pc: branch (condJump), jump (forceJump)
//memory: memRead, memWrite, memToReg
//ALU: ALUOp, ALUSrc
//FPU: FPUOp, FPUSrc, FPURnd
//FPU Reg: FPUWrite, rs3 (for 3 input operations)
);

always_comb begin
    case(Op)
        //ALU Cases
        7'b0110011: begin /*(R-type)*/
            regWriteSrc = 3'b010;
            ALUSrc = 0;
            regWrite = 1;
            branch = 0;
            memWrite = 0;
            memRead = 0;
            memToReg = 0;
            jump = 0;
            regEnable = 1;
            FPUOp = '0;
            FPUSrc = 0;
            FPURnd = '0;
            case(funct3) 
                3'b000: if(funct7 == 0000000) begin ALUOp = 4'd0; end else if (funct7 == 0100000) begin ALUOp = 4'd9; end
                3'b001: ALUOp = 4'd3;
                3'b010: ALUOp = 4'd4;
                3'b011: ALUOp = 4'd5;
                3'b100: ALUOp = 4'd9;
                3'b101: if(funct7 == 0000000) begin ALUOp = 4'd7; end else if (funct7 == 0100000) begin ALUOp = 4'd6; end
                3'b110: ALUOp = 4'd2;
                3'b111: ALUOp = 4'd1;
            endcase
        end

        7'b 0000011: begin /*(I-Type)*/
            regWriteSrc = 3'b100;
            ALUSrc = 1;
            regWrite = 1;
            branch = 0;
            memWrite = 0;
            memRead = 1;
            memToReg = 1;
            jump = 0;
            regEnable = 1;
            FPUOp = '0;
            FPUSrc = 0;
            FPURnd = '0;
        end

        7'b0010011: begin /*I-Type*/
            regWriteSrc = 01;
            ALUSrc = 1;
            regWrite = 1;
            branch = 0;
            memWrite = 0;
            memRead = 1;
            memToReg = 1;
            jump = 0;
            regEnable = 1;
            FPUOp = '0;
            FPUSrc = 0;
        end

        7'b0100011: begin /*(S-Type)*/
            ALUSrc = 0;
            regWrite = 0;
            branch = 0;
            memWrite = 1;
            memRead = 0;
            memToReg = 0; //X
            jump = 0;
            regEnable = 1;
            FPUOp = '0;
            FPUSrc = 0;
            FPURnd = '0;
        end
        7'b1100011: begin /*(B-Type)*/
            ALUSrc = 0;
            regWrite = 0;
            branch = 1;
            memWrite = 0;
            memRead = 0;
            memToReg = 0; //X
            jump = 0;
            regEnable = 1;
            FPUOp = '0;
            FPUSrc = 0;
            FPURnd = '0;
        end
        7'b0110111: begin /*(U-type, lui)*/ 
            regWriteSrc = 3'b100; //from immGen
            ALUSrc = 0;
            regWrite = 1;
            FPUSrc = 0;
            FPURnd = '0;
            branch = 0;
            memWrite = 0;
            memRead = 0;
            memToReg = 0;
            jump = 0;
            regEnable = 1;
            FPUOp = '0;
            FPUSrc = 0;
            FPURnd = '0;
        end
        7'b0010111: begin /*(U-Type, auipc)*/
            regWriteSrc = 3'b011; //from ALU
            ALUSrc = 0;
            regWrite = 1;
            branch = 0;
            memWrite = 0;
            memRead = 0;
            memToReg = 0;
            jump = 0;
            regEnable = 1;
            FPUOp = '0;
            FPUSrc = 0;
            FPUSrc = 0;
            FPURnd = '0;
        end
        7'b1101111: begin /*(J-type, jal)*/
            regWriteSrc = 3'b000; //from PC
            ALUSrc = 0;
            regWrite = 1;
            branch = 0;
            memWrite = 0;
            memRead = 0;
            memToReg = 0;
            jump = 1;
            regEnable = 1;
            FPUOp = '0;
            FPUSrc = 0;
            FPURnd = '0;
        end
        7'b1100111: begin /*(J-type, jalr)*/
            regWriteSrc = 3'b000; //from PC
            ALUSrc = 0;
            regWrite = 1;
            branch = 0;
            memWrite = 0;
            memRead = 0;
            memToReg = 0;
            jump = 1;
            regEnable = 1;
            FPUOp = '0;
            FPUSrc = 0;
            FPURnd = '0;
        end

        //FPU Cases
        7'b000011: begin//(FLW - load word)
            FPUOp = 5'b1;
            FPUSrc = 0;
            FPURnd = 010;
            regEnable = 0;
            FPUWrite = 1;
        end 
        7'b0100111: begin //(FSW - store word)
            FPUOp = 5'd2;
            FPUSrc = 0;
            FPURnd = 010;
            regEnable = 0;
            FPUWrite = 0; //reading value from register -> goes to internal mem
        end
        7'b1000011: begin //(FMADD.S) rs1 x rs2 + rs3
            FPUOp = 5'd3;
            FPUSrc = 1;
            regEnable = 0;
            FPUWrite = 1;
            rs3 = funct7[6:2];

        end
        7'b1000111: begin //(FMSUB.S) rs1 x rs2 - rs3
            FPUOp = 5'd4;
            FPUSrc = 1;
            regEnable = 0;
            FPUWrite = 1;
            rs3 = funct7[6:2];
        end
        7'b1001011: begin //(FNMSUB.S) -(rs1 x rs2 - rs3)
            FPUOp = 5'd5;
            FPUSrc = 1;
            regEnable = 0;
            FPUWrite = 1;
            rs3 = funct7[6:2];
        end 
        7'b1001111: begin //(FNMADD.S) -(rs1 x rs2 + rs3)
            FPUOp = 5'd6;
            FPUSrc = 1;
            regEnable = 0;
            FPUWrite = 1;
            rs3 = funct7[6:2];
        end
        7'b1010011: begin //Math
            regEnable = 0;
            FPUWrite = 1;
            case(funct7)
                'b0000000: begin FPUOp = 5'd7; end //ADD
                'b0000100: begin FPUOp = 5'd8; end //SUB
                'b0001000: begin FPUOp = 5'd9; end //MUL
                'b0001100: begin FPUOp = 5'd10; end //DIV
                'b0101100: begin FPUOp = 5'd11; end //SQRT
                'b0010000: begin 
                    if(funct3 == 'b000) begin FPURnd = 'b000; FPUOp = 5'd12; end //FSGNJ
                    if(funct3 == 'b001) begin FPURnd = 'b001; FPUOp = 5'd13; end //FSGNJN
                    if(funct3 == 'b010) begin FPURnd = 'b010; FPUOp = 5'd14; end //FSGNJX
                end 
                7'b0010100: begin
                    if(funct3 == 3'b000) begin FPURnd = 3'b000; FPUOp = 5'd15; end //FMIN
                    if(funct3 == 3'b001) begin FPURnd = 3'b001; FPUOp = 5'd16; end //FMAX
                end
                7'b1010000: begin
                    if(funct3 == 3'b010) begin FPURnd = 3'b010; FPUOp = 5'd17; end //FEQ
                    if(funct3 == 3'b001) begin FPURnd = 3'b001; FPUOp = 5'd18; end //FLT
                    if(funct3 == 3'b000) begin FPURnd = 3'b000; FPUOp = 5'd19; end //FLE
                end
                7'b1111000: begin FPURnd = 3'b000; FPUOp = 5'd20; end //FMV
                7'b1010011: begin 
                    if(funct7 == 7'b1100000) begin
                        if(rs2 == '0) begin FPUOp = 5'd21; end //FCVT.W
                        if(rs2 == 5'b00001) begin FPUOp = 5'd22; end //FCVT.WU
                    end
                    else if(funct7 == 'b1101000) begin
                        if(rs2 == '0) begin FPUOp = 5'd23; end //FCVT.S.W
                        if(rs2 == 5'b00001) begin FPUOp = 5'd24; end //FCVT.S.WU 
                    end
                end
                7'b1110000: begin FPURnd = 3'b001; FPUOp = 5'd25; end //FCLASS.S
                7'b1111000: begin FPURnd = 3'b000; FPUOp = 5'd26; end //FMV.S
                
            endcase

        end 


    endcase
end


endmodule