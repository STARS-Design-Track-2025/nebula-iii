`default_nettype none
module t05_translation (
	clk,
	rst,
	en_state,
	totChar,
	charIn,
	path,
	sram_complete,
	word_cnt,
	writeBin,
	nextCharEn,
	writeEn,
	pulse,
	char_index,
	fin_state
);
	input wire clk;
	input wire rst;
	input wire [3:0] en_state;
	input wire [31:0] totChar;
	input wire [7:0] charIn;
	input wire [127:0] path;
	input wire sram_complete;
	input wire [3:0] word_cnt;
	output reg writeBin;
	output reg nextCharEn;
	output reg writeEn;
	output reg pulse;
	output wire [7:0] char_index;
	output reg fin_state;
	reg [6:0] index;
	reg [6:0] index_n;
	reg resEn;
	reg resEn_n;
	reg writeEn_n;
	reg nextCharEn_n;
	reg totalEn;
	reg totalEn_n;
	reg start;
	reg start_n;
	reg write_fin;
	reg write_fin_n;
	assign char_index = charIn;
	always @(posedge clk or posedge rst)
		if (rst) begin
			index <= 7'd31;
			writeEn <= 1'sb0;
			nextCharEn <= 1'sb0;
			totalEn <= 1;
			resEn <= 1'sb0;
			start <= 1;
			write_fin <= 0;
		end
		else if (en_state == 5) begin
			writeEn <= writeEn_n;
			nextCharEn <= nextCharEn_n;
			index <= index_n;
			totalEn <= totalEn_n;
			resEn <= resEn_n;
			start <= start_n;
			write_fin <= write_fin_n;
		end
	always @(*) begin
		index_n = index;
		nextCharEn_n = nextCharEn;
		writeEn_n = writeEn;
		resEn_n = resEn;
		totalEn_n = totalEn;
		start_n = start;
		write_fin_n = write_fin;
		writeBin = 0;
		fin_state = 0;
		pulse = 0;
		if (resEn == 1) begin
			totalEn_n = 0;
			index_n = 7'd127;
			nextCharEn_n = 1;
			writeEn_n = 0;
			resEn_n = 0;
		end
		else if (totalEn == 1) begin
			writeEn_n = 1;
			writeBin = totChar[index[4:0]];
			index_n = index - 1;
			if ((index == 0) && (index_n == 127)) begin
				resEn_n = 1;
				pulse = 1;
			end
		end
		else if (totalEn == 0) begin
			nextCharEn_n = 0;
			if ((charIn == 8'b00011010) && !sram_complete) begin
				fin_state = 1;
				writeEn_n = 0;
			end
			else if (sram_complete && write_fin) begin
				pulse = 1;
				start_n = 0;
				write_fin_n = 0;
			end
			else if (sram_complete) begin
				index_n = index - 1;
				if (path[index] == 1) begin
					writeEn_n = 1;
					write_fin_n = 0;
				end
				if (writeEn == 1)
					writeBin = path[index];
				if ((index == 0) && (index_n == 127)) begin
					writeEn_n = 0;
					write_fin_n = 1;
					resEn_n = 1;
				end
			end
		end
	end
endmodule
