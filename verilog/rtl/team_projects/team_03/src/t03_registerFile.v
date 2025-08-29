`default_nettype none
module t03_registerFile (
	clk,
	regwrite,
	reset,
	memToReg,
	jal,
	instruction,
	result_ALU,
	data_out,
	pc,
	read_data1,
	read_data2
);
	reg _sv2v_0;
	input wire clk;
	input wire regwrite;
	input wire reset;
	input wire memToReg;
	input wire jal;
	input wire [31:0] instruction;
	input wire [31:0] result_ALU;
	input wire [31:0] data_out;
	input wire [31:0] pc;
	output wire [31:0] read_data1;
	output wire [31:0] read_data2;
	reg [1023:0] regfile;
	wire [4:0] rs1;
	wire [4:0] rs2;
	wire [4:0] rd;
	reg [31:0] write_data;
	assign rs1 = instruction[19:15];
	assign rs2 = instruction[24:20];
	assign rd = instruction[11:7];
	assign read_data1 = regfile[rs1 * 32+:32];
	assign read_data2 = regfile[rs2 * 32+:32];
	always @(posedge clk or posedge reset)
		if (reset)
			regfile <= 1'sb0;
		else if (regwrite && (rd != 0))
			regfile[rd * 32+:32] <= write_data;
	always @(*) begin
		if (_sv2v_0)
			;
		if (jal)
			write_data = pc;
		else if (memToReg)
			write_data = data_out;
		else
			write_data = result_ALU;
	end
	initial _sv2v_0 = 0;
endmodule
