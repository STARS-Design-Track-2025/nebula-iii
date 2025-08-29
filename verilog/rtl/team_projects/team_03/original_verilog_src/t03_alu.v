`default_nettype none
module t03_alu (
	control,
	pc,
	immediate,
	rd1,
	rd2,
	ALUSrc,
	Auipc,
	lui,
	result,
	zero,
	negative,
	overflow
);
	reg _sv2v_0;
	input wire [3:0] control;
	input wire [31:0] pc;
	input wire [31:0] immediate;
	input wire [31:0] rd1;
	input wire [31:0] rd2;
	input wire ALUSrc;
	input wire Auipc;
	input wire lui;
	output reg [31:0] result;
	output reg zero;
	output reg negative;
	output reg overflow;
	reg [31:0] num1;
	reg [31:0] num2;
	wire num1_sign;
	wire num2_sign;
	assign num1_sign = num1[31];
	assign num2_sign = num2[31];
	reg cout;
	reg borrow_out;
	wire [3:0] operation;
	assign operation = control;
	always @(*) begin
		if (_sv2v_0)
			;
		num1 = rd1;
		num2 = rd2;
		if (Auipc)
			num1 = pc;
		else if (lui)
			num1 = 32'd0;
		if (ALUSrc)
			num2 = immediate;
	end
	always @(*) begin
		if (_sv2v_0)
			;
		cout = 0;
		borrow_out = 0;
		case (operation)
			4'b0111: result = num1 & num2;
			4'b0110: result = num1 | num2;
			4'b0000: {cout, result} = num1 + num2;
			4'b1000: {borrow_out, result} = {1'b0, num1} - {1'b0, num2};
			4'b0100: result = num1 ^ num2;
			4'b0001: result = num1 << num2;
			4'b0101: result = num1 >> num2;
			4'b1101: result = num1 >>> num2;
			4'b0010:
				if ((num1_sign == 1) && (num2_sign == 1))
					result = (num1 < num2 ? 0 : 1);
				else if (num1_sign == 1)
					result = 1;
				else if (num2_sign == 1)
					result = 0;
				else
					result = (num1 < num2 ? 1 : 0);
			4'b0011: result = (num1 < num2 ? 1 : 0);
			default: result = 1'sb0;
		endcase
		zero = (result == 0 ? 1 : 0);
		negative = result[31];
		overflow = cout || borrow_out;
	end
	initial _sv2v_0 = 0;
endmodule
