`default_nettype none
module t03_NES_clkdiv_counter (
	clk,
	rst,
	clkdiv,
	finished,
	button_en,
	latch,
	pulse,
	counter
);
	reg _sv2v_0;
	input wire clk;
	input wire rst;
	output reg clkdiv;
	output reg finished;
	output reg button_en;
	output reg latch;
	output reg pulse;
	output reg [15:0] counter;
	reg [3:0] count_div;
	reg [15:0] n_counter;
	reg [3:0] en_counter;
	parameter LATCH_LENGTH = 16'd41667;
	always @(posedge clk or posedge rst)
		if (rst) begin
			clkdiv <= 0;
			count_div <= 0;
			counter <= 0;
			en_counter <= 0;
		end
		else begin
			if (count_div == 3) begin
				count_div <= 0;
				clkdiv <= ~clkdiv;
				counter <= n_counter;
			end
			else begin
				count_div <= count_div + 1;
				counter <= counter;
			end
			en_counter <= en_counter + 1;
		end
	always @(*) begin
		if (_sv2v_0)
			;
		if (counter == LATCH_LENGTH)
			n_counter = 0;
		else
			n_counter = counter + 1;
		if (counter > 16'd264)
			finished = 1;
		else
			finished = 0;
		if (counter < 30)
			latch = 1;
		else
			latch = 0;
		if ((counter > 16'd44) && (counter < 16'd285)) begin
			if (((counter - 45) % 30) <= 14)
				pulse = 1;
			else
				pulse = 0;
		end
		else
			pulse = 0;
		if (((count_div == 3) && ((counter % 16'd30) == 29)) && !finished)
			button_en = 1;
		else
			button_en = 0;
	end
	initial _sv2v_0 = 0;
endmodule
