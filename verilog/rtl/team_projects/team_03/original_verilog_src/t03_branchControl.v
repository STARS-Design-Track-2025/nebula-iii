`default_nettype none
module t03_branchControl (
	branch,
	jump,
	zero,
	negative,
	overflow,
	control
);
	reg _sv2v_0;
	input wire [2:0] branch;
	input wire [1:0] jump;
	input wire zero;
	input wire negative;
	input wire overflow;
	output reg [1:0] control;
	always @(*) begin
		if (_sv2v_0)
			;
		control[0] = jump == 2'b10;
		if (jump == 2'b01)
			control[1] = 1'b1;
		else
			case (branch)
				3'b000: control[1] = zero;
				3'b001: control[1] = ~zero;
				3'b100: control[1] = negative;
				3'b101: control[1] = ~negative;
				3'b110: control[1] = overflow;
				3'b111: control[1] = ~overflow;
				default: control[1] = 1'b0;
			endcase
	end
	initial _sv2v_0 = 0;
endmodule
