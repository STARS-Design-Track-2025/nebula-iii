`default_nettype none
module t03_hardware_clock (
	clk,
	rst,
	new_counter
);
	reg _sv2v_0;
	input wire clk;
	input wire rst;
	output reg [31:0] new_counter;
	reg [31:0] count;
	reg [31:0] n_count;
	reg [31:0] n_new_counter;
	always @(posedge clk or posedge rst)
		if (rst) begin
			count <= 0;
			new_counter <= 0;
		end
		else begin
			count <= n_count;
			new_counter <= n_new_counter;
		end
	always @(*) begin
		if (_sv2v_0)
			;
		n_count = count;
		n_new_counter = new_counter;
		if (count == 10000) begin
			n_new_counter = new_counter + 1;
			n_count = 0;
		end
		else
			n_count = count + 1;
	end
	initial _sv2v_0 = 0;
endmodule
