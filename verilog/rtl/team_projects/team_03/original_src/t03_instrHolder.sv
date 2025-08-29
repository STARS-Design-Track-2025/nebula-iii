`default_nettype none
`timescale 1ps/1ps

module t03_instrHolder (
    input logic clk,
    input logic rst,
    input logic [31:0] dataOut,
    input logic freezeInstr,
    output logic [31:0] instruction
);

    logic [31:0] registeredInstr;

    always_ff @ (posedge clk, posedge rst) begin
        if(rst) begin
            registeredInstr = 32'b0;
        end else begin
            registeredInstr = instruction;
        end
    end

    always_comb begin
        if(freezeInstr) begin
            instruction = registeredInstr;
        end else begin
            instruction = dataOut;
        end
    end
endmodule