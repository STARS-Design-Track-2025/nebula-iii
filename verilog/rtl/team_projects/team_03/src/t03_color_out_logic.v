`default_nettype none
module t03_color_out_logic (
	player_1_sprite,
	player_2_sprite,
	Vcnt,
	Hcnt,
	text_sprite,
	text_color,
	color_out
);
	reg _sv2v_0;
	input wire [7:0] player_1_sprite;
	input wire [7:0] player_2_sprite;
	input wire [10:0] Vcnt;
	input wire [10:0] Hcnt;
	input wire [7:0] text_sprite;
	input wire [7:0] text_color;
	output reg [7:0] color_out;
	wire [10:0] min_x_to_display;
	wire [10:0] min_y_to_display;
	assign min_x_to_display = 37;
	assign min_y_to_display = 29;
	reg [7:0] background_color;
	always @(*) begin
		if (_sv2v_0)
			;
		background_color = 0;
		if ((Hcnt > min_x_to_display) && (Hcnt < 11'd600)) begin
			if ((Vcnt > min_y_to_display) && (Vcnt < 600))
				background_color = 8'b01010111;
			if ((Vcnt >= 600) && (Vcnt < 800))
				background_color = 8'b00010100;
		end
		else
			background_color = 8'b00000000;
		if ((player_1_sprite != 8'd0) && (player_2_sprite != 8'd0))
			color_out = player_1_sprite;
		else if (player_1_sprite != 8'd0)
			color_out = player_1_sprite;
		else if (player_2_sprite != 8'd0)
			color_out = player_2_sprite;
		else if (text_sprite != 8'd0)
			color_out = text_color;
		else
			color_out = background_color;
	end
	initial _sv2v_0 = 0;
endmodule
