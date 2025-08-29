`default_nettype none
module team_03 (
	clk,
	nrst,
	en,
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
	wire rst;
	assign rst = ~nrst | ~en;
	wire ack;
	wire [31:0] dataOut;
	wire [31:0] data;
	wire [31:0] address;
	wire write;
	wire read;
	wire NESConfirm;
	wire [31:0] NESData;
	wire [31:0] new_counter;
	wire DEBUGALUsrc;
	wire DEBUGfreezePc;
	t03_cputop CPU(
		.clk(clk),
		.rst(rst),
		.ack(ack),
		.dataOut(dataOut),
		.data(data),
		.address(address),
		.write(write),
		.read(read),
		.ALUsrc(DEBUGALUsrc),
		.freezePc(DEBUGfreezePc)
	);
	wire [2:0] gameState;
	wire [1:0] p1State;
	wire [1:0] p2State;
	wire [3:0] p1health;
	wire [3:0] p2health;
	wire [10:0] x1;
	wire [10:0] x2;
	wire [10:0] y1;
	wire [10:0] y2;
	wire p1Left;
	wire p2Left;
	t03_MMIOInterface MMIOInterface(
		.rst(rst),
		.clk(clk),
		.data(data),
		.address(address),
		.write(write),
		.read(read),
		.dataOut(dataOut),
		.ack(ack),
		.new_counter(new_counter),
		.NESData(NESData),
		.NESConfirm(NESConfirm),
		.gameState(gameState),
		.p1State(p1State),
		.p2State(p2State),
		.p1health(p1health),
		.p2health(p2health),
		.x1(x1),
		.x2(x2),
		.y1(y1),
		.y2(y2),
		.p1Left(p1Left),
		.p2Left(p2Left),
		.DAT_I(DAT_I),
		.ACK_I(ACK_I),
		.ADR_O(ADR_O),
		.DAT_O(DAT_O),
		.SEL_O(SEL_O),
		.WE_O(WE_O),
		.STB_O(STB_O),
		.CYC_O(CYC_O)
	);
	wire latch;
	wire pulse;
	wire player1;
	wire player2;
	t03_NESControllers NES(
		.clk(clk),
		.rst(rst),
		.confirm(NESConfirm),
		.packedOutput(NESData),
		.latch(latch),
		.pulse(pulse),
		.player_1_in(player1),
		.player_2_in(player2)
	);
	t03_hardware_clock hardwareClk(
		.clk(clk),
		.rst(rst),
		.new_counter(new_counter)
	);
	wire [7:0] dpu_colors;
	wire [1:0] dpu_vga;
	t03_DPUtop DPU(
		.clk(clk),
		.rst(rst),
		.gameState(gameState),
		.p1State(p1State),
		.p2State(p2State),
		.p1health(p1health),
		.p2health(p2health),
		.x1(x1),
		.x2(x2),
		.y1(y1),
		.y2(y2),
		.left(dpu_vga),
		.right(dpu_colors),
		.p1Left(p1Left),
		.p2Left(p2Left)
	);
	assign gpio_out[12:1] = {latch, pulse, dpu_colors, dpu_vga};
	assign {player2, player1} = gpio_in[14:13];
	assign {gpio_out[33:13], gpio_out[0]} = 1'sb0;
	assign gpio_oeb[12:1] = 1'sb0;
	assign gpio_oeb[14:13] = 1'sb1;
	assign {gpio_oeb[33:15], gpio_oeb[0]} = 1'sb1;
endmodule
