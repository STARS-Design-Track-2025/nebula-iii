//this module is responsible for generating the immediate given the input instruction
//the output immediate is as 32 bit value, which is usually sign extended
`default_nettype none
`timescale 1ps/1ps

module t03_imm_gen(
    input logic [31:0] instruction,
    output logic [31:0] immediate
);
    logic [6:0] opcode;
    assign opcode = instruction[6:0];

    always @(*) begin //Because we are using icarus verilog to simulate
        case (opcode)
            7'b0010011: begin //this is the first part of I-Type instruction
                immediate = {{20{instruction[31]}}, instruction[31:20]};
            end
            7'b0000011: begin //this is the second part of the I-Type instruction (load byte, etc)
                immediate = {{20{instruction[31]}}, instruction[31:20]}; //this has the same instruction as the previous case
            end
            7'b0100011: begin //this is the S-Type Instruction
                immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            end
            7'b1100011: begin //this is B-Type Instruction
                immediate = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            end
            7'b1101111: begin //this is an instruction specific for Jump and Link (JAL)
                immediate = {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            end
            7'b1100111: begin //this is an instruction specific for Jump and Link Reg (JALR)
                immediate = {{20{instruction[31]}}, instruction[31:20]};
            end
            7'b0110111: begin //this is an instruction specific for load upper immediate (LUI)
                immediate = {instruction[31:12], 12'b0};
            end
            7'b0010111: begin //this is an instruction specific for adding upper immediate to PC (AUIPC)
                immediate = {instruction[31:12], 12'b0};
            end
            default: immediate = '0;
        endcase
    end
endmodule