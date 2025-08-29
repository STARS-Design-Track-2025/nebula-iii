`default_nettype none
module t03_DPUtop (
	clk,
	rst,
	gameState,
	p1State,
	p2State,
	p1health,
	p2health,
	x1,
	x2,
	y1,
	y2,
	p1Left,
	p2Left,
	left,
	right
);
	input wire clk;
	input wire rst;
	input wire [2:0] gameState;
	input wire [1:0] p1State;
	input wire [1:0] p2State;
	input wire [3:0] p1health;
	input wire [3:0] p2health;
	input wire [10:0] x1;
	input wire [10:0] x2;
	input wire [10:0] y1;
	input wire [10:0] y2;
	input wire p1Left;
	input wire p2Left;
	output wire [1:0] left;
	output wire [7:0] right;
	wire [10:0] Vcnt;
	wire [10:0] Hcnt;
	wire tc;
	wire vsync;
	wire [10:0] vertical_multiplier;
	wire at_display;
	wire color_logic;
	wire hsync;
	wire en;
	wire [7:0] player_1_color_out;
	wire [7:0] player_2_color_out;
	wire [7:0] text_color_out;
	wire [7:0] color;
	assign right[0] = color[7];
	assign right[1] = color[6];
	assign right[2] = color[5];
	assign right[3] = color[4];
	assign right[4] = color[3];
	assign right[5] = color[2];
	assign right[6] = color[1];
	assign right[7] = color[0];
	assign left[0] = hsync;
	assign left[1] = vsync;
	wire [71:0] alphabet;
	wire [863:0] characters;
	wire [2399:0] player_sprite;
	wire is_1_displayed;
	wire is_2_displayed;
	wire clk_2hz;
	wire [11:0] p1health1d;
	wire [11:0] p2health2d;
	wire [7:0] text_color;
	t03_bin4_to_bcd_decoder player_1_health_decoder(
		.health(p1health),
		.phealth(p1health1d)
	);
	t03_bin4_to_bcd_decoder player_2_health_decoder(
		.health(p2health),
		.phealth(p2health2d)
	);
	t03_alphabet_decoder state_decoder(
		.clk(clk),
		.rst(rst),
		.game_state(gameState),
		.alphabet(alphabet),
		.p1health(p1health1d),
		.p2health(p2health2d),
		.text_color(text_color)
	);
	t03_clock_divider clock_divider(
		.hwclk(clk),
		.rst(rst),
		.clkdiv(clk_2hz)
	);
	t03_horizontal_counter horzintal(
		.tc(tc),
		.rst(rst),
		.clk(clk),
		.Hcnt(Hcnt)
	);
	t03_vertical_counter vertical(
		.tc(tc),
		.clk(clk),
		.Vcnt(Vcnt),
		.rst(rst)
	);
	t03_comparator comparer(
		.Hcnt(Hcnt),
		.Vcnt(Vcnt),
		.hsync(hsync),
		.vsync(vsync),
		.at_display(at_display)
	);
	t03_text_lut text_lutter(
		.alphabet(alphabet),
		.characters(characters)
	);
	t03_text_display display_logic(
		.Hcnt(Hcnt),
		.Vcnt(Vcnt),
		.text(characters),
		.color(text_color_out),
		.clk(clk),
		.rst(rst),
		.x(11'd30),
		.y(11'd100)
	);
	t03_player_1_display player_1_display(
		.Hcnt(Hcnt),
		.Vcnt(Vcnt),
		.player(player_sprite),
		.color(player_1_color_out),
		.clk(clk),
		.rst(rst),
		.x(x1),
		.y(11'd500 - y1),
		.is_1_displayed(is_1_displayed)
	);
	t03_player_2_display player_2_display(
		.Hcnt(Hcnt),
		.Vcnt(Vcnt),
		.player(player_sprite),
		.color(player_2_color_out),
		.clk(clk),
		.rst(rst),
		.x(x2),
		.y(11'd500 - y2),
		.is_2_displayed(is_2_displayed)
	);
	t03_player_lut player(
		.player_state({p2State, p1State}),
		.player(player_sprite),
		.is_1_displayed(is_1_displayed),
		.is_2_displayed(is_2_displayed),
		.p1Left(p1Left),
		.p2Left(p2Left)
	);
	t03_color_out_logic color_comparator(
		.player_1_sprite(player_1_color_out),
		.player_2_sprite(player_2_color_out),
		.text_sprite(text_color_out),
		.text_color(text_color),
		.color_out(color),
		.Hcnt(Hcnt),
		.Vcnt(Vcnt)
	);
	wire [31:0] address;
	wire [31:0] mock_data;
endmodule
