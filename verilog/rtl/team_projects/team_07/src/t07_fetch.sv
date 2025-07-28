// module to fetch instructions and manage the program counter
module t07_fetch (
    // Inputs
    input logic clk, nrst, busy_o, busy_o_edge,
    input logic [31:0] ExtInstruction, // External instruction input
    input logic [31:0] programCounter, // Current program counter value
    
    // Outputs
    output logic [31:0] Instruction, // Output instruction to CPU control unit
    output logic [31:0] PC_out // Output program counter value  

);

logic [31:0] n_ExtInstruction, n_PC_out; // Next instruction to fetch

always_ff @(negedge nrst, posedge clk) begin
    if (~nrst) begin
        Instruction <= 32'b0; // Reset instruction to zero on reset
        PC_out <= 32'b0; // Reset program counter output to zero
    end if (busy_o_edge == 1) begin
        Instruction <= ExtInstruction; // Fetch instruction from external memory when not frozen
        PC_out <= programCounter; // Update program counter output
    end
end

endmodule