`default_nettype none
module t01_ai_feature_extract (
	clk,
	rst,
	extract_start,
	tetris_grid,
	ofm_done,
	extract_ready,
	lines_cleared,
	holes,
	bumpiness,
	height_sum
);
	reg _sv2v_0;
	input wire clk;
	input wire rst;
	input wire extract_start;
	input wire [199:0] tetris_grid;
	input wire ofm_done;
	output reg extract_ready;
	output reg [7:0] lines_cleared;
	output wire [7:0] holes;
	output wire [7:0] bumpiness;
	output wire [7:0] height_sum;
	reg [2:0] c_state;
	reg [2:0] n_state;
	wire [199:0] cleared_array;
	reg [199:0] working_array;
	reg [199:0] line_clear_input_array;
	wire [9:0] clear_score;
	wire [2:0] lines_cleared_tmp;
	reg clear_start;
	wire clear_complete;
	t01_lineclear line_clear_master(
		.clk(clk),
		.reset(rst || (extract_start && extract_ready)),
		.gamestate('d10),
		.start_eval(clear_start),
		.input_array(line_clear_input_array),
		.input_color_array(),
		.output_array(cleared_array),
		.output_color_array(),
		.eval_complete(clear_complete),
		.score(clear_score),
		.lines_cleared_count(lines_cleared_tmp)
	);
	reg [4:0] heights [0:9];
	reg [4:0] n_heights [0:9];
	wire [4:0] bump_spread [0:8];
	reg [3:0] height_column_counter;
	reg [3:0] n_height_column_counter;
	assign height_sum = (((((((({3'b000, heights[0]} + {3'b000, heights[1]}) + {3'b000, heights[2]}) + {3'b000, heights[3]}) + {3'b000, heights[4]}) + {3'b000, heights[5]}) + {3'b000, heights[6]}) + {3'b000, heights[7]}) + {3'b000, heights[8]}) + {3'b000, heights[9]};
	assign bump_spread[0] = (heights[0] > heights[1] ? heights[0] - heights[1] : heights[1] - heights[0]);
	assign bump_spread[1] = (heights[1] > heights[2] ? heights[1] - heights[2] : heights[2] - heights[1]);
	assign bump_spread[2] = (heights[2] > heights[3] ? heights[2] - heights[3] : heights[3] - heights[2]);
	assign bump_spread[3] = (heights[3] > heights[4] ? heights[3] - heights[4] : heights[4] - heights[3]);
	assign bump_spread[4] = (heights[4] > heights[5] ? heights[4] - heights[5] : heights[5] - heights[4]);
	assign bump_spread[5] = (heights[5] > heights[6] ? heights[5] - heights[6] : heights[6] - heights[5]);
	assign bump_spread[6] = (heights[6] > heights[7] ? heights[6] - heights[7] : heights[7] - heights[6]);
	assign bump_spread[7] = (heights[7] > heights[8] ? heights[7] - heights[8] : heights[8] - heights[7]);
	assign bump_spread[8] = (heights[8] > heights[9] ? heights[8] - heights[9] : heights[9] - heights[8]);
	assign bumpiness = ((((((({3'b000, bump_spread[0]} + {3'b000, bump_spread[1]}) + {3'b000, bump_spread[2]}) + {3'b000, bump_spread[3]}) + {3'b000, bump_spread[4]}) + {3'b000, bump_spread[5]}) + {3'b000, bump_spread[6]}) + {3'b000, bump_spread[7]}) + {3'b000, bump_spread[8]};
	reg [7:0] c_holes;
	reg [7:0] n_holes;
	reg [3:0] hole_column_counter;
	reg [3:0] n_hole_column_counter;
	reg found_first_block_reg;
	reg n_found_first_block;
	reg [4:0] first_block_row_reg;
	reg [4:0] n_first_block_row;
	reg [7:0] holes_in_column_reg;
	reg [7:0] n_holes_in_column;
	reg [4:0] hole_scan_row;
	reg [4:0] n_hole_scan_row;
	always @(posedge clk or posedge rst)
		if (rst) begin
			c_state <= 3'd0;
			c_holes <= 8'd0;
			working_array <= 200'd0;
			line_clear_input_array <= 200'd0;
			height_column_counter <= 4'd0;
			hole_column_counter <= 4'd0;
			lines_cleared <= 8'd0;
			heights[0] <= 5'd0;
			heights[1] <= 5'd0;
			heights[2] <= 5'd0;
			heights[3] <= 5'd0;
			heights[4] <= 5'd0;
			heights[5] <= 5'd0;
			heights[6] <= 5'd0;
			heights[7] <= 5'd0;
			heights[8] <= 5'd0;
			heights[9] <= 5'd0;
			found_first_block_reg <= 1'b0;
			first_block_row_reg <= 5'd0;
			holes_in_column_reg <= 8'd0;
			hole_scan_row <= 5'd0;
		end
		else if (clear_start && !extract_start)
			line_clear_input_array <= tetris_grid;
		else if (extract_start) begin
			c_state <= n_state;
			c_holes <= n_holes;
			if ((c_state == 3'd1) && clear_complete) begin
				lines_cleared <= {5'b00000, lines_cleared_tmp};
				working_array <= cleared_array;
			end
			height_column_counter <= n_height_column_counter;
			hole_column_counter <= n_hole_column_counter;
			heights[0] <= n_heights[0];
			heights[1] <= n_heights[1];
			heights[2] <= n_heights[2];
			heights[3] <= n_heights[3];
			heights[4] <= n_heights[4];
			heights[5] <= n_heights[5];
			heights[6] <= n_heights[6];
			heights[7] <= n_heights[7];
			heights[8] <= n_heights[8];
			heights[9] <= n_heights[9];
			found_first_block_reg <= n_found_first_block;
			first_block_row_reg <= n_first_block_row;
			holes_in_column_reg <= n_holes_in_column;
			hole_scan_row <= n_hole_scan_row;
		end
	assign holes = c_holes;
	always @(*) begin
		if (_sv2v_0)
			;
		n_state = c_state;
		n_holes = c_holes;
		extract_ready = 1'b0;
		clear_start = 1'b0;
		n_heights[0] = heights[0];
		n_heights[1] = heights[1];
		n_heights[2] = heights[2];
		n_heights[3] = heights[3];
		n_heights[4] = heights[4];
		n_heights[5] = heights[5];
		n_heights[6] = heights[6];
		n_heights[7] = heights[7];
		n_heights[8] = heights[8];
		n_heights[9] = heights[9];
		n_height_column_counter = height_column_counter;
		n_hole_column_counter = hole_column_counter;
		n_found_first_block = found_first_block_reg;
		n_first_block_row = first_block_row_reg;
		n_holes_in_column = holes_in_column_reg;
		n_hole_scan_row = hole_scan_row;
		case (c_state)
			3'd0: begin
				n_hole_column_counter = 4'd0;
				n_height_column_counter = 4'd0;
				n_holes = 8'd0;
				n_heights[0] = 5'd0;
				n_heights[1] = 5'd0;
				n_heights[2] = 5'd0;
				n_heights[3] = 5'd0;
				n_heights[4] = 5'd0;
				n_heights[5] = 5'd0;
				n_heights[6] = 5'd0;
				n_heights[7] = 5'd0;
				n_heights[8] = 5'd0;
				n_heights[9] = 5'd0;
				n_found_first_block = 1'b0;
				n_first_block_row = 5'd0;
				n_holes_in_column = 8'd0;
				n_hole_scan_row = 5'd0;
				if (extract_start)
					n_state = 3'd1;
			end
			3'd1: begin
				clear_start = 1'b1;
				if (clear_complete) begin
					clear_start = 1'b0;
					n_state = 3'd2;
				end
			end
			3'd2:
				if (height_column_counter >= 4'd10)
					n_state = 3'd3;
				else begin
					n_heights[height_column_counter] = 5'd0;
					begin : sv2v_autoblock_1
						reg signed [31:0] r;
						for (r = 19; r >= 0; r = r - 1)
							if (working_array[(r * 10) + height_column_counter])
								n_heights[height_column_counter] = 5'd20 - r[4:0];
					end
					n_height_column_counter = height_column_counter + 4'd1;
				end
			3'd3:
				if (hole_column_counter >= 4'd10)
					n_state = 3'd4;
				else if (!found_first_block_reg) begin
					if (hole_scan_row >= 5'd20) begin
						n_hole_column_counter = hole_column_counter + 4'd1;
						n_hole_scan_row = 5'd0;
						n_found_first_block = 1'b0;
						n_first_block_row = 5'd0;
						n_holes_in_column = 8'd0;
					end
					else if (working_array[(hole_scan_row * 10) + hole_column_counter]) begin
						n_found_first_block = 1'b1;
						n_first_block_row = hole_scan_row;
						n_hole_scan_row = hole_scan_row + 5'd1;
					end
					else
						n_hole_scan_row = hole_scan_row + 5'd1;
				end
				else if (hole_scan_row >= 5'd20) begin
					n_holes = c_holes + holes_in_column_reg;
					n_hole_column_counter = hole_column_counter + 4'd1;
					n_hole_scan_row = 5'd0;
					n_found_first_block = 1'b0;
					n_first_block_row = 5'd0;
					n_holes_in_column = 8'd0;
				end
				else if (!working_array[(hole_scan_row * 10) + hole_column_counter]) begin
					n_holes_in_column = holes_in_column_reg + 8'd1;
					n_hole_scan_row = hole_scan_row + 5'd1;
				end
				else
					n_hole_scan_row = hole_scan_row + 5'd1;
			3'd4: begin
				extract_ready = 1'b1;
				if (ofm_done)
					n_state = 3'd0;
			end
			default:
				;
		endcase
	end
	initial _sv2v_0 = 0;
endmodule
