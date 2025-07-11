module t07_ALU (
    input logic [31:0] valA, valB,
    input logic [3:0] func3,
    output logic [31:0] result,
    output logic [5:0] ALUflags
);

always_comb begin
    case (op)
        3'd0: result = valA + valB;
        3'd1: result = valA - valB;
        3'd2: result = valA * valB;
        3'd3: result = valA / valB;
        3'd4: result = valA << 1;
        3'd5: result = valA >> 1;
        3'd6: result = valA & valB;
        3'd7: result = valA | valB;
        3'd8
        default: result = 32'b0;
    endcase
end

    
endmodule