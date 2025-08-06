`default_nettype none
module t05_controller (
	clk,
	rst,
	cont_en,
	restart_en,
	finState,
	op_fin,
	fin_idle,
	fin_HG,
	fin_FLV,
	fin_HT,
	fin_FINISHED,
	fin_CBS,
	fin_TRN,
	fin_SPI,
	state_reg,
	finished_signal
);
	reg _sv2v_0;
	input wire clk;
	input wire rst;
	input wire cont_en;
	input wire restart_en;
	input wire [7:0] finState;
	input wire [5:0] op_fin;
	input wire fin_idle;
	input wire fin_HG;
	input wire fin_FLV;
	input wire fin_HT;
	input wire fin_FINISHED;
	input wire fin_CBS;
	input wire fin_TRN;
	input wire fin_SPI;
	output reg [3:0] state_reg;
	output reg finished_signal;
	reg finished;
	reg en_reg;
	reg [7:0] fin_reg;
	wire [7:0] finState_next;
	reg [3:0] next_state;
	wire [7:0] fin_signal;
	assign fin_signal = {fin_idle, fin_HG, fin_FLV, fin_HT, fin_FINISHED, fin_CBS, fin_TRN, fin_SPI};
	always @(posedge clk or posedge rst)
		if (rst) begin
			state_reg <= 4'd0;
			en_reg <= 1'b0;
			fin_reg <= 1'sb0;
			finished_signal <= 1'b0;
		end
		else begin
			fin_reg <= finState;
			state_reg <= next_state;
			finished_signal <= finished;
			if (cont_en)
				en_reg <= 1'b1;
		end
	always @(*) begin
		if (_sv2v_0)
			;
		finished = finished_signal;
		case (fin_reg)
			8'b10000000: next_state = 4'd1;
			8'b11000000: next_state = 4'd2;
			8'b11100000: next_state = 4'd3;
			8'b11010000: next_state = 4'd2;
			8'b11101000: next_state = 4'd4;
			8'b11101100: next_state = 4'd5;
			8'b11101110: next_state = 4'd6;
			8'b11101111: next_state = 4'd8;
			default: next_state = 4'd0;
		endcase
	end
	initial _sv2v_0 = 0;
endmodule
