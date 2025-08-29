`default_nettype none
module t03_player_2_display (
	Hcnt,
	Vcnt,
	player,
	color,
	x,
	y,
	is_2_displayed,
	clk,
	rst
);
	reg _sv2v_0;
	input wire [10:0] Hcnt;
	input wire [10:0] Vcnt;
	input wire [2399:0] player;
	output reg [7:0] color;
	input wire [10:0] x;
	input wire [10:0] y;
	output reg is_2_displayed;
	input clk;
	input rst;
	wire [10:0] min_x_to_display;
	wire [10:0] min_y_to_display;
	assign min_x_to_display = 37;
	assign min_y_to_display = 29;
	parameter y_length = 20;
	parameter x_length = 15;
	wire [10:0] x_text_placement;
	wire [10:0] y_text_placement;
	assign x_text_placement = x + min_x_to_display;
	assign y_text_placement = y + min_y_to_display;
	reg [7:0] next_color;
	always @(posedge clk or posedge rst)
		if (rst)
			color <= 0;
		else
			color <= next_color;
	reg [11:0] displacement;
	always @(*) begin
		if (_sv2v_0)
			;
		next_color = color;
		displacement = 0;
		is_2_displayed = 0;
		if (((Vcnt > y_text_placement) && (Vcnt < (y_text_placement + (y_length * 5)))) && ((Hcnt > x_text_placement) && (Hcnt <= (x_text_placement + x_length)))) begin
			displacement = (x_length * y_length) - ((((Vcnt - y_text_placement) / 5) * x_length) + (Hcnt - x_text_placement));
			is_2_displayed = 1;
			if (player[(displacement * 8) + 7-:8] == 8'b11100000)
				next_color[7:0] = 8'b00000111;
			else if (player[(displacement * 8) + 7-:8] != 8'd0)
				next_color[7:0] = player[(displacement * 8) + 7-:8];
			else
				next_color[7:0] = 8'b01010111;
		end
		else begin
			next_color[7:0] = 8'd0;
			is_2_displayed = 0;
		end
	end
	initial _sv2v_0 = 0;
endmodule
