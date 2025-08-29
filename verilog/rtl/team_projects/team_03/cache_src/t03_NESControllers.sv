`default_nettype none
`timescale 1ms/10ps
// Empty top module

module t03_NESControllers (
  // I/O ports
  input logic clk, rst, //hz100 is currently 10MHz, check PPL in ice40hx8k.sv to change it 
  input logic player_1_in,
  input logic player_2_in,
  output logic latch,
  output logic pulse, 
  output logic confirm,
  output logic [31:0] packedOutput
);
  // Your code goes here...

  logic clkdiv, finished, button_en;
  logic [15:0] counter;
  logic [7:0] parallelOut1, parallelOut2;
  logic [1:0] player_state1, player_state2;

  logic [15:0] controllerInputs, synchronizedOut;
  logic p1Resting;
  logic p2Resting;
  logic buttonAPressP1;
  logic buttonBPressP1;
  logic buttonAPressP2;
  logic buttonBPressP2;

  t03_NES_clkdiv_counter clkdivider (.clk(clk), .rst(rst), .clkdiv(clkdiv), .finished(finished), .button_en(button_en), .latch(latch), .pulse(pulse), .counter(counter));
  t03_eight_bit_shift shifter1 (.clk(clk), .rst(rst), .button_en(button_en), .data(player_1_in), .finished(finished), .latchedValue(parallelOut1));
  t03_eight_bit_shift shifter2 (.clk(clk), .rst(rst), .button_en(button_en), .data(player_2_in), .finished(finished), .latchedValue(parallelOut2));

  t03_player_FSM_new fsm1 (.clk(clk), .rst(rst), .finished(finished), .buttonAPress(parallelOut1[7]), .buttonBPress(parallelOut1[6]), .player_state(player_state1), .resting(p1Resting));
  t03_player_FSM_new fsm2 (.clk(clk), .rst(rst), .finished(finished), .buttonAPress(parallelOut2[7]), .buttonBPress(parallelOut2[6]), .player_state(player_state2), .resting(p2Resting));

  assign controllerInputs = {~parallelOut1, ~parallelOut2};

  // outputSynchronizer outputSync(.clk(clk), .rst(rst), .controllerInputs(controllerInputs), .syncronizedOut(synchronizedOut),
  //   .buttonAPressP1(buttonAPressP1), .buttonBPressP1(buttonBPressP1), .buttonAPressP2(buttonAPressP2), .buttonBPressP2(buttonBPressP2));

  logic [1:0] player_state_1_out;
  logic [1:0] player_state_2_out;

  assign player_state_1_out = (player_state1 && !p1Resting) ? player_state1 : 2'b0; 
  assign player_state_2_out = (player_state2 && !p2Resting) ? player_state2 : 2'b0; 

  //31
  assign packedOutput = {1'b0, 1'b0, player_state_1_out, 1'b0, 1'b0, player_state_2_out, controllerInputs, 8'b0};

  assign confirm = 1'b1;



endmodule