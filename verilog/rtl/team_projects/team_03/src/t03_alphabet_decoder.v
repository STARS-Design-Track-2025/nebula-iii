`default_nettype none
module t03_alphabet_decoder (
	game_state,
	alphabet,
	text_color,
	p1health,
	p2health,
	clk,
	rst
);
	reg _sv2v_0;
	input wire [2:0] game_state;
	output reg [71:0] alphabet;
	output reg [7:0] text_color;
	input wire [11:0] p1health;
	input wire [11:0] p2health;
	input wire clk;
	input wire rst;
	always @(*) begin
		if (_sv2v_0)
			;
		text_color = 8'b11111111;
		case (game_state)
			3'd0: begin
				alphabet = 72'h3d11124a54930114e5;
				text_color = 8'b11111111;
			end
			3'd1: begin
				alphabet = 72'h9659511000d8965965;
				text_color = 8'b01011000;
			end
			3'd2: begin
				alphabet = 72'h9659654844e5965965;
				text_color = 8'b11111100;
			end
			3'd3: begin
				alphabet = 72'h9659452061d3965965;
				text_color = 8'b11100100;
			end
			3'd4: begin
				alphabet = {p1health[11:6], p1health[5:0], 48'h965965965965, p2health[11:6], p2health[5:0]};
				text_color = 8'b11111111;
			end
			3'd5: begin
				alphabet = 72'h95620d3444653db965;
				text_color = 8'b11100100;
			end
			3'd6: begin
				alphabet = 72'h95620d3444653dc965;
				text_color = 8'b00000111;
			end
			default: alphabet = {12 {6'd37}};
		endcase
	end
	initial _sv2v_0 = 0;
endmodule
