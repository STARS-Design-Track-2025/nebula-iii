`default_nettype none
module t03_instrHolder (
	clk,
	rst,
	dataOut,
	freezeInstr,
	instruction
);
	reg _sv2v_0;
	input wire clk;
	input wire rst;
	input wire [31:0] dataOut;
	input wire freezeInstr;
	output reg [31:0] instruction;
	reg [31:0] registeredInstr;
	always @(posedge clk or posedge rst)
		if (rst)
			registeredInstr = 32'b00000000000000000000000000000000;
		else
			registeredInstr = instruction;
	always @(*) begin
		if (_sv2v_0)
			;
		if (freezeInstr)
			instruction = registeredInstr;
		else
			instruction = dataOut;
	end
	initial _sv2v_0 = 0;
endmodule
