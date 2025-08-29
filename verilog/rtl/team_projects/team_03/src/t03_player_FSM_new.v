`default_nettype none
module t03_player_FSM_new (
	clk,
	rst,
	finished,
	buttonAPress,
	buttonBPress,
	player_state,
	resting
);
	parameter MAX_COUNT = 26'd6718863;
	parameter HALF_COUNT = 26'd3359432;
	parameter THREE_QUARTER_COUNT = 26'd5039147;
	input wire clk;
	input wire rst;
	input wire finished;
	input wire buttonAPress;
	input wire buttonBPress;
	output reg [1:0] player_state;
	output reg resting;
	reg [25:0] counter;
	reg [25:0] n_counter;
	reg attack;
	reg n_attack;
	reg block;
	reg n_block;
	reg [1:0] n_player_state;
	reg counting;
	reg n_counting;
	always @(posedge clk or posedge rst)
		if (rst) begin
			counter <= 1'sb0;
			player_state <= 2'b00;
			block <= 1'sb0;
			attack <= 1'sb0;
			counting <= 1'sb1;
		end
		else if (finished) begin
			counter <= n_counter;
			attack <= n_attack;
			block <= n_block;
			player_state <= n_player_state;
			counting <= n_counting;
		end
	always @(*) begin
		n_attack = 0;
		n_block = 0;
		n_player_state = player_state;
		n_counting = counting;
		n_counter = counter;
		if (counting)
			n_counter = counter + 1;
		if (counter <= HALF_COUNT)
			n_block = 1;
		if (counter <= THREE_QUARTER_COUNT)
			n_attack = 1;
		case (player_state)
			2'b00: begin
				resting = 1;
				if (!buttonAPress) begin
					n_player_state = 2'b01;
					n_counting = 1;
					n_counter = 0;
				end
				else if (!buttonBPress) begin
					n_player_state = 2'b10;
					n_counting = 1;
					n_counter = 0;
				end
			end
			2'b01: begin
				if (buttonAPress && (counter >= MAX_COUNT)) begin
					n_counter = 0;
					n_counting = 0;
					n_player_state = 2'b00;
				end
				if (!buttonAPress || (counter >= THREE_QUARTER_COUNT))
					resting = 1;
				else
					resting = 0;
			end
			2'b10: begin
				if (buttonBPress && (counter >= THREE_QUARTER_COUNT)) begin
					n_counter = 0;
					n_counting = 0;
					n_player_state = 2'b00;
				end
				if (!buttonBPress || (counter >= HALF_COUNT))
					resting = 1;
				else
					resting = 0;
			end
			default: begin
				n_player_state = 2'b00;
				resting = 0;
			end
		endcase
	end
endmodule
