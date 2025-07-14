`default_nettype none

// Immediate Generator for Team 07
/* This module generates immediate values from the instruction set.

- It extracts the immediate value based on the instruction format.
- The immediate value is used in various operations within the CPU.
- It supports different instruction types such as R-type, I-type, and J-type.
- The output is a 32-bit immediate value that can be used by the ALU or other components of the CPU.

Instruction types:


I-type: loads and immediate arithmetic operations.
S-type: store operations.
B-type: conditional branch format
J-type: unconditional jump format
U-type: upper immediate for large constants.

*/

module t07_immGen (
    input logic clk,
    input logic [31:0] instruction,
    
    output logic [31:0] immediate
);

    logic [6:0] opcode;
    logic [31:0] imm_temp;

    assign opcode = instruction[6:0];

always_comb begin
    case(opcode)
    7'b0000011: begin // i-type
       imm_temp = {{20{instruction[31]}}, instruction[31:20]};
    end
    7'b0100011: begin // s-type
        imm_temp = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
    end
    7'b1100011: begin // b-type
        imm_temp = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
    end
    7'b1101111: begin // j-type
        imm_temp = { {12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0 };

    end
    7'b0110111: begin // u-type
        imm_temp = {instruction[31:12], 12'b0};
        
    end
    default: begin
        imm_temp = 32'b0;
    end
    endcase
end

endmodule
