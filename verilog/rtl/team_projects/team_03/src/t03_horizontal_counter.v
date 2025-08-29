`default_nettype none
module t03_horizontal_counter (
	tc,
	rst,
	clk,
	Hcnt
);
	reg _sv2v_0;
	output reg tc;
	input wire rst;
	input wire clk;
	output reg [10:0] Hcnt;
	wire [10:0] hcnt_max;
	reg next_tc;
	reg [10:0] next_Hcnt;
	assign hcnt_max = 11'd208;
	parameter STRETCH_COUNTER = 4;
	always @(posedge clk or posedge rst)
		if (rst) begin
			tc <= 0;
			Hcnt <= 0;
		end
		else begin
			tc <= next_tc;
			Hcnt <= next_Hcnt;
		end
	always @(*) begin
		if (_sv2v_0)
			;
		next_tc = tc;
		next_Hcnt = Hcnt;
		if (Hcnt < hcnt_max) begin
			next_Hcnt = Hcnt + 1;
			next_tc = 0;
		end
		else if (Hcnt >= hcnt_max) begin
			next_tc = 1;
			next_Hcnt = 0;
		end
	end
	initial _sv2v_0 = 0;
endmodule
