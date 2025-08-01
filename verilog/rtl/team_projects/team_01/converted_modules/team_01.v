`default_nettype none
module team_01 (
	clk,
	nrst,
	en,
	la_data_in,
	la_data_out,
	la_oenb,
	ADR_O,
	DAT_O,
	SEL_O,
	WE_O,
	STB_O,
	CYC_O,
	DAT_I,
	ACK_I,
	gpio_in,
	gpio_out,
	gpio_oeb
);
	input wire clk;
	input wire nrst;
	input wire en;
	input wire [31:0] la_data_in;
	output wire [31:0] la_data_out;
	input wire [31:0] la_oenb;
	output wire [31:0] ADR_O;
	output wire [31:0] DAT_O;
	output wire [3:0] SEL_O;
	output wire WE_O;
	output wire STB_O;
	output wire CYC_O;
	input wire [31:0] DAT_I;
	input wire ACK_I;
	input wire [33:0] gpio_in;
	output wire [33:0] gpio_out;
	output wire [33:0] gpio_oeb;
	assign gpio_out = 1'sb0;
	assign gpio_oeb = 1'sb0;
endmodule
