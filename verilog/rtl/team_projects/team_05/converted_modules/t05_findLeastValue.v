`default_nettype none
module t05_findLeastValue (
	clk,
	rst,
	compVal,
	en_state,
	sum,
	charWipe1,
	charWipe2,
	least1,
	least2,
	histo_index,
	fin_state,
	flv_r_wr,
	pulse_FLV,
	wipe_the_char_1,
	wipe_the_char_2,
	nextChar,
	word_cnt,
	FLV_done,
	HTREE_complete,
	HT_fin
);
	input wire clk;
	input wire rst;
	input wire [63:0] compVal;
	input wire [3:0] en_state;
	output reg [63:0] sum;
	output reg [7:0] charWipe1;
	output reg [7:0] charWipe2;
	output reg [8:0] least1;
	output reg [8:0] least2;
	output reg [8:0] histo_index;
	output reg fin_state;
	output reg flv_r_wr;
	output reg pulse_FLV;
	output reg wipe_the_char_1;
	output reg wipe_the_char_2;
	input wire nextChar;
	input wire [3:0] word_cnt;
	input wire FLV_done;
	input wire HTREE_complete;
	input wire HT_fin;
	reg [8:0] least1_n;
	reg [8:0] least2_n;
	reg [8:0] count_n;
	reg [8:0] sumCount;
	reg [63:0] val1;
	reg [63:0] val2;
	reg [63:0] val1_n;
	reg [63:0] val2_n;
	reg [63:0] sum_n;
	reg [7:0] charWipe1_n;
	reg [7:0] charWipe2_n;
	reg fin_state_n;
	reg startup;
	reg startup_n;
	reg alt;
	reg [3:0] alternator_timer;
	reg [3:0] alternator_timer_n;
	reg wipe_the_char_1_n;
	reg wipe_the_char_2_n;
	always @(posedge clk or posedge rst)
		if (rst || HTREE_complete) begin
			least1 <= 9'b110000000;
			least2 <= 9'b110000000;
			histo_index <= 0;
			charWipe1 <= 0;
			charWipe2 <= 0;
			sum <= 0;
			val1 <= 1'sb1;
			val2 <= 1'sb1;
			fin_state <= 0;
			startup <= 1;
			alternator_timer <= 0;
			wipe_the_char_1 <= 0;
			wipe_the_char_2 <= 0;
		end
		else if (en_state == 2) begin
			least1 <= least1_n;
			least2 <= least2_n;
			histo_index <= count_n;
			charWipe1 <= charWipe1_n;
			charWipe2 <= charWipe2_n;
			sum <= sum_n;
			val1 <= val1_n;
			val2 <= val2_n;
			fin_state <= fin_state_n;
			startup <= startup_n;
			alternator_timer <= alternator_timer_n;
			wipe_the_char_1 <= wipe_the_char_1_n;
			wipe_the_char_2 <= wipe_the_char_2_n;
		end
	always @(*) begin
		count_n = histo_index;
		pulse_FLV = 0;
		startup_n = startup;
		alternator_timer_n = alternator_timer;
		alt = 0;
		if (histo_index == 0) begin
			if (alternator_timer < 5)
				alternator_timer_n = alternator_timer + 1;
			else begin
				alt = 1;
				alternator_timer_n = 0;
			end
		end
		else if (histo_index > 127) begin
			if (alternator_timer < 9)
				alternator_timer_n = alternator_timer + 1;
			else begin
				alt = 1;
				alternator_timer_n = 0;
			end
		end
		else if (alternator_timer < 4)
			alternator_timer_n = alternator_timer + 1;
		else begin
			alt = 1;
			alternator_timer_n = 0;
		end
		if ((((histo_index < 256) && alt) || startup) && (en_state == 2)) begin
			if (startup)
				count_n = 0;
			else
				count_n = histo_index + 1;
			pulse_FLV = 1;
			startup_n = 0;
		end
	end
	always @(*) begin
		val1_n = val1;
		val2_n = val2;
		charWipe1_n = charWipe1;
		charWipe2_n = charWipe2;
		least1_n = least1;
		least2_n = least2;
		sumCount = histo_index - 128;
		sum_n = sum;
		fin_state_n = fin_state;
		flv_r_wr = 0;
		wipe_the_char_1_n = wipe_the_char_1;
		wipe_the_char_2_n = wipe_the_char_2;
		if (((compVal != 0) && (histo_index < 256)) && (fin_state != 1)) begin
			if ((val1 > compVal) && (histo_index < 128)) begin
				least2_n = least1;
				charWipe2_n = charWipe1;
				val2_n = val1;
				wipe_the_char_2_n = wipe_the_char_1;
				least1_n = {1'b0, histo_index[7:0]};
				charWipe1_n = histo_index[7:0];
				val1_n = compVal;
				wipe_the_char_1_n = 1;
			end
			else if ((val2 > compVal) && (histo_index < 128)) begin
				least2_n = {1'b0, histo_index[7:0]};
				charWipe2_n = histo_index[7:0];
				val2_n = compVal;
				wipe_the_char_2_n = 1;
			end
			else if ((val1 > compVal) && (histo_index > 127)) begin
				least2_n = least1;
				charWipe2_n = charWipe1;
				val2_n = val1;
				wipe_the_char_2_n = wipe_the_char_1;
				least1_n = {1'b1, sumCount[7:0]};
				charWipe1_n = 1'sb0;
				val1_n = compVal;
				wipe_the_char_1_n = 0;
			end
			else if ((val2 > compVal) && (histo_index > 127)) begin
				least2_n = {1'b1, sumCount[7:0]};
				charWipe2_n = 1'sb0;
				val2_n = compVal;
				wipe_the_char_2_n = 0;
				wipe_the_char_2_n = 0;
			end
		end
		if ((val1 != {64 {1'sb1}}) && (val2 != {64 {1'sb1}}))
			sum_n = val1 + val2;
		if ((histo_index == 256) && FLV_done) begin
			fin_state_n = 1;
			flv_r_wr = 1;
		end
	end
endmodule
