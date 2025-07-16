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

    input logic [31:0] instruction,
    input logic [2:0] func3,
    output logic [31:0] immediate
);

    logic [6:0] opcode;
   

    assign opcode = instruction[6:0];
    logic [11:0] imm_s;

always_comb begin
    imm_s = 12'b0; // Default assignment to avoid latch inference
    case(opcode)
    7'b0000011: begin // i-type
       immediate = {{20{instruction[31]}}, instruction[31:20]};
    end

    7'b0010011: begin // i-type part 2
        if (func3 == 3'b000 || func3 == 3'b010 || func3 == 3'b011 || func3 == 3'b100 || func3 == 3'b110 || func3 == 3'b111) begin
       immediate = {{20{instruction[31]}}, instruction[31:20]};
        end else if (func3 == 3'b001) begin //slli
            // slli instruction
            immediate = {27'b0, instruction[24:20]}; // Shift amount is in bits 24-20
        end else if (func3 == 3'b101) begin //srli/srai
            immediate = {27'b0, instruction[24:20]};
        end else begin
            immediate = 32'b0; // Default case for unsupported func3

    end
    end

    7'b0100011: begin // S-type
    immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
    end

    7'b1100011: begin // b-type (all types)
        immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
    end
    7'b1101111: begin // j-type
        immediate = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};

    end
    //lui
    7'b0110111: begin // u-type
        immediate = {12'b0, instruction[31:12]};
    end
    //auipc
    7'b0010111: begin // u-type
        immediate = {12'b0, instruction[31:12]};
    end
    default: begin
        immediate = 32'b0;
    end
    endcase
end

endmodule
