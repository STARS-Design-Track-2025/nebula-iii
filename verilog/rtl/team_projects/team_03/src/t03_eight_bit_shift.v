`default_nettype none
module t03_eight_bit_shift (
	clk,
	rst,
	button_en,
	data,
	finished,
	latchedValue
);
	input wire clk;
	input wire rst;
	input wire button_en;
	input wire data;
	input wire finished;
	output reg [7:0] latchedValue;
	wire [7:0] n_parallelOut;
	reg [7:0] parallelOut;
	wire [7:0] n_latchedValue;
	always @(posedge clk or posedge rst)
		if (rst)
			parallelOut <= 1'sb1;
		else if (button_en)
			parallelOut <= {parallelOut[6:0], data};
	always @(posedge clk or posedge rst)
		if (rst)
			latchedValue <= 1'sb1;
		else if (finished)
			latchedValue <= parallelOut;
endmodule
