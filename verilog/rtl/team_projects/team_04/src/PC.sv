module PC (
    input logic clk,
    input logic rst,
    input logic [31:0] PC_Jalr,
    input logic Jalr,
    input logic Jal,
    input logic Branch,
    input logic Freeze,
    input logic [31:0] imm,
    output logic [31:0] PC
);

logic [31:0] n_PC;

always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
        PC <= 0;
    end
    else begin
        PC <= n_PC;
    end
end

always_comb begin
    n_PC = PC + 32'd4;
    if (Freeze) begin
        n_PC = PC;
    end
    else if (Jalr) begin
        n_PC = PC_Jalr;
    end
    else if (Branch || Jal) begin
        n_PC += imm;
    end
    
end
endmodule