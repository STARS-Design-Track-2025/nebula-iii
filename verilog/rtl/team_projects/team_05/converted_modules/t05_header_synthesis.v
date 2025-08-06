`default_nettype none
module t05_header_synthesis (
	clk,
	rst,
	char_index,
	char_found,
	curr_path,
	track_length,
	state_3,
	left,
	num_lefts,
	header,
	enable,
	bit1,
	write_finish
);
	reg _sv2v_0;
	input wire clk;
	input wire rst;
	input wire [7:0] char_index;
	input wire char_found;
	input wire [127:0] curr_path;
	input wire [6:0] track_length;
	input wire state_3;
	input wire left;
	input wire [7:0] num_lefts;
	output reg [8:0] header;
	output reg enable;
	output reg bit1;
	output reg write_finish;
	reg char_added;
	reg [8:0] next_header;
	reg [7:0] zeroes;
	reg [7:0] next_zeroes;
	reg next_enable;
	reg [7:0] count;
	reg [7:0] next_count;
	reg [8:0] path_count;
	reg [8:0] next_path_count;
	reg next_bit1;
	reg next_char_added;
	reg next_write_finish;
	reg start;
	reg next_write_zeroes;
	reg write_zeroes;
	reg next_start;
	reg zero_sent;
	reg next_zero_sent;
	reg write_char_path;
	reg next_write_char_path;
	wire next_first_char;
	reg write_num_lefts;
	reg next_write_num_lefts;
	always @(posedge clk or posedge rst)
		if (rst) begin
			header <= 9'b000000000;
			zeroes <= 0;
			enable <= 0;
			count <= 0;
			bit1 <= 0;
			char_added <= 0;
			write_finish <= 0;
			write_zeroes <= 0;
			start <= 0;
			zero_sent <= 0;
			write_char_path <= 0;
			path_count <= 0;
			write_num_lefts <= 0;
		end
		else begin
			header <= next_header;
			zeroes <= next_zeroes;
			enable <= next_enable;
			count <= next_count;
			bit1 <= next_bit1;
			char_added <= next_char_added;
			write_finish <= next_write_finish;
			write_zeroes <= next_write_zeroes;
			start <= next_start;
			zero_sent <= next_zero_sent;
			write_char_path <= next_write_char_path;
			path_count <= next_path_count;
			write_num_lefts <= next_write_num_lefts;
		end
	always @(*) begin
		if (_sv2v_0)
			;
		next_header = header;
		next_zeroes = zeroes;
		next_enable = enable;
		next_count = count;
		next_bit1 = bit1;
		next_char_added = char_added;
		next_write_finish = write_finish;
		next_write_zeroes = write_zeroes;
		next_start = start;
		next_write_char_path = write_char_path;
		next_path_count = path_count;
		next_write_num_lefts = write_num_lefts;
		next_zero_sent = 0;
		if (char_found == 1'b1) begin
			next_header = {1'b1, char_index};
			next_char_added = 1;
			next_enable = 0;
			next_start = 1;
			next_write_finish = 0;
			next_write_char_path = 1;
		end
		if ((((state_3 && !char_added) && !char_found) && (curr_path[0] == 1)) && (track_length > 0)) begin
			next_write_zeroes = 1;
			next_enable = 1;
			next_write_finish = 0;
			next_bit1 = 0;
			next_zeroes = zeroes + 1;
		end
		else if (write_zeroes) begin
			next_write_finish = 1;
			next_write_zeroes = 0;
			next_enable = 0;
			next_zeroes = 0;
		end
		if (write_char_path) begin
			if (start) begin
				next_enable = 1;
				next_start = 0;
				next_bit1 = header[8];
				next_header = {header[7:0], 1'b0};
				next_count = count + 1;
				next_char_added = 1;
			end
			else if (enable && char_added) begin
				if (count < 9) begin
					next_bit1 = header[8];
					next_header = {header[7:0], 1'b0};
					next_count = count + 1;
				end
				else begin
					next_count = 0;
					next_enable = 0;
					next_write_finish = 1;
					next_bit1 = 0;
					next_char_added = 0;
					next_zero_sent = 0;
					next_path_count = 0;
					next_write_char_path = 0;
					if ((num_lefts != 0) && left) begin
						next_write_num_lefts = 1;
						next_write_finish = 0;
					end
				end
			end
			else begin
				next_bit1 = 1'b0;
				next_count = 0;
			end
		end
		else if (write_num_lefts) begin
			if (count == 0) begin
				next_bit1 = 1'b1;
				next_count = count + 1;
				next_write_char_path = 0;
				next_enable = 1;
			end
			else if (count < 9) begin
				next_enable = 1;
				next_bit1 = num_lefts[8 - count];
				next_count = count + 1;
			end
			else begin
				next_count = 0;
				next_enable = 0;
				next_bit1 = 0;
				next_write_num_lefts = 0;
				next_write_finish = 1;
				next_path_count = 0;
			end
		end
	end
	initial _sv2v_0 = 0;
endmodule
