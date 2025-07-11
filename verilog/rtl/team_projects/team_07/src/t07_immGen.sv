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

module immGen (
    input logic clk,
    input logic [31:0] instruction,
    
    output logic [31:0] immediate
);

    logic [6:0] operation;
    logic [11:0] imm_temp;

    assign operation = instruction[6:0];
always_comb begin
    case(operation)
    7'b0000011: begin // i-type
       imm_temp = instruction [11:0];
    end
    7'b0100011: begin // s-type
        imm_temp = {instruction[11:5],instruction[4:0]};

    end
    7'b1100011: begin // b-type
        imm_temp = {instruction[12], instruction[10:5], instruction[4:1], instruction[11]};
    end
    7'b1101111: begin // j-type
        imm_temp = {instruction[20], instruction[10:1], instruction[11], instruction[19:12]};

    end
    7'b0110111: begin // u-type
        imm_temp = instruction[31:12];
        
    end
    endcase
end



    



endmodule
