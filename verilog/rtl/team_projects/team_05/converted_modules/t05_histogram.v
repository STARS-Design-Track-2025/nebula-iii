`default_nettype none
module t05_histogram (
	clk,
	rst,
	en_state,
	spi_in,
	sram_in,
	busy_i,
	init,
	read_i,
	write_i,
	pulse,
	out_valid,
	out,
	eof,
	complete,
	total,
	sram_out,
	hist_addr,
	wr_r_en,
	get_data,
	confirm,
	out_of_init
);
	reg _sv2v_0;
	input wire clk;
	input wire rst;
	input wire [3:0] en_state;
	input wire [7:0] spi_in;
	input wire [31:0] sram_in;
	input wire busy_i;
	input wire init;
	input wire read_i;
	input wire write_i;
	input wire pulse;
	input wire out_valid;
	input wire [7:0] out;
	output reg eof;
	output reg complete;
	output reg [31:0] total;
	output reg [31:0] sram_out;
	output reg [7:0] hist_addr;
	output reg [1:0] wr_r_en;
	output reg get_data;
	output reg confirm;
	output reg out_of_init;
	reg [3:0] next_state;
	wire [7:0] new_spi;
	reg [3:0] state;
	reg init_edge;
	reg [1:0] wait_cnt;
	reg [1:0] wait_cnt_n;
	reg [7:0] end_file = 8'h1a;
	reg [31:0] total_n;
	reg [1:0] wr_r_en_n;
	reg [7:0] hist_addr_n;
	reg eof_n;
	reg complete_n;
	reg [3:0] timer_n;
	reg [3:0] timer;
	reg confirm_n;
	reg [31:0] sram_out_n;
	reg out_of_init_n;
	always @(posedge clk or posedge rst)
		if (rst) begin
			state <= 4'd0;
			wait_cnt <= 0;
			wr_r_en <= 0;
			total <= 0;
			hist_addr <= 0;
			eof <= 0;
			complete <= 0;
			total <= 0;
			wait_cnt <= 0;
			timer <= 1'sb0;
			sram_out <= 1'sb0;
			init_edge <= 0;
			confirm <= 0;
			out_of_init <= 0;
		end
		else if (en_state == 1) begin
			state <= next_state;
			wait_cnt <= wait_cnt_n;
			wr_r_en <= wr_r_en_n;
			total <= total_n;
			hist_addr <= hist_addr_n;
			eof <= eof_n;
			complete <= complete_n;
			total <= total_n;
			wait_cnt <= wait_cnt_n;
			timer <= timer_n;
			sram_out <= sram_out_n;
			init_edge <= init;
			confirm <= confirm_n;
			out_of_init <= out_of_init_n;
		end
	always @(*) begin
		if (_sv2v_0)
			;
		next_state = state;
		wr_r_en_n = wr_r_en;
		complete_n = complete;
		eof_n = eof;
		hist_addr_n = hist_addr;
		total_n = total;
		wait_cnt_n = wait_cnt;
		timer_n = timer;
		sram_out_n = sram_out;
		out_of_init_n = out_of_init;
		get_data = 0;
		confirm_n = 0;
		case (state)
			4'd0: begin
				wr_r_en_n = 2'd3;
				complete_n = 0;
				eof_n = 0;
				hist_addr_n = 0;
			end
			4'd1:
				if (out_valid) begin
					if (out == 8'h1a) begin
						next_state = 4'd4;
						eof_n = 1;
						wr_r_en_n = 2'd3;
					end
				end
				else if (!out_of_init) begin
					next_state = 4'd0;
					out_of_init_n = 1;
				end
				else if (out_of_init) begin
					next_state = 4'd2;
					wr_r_en_n = 2'd3;
					hist_addr_n = spi_in;
					total_n = total + 1;
				end
			4'd2: begin
				wr_r_en_n = 2'd3;
				if (!busy_i) begin
					next_state = 4'd6;
					get_data = 1;
				end
			end
			4'd6: begin
				wr_r_en_n = 2'd3;
				if (!busy_i) begin
					next_state = 4'd3;
					wr_r_en_n = 2'd1;
					sram_out_n = sram_in + 1;
				end
			end
			4'd7: begin
				wr_r_en_n = 2'd3;
				if (!busy_i) begin
					next_state = 4'd0;
					wr_r_en_n = 2'd3;
				end
			end
			4'd3: begin
				next_state = 4'd7;
				wr_r_en_n = 2'd3;
			end
			4'd5: begin
				next_state = 4'd5;
				complete_n = 1;
				wr_r_en_n = 2'd3;
			end
			4'd4: begin
				next_state = 4'd5;
				total_n = total + 1;
				wr_r_en_n = 2'd3;
			end
			default: next_state = 4'd0;
		endcase
		if (pulse && !busy_i) begin
			next_state = 4'd1;
			wr_r_en_n = 1'sb0;
			confirm_n = 1;
			hist_addr_n = spi_in;
		end
		if (init) begin
			next_state = 4'd3;
			wr_r_en_n = 2'd1;
			sram_out_n = sram_out;
		end
		else if (init_edge && !init) begin
			next_state = 4'd1;
			wr_r_en_n = 2'd0;
		end
	end
	initial _sv2v_0 = 0;
endmodule
