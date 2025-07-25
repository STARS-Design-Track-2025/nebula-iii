module t04_PC (
    input logic clk,
    input logic rst,
    input logic [31:0] PC_Jalr,
    input logic Jalr,
    input logic Jal,
    input logic i_ack,
    input logic Branch,
    input logic Freeze,
    input logic [31:0] imm,
    output logic [31:0] PC
);

logic [31:0] n_PC;
logic i_ack1;
logic i_ack2;

always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
        PC <= 32'h33000000; //32'h33000000
        i_ack1 <= 0;
        i_ack2 <= 0;
    end
    else begin
        PC <= n_PC;
        i_ack1 <= i_ack;
        i_ack2 <= i_ack1;
    end
end

always_comb begin
    n_PC = PC + 32'd4;
    if (Freeze || (i_ack2 && !i_ack1)) begin
        n_PC = PC;
    end
    else if (Jalr) begin
        n_PC = PC_Jalr;
    end
    else if (Branch || Jal) begin
        n_PC = PC + imm;
    end
    
end
endmodule