`default_nettype none
module t03_imm_gen (
	instruction,
	immediate
);
	input wire [31:0] instruction;
	output reg [31:0] immediate;
	wire [6:0] opcode;
	assign opcode = instruction[6:0];
	always @(*)
		case (opcode)
			7'b0010011: immediate = {{20 {instruction[31]}}, instruction[31:20]};
			7'b0000011: immediate = {{20 {instruction[31]}}, instruction[31:20]};
			7'b0100011: immediate = {{20 {instruction[31]}}, instruction[31:25], instruction[11:7]};
			7'b1100011: immediate = {{19 {instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
			7'b1101111: immediate = {{11 {instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
			7'b1100111: immediate = {{20 {instruction[31]}}, instruction[31:20]};
			7'b0110111: immediate = {instruction[31:12], 12'b000000000000};
			7'b0010111: immediate = {instruction[31:12], 12'b000000000000};
			default: immediate = 1'sb0;
		endcase
endmodule
