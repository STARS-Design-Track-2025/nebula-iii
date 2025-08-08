`default_nettype none
module team_01_fpga_top (
	hwclk,
	reset,
	pb,
	J39_b15,
	J39_c15,
	left,
	right,
	red,
	green,
	blue
);
	reg _sv2v_0;
	input wire hwclk;
	input wire reset;
	input wire [20:0] pb;
	input wire J39_b15;
	input wire J39_c15;
	output wire [7:0] left;
	output wire [1:0] right;
	output wire red;
	output wire green;
	output wire blue;
	assign left[4:0] = 1'sb0;
	assign right[1:0] = 1'sb0;
	wire [4:0] next_block_type;
	wire [47:0] next_block_preview;
	wire clk_25m;
	wire rst;
	assign rst = reset;
	assign clk_25m = hwclk;
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
	wire [2:0] next_block_color;
	wire onehuzz;
	wire [9:0] current_score;
	wire finish;
	wire gameover;
	wire [3:0] gamestate;
	wire clk10k;
	wire [15:0] lfsr_reg;
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
		else if (next_block_color != 3'b000)
			final_color = next_block_color;
		else if (credits != 3'b000)
			final_color = credits;
		else
			final_color = grid_color_movement;
	end
	reg [1:0] c_top_state;
	reg [1:0] n_top_state;
	wire [1:0] top_level_state;
	assign top_level_state = c_top_state;
	always @(posedge clk_25m or posedge rst)
		if (rst)
			c_top_state <= 2'd0;
		else
			c_top_state <= n_top_state;
	reg tetris_right;
	reg tetris_left;
	reg tetris_rotate_r;
	reg tetris_rotate_l;
	reg tetris_speed_up;
	wire ai_left;
	wire ai_right;
	wire left_i;
	wire right_i;
	wire rotate_l;
	wire rotate_r;
	always @(*) begin
		if (_sv2v_0)
			;
		n_top_state = c_top_state;
		tetris_right = 0;
		tetris_left = 0;
		tetris_rotate_r = 0;
		tetris_rotate_l = 0;
		tetris_speed_up = 0;
		case (c_top_state)
			2'd0: begin
				tetris_right = right_i;
				if ((gamestate == 0) || (gamestate == 'd9)) begin
					if (pb[16])
						n_top_state = 2'd2;
					else if (pb[19])
						n_top_state = 2'd1;
				end
			end
			2'd1:
				if (gamestate == 'd8)
					n_top_state = 2'd0;
				else begin
					tetris_right = right_i;
					tetris_left = left_i;
					tetris_rotate_r = rotate_r;
					tetris_rotate_l = rotate_l;
					tetris_speed_up = pb[8];
				end
			2'd2:
				if (gamestate == 'd8)
					n_top_state = 2'd0;
				else begin
					tetris_right = ai_right;
					tetris_left = ai_left;
					tetris_rotate_r = 0;
					tetris_rotate_l = 0;
					tetris_speed_up = 1'b1;
				end
			default:
				;
		endcase
	end
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
		.hsync(left[7]),
		.vsync(left[6]),
		.x_out(x),
		.y_out(y)
	);
	wire ai_new_spawn;
	t01_clkdiv1hz yo(
		.clk(clk_25m),
		.rst(rst),
		.newclk(onehuzz),
		.speed_up(speed_mode_o),
		.top_level_state(top_level_state),
		.ai_new_spawn(ai_new_spawn),
		.scoremod(scoremod)
	);
	t01_speed_controller jorkingtree(
		.clk(clk_25m),
		.reset(rst),
		.current_score(current_score),
		.scoremod(scoremod),
		.gamestate(gamestate)
	);
	wire [3:0] ai_blockX;
	wire [4:0] ai_block_type;
	wire ai_col_right;
	wire ai_force_right;
	wire ai_need_rotate;
	wire ai_rotated;
	wire [4:0] current_layer_block_type;
	wire [3:0] ofm_blockX;
	wire [4:0] ofm_block_type;
	wire [4:0] ofm_block_type_input;
	wire ofm_layer_done;
	t01_ai_tetrisFSM plait(
		.clk(clk_25m),
		.reset(rst),
		.onehuzz(onehuzz),
		.right_i(right_i),
		.left_i(left_i),
		.start_i(pb[19]),
		.rotate_r(rotate_r),
		.rotate_l(rotate_l),
		.speed_up_i(tetris_speed_up),
		.display_array(new_block_array),
		.final_display_color(final_display_color),
		.gameover(gameover),
		.score(current_score),
		.speed_mode_o(speed_mode_o),
		.gamestate(gamestate),
		.next_block_type_o(next_block_type),
		.next_block_preview(next_block_preview),
		.top_level_state(top_level_state),
		.ai_done(ofm_layer_done),
		.ai_new_spawn(ai_new_spawn),
		.ai_col_right(ai_col_right),
		.ai_blockX(ai_blockX),
		.ofm_blockX(ofm_blockX),
		.current_block_type(current_layer_block_type),
		.ai_block_type(ai_block_type),
		.ai_need_rotate(ai_need_rotate),
		.ai_rotated(ai_rotated),
		.ofm_block_type_input(ofm_block_type_input),
		.ofm_block_type(ofm_block_type),
		.ai_force_right(ai_force_right)
	);
	t01_tetrisGrid miguelohara(
		.x(x),
		.y(y),
		.shape_color(grid_color_movement),
		.final_display_color(final_display_color),
		.gameover(gameover),
		.top_level_state(top_level_state)
	);
	t01_scoredisplay ralsei(
		.clk(onehuzz),
		.rst(rst),
		.score(current_score),
		.x(x),
		.y(y),
		.shape_color(score_color)
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
	t01_lookahead justinjiang(
		.x(x),
		.y(y),
		.next_block_data(next_block_preview),
		.display_color(next_block_color)
	);
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
		.square_out(left[5]),
		.lfsr(lfsr_reg),
		.gameover(gameover)
	);
	wire c_piece_done;
	wire mmu_all_done;
	wire mmu_done;
	wire extract_start;
	wire extract_ready;
	wire potential_force_right;
	wire [7:0] lines_cleared;
	wire [7:0] holes;
	wire [7:0] bumpiness;
	wire [7:0] height_sum;
	t01_ai_game_engine ai_game_engine(
		.clk(clk_25m),
		.rst(rst),
		.gamestate(gamestate),
		.col_right(ai_col_right),
		.ai_right(ai_right),
		.ai_left(ai_left),
		.falling_blockX(ai_blockX),
		.extract_start(extract_start),
		.ofm_done(ofm_layer_done),
		.current_block_type(current_layer_block_type),
		.ai_new_spawn(ai_new_spawn),
		.need_rotate(ai_need_rotate),
		.rotate_block_type(ai_block_type),
		.ai_rotated(ai_rotated),
		.force_right(ai_force_right)
	);
	t01_ai_feature_extract fe(
		.clk(clk_25m),
		.rst(rst),
		.extract_start(extract_start),
		.tetris_grid(new_block_array),
		.extract_ready(extract_ready),
		.lines_cleared(lines_cleared),
		.holes(holes),
		.bumpiness(bumpiness),
		.height_sum(height_sum),
		.ofm_done(ofm_layer_done)
	);
	t01_ai_ofm ofm(
		.clk(clk_25m),
		.rst(rst || (ai_new_spawn && (gamestate == 'd1))),
		.gamestate(gamestate),
		.mmu_done(extract_ready),
		.blockX_i(ai_blockX),
		.block_type_i(ofm_block_type_input),
		.blockX_o(ofm_blockX),
		.block_type_o(ofm_block_type),
		.done(ofm_layer_done),
		.lines_cleared_i(lines_cleared),
		.bumpiness_i(bumpiness),
		.heights_i(height_sum),
		.holes_i(holes)
	);
	initial _sv2v_0 = 0;
endmodule
