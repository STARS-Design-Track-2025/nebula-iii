`default_nettype none
module t05_sram_interface (
	clk,
	rst,
	histogram,
	histgram_addr,
	hist_r_wr,
	hist_read_latch,
	find_least,
	charwipe1,
	charwipe2,
	flv_r_wr,
	pulse_FLV,
	wipe_the_char_1,
	wipe_the_char_2,
	new_node,
	htreeindex,
	htree_write,
	pulse_HTREE,
	htree_r_wr,
	HT_state,
	least1_HTREE,
	least2_HTREE,
	curr_index,
	char_index,
	codebook_path,
	cb_r_wr,
	pulse_CB,
	translation,
	pulse_TRN,
	state,
	wr_en,
	r_en,
	busy_o,
	select,
	addr,
	data_i,
	data_o,
	nulls,
	ht_done,
	write_HT_fin,
	HTREE_complete,
	HT_read_complete,
	sum_2,
	HT_over_complete,
	old_char,
	init,
	nextChar,
	comp_val,
	nextChar_FLV,
	word_cnt,
	FLV_done,
	h_element,
	cb_done,
	CB_read_complete,
	CB_write_complete,
	path,
	TRN_complete,
	ctrl_done
);
	reg _sv2v_0;
	input wire clk;
	input wire rst;
	input wire [31:0] histogram;
	input wire [7:0] histgram_addr;
	input wire [1:0] hist_r_wr;
	input wire hist_read_latch;
	input wire [8:0] find_least;
	input wire [7:0] charwipe1;
	input wire [7:0] charwipe2;
	input wire flv_r_wr;
	input wire pulse_FLV;
	input wire wipe_the_char_1;
	input wire wipe_the_char_2;
	input wire [70:0] new_node;
	input wire [6:0] htreeindex;
	input wire [6:0] htree_write;
	input wire pulse_HTREE;
	input wire htree_r_wr;
	input wire [3:0] HT_state;
	input wire [8:0] least1_HTREE;
	input wire [8:0] least2_HTREE;
	input wire [7:0] curr_index;
	input wire [7:0] char_index;
	input wire [127:0] codebook_path;
	input wire cb_r_wr;
	input wire pulse_CB;
	input wire [7:0] translation;
	input wire pulse_TRN;
	input wire [3:0] state;
	output reg wr_en;
	output reg r_en;
	input wire busy_o;
	output reg [3:0] select;
	output reg [31:0] addr;
	output reg [31:0] data_i;
	input wire [31:0] data_o;
	output reg [63:0] nulls;
	output wire ht_done;
	output reg write_HT_fin;
	output reg HTREE_complete;
	output reg HT_read_complete;
	output reg sum_2;
	output reg HT_over_complete;
	output reg [31:0] old_char;
	output reg init;
	output reg nextChar;
	output reg [63:0] comp_val;
	output reg nextChar_FLV;
	output reg [3:0] word_cnt;
	output reg FLV_done;
	output reg [70:0] h_element;
	output wire cb_done;
	output reg CB_read_complete;
	output reg CB_write_complete;
	output reg [127:0] path;
	output reg TRN_complete;
	output wire [5:0] ctrl_done;
	reg nextChar_n;
	reg [3:0] word_cnt_n;
	reg [63:0] comp_val_n;
	reg [63:0] nulls_n;
	reg [70:0] h_element_n;
	reg [127:0] path_n;
	reg init_n;
	reg [23:0] init_counter;
	reg [23:0] init_counter_n;
	reg busy_o_last;
	reg [31:0] old_char_n;
	reg check;
	reg check_n;
	wire [31:0] HTREE_log;
	assign ctrl_done = 1'sb0;
	assign cb_done = 0;
	assign ht_done = 0;
	assign HTREE_log = {23'd0, find_least} - 32'd128;
	wire [31:0] ht_write_1;
	assign ht_write_1 = {25'd0, htree_write} + 32'd1;
	wire [31:0] ht_index_1_over;
	assign ht_index_1_over = ({25'd0, htreeindex} * 2'd2) + 32'd1;
	reg [2:0] zero_cnt;
	reg [2:0] zero_cnt_n;
	reg FLV_done_n;
	reg [2:0] write_counter_FLV;
	reg [2:0] write_counter_FLV_n;
	reg write_HT_fin_n;
	reg [3:0] counter_HTREE;
	reg [3:0] counter_HTREE_n;
	wire [31:0] char_index_1;
	wire [31:0] char_index_2;
	wire [31:0] char_index_3;
	assign char_index_1 = ({25'd0, char_index[6:0]} * 3'd4) + 32'd1;
	assign char_index_2 = ({25'd0, char_index[6:0]} * 3'd4) + 32'd2;
	assign char_index_3 = ({25'd0, char_index[6:0]} * 3'd4) + 32'd3;
	wire [31:0] curr_index_1;
	assign curr_index_1 = {25'd0, curr_index[6:0]} + 32'd1;
	reg CB_read_counter;
	reg CB_read_counter_n;
	reg [1:0] CB_write_counter;
	reg [1:0] CB_write_counter_n;
	reg CB_read_complete_n;
	reg CB_write_complete_n;
	reg [2:0] TRN_counter;
	reg [2:0] TRN_counter_n;
	reg TRN_complete_n;
	wire [31:0] trn_1;
	wire [31:0] trn_2;
	wire [31:0] trn_3;
	assign trn_1 = ({25'd0, translation[6:0]} * 3'd4) + 32'd1;
	assign trn_2 = ({25'd0, translation[6:0]} * 3'd4) + 32'd2;
	assign trn_3 = ({25'd0, translation[6:0]} * 3'd4) + 32'd3;
	always @(posedge clk or posedge rst)
		if (rst) begin
			word_cnt <= 6;
			comp_val <= 1'sb0;
			nulls <= 1'sb0;
			h_element <= 1'sb0;
			path <= 1'sb0;
			init <= 1;
			init_counter <= 1'sb0;
			busy_o_last <= 0;
			old_char <= 1'sb0;
			check <= 0;
			zero_cnt <= 0;
			FLV_done <= 1'sb0;
			write_counter_FLV <= 0;
			write_HT_fin <= 0;
			counter_HTREE <= 0;
			CB_read_counter <= 0;
			CB_write_counter <= 0;
			CB_read_complete <= 0;
			CB_write_complete <= 0;
			TRN_counter <= 0;
			TRN_complete <= 0;
			nextChar <= 0;
		end
		else begin
			word_cnt <= word_cnt_n;
			comp_val <= comp_val_n;
			nulls <= nulls_n;
			h_element <= h_element_n;
			path <= path_n;
			init <= init_n;
			init_counter <= init_counter_n;
			busy_o_last <= busy_o;
			old_char <= old_char_n;
			check <= check_n;
			write_counter_FLV <= write_counter_FLV_n;
			busy_o_last <= busy_o;
			zero_cnt <= zero_cnt_n;
			FLV_done <= FLV_done_n;
			write_HT_fin <= write_HT_fin_n;
			counter_HTREE <= counter_HTREE_n;
			CB_read_counter <= CB_read_counter_n;
			CB_write_counter <= CB_write_counter_n;
			CB_read_complete <= CB_read_complete_n;
			CB_write_complete <= CB_write_complete_n;
			TRN_counter <= TRN_counter_n;
			TRN_complete <= TRN_complete_n;
			nextChar <= nextChar_n;
		end
	always @(*) begin
		if (_sv2v_0)
			;
		select = 4'b1111;
		addr = 32'h33000000;
		wr_en = 0;
		r_en = 0;
		nextChar_n = nextChar;
		nextChar_FLV = 0;
		data_i = 0;
		HTREE_complete = 0;
		HT_read_complete = 0;
		HT_over_complete = 0;
		sum_2 = 0;
		old_char_n = old_char;
		check_n = check;
		write_HT_fin_n = write_HT_fin;
		comp_val_n = comp_val;
		word_cnt_n = word_cnt;
		nulls_n = nulls;
		h_element_n = h_element;
		path_n = path;
		init_n = init;
		init_counter_n = init_counter;
		zero_cnt_n = zero_cnt;
		FLV_done_n = FLV_done;
		write_counter_FLV_n = write_counter_FLV;
		counter_HTREE_n = counter_HTREE;
		CB_read_counter_n = CB_read_counter;
		CB_write_counter_n = CB_write_counter;
		CB_read_complete_n = CB_read_complete;
		CB_write_complete_n = CB_write_complete;
		TRN_counter_n = TRN_counter;
		TRN_complete_n = TRN_complete;
		case (state)
			1: begin
				if (init) begin
					addr = (init_counter < 2048 ? 32'h33001024 + (init_counter * 4) : 32'h33001ffc);
					data_i = 1'sb0;
					wr_en = ~check;
					r_en = 0;
					if (((init_counter == 2048) && !check) && ((busy_o_last == 1) && (busy_o == 0)))
						check_n = 1;
					else if ((init_counter <= 2047) && ((busy_o_last == 1) && (busy_o == 0)))
						init_counter_n = init_counter + 1;
					else if (check)
						init_n = 0;
				end
				else begin
					data_i = histogram;
					addr = 32'h33001024 + (histgram_addr * 4);
					if ((hist_r_wr == 1) && (busy_o == 0)) begin
						wr_en = 1;
						r_en = 0;
						nextChar_n = 1;
					end
					else if ((hist_r_wr == 0) && (busy_o == 0)) begin
						wr_en = 0;
						r_en = 1;
					end
					else if (!busy_o)
						nextChar_n = 0;
				end
				if (hist_read_latch)
					old_char_n = data_o;
			end
			2: begin
				write_HT_fin_n = 0;
				case (word_cnt)
					0: begin
						addr = 1'sb0;
						if ((find_least == 256) && (write_counter_FLV == 4)) begin
							FLV_done_n = 1;
							word_cnt_n = 0;
							write_counter_FLV_n = 0;
						end
						else if (pulse_FLV && !busy_o) begin
							FLV_done_n = 0;
							word_cnt_n = 1;
							comp_val_n = 1'sb0;
						end
						else if (pulse_FLV && (find_least == 0)) begin
							FLV_done_n = 0;
							word_cnt_n = 1;
							comp_val_n = 1'sb0;
						end
					end
					1:
						if ((find_least == 256) && wipe_the_char_1) begin
							addr = 32'h33001024 + (charwipe1 * 4);
							data_i = 1'sb0;
							write_counter_FLV_n = write_counter_FLV + 1;
							wr_en = 1;
							word_cnt_n = 9;
						end
						else if (find_least == 256) begin
							write_counter_FLV_n = write_counter_FLV + 1;
							word_cnt_n = 9;
						end
						else if (find_least < 128) begin
							addr = 32'h33001024 + (find_least * 4);
							if (!flv_r_wr)
								r_en = 1;
							word_cnt_n = 2;
							nextChar_FLV = 1;
						end
						else if (find_least > 127) begin
							addr = 32'h33000000 + ((HTREE_log * 2) * 4);
							if (!flv_r_wr)
								r_en = 1;
							word_cnt_n = 7;
							nextChar_FLV = 1;
						end
					2: begin
						if (!busy_o) begin
							comp_val_n[31:0] = data_o;
							comp_val_n[63:32] = 1'sb0;
							nextChar_FLV = 1;
							word_cnt_n = 0;
						end
						else if ((find_least == 0) && (zero_cnt == 3))
							word_cnt_n = 0;
						if (zero_cnt != 3)
							zero_cnt_n = zero_cnt + 1;
					end
					3:
						if (!busy_o) begin
							addr = 32'h33000000 + (((HTREE_log * 2) + 1) * 4);
							if (!flv_r_wr)
								r_en = 1;
							word_cnt_n = 4;
						end
					7:
						if (!busy_o)
							word_cnt_n = 8;
					8: begin
						comp_val_n[63:32] = {18'd0, data_o[13:0]};
						word_cnt_n = 3;
					end
					4:
						if (!busy_o) begin
							comp_val_n[31:0] = data_o;
							nextChar_FLV = 1;
							word_cnt_n = 0;
						end
					5:
						if (!busy_o && wipe_the_char_2) begin
							addr = 32'h33001024 + (charwipe2 * 4);
							data_i = 1'sb0;
							wr_en = 1;
							write_counter_FLV_n = write_counter_FLV + 1;
							nextChar_FLV = 1;
							word_cnt_n = 11;
						end
						else if (!busy_o) begin
							write_counter_FLV_n = write_counter_FLV + 1;
							nextChar_FLV = 1;
							word_cnt_n = 11;
						end
					9:
						if (!busy_o)
							word_cnt_n = 10;
					10:
						if (!busy_o)
							word_cnt_n = 5;
					6: word_cnt_n = 1;
					11: word_cnt_n = 12;
					12: word_cnt_n = 13;
					13: word_cnt_n = 14;
					14:
						if (write_counter_FLV != 4)
							word_cnt_n = 1;
						else if (write_counter_FLV == 4)
							word_cnt_n = 0;
				endcase
			end
			3:
				case (word_cnt)
					0:
						if (((((((HT_state == 3) && !busy_o) && (counter_HTREE == 4)) && least1_HTREE[8]) && least2_HTREE[8]) && (least1_HTREE != 384)) && (least2_HTREE != 384))
							HT_over_complete = 1;
						else if (((((HT_state == 5) || (HT_state == 3)) && (counter_HTREE == 4)) && !busy_o) && !HT_over_complete) begin
							HTREE_complete = 1;
							counter_HTREE_n = 1'sb0;
						end
						else if (((!least1_HTREE[8] && !least2_HTREE[8]) && !busy_o) && (counter_HTREE == 2)) begin
							HTREE_complete = 1;
							counter_HTREE_n = 1'sb0;
						end
						else if (pulse_HTREE && !busy_o) begin
							word_cnt_n = 8;
							counter_HTREE_n = 0;
						end
						else if (htree_r_wr) begin
							word_cnt_n = 8;
							counter_HTREE_n = 0;
						end
						else if ((((HT_state == 9) || (HT_state == 11)) && !busy_o) && (counter_HTREE == 2)) begin
							nulls_n[31:0] = data_o;
							word_cnt_n = 8;
							HT_read_complete = 1;
							sum_2 = 1;
						end
						else if ((((least1_HTREE[8] && least2_HTREE[8]) && !busy_o) && (HT_state == 8)) && (counter_HTREE == 3)) begin
							counter_HTREE_n = 0;
							word_cnt_n = 8;
						end
					1:
						if (!htree_r_wr && write_HT_fin) begin
							addr = 32'h33000000 + ((htreeindex * 2) * 4);
							wr_en = 1;
							word_cnt_n = 9;
							data_i = {new_node[63:46], 14'd0};
							counter_HTREE_n = counter_HTREE + 1;
						end
						else if (!htree_r_wr) begin
							addr = 32'h33000000 + (htree_write * 4);
							wr_en = 1;
							word_cnt_n = 6;
							data_i = new_node[63:32];
							counter_HTREE_n = counter_HTREE + 1;
						end
						else if (htree_r_wr) begin
							addr = 32'h33000000 + ((htreeindex * 2) * 4);
							r_en = 1;
							word_cnt_n = 4;
							counter_HTREE_n = counter_HTREE + 1;
						end
					2: begin
						addr = 32'h33000000 + (ht_write_1 * 4);
						wr_en = 1;
						word_cnt_n = 0;
						data_i = new_node[31:0];
						write_HT_fin_n = 1;
						counter_HTREE_n = counter_HTREE + 1;
					end
					3: begin
						addr = 32'h33000000 + (ht_index_1_over * 4);
						r_en = 1;
						word_cnt_n = 0;
						counter_HTREE_n = counter_HTREE + 1;
					end
					4:
						if (!busy_o)
							word_cnt_n = 5;
					5: begin
						nulls_n[63:32] = data_o;
						word_cnt_n = 3;
					end
					6:
						if (!busy_o)
							word_cnt_n = 7;
					7: word_cnt_n = 2;
					8: word_cnt_n = 1;
					9:
						if (!busy_o)
							word_cnt_n = 10;
					10: word_cnt_n = 11;
					11: begin
						addr = 32'h33000000 + (ht_index_1_over * 4);
						wr_en = 1;
						word_cnt_n = 0;
						data_i = 1'sb0;
						counter_HTREE_n = counter_HTREE + 1;
					end
				endcase
			4:
				case (word_cnt)
					0:
						if (pulse_CB && !busy_o) begin
							word_cnt_n = 1;
							CB_read_complete_n = 0;
							CB_write_complete_n = 0;
							CB_write_counter_n = 0;
						end
						else if (!busy_o && (CB_write_counter == 2))
							CB_write_complete_n = 1;
						else if (!busy_o && (CB_read_counter == 1)) begin
							h_element_n[31:0] = data_o;
							CB_read_complete_n = 1;
						end
					1:
						if (cb_r_wr) begin
							addr = 32'h33001024 + ((char_index[6:0] * 4) * 4);
							wr_en = 1;
							data_i = codebook_path[127:96];
							word_cnt_n = 2;
						end
						else if (!cb_r_wr) begin
							addr = 32'h33000000 + (curr_index[6:0] * 4);
							r_en = 1;
							word_cnt_n = 7;
						end
					2:
						if (!busy_o)
							word_cnt_n = 3;
					3:
						if (CB_write_counter == 0)
							word_cnt_n = 4;
						else if (CB_write_counter == 1)
							word_cnt_n = 5;
						else if (CB_write_counter == 2)
							word_cnt_n = 6;
					4: begin
						addr = 32'h33001024 + (char_index_1 * 4);
						wr_en = 1;
						data_i = codebook_path[95:64];
						word_cnt_n = 2;
						CB_write_counter_n = CB_write_counter + 1;
					end
					5: begin
						addr = 32'h33001024 + (char_index_2 * 4);
						wr_en = 1;
						data_i = codebook_path[63:32];
						word_cnt_n = 2;
						CB_write_counter_n = CB_write_counter + 1;
					end
					6: begin
						addr = 32'h33001024 + (char_index_3 * 4);
						wr_en = 1;
						data_i = codebook_path[31:0];
						word_cnt_n = 0;
					end
					7:
						if (!busy_o)
							word_cnt_n = 8;
					8: begin
						h_element_n[63:32] = data_o;
						word_cnt_n = 9;
					end
					9: begin
						addr = 32'h33000000 + (curr_index_1 * 4);
						r_en = 1;
						word_cnt_n = 0;
						CB_read_counter_n = 1;
					end
				endcase
			5:
				case (word_cnt)
					0:
						if (!busy_o && (TRN_counter == 3)) begin
							TRN_complete_n = 1;
							TRN_counter_n = 0;
							path_n[31:0] = data_o;
						end
						else if (pulse_TRN && !busy_o) begin
							word_cnt_n = 1;
							TRN_complete_n = 0;
						end
					1:
						if (!busy_o)
							word_cnt_n = 2;
					2:
						if (TRN_counter == 0)
							word_cnt_n = 3;
						else if (TRN_counter == 1) begin
							word_cnt_n = 4;
							path_n[127:96] = data_o;
						end
						else if (TRN_counter == 2) begin
							word_cnt_n = 5;
							path_n[95:64] = data_o;
						end
						else if (TRN_counter == 3) begin
							word_cnt_n = 6;
							path_n[63:32] = data_o;
						end
					3: begin
						addr = 32'h33001024 + ((translation[6:0] * 4) * 4);
						TRN_counter_n = TRN_counter + 1;
						word_cnt_n = 1;
						r_en = 1;
					end
					4: begin
						addr = 32'h33001024 + (trn_1 * 4);
						TRN_counter_n = TRN_counter + 1;
						word_cnt_n = 1;
						r_en = 1;
					end
					5: begin
						addr = 32'h33001024 + (trn_2 * 4);
						TRN_counter_n = TRN_counter + 1;
						word_cnt_n = 1;
						r_en = 1;
					end
					6: begin
						addr = 32'h33001024 + (trn_3 * 4);
						word_cnt_n = 0;
						r_en = 1;
					end
				endcase
			default: addr = 1'sb0;
		endcase
	end
	initial _sv2v_0 = 0;
endmodule
