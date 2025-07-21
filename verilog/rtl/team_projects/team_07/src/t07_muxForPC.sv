module t07_muxForPC (
    input logic [31:0] immediate, ALUResult,
    input logic [6:0] Op,
    output logic [31:0] PCJump
);

always_comb begin
    if(Op == 'b1100111) begin PCJump = ALUResult; end
    else begin PCJump = immediate; end
end
endmodule
