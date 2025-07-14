// this module takes an input of what type of jump to perform
// and outputs the next program counter address. 


//In the case of a force jump, the link address is set to the 
//next program counter value and the program counter is set to the
//jump distance plus the current program counter.

// In the case of a conditional jump, the link address is zero
// and the program counter is set to the current program counter value plus
// the jump distance if the condition is met.

// In all other cases, the link address is zero and the program counter
// is set to the current program counter value plus 4.

module program_counter (
    //inputs
    input logic clk, rst,
    input logic forceJump,
    input logic condJump,
    input logic [2:0] ALU_flags,
    input logic [31:0] JumpDist,

    //outputs
    output logic [31:0] programCounter, linkAddress
);
logic [31:0] n_programCounter, n_linkAddress; // Next values for program counter and link address

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        programCounter <= 32'b0; // Reset PC to 0
        linkAddress <= 32'b0; // Reset link address to 0
    end else begin
        programCounter <= n_programCounter; // Default increment
        linkAddress <= n_linkAddress; // Default link address
    end
end

always_comb begin
    if (forceJump) begin
        // If force jump is requested, set link address to next programCounter and move programCounter by the jump
        n_linkAddress = programCounter + 4;
        n_programCounter = programCounter + JumpDist;
    end else if (condJump) begin 
        if (ALU_flags[2]) begin // Assuming ALU_flags[2] indicates a condition met for a branch
            // If condition is met, set link address and jump
            n_linkAddress = 32'b0;
            n_programCounter = programCounter + JumpDist;
        end else begin
            n_linkAddress = 32'b0;
            n_programCounter = programCounter + 4; // No jump, just increment PC
        end
    end else begin
        //Normal operation, just increment program counter
        n_linkAddress = 32'b0;
        n_programCounter = programCounter + 4;
    end
end

// always_ff @(posedge clk or posedge rst) begin
//     if (rst) begin
//         programCounter <= 32'b0; // Reset PC to 0
//         linkAddress <= 32'b0; // Reset link address to 0
//     end else begin
//         if (forceJump) begin
//             // If force jump is requested, set link address to next programCounter and move programCounter by the jump
//             linkAddress <= programCounter + 4;
//             programCounter <= programCounter + JumpDist;
//         end else if (condJump) begin 
//             if (ALU_flags[2]) begin // Assuming ALU_flags[2] indicates a condition met for a branch
//                 // If condition is met, set link address and jump
//                 linkAddress <= 32'b0;
//                 programCounter <= programCounter + JumpDist;
//             end else begin
//                 linkAddress <= 32'b0;
//                 programCounter <= programCounter + 4; // No jump, just increment PC
//             end
//         end else begin
//             //Normal operation, just increment program counter
//             linkAddress <= 32'b0;
//             programCounter <= programCounter + 4;
//         end
//     end
// end
endmodule