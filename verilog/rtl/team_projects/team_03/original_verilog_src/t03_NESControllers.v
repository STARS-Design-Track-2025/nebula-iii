`default_nettype none
module t03_NESControllers (
	clk,
	rst,
	player_1_in,
	player_2_in,
	latch,
	pulse,
	confirm,
	packedOutput
);
	input wire clk;
	input wire rst;
	input wire player_1_in;
	input wire player_2_in;
	output wire latch;
	output wire pulse;
	output wire confirm;
	output wire [31:0] packedOutput;
	wire clkdiv;
	wire finished;
	wire button_en;
	wire [15:0] counter;
	wire [7:0] parallelOut1;
	wire [7:0] parallelOut2;
	wire [1:0] player_state1;
	wire [1:0] player_state2;
	wire [15:0] controllerInputs;
	wire [15:0] synchronizedOut;
	wire p1Resting;
	wire p2Resting;
	wire buttonAPressP1;
	wire buttonBPressP1;
	wire buttonAPressP2;
	wire buttonBPressP2;
	t03_NES_clkdiv_counter clkdivider(
		.clk(clk),
		.rst(rst),
		.clkdiv(clkdiv),
		.finished(finished),
		.button_en(button_en),
		.latch(latch),
		.pulse(pulse),
		.counter(counter)
	);
	t03_eight_bit_shift shifter1(
		.clk(clk),
		.rst(rst),
		.button_en(button_en),
		.data(player_1_in),
		.finished(finished),
		.latchedValue(parallelOut1)
	);
	t03_eight_bit_shift shifter2(
		.clk(clk),
		.rst(rst),
		.button_en(button_en),
		.data(player_2_in),
		.finished(finished),
		.latchedValue(parallelOut2)
	);
	t03_player_FSM_new fsm1(
		.clk(clk),
		.rst(rst),
		.finished(finished),
		.buttonAPress(parallelOut1[7]),
		.buttonBPress(parallelOut1[6]),
		.player_state(player_state1),
		.resting(p1Resting)
	);
	t03_player_FSM_new fsm2(
		.clk(clk),
		.rst(rst),
		.finished(finished),
		.buttonAPress(parallelOut2[7]),
		.buttonBPress(parallelOut2[6]),
		.player_state(player_state2),
		.resting(p2Resting)
	);
	assign controllerInputs = {~parallelOut1, ~parallelOut2};
	wire [1:0] player_state_1_out;
	wire [1:0] player_state_2_out;
	assign player_state_1_out = (player_state1 && !p1Resting ? player_state1 : 2'b00);
	assign player_state_2_out = (player_state2 && !p2Resting ? player_state2 : 2'b00);
	assign packedOutput = {2'b00, player_state_1_out, 2'b00, player_state_2_out, controllerInputs, 8'b00000000};
	assign confirm = 1'b1;
endmodule
