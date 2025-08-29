`default_nettype none
module t03_instruction_cache (
	clk,
	rst,
	cache_out,
	hit,
	next_hit,
	input_instruction,
	next_address,
	current_address,
	cache_read
);
	parameter SET_SIZE = 15;
	input wire clk;
	input wire rst;
	output reg [31:0] cache_out;
	output reg hit;
	output reg next_hit;
	input wire [31:0] input_instruction;
	input wire [31:0] next_address;
	input wire [31:0] current_address;
	input wire cache_read;
	reg [SET_SIZE:0] valid_bit;
	reg [SET_SIZE:0] n_valid_bit;
	reg [(SET_SIZE >= 0 ? ((SET_SIZE + 1) * 26) - 1 : ((1 - SET_SIZE) * 26) + ((SET_SIZE * 26) - 1)):(SET_SIZE >= 0 ? 0 : SET_SIZE * 26)] address_tags;
	reg [(SET_SIZE >= 0 ? ((SET_SIZE + 1) * 26) - 1 : ((1 - SET_SIZE) * 26) + ((SET_SIZE * 26) - 1)):(SET_SIZE >= 0 ? 0 : SET_SIZE * 26)] n_address_tags;
	reg [(SET_SIZE >= 0 ? ((SET_SIZE + 1) * 32) - 1 : ((1 - SET_SIZE) * 32) + ((SET_SIZE * 32) - 1)):(SET_SIZE >= 0 ? 0 : SET_SIZE * 32)] instructions;
	reg [(SET_SIZE >= 0 ? ((SET_SIZE + 1) * 32) - 1 : ((1 - SET_SIZE) * 32) + ((SET_SIZE * 32) - 1)):(SET_SIZE >= 0 ? 0 : SET_SIZE * 32)] n_instructions;
	always @(posedge clk or posedge rst)
		if (rst) begin
			valid_bit <= 0;
			address_tags <= 0;
			instructions <= 0;
		end
		else if (|input_instruction) begin
			valid_bit <= n_valid_bit;
			address_tags <= n_address_tags;
			instructions <= n_instructions;
		end
	always @(*) begin
		n_valid_bit = valid_bit;
		n_address_tags = address_tags;
		n_instructions = instructions;
		cache_out = 0;
		hit = 0;
		if (valid_bit[current_address[5:2]] && (address_tags[(SET_SIZE >= 0 ? current_address[5:2] : SET_SIZE - current_address[5:2]) * 26+:26] == current_address[31:6])) begin
			hit = 1;
			cache_out = instructions[(SET_SIZE >= 0 ? current_address[5:2] : SET_SIZE - current_address[5:2]) * 32+:32];
		end
		if (cache_read) begin
			n_instructions[(SET_SIZE >= 0 ? current_address[5:2] : SET_SIZE - current_address[5:2]) * 32+:32] = input_instruction;
			n_address_tags[(SET_SIZE >= 0 ? current_address[5:2] : SET_SIZE - current_address[5:2]) * 26+:26] = current_address[31:6];
			n_valid_bit[current_address[5:2]] = 1;
		end
	end
	always @(*) begin
		next_hit = 0;
		if (valid_bit[next_address[5:2]] && (address_tags[(SET_SIZE >= 0 ? next_address[5:2] : SET_SIZE - next_address[5:2]) * 26+:26] == next_address[31:6]))
			next_hit = 1;
	end
endmodule
