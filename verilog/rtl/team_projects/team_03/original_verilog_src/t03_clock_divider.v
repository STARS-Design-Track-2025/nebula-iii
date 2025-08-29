`default_nettype none
module t03_clock_divider (
	hwclk,
	clkdiv,
	rst
);
	reg _sv2v_0;
	input wire hwclk;
	output reg clkdiv;
	input rst;
	reg [22:0] ctr;
	reg [22:0] next_ctr;
	reg next_clk;
	always @(posedge hwclk or posedge rst)
		if (rst) begin
			ctr <= 0;
			clkdiv <= 0;
		end
		else begin
			ctr <= next_ctr;
			clkdiv <= next_clk;
		end
	always @(*) begin
		if (_sv2v_0)
			;
		next_clk = hwclk;
		next_ctr = ctr;
		if (next_ctr == 5000000) begin
			next_ctr = 0;
			next_clk = 1;
		end
		else begin
			next_ctr = next_ctr + 1;
			next_clk = 0;
		end
	end
	initial _sv2v_0 = 0;
endmodule
