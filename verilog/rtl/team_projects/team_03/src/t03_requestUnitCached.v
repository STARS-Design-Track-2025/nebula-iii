`default_nettype none
module t03_requestUnitCached (
	clk,
	rst,
	ack,
	next_hit,
	memRead,
	memWrite,
	pcMemory,
	resultALU,
	read,
	write,
	freezePC,
	freezeInstr,
	addressSrc,
	address,
	cache_read
);
	reg _sv2v_0;
	input wire clk;
	input wire rst;
	input wire ack;
	input wire next_hit;
	input wire memRead;
	input wire memWrite;
	input wire [31:0] pcMemory;
	input wire [31:0] resultALU;
	output reg read;
	output reg write;
	output reg freezePC;
	output reg freezeInstr;
	output reg addressSrc;
	output wire [31:0] address;
	output reg cache_read;
	reg [1:0] state;
	reg [1:0] next_state;
	reg [1:0] previous_state;
	assign address = (addressSrc ? resultALU : pcMemory);
	always @(posedge clk or posedge rst)
		if (rst) begin
			state <= 2'b00;
			previous_state <= 2'b00;
		end
		else begin
			state <= next_state;
			previous_state <= state;
		end
	always @(*) begin
		if (_sv2v_0)
			;
		next_state = state;
		case (state)
			2'b00:
				if (memRead)
					next_state = 2'b10;
				else if (memWrite)
					next_state = 2'b11;
				else if (~next_hit && ~(memRead | memWrite))
					next_state = 2'b01;
				else
					next_state = 2'b00;
			2'b01:
				if (ack)
					next_state = 2'b00;
			2'b10:
				if (!next_hit && ack)
					next_state = 2'b01;
				else if (next_hit && ack)
					next_state = 2'b00;
			2'b11:
				if (!next_hit && ack)
					next_state = 2'b01;
				else if (next_hit && ack)
					next_state = 2'b00;
		endcase
	end
	always @(*) begin
		if (_sv2v_0)
			;
		cache_read = 0;
		case (state)
			2'b00: begin
				freezePC = (next_state != 2'b00 ? 1 : 0);
				freezeInstr = 1'b0;
				read = ~memWrite && ~next_hit;
				write = memWrite;
				addressSrc = memWrite | memRead;
				cache_read = previous_state == 2'b01;
			end
			2'b01: begin
				freezePC = ~ack;
				freezeInstr = 1'b1;
				read = 1'b1;
				write = 1'b0;
				addressSrc = 1'b0;
			end
			2'b10: begin
				freezePC = ~next_hit;
				freezeInstr = 1'b1;
				read = 1'b1;
				write = 1'b0;
				addressSrc = 1'b1;
			end
			2'b11: begin
				freezePC = ~next_hit;
				freezeInstr = 1'b1;
				read = 1'b0;
				write = 1'b1;
				addressSrc = 1'b1;
			end
		endcase
	end
	initial _sv2v_0 = 0;
endmodule
