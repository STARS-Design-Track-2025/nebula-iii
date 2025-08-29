`default_nettype none
module t03_text_display (
	Hcnt,
	Vcnt,
	text,
	color,
	x,
	y,
	clk,
	rst
);
	input wire [10:0] Hcnt;
	input wire [10:0] Vcnt;
	input wire [863:0] text;
	output reg [7:0] color;
	input wire [10:0] x;
	input wire [10:0] y;
	input clk;
	input rst;
	wire [10:0] min_x_to_display;
	wire [10:0] min_y_to_display;
	assign min_x_to_display = 37;
	assign min_y_to_display = 29;
	parameter y_length = 8;
	parameter x_length = 108;
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
	reg [10:0] displacement;
	always @(*) begin
		next_color = color;
		displacement = 0;
		if (((Vcnt > y_text_placement) && (Vcnt < (y_text_placement + (y_length * 5)))) && ((Hcnt > x_text_placement) && (Hcnt <= (x_text_placement + x_length)))) begin
			displacement = (x_length * y_length) - ((((Vcnt - y_text_placement) / 5) * x_length) + (Hcnt - x_text_placement));
			if (text[displacement[9:0]])
				next_color[7:0] = 8'b11111111;
			else
				next_color[7:0] = 8'b00000000;
		end
		else
			next_color[7:0] = 8'd0;
	end
endmodule
