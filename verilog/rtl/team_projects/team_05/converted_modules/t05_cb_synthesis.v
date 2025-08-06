`default_nettype none
module t05_cb_synthesis (
	clk,
	rst,
	max_index,
	h_element,
	write_finish,
	en_state,
	SRAM_enable,
	read_complete,
	write_complete,
	char_found,
	char_path,
	char_index,
	state_3,
	curr_index,
	curr_path,
	finished,
	track_length,
	num_lefts,
	left,
	pulse,
	cb_r_wr
);
	reg _sv2v_0;
	input wire clk;
	input wire rst;
	input wire [6:0] max_index;
	input wire [70:0] h_element;
	input wire write_finish;
	input wire [3:0] en_state;
	input wire SRAM_enable;
	input wire read_complete;
	input wire write_complete;
	output reg char_found;
	output reg [127:0] char_path;
	output reg [7:0] char_index;
	output reg state_3;
	output reg [6:0] curr_index;
	output reg [127:0] curr_path;
	output reg finished;
	output reg [6:0] track_length;
	output reg [7:0] num_lefts;
	output reg left;
	output reg pulse;
	output reg cb_r_wr;
	reg [8:0] least1;
	reg [8:0] least2;
	reg [127:0] next_path;
	reg [6:0] next_index;
	reg [3:0] next_state;
	reg [3:0] curr_state;
	reg [6:0] next_track_length;
	reg wait_cycle;
	reg next_wait_cycle;
	reg [6:0] pos;
	reg [6:0] next_pos;
	reg sent;
	reg next_sent;
	reg [7:0] next_num_lefts;
	reg next_left;
	reg [127:0] char_path_n;
	reg setup;
	reg setup_n;
	reg left_check;
	reg left_check_n;
	reg check_right;
	reg check_right_n;
	reg [7:0] char_index_n;
	reg [6:0] cb_length;
	reg [6:0] cb_length_n;
	reg [6:0] end_cnt;
	reg [6:0] end_cnt_n;
	reg end_cond;
	reg end_cond_n;
	reg end_check;
	reg end_check_n;
	reg [6:0] end_track;
	reg [6:0] end_track_n;
	reg cb_enable;
	reg cb_enable_n;
	reg [127:0] temp_path;
	reg [127:0] temp_path_n;
	reg [6:0] i;
	reg [6:0] i_n;
	reg pulse_first;
	reg pulse_first_n;
	reg char_found_n;
	reg state_3_n;
	always @(posedge clk or posedge rst)
		if (rst) begin
			curr_state <= 4'd5;
			curr_path <= 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001;
			curr_index <= 1'sb0;
			track_length <= 7'b0000000;
			char_found <= 0;
			pos <= 7'b0000001;
			wait_cycle <= 1;
			sent <= 0;
			num_lefts <= 0;
			left <= 0;
			char_path <= 1'sb0;
			setup <= 1;
			left_check <= 0;
			check_right <= 0;
			cb_length <= 1'sb0;
			end_cnt <= 127;
			end_check <= 0;
			cb_enable <= 0;
			end_cond <= 0;
			end_track <= 1'sb0;
			char_index <= 0;
			temp_path <= 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001;
			i <= 0;
			pulse_first <= 0;
			state_3 <= 0;
		end
		else if (en_state == 4) begin
			char_path <= char_path_n;
			curr_path <= next_path;
			char_found <= char_found_n;
			curr_state <= next_state;
			track_length <= next_track_length;
			curr_index <= next_index;
			pos <= next_pos;
			wait_cycle <= next_wait_cycle;
			sent <= next_sent;
			num_lefts <= next_num_lefts;
			left <= next_left;
			setup <= setup_n;
			left_check <= left_check_n;
			check_right <= check_right_n;
			cb_length <= cb_length_n;
			end_cnt <= end_cnt_n;
			end_check <= end_check_n;
			cb_enable <= cb_enable_n;
			end_cond <= end_cond_n;
			char_index <= char_index_n;
			temp_path <= temp_path_n;
			i <= i_n;
			pulse_first <= pulse_first_n;
			state_3 <= state_3_n;
		end
	always @(*) begin
		if (_sv2v_0)
			;
		least2 = h_element[54:46];
		least1 = h_element[63:55];
		char_found_n = char_found;
		char_path_n = char_path;
		char_index_n = char_index;
		finished = 0;
		pulse = 0;
		state_3_n = state_3;
		end_cond_n = end_cond;
		setup_n = setup;
		next_state = curr_state;
		next_path = curr_path;
		next_index = curr_index;
		next_track_length = track_length;
		next_pos = pos;
		next_wait_cycle = wait_cycle;
		next_sent = sent;
		next_num_lefts = num_lefts;
		next_left = left;
		check_right_n = check_right;
		cb_r_wr = 0;
		left_check_n = left_check;
		cb_length_n = cb_length;
		end_cnt_n = end_cnt;
		end_track_n = end_track;
		end_check_n = end_check;
		cb_enable_n = cb_enable;
		temp_path_n = temp_path;
		i_n = i;
		pulse_first_n = pulse_first;
		case (curr_state)
			4'd5: begin
				state_3_n = 0;
				if (setup) begin
					next_state = 4'd6;
					next_index = max_index;
				end
				else if ((wait_cycle == 0) && !SRAM_enable) begin
					next_state = 4'd0;
					next_pos = 1;
				end
				else begin
					next_state = 4'd5;
					next_wait_cycle = 0;
				end
			end
			4'd0: begin
				state_3_n = 0;
				if ((wait_cycle == 0) && !SRAM_enable) begin
					next_track_length = track_length + 1;
					if ((least1[8] == 1'b0) || (least1 == 9'b110000000)) begin
						if ((least1 != 9'b110000000) && (read_complete || write_complete)) begin
							char_index_n = least1[7:0];
							char_found_n = 1;
							next_state = 4'd6;
							next_wait_cycle = 1;
							next_left = 1;
							if (check_right) begin
								next_path = {curr_path[126:0], 1'b0};
								next_num_lefts = num_lefts + 1;
								char_path_n = next_path;
								check_right_n = 0;
								cb_length_n = cb_length + 1;
							end
						end
						else if (((least1 == 9'b110000000) && (least2 == 9'b110000000)) && (read_complete || write_complete))
							next_state = 4'd4;
					end
					else if ((least1[8] == 1'b1) && (read_complete || write_complete)) begin
						char_found_n = 0;
						pulse = 1;
						next_path = {curr_path[126:0], 1'b0};
						next_num_lefts = num_lefts + 1;
						char_path_n = next_path;
						next_index = least1[6:0] * 2;
						next_wait_cycle = 1;
						cb_length_n = cb_length + 1;
					end
				end
				else
					next_wait_cycle = 0;
			end
			4'd6: begin
				state_3_n = 0;
				char_found_n = 0;
				if (end_check) begin
					end_cnt_n = end_cnt - 1;
					if (cb_enable) begin
						if (curr_path[end_cnt] == 1) begin
							end_track_n = end_track + 1;
							if (end_cnt == 0) begin
								cb_enable_n = 0;
								end_check_n = 0;
								end_cond_n = 1;
							end
							if (end_track == (cb_length - 1)) begin
								end_cond_n = 1;
								cb_enable_n = 0;
								end_check_n = 0;
							end
						end
						else begin
							end_check_n = 0;
							cb_enable_n = 0;
						end
					end
					else if (curr_path[end_cnt] == 1)
						cb_enable_n = 1;
				end
				else begin
					pulse = 1;
					next_state = 4'd7;
				end
			end
			4'd7: begin
				state_3_n = 0;
				if (end_cond && write_complete)
					next_state = 4'd4;
				else if (write_complete) begin
					next_state = 4'd3;
					next_wait_cycle = 1;
					next_num_lefts = 0;
					next_left = 0;
				end
				else if (!read_complete && !setup)
					cb_r_wr = 1;
				else if (setup && read_complete) begin
					setup_n = 0;
					next_state = 4'd5;
				end
				else begin
					next_sent = 1;
					next_state = curr_state;
				end
			end
			4'd2: begin
				state_3_n = 0;
				if ((wait_cycle == 0) && (read_complete || write_complete)) begin
					pulse = 1;
					if (pulse_first) begin
						pulse_first_n = 0;
						i_n = i + 1;
					end
					else if (i < cb_length) begin
						if (!least1[8]) begin
							next_state = 4'd0;
							check_right_n = 1;
						end
						else if (!curr_path[cb_length - i] && least1[8]) begin
							next_index = least1[6:0] * 2;
							next_state = 4'd2;
						end
						else if (curr_path[cb_length - i] && least2[8]) begin
							next_index = least2[6:0] * 2;
							next_state = 4'd2;
						end
						i_n = i + 1;
					end
					else if (i == cb_length) begin
						next_path = {1'b0, curr_path[127:1]};
						cb_length_n = cb_length - 1;
						next_state = 4'd1;
						i_n = 0;
					end
				end
				else
					next_wait_cycle = 0;
			end
			4'd3: begin
				state_3_n = 1;
				char_found_n = 0;
				next_wait_cycle = 1;
				if ((curr_path[0] == 1'b1) && (cb_length > 0)) begin
					next_sent = 0;
					next_path = {1'b0, curr_path[127:1]};
					cb_length_n = cb_length - 1;
					next_index = max_index - 2;
					temp_path_n = curr_path;
					pulse_first_n = 1;
					if (next_path[0] && (cb_length > 0))
						next_state = 4'd3;
					else
						next_state = 4'd2;
				end
				else if ((curr_path[0] == 1'b0) && (cb_length > 0)) begin
					next_index = max_index - 2;
					next_path = {1'b0, curr_path[127:1]};
					cb_length_n = cb_length - 1;
					if (!least1[8])
						left_check_n = 1;
					next_state = 4'd1;
				end
				else if ((curr_path[0] == 1'b1) && (cb_length == 0))
					next_state = 4'd4;
			end
			4'd1: begin
				state_3_n = 0;
				next_pos = 1;
				if ((wait_cycle == 0) && !SRAM_enable) begin
					next_track_length = track_length + 1;
					next_wait_cycle = 1;
					if ((least2[8] == 1'b0) || (least2 == 9'b110000000)) begin
						if ((least2 != 9'b110000000) && (read_complete || write_complete)) begin
							end_check_n = 1;
							cb_enable_n = 0;
							end_track_n = 0;
							end_cnt_n = 127;
							char_index_n = least2[7:0];
							char_found_n = 1;
							next_state = 4'd6;
							if (left_check) begin
								next_path = {curr_path[126:0], 1'b1};
								char_path_n = next_path;
								left_check_n = 0;
								cb_length_n = cb_length + 1;
							end
						end
					end
					else if ((least2[8] == 1'b1) && (read_complete || write_complete)) begin
						char_found_n = 0;
						pulse = 1;
						next_path = {curr_path[126:0], 1'b1};
						next_index = least2[6:0] * 2;
						char_path_n = next_path;
						next_num_lefts = 0;
						next_state = 4'd0;
						check_right_n = 1;
						cb_length_n = cb_length + 1;
					end
				end
				else
					next_wait_cycle = 0;
			end
			4'd4: begin
				state_3_n = 0;
				finished = 1;
			end
			default: begin
				state_3_n = 0;
				next_state = curr_state;
			end
		endcase
	end
	initial _sv2v_0 = 0;
endmodule
