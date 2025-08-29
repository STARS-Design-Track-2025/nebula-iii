`default_nettype none
module t03_vertical_counter (
	rst,
	clk,
	Vcnt,
	tc
);
	reg _sv2v_0;
	input wire rst;
	input wire clk;
	output reg [10:0] Vcnt;
	input tc;
	wire [10:0] vcnt_max;
	reg [10:0] next_Vcnt;
	assign vcnt_max = 11'd666;
	always @(posedge clk or posedge rst)
		if (rst) begin
			Vcnt <= 0;
		end
		else begin
			Vcnt <= next_Vcnt;
		end
	always @(*) begin
		if (_sv2v_0)
			;
		next_Vcnt = Vcnt;
		if ((Vcnt <= vcnt_max) && tc)
			next_Vcnt = Vcnt + 1;
		else if (Vcnt > vcnt_max)
			next_Vcnt = 0;
	end
	initial _sv2v_0 = 0;
endmodule
