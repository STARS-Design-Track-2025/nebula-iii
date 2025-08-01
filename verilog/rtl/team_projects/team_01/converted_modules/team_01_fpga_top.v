`default_nettype none
module team_01_fpga_top (
	hwclk,
	reset,
	pb,
	left,
	right,
	ss7,
	ss6,
	ss5,
	ss4,
	ss3,
	ss2,
	ss1,
	ss0,
	red,
	green,
	blue,
	txdata,
	rxdata,
	txclk,
	rxclk,
	txready,
	rxready
);
	reg _sv2v_0;
	input wire hwclk;
	input wire reset;
	input wire [20:0] pb;
	output wire [7:0] left;
	output wire [7:0] right;
	output wire [7:0] ss7;
	output wire [7:0] ss6;
	output wire [7:0] ss5;
	output wire [7:0] ss4;
	output wire [7:0] ss3;
	output wire [7:0] ss2;
	output wire [7:0] ss1;
	output wire [7:0] ss0;
	output wire red;
	output wire green;
	output wire blue;
	output wire [7:0] txdata;
	input wire [7:0] rxdata;
	output wire txclk;
	output wire rxclk;
	input wire txready;
	input wire rxready;
	wire [4:0] next_block_type;
	wire [47:0] next_block_preview;
	wire clk_25m;
	wire rst;
	assign rst = reset;
	assign clk_25m = hwclk;
	wire J39_b15;
	wire J39_c15;
	wire J40_n4;
	wire [9:0] x;
	wire [9:0] y;
	wire [2:0] grid_color;
	wire [2:0] score_color;
	wire [2:0] starboy_color;
	reg [2:0] final_color;
	wire [2:0] grid_color_movement;
	wire [2:0] grid_color_hold;
	wire [2:0] credits;
	wire onehuzz;
	wire [9:0] current_score;
	wire finish;
	wire gameover;
	wire [3:0] gamestate;
	wire [24:0] scoremod;
	wire [199:0] new_block_array;
	wire speed_mode_o;
	wire [599:0] final_display_color;
	always @(*) begin
		if (_sv2v_0)
			;
		if (starboy_color != 3'b000)
			final_color = starboy_color;
		else if (score_color != 3'b000)
			final_color = score_color;
		else if (credits != 3'b000)
			final_color = credits;
		else
			final_color = grid_color_movement;
	end
	wire right_i;
	wire left_i;
	wire rotate_r;
	wire rotate_l;
	wire start_i;
	t01_debounce NIRAJMENONFANCLUB(
		.clk(clk_25m),
		.pb(pb[0]),
		.button(right_i)
	);
	t01_debounce BENTANAYAYAYAYAYAY(
		.clk(clk_25m),
		.pb(pb[3]),
		.button(left_i)
	);
	t01_debounce nandyhu(
		.clk(clk_25m),
		.pb(pb[4]),
		.button(rotate_r)
	);
	t01_debounce benmillerlite(
		.clk(clk_25m),
		.pb(pb[7]),
		.button(rotate_l)
	);
	t01_vgadriver ryangosling(
		.clk(clk_25m),
		.rst(rst),
		.color_in(final_color),
		.red(red),
		.green(green),
		.blue(blue),
		.hsync(right[0]),
		.vsync(right[1]),
		.x_out(x),
		.y_out(y)
	);
	t01_clkdiv1hz yo(
		.clk(clk_25m),
		.rst(rst),
		.newclk(onehuzz),
		.speed_up(speed_mode_o),
		.scoremod(scoremod)
	);
	t01_speed_controller jorkingtree(
		.clk(clk_25m),
		.reset(rst),
		.current_score(current_score),
		.scoremod(scoremod),
		.gamestate(gamestate)
	);
	t01_tetrisFSM plait(
		.clk(clk_25m),
		.reset(rst),
		.onehuzz(onehuzz),
		.en_newgame(J39_b15),
		.right_i(right),
		.left_i(left),
		.start_i(J39_b15),
		.rotate_r(rotate_r),
		.rotate_l(rotate_l),
		.speed_up_i(J39_c15),
		.display_array(new_block_array),
		.final_display_color(final_display_color),
		.gameover(gameover),
		.score(current_score),
		.speed_mode_o(speed_mode_o),
		.gamestate(gamestate),
		.next_block_type_o(next_block_type),
		.next_block_preview(next_block_preview)
	);
	t01_tetrisGrid miguelohara(
		.x(x),
		.y(y),
		.shape_color(grid_color_movement),
		.final_display_color(final_display_color),
		.gameover(gameover)
	);
	t01_scoredisplay ralsei(
		.clk(onehuzz),
		.rst(rst),
		.score(current_score),
		.x(x),
		.y(y),
		.shape_color(score_color)
	);
	wire [2:0] next_block_color;
	t01_lookahead justinjiang(
		.x(x),
		.y(y),
		.next_block_data(next_block_preview),
		.display_color(next_block_color)
	);
	t01_starboyDisplay silly(
		.clk(onehuzz),
		.rst(rst),
		.x(x),
		.y(y),
		.shape_color(starboy_color)
	);
	t01_tetrisCredits nebulabubu(
		.x(x),
		.y(y),
		.text_color(credits)
	);
	wire [15:0] lfsr_reg;
	wire clk10k;
	localparam [0:0] sv2v_uu_chchch_ext_enable_1 = 1'sb1;
	t01_counter chchch(
		.clk(clk10k),
		.rst(rst),
		.enable(sv2v_uu_chchch_ext_enable_1),
		.lfsr_reg(lfsr_reg),
		.block_type()
	);
	t01_clkdiv10k thebackofmyfavoritestorespencers(
		.clk(clk_25m),
		.rst(rst),
		.newclk(clk10k)
	);
	t01_musicman piercetheveil(
		.clk(clk_25m),
		.rst(rst),
		.square_out(J40_n4),
		.lfsr(lfsr_reg),
		.gameover(gameover)
	);
	initial _sv2v_0 = 0;
endmodule
