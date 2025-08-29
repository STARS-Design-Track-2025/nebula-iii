`default_nettype none
module t03_pc (
	clk,
	rst,
	freezePc,
	offset,
	ALUResult,
	control,
	currentPc,
	toMemory
);
	reg _sv2v_0;
	parameter BASE_ADDRESS = 0;
	input wire clk;
	input wire rst;
	input wire freezePc;
	input wire [31:0] offset;
	input wire [31:0] ALUResult;
	input wire [1:0] control;
	output reg [31:0] currentPc;
	output wire [31:0] toMemory;
	reg [31:0] nextPc;
	always @(posedge clk or posedge rst)
		if (rst)
			currentPc <= 32'b00000000000000000000000000000000;
		else if (~freezePc)
			currentPc <= nextPc;
		else
			currentPc <= currentPc;
	always @(*) begin
		if (_sv2v_0)
			;
		case (control)
			2'b00: nextPc = currentPc + 4;
			2'b01: nextPc = ALUResult;
			2'b10: nextPc = currentPc + offset;
			2'b11: nextPc = ALUResult;
		endcase
	end
	assign toMemory = nextPc + BASE_ADDRESS;
	initial _sv2v_0 = 0;
endmodule
