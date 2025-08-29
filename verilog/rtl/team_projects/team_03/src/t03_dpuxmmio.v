`default_nettype none
module t03_dpuxmmio (
	addr,
	data,
	clk,
	rst,
	gameState,
	p1State,
	p2State,
	p1health,
	p2health,
	x1,
	x2,
	y1,
	y2,
	p1Left,
	p2Left
);
	input wire [31:0] addr;
	input wire [31:0] data;
	input wire clk;
	input wire rst;
	output reg [2:0] gameState;
	output reg [1:0] p1State;
	output reg [1:0] p2State;
	output reg [3:0] p1health;
	output reg [3:0] p2health;
	output reg [10:0] x1;
	output reg [10:0] x2;
	output reg [10:0] y1;
	output reg [10:0] y2;
	output reg p1Left;
	output reg p2Left;
	reg [2:0] n_gameState;
	reg [1:0] n_p1State;
	reg [1:0] n_p2State;
	reg [3:0] n_p1health;
	reg [3:0] n_p2health;
	reg [10:0] n_x1;
	reg [10:0] n_x2;
	reg [10:0] n_y1;
	reg [10:0] n_y2;
	reg n_p2Left;
	reg n_p1Left;
	always @(posedge clk or posedge rst)
		if (rst) begin
			gameState <= 3'b000;
			p1State <= 2'b00;
			p2State <= 2'b00;
			p1health <= 4'd0;
			p2health <= 4'd0;
			x1 <= 1'sb0;
			x2 <= 1'sb0;
			y1 <= 1'sb0;
			y2 <= 1'sb0;
		end
		else begin
			gameState <= n_gameState;
			p1State <= n_p1State;
			p2State <= n_p2State;
			p1health <= n_p1health;
			p2health <= n_p2health;
			x1 <= n_x1;
			x2 <= n_x2;
			y1 <= n_y1;
			y2 <= n_y2;
			p1Left <= n_p1Left;
			p2Left <= n_p2Left;
		end
	always @(*) begin
		n_x1 = x1;
		n_x2 = x2;
		n_y1 = y1;
		n_y2 = y2;
		n_gameState = gameState;
		n_p1State = p1State;
		n_p2State = p2State;
		n_p1health = p1health;
		n_p2health = p2health;
		n_p1Left = p1Left;
		n_p2Left = p2Left;
		case (addr)
			32'hff000004: begin
				n_gameState = data[30:28];
				n_p1State = data[27:26];
				n_p2State = data[25:24];
				n_p1health = data[23:20];
				n_p2health = data[19:16];
				n_p1Left = data[1];
				n_p2Left = data[0];
			end
			32'hff000008: begin
				n_x1 = {3'b000, data[31:24]};
				n_y1 = {3'b000, data[23:16]};
				n_x2 = {3'b000, data[15:8]};
				n_y2 = {3'b000, data[7:0]};
			end
		endcase
	end
endmodule
