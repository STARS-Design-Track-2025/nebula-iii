`default_nettype none
module t05_bytecount (
	clk,
	en,
	nrst,
	pulse,
	in,
	out,
	out_valid,
	leftover_data,
	leftover_count
);
	input wire clk;
	input wire en;
	input wire nrst;
	input wire pulse;
	input wire [6:0] in;
	output reg [7:0] out;
	output reg out_valid;
	output reg [6:0] leftover_data;
	output reg [2:0] leftover_count;
	reg [13:0] bit_buf;
	reg [3:0] bits_in_buf;
	reg [13:0] bit_buf_next;
	reg [3:0] bits_in_buf_next;
	reg [7:0] out_next;
	reg out_valid_next;
	wire [6:0] leftover_data_next;
	wire [2:0] leftover_count_next;
	reg [6:0] leftover_data_comb;
	reg [2:0] leftover_count_comb;
	reg [3:0] temp_count;
	reg [13:0] temp_buf;
	reg [3:0] shift_amount;
	reg [13:0] mask;
	reg [3:0] leftover_bits;
	reg [6:0] tbam;
	always @(*) begin
		leftover_bits = 1'sb0;
		shift_amount = 1'sb0;
		mask = 1'sb0;
		tbam = 1'sb0;
		bit_buf_next = bit_buf;
		bits_in_buf_next = bits_in_buf;
		out_next = out;
		out_valid_next = 1'b0;
		temp_buf = bit_buf;
		temp_count = bits_in_buf;
		if (pulse) begin
			temp_buf = (bit_buf << 7) | in;
			temp_count = bits_in_buf + 4'd7;
		end
		leftover_count_comb = temp_count[2:0];
		leftover_data_comb = temp_buf[6:0];
		if (temp_count >= 4'd8) begin
			shift_amount = temp_count - 4'd8;
			out_next = temp_buf >> shift_amount;
			out_valid_next = 1'b1;
			leftover_bits = temp_count - 4'd8;
			if (leftover_bits == 0) begin
				bit_buf_next = 14'd0;
				bits_in_buf_next = 4'd0;
				leftover_count_comb = 3'd0;
				leftover_data_comb = 7'd0;
			end
			else begin
				mask = (14'd1 << leftover_bits) - 1;
				bit_buf_next = temp_buf & mask;
				bits_in_buf_next = leftover_bits;
				leftover_count_comb = leftover_bits[2:0];
				tbam = temp_buf & mask;
				leftover_data_comb = tbam[6:0];
			end
		end
		else begin
			bit_buf_next = temp_buf;
			bits_in_buf_next = temp_count;
		end
	end
	always @(posedge clk or negedge nrst)
		if (~nrst) begin
			bit_buf <= 14'd0;
			bits_in_buf <= 4'd0;
			out <= 8'd0;
			out_valid <= 1'b0;
			leftover_count <= leftover_count_next;
			leftover_data <= leftover_data_next;
		end
		else if (en) begin
			bit_buf <= bit_buf_next;
			bits_in_buf <= bits_in_buf_next;
			out <= out_next;
			out_valid <= out_valid_next;
			leftover_count <= leftover_count_next;
			leftover_data <= leftover_data_next;
		end
		else
			out_valid <= 1'b0;
	assign leftover_count_next = leftover_count_comb;
	assign leftover_data_next = leftover_data_comb;
endmodule
