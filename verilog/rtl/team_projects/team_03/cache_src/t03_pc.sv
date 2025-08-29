`default_nettype none
`timescale 1ms/10ps

module t03_pc # (parameter BASE_ADDRESS = 0) (
    input logic clk,
    input logic rst,
    input logic freezePc,
    input logic [31:0] offset,
    input logic [31:0] ALUResult,
    input logic [1:0] control,
    output logic [31:0] currentPc,
    output logic [31:0] currentPc_base_address,
    output logic [31:0] toMemory
);

logic [31:0] nextPc;

always_ff @ (posedge clk, posedge rst) begin
    if(rst) begin
        currentPc <= 32'b0;
    end else if (~freezePc) begin
        currentPc <= nextPc;
    end else begin
        currentPc <= currentPc;
    end
end

always_comb begin
    case(control)
        2'b00: begin
            nextPc = currentPc + 4;
        end
        2'b01: begin
            nextPc = ALUResult;
        end
        2'b10: begin
            nextPc = currentPc + offset;
        end
        2'b11: begin
            nextPc = ALUResult;
        end
    endcase
end

assign toMemory = nextPc + BASE_ADDRESS;
assign currentPc_base_address = currentPc + BASE_ADDRESS;

endmodule