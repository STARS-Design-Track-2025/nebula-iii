`default_nettype none
module t03_requestUnit (
	clk,
	rst,
	ack,
	memRead,
	memWrite,
	pcMemory,
	resultALU,
	read,
	write,
	freezePC,
	freezeInstr,
	addressSrc,
	address
);
	reg _sv2v_0;
	input wire clk;
	input wire rst;
	input wire ack;
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
	reg [1:0] state;
	reg [1:0] next_state;
	assign address = (addressSrc ? resultALU : pcMemory);
	always @(posedge clk or posedge rst)
		if (rst)
			state = 2'b00;
		else
			state = next_state;
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
				else
					next_state = 2'b01;
			2'b01:
				if (ack)
					next_state = 2'b00;
			2'b10:
				if (ack)
					next_state = 2'b01;
			2'b11:
				if (ack)
					next_state = 2'b01;
		endcase
	end
	always @(*) begin
		if (_sv2v_0)
			;
		case (state)
			2'b00: begin
				freezePC = 1'b1;
				freezeInstr = 1'b0;
				read = ~memWrite;
				write = memWrite;
				addressSrc = memWrite | memRead;
			end
			2'b01: begin
				freezePC = ~ack;
				freezeInstr = 1'b1;
				read = 1'b1;
				write = 1'b0;
				addressSrc = 1'b0;
			end
			2'b10: begin
				freezePC = 1'b1;
				freezeInstr = 1'b1;
				read = 1'b1;
				write = 1'b0;
				addressSrc = 1'b1;
			end
			2'b11: begin
				freezePC = 1'b1;
				freezeInstr = 1'b1;
				read = 1'b0;
				write = 1'b1;
				addressSrc = 1'b1;
			end
		endcase
	end
	initial _sv2v_0 = 0;
endmodule
