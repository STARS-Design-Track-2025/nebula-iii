`default_nettype none
module t05_hTree (
	clk,
	rst_n,
	least1,
	least2,
	sum,
	nulls,
	SRAM_finished,
	HT_en,
	write_HT_fin,
	sram_complete,
	read_complete,
	over_complete,
	sum_2,
	node_reg,
	clkCount,
	nullSumIndex,
	HT_fin_reg,
	HT_Finished,
	WriteorRead,
	pulse,
	state
);
	input wire clk;
	input wire rst_n;
	input wire [8:0] least1;
	input wire [8:0] least2;
	input wire [63:0] sum;
	input wire [63:0] nulls;
	input wire SRAM_finished;
	input wire [3:0] HT_en;
	input wire write_HT_fin;
	input wire sram_complete;
	input wire read_complete;
	input wire over_complete;
	input wire sum_2;
	output reg [70:0] node_reg;
	output reg [6:0] clkCount;
	output reg [6:0] nullSumIndex;
	output reg HT_fin_reg;
	output reg HT_Finished;
	output reg WriteorRead;
	output reg pulse;
	output reg [3:0] state;
	reg [3:0] next_state;
	reg [70:0] node;
	reg [6:0] clkCount_reg;
	reg [6:0] nullSumIndex_reg;
	reg [8:0] least1_reg;
	reg [8:0] least2_reg;
	reg [63:0] sum_reg;
	reg [70:0] null1;
	reg [70:0] null2;
	reg [70:0] null1_reg;
	reg [70:0] null2_reg;
	reg [70:0] tree;
	reg [70:0] tree_reg;
	reg HT_fin;
	reg HT_finished;
	reg [2:0] nullsum_delay_counter;
	reg [2:0] nullsum_delay_counter_reg;
	reg WorR;
	reg wait_cnt;
	reg wait_cnt_n;
	reg closing;
	reg closing_n;
	reg finish_check;
	reg finish_check_n;
	always @(posedge clk or posedge rst_n)
		if (rst_n) begin
			state <= 4'd1;
			nullSumIndex <= 0;
			HT_fin_reg <= 0;
			null1_reg <= 71'b00000000000000000000000000000000000000000000000000000000000000000000000;
			null2_reg <= 71'b00000000000000000000000000000000000000000000000000000000000000000000000;
			tree_reg <= 71'b00000000000000000000000000000000000000000000000000000000000000000000000;
			clkCount <= 0;
			HT_Finished <= 1'b0;
			nullsum_delay_counter_reg <= 3'b000;
			WriteorRead <= 1'sb0;
			wait_cnt <= 0;
			closing <= 0;
			finish_check <= 1;
		end
		else if (HT_en == 4'b0011) begin
			state <= next_state;
			clkCount <= clkCount_reg;
			least1_reg <= least1;
			least2_reg <= least2;
			sum_reg <= sum;
			tree_reg <= tree;
			null1_reg <= null1;
			null2_reg <= null2;
			nullSumIndex <= nullSumIndex_reg;
			HT_fin_reg <= HT_fin;
			HT_Finished <= HT_finished;
			node_reg <= node;
			nullsum_delay_counter_reg <= nullsum_delay_counter;
			WriteorRead <= WorR;
			wait_cnt <= wait_cnt_n;
			closing <= closing_n;
			finish_check <= finish_check_n;
		end
	always @(*) begin
		tree = tree_reg;
		null1 = null1_reg;
		null2 = null2_reg;
		clkCount_reg = clkCount;
		nullSumIndex_reg = nullSumIndex;
		next_state = state;
		HT_fin = HT_fin_reg;
		HT_finished = 1'b0;
		WorR = 1'b0;
		pulse = 0;
		node = node_reg;
		nullsum_delay_counter = nullsum_delay_counter_reg;
		wait_cnt_n = wait_cnt;
		closing_n = closing;
		finish_check_n = finish_check;
		if (HT_en == 4'b0011) begin
			if (((least1[8] && (least2 == 9'b110000000)) || (least2[8] && (least1 == 9'b110000000))) && (least1 != least2)) begin
				if ((least1[8] && (least2 == 9'b110000000)) && (least1 != 9'b110000000)) begin
					tree = {clkCount, least1, 9'b110000000, sum[45:0]};
					closing_n = 1;
				end
				else if ((least2[8] && (least1 == 9'b110000000)) && (least2 != 9'b110000000)) begin
					tree = {clkCount, 9'b110000000, least2, sum[45:0]};
					closing_n = 1;
				end
				else begin
					tree = {clkCount, 18'b110000000110000000, sum[45:0]};
					closing_n = 1;
				end
			end
			if (((least1 == 9'b110000000) && (least2 == 9'b110000000)) && !write_HT_fin) begin
				HT_finished = 1'b1;
				tree = {clkCount, 18'b011000000110000000, sum[45:0]};
				if (finish_check) begin
					clkCount_reg = clkCount - 2;
					finish_check_n = 0;
				end
			end
			else
				case (state)
					4'd1: begin
						WorR = 1'b0;
						if (!write_HT_fin && !closing) begin
							tree = {clkCount, least1, least2, sum[45:0]};
							pulse = 1;
						end
						else if (!write_HT_fin)
							pulse = 1;
						else if (write_HT_fin) begin
							if (least1[8] && (least1 != 9'b110000000))
								next_state = 4'd2;
							else if (least2[8] && (least2 != 9'b110000000))
								next_state = 4'd4;
							else if (sram_complete) begin
								clkCount_reg = clkCount + 2;
								next_state = 4'd0;
							end
						end
						HT_finished = 1'b0;
						node = tree;
					end
					4'd2: begin
						WorR = 1'b1;
						nullSumIndex_reg = least1[6:0];
						next_state = 4'd10;
						node = node_reg;
						wait_cnt_n = 0;
					end
					4'd10: begin
						WorR = 1;
						if (wait_cnt)
							next_state = 4'd11;
						else begin
							next_state = 4'd10;
							wait_cnt_n = wait_cnt + 1;
						end
					end
					4'd11: begin
						WorR = 0;
						nullSumIndex_reg = least1[6:0];
						if (read_complete)
							next_state = 4'd3;
						else
							next_state = 4'd11;
						node = node_reg;
					end
					4'd3: begin
						WorR = 1'b0;
						null1 = {least1[6:0], nulls[63:46], 46'b0000000000000000000000000000000000000000000000};
						if (least2[8] && over_complete)
							next_state = 4'd4;
						else if (sram_complete) begin
							clkCount_reg = clkCount + 2;
							next_state = 4'd0;
						end
						node = null1;
					end
					4'd4: begin
						WorR = 1'b1;
						nullSumIndex_reg = least2[6:0];
						next_state = 4'd8;
						node = node_reg;
						wait_cnt_n = 0;
					end
					4'd8: begin
						WorR = 1;
						if (wait_cnt)
							next_state = 4'd9;
						else begin
							next_state = 4'd8;
							wait_cnt_n = wait_cnt + 1;
						end
					end
					4'd9: begin
						WorR = 0;
						nullSumIndex_reg = least2[6:0];
						if (read_complete || sum_2)
							next_state = 4'd5;
						else
							next_state = 4'd9;
						node = node_reg;
					end
					4'd5: begin
						WorR = 1'b0;
						null2 = {least2[6:0], nulls[63:46], 46'b0000000000000000000000000000000000000000000000};
						if (sram_complete) begin
							nullsum_delay_counter = 3'b000;
							clkCount_reg = clkCount + 2;
							next_state = 4'd0;
						end
						node = null2;
					end
					4'd0: begin
						HT_fin = 1'b1;
						next_state = 4'd7;
						node = node_reg;
					end
					4'd7: begin
						HT_fin = 1'b0;
						node = node_reg;
						if (HT_en == 3)
							next_state = 4'd1;
					end
					default: begin
						next_state = 4'd1;
						node = node_reg;
					end
				endcase
		end
	end
endmodule
