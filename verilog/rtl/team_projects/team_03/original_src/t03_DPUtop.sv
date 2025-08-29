`default_nettype none
`timescale 1ps/1ps
// Empty top module

module t03_DPUtop (
  // I/O ports
  input  logic clk, rst, //clk is currently 10MHz, check PPL in ice40hx8k.sv to change it 
  input logic [2:0] gameState,
  input logic [1:0] p1State, p2State,
  input logic [3:0] p1health, p2health,
  input logic [10:0] x1, x2, y1, y2,
  input logic p1Left, p2Left, 
  output logic [7:0] right,
  output logic [1:0] left
);
  // Your code goes here...

  // Mapping r[0] R, r[1] G, r[2] B, HS r[3], VS r[4]
   logic [10:0] Vcnt;
   logic [10:0] Hcnt;
   logic tc;
   logic vsync;
   logic [10:0] vertical_multiplier;

   logic at_display;
   logic color_logic;
   logic hsync;

   logic en;

   logic [7:0] player_1_color_out;
   logic [7:0] player_2_color_out;
   logic [7:0] text_color_out;  
  
   logic [7:0] color;
  //  assign color_logic = (color != 0) ? 1 : 0; //use this for text testing!
   assign right[0] = color[7];
   assign right[1] = color[6];
   assign right[2] = color[5];
   
   assign right[3] = color[4];
   assign right[4] = color[3];
   assign right[5] = color[2];

   assign right[6] = color[1];
   assign right[7] = color[0];

   assign left[0] = hsync;
   assign left[1] = vsync;

  logic [71:0] alphabet;
  logic [863:0] characters;
  logic [2399:0] player_sprite;


  logic is_1_displayed;
  logic is_2_displayed;

  logic clk_2hz;
  //ports must be flattened
  logic [11:0] p1health1d;
  logic [11:0] p2health2d;
  logic [7:0] text_color;
 
    //10MHZ to 2HZ(1 second)
  t03_bin4_to_bcd_decoder player_1_health_decoder(.health(p1health), .phealth(p1health1d));
  t03_bin4_to_bcd_decoder player_2_health_decoder(.health(p2health), .phealth(p2health2d));
  t03_alphabet_decoder state_decoder(.clk(clk), .rst(rst), .game_state(gameState), .alphabet(alphabet), .p1health(p1health1d), .p2health(p2health2d),  .text_color(text_color));
  
  t03_clock_divider clock_divider(.hwclk(clk), .rst(rst), .clkdiv(clk_2hz));
  t03_horizontal_counter horzintal(.tc(tc), .rst(rst), .clk(clk), .Hcnt(Hcnt));
  t03_vertical_counter vertical(.tc(tc), .clk(clk), .Vcnt(Vcnt), .rst(rst));
  t03_comparator comparer(.Hcnt(Hcnt),.Vcnt(Vcnt), .hsync(hsync), .vsync(vsync), .at_display(at_display));

  t03_text_lut text_lutter(.alphabet(alphabet), .characters(characters));
  t03_text_display display_logic(.Hcnt(Hcnt),.Vcnt(Vcnt),.text(characters),.color(text_color_out), .clk(clk),.rst(rst), .x(11'd30), .y(11'd100));


  //input p1Left & p2Left here.
  t03_player_1_display player_1_display(.Hcnt(Hcnt),.Vcnt(Vcnt),.player(player_sprite),.color(player_1_color_out),.clk(clk),.rst(rst),.x(x1),.y(11'd500 - y1), .is_1_displayed(is_1_displayed));
  t03_player_2_display player_2_display(.Hcnt(Hcnt),.Vcnt(Vcnt),.player(player_sprite),.color(player_2_color_out),.clk(clk),.rst(rst),.x(x2),.y(11'd500 - y2), .is_2_displayed(is_2_displayed));
  t03_player_lut player(.player_state({p2State,p1State}), .player(player_sprite), .is_1_displayed(is_1_displayed), .is_2_displayed(is_2_displayed), .p1Left(p1Left), .p2Left(p2Left));


  t03_color_out_logic color_comparator(.player_1_sprite(player_1_color_out), .player_2_sprite(player_2_color_out), .text_sprite(text_color_out), .text_color(text_color), .color_out(color), .Hcnt(Hcnt), .Vcnt(Vcnt));

  logic [31:0] address;
  logic [31:0] mock_data;
  
  
  
  
  
  
  // //"CPU"
  //  logic[2:0] game_state_unpacked;
  // logic [1:0] p1State_unpacked;
  // logic [1:0] p2State_unpacked;

  // logic [3:0] p1health_unpacked;
  // logic [3:0] p2health_unpacked;

  // logic [10:0] player_1_x_unpacked;
  // logic [10:0] player_2_x_unpacked;

  // logic [10:0] player_1_y_unpacked;
  // logic [10:0] player_2_y_unpacked;
  // //changes player_states
  // change_player_states player_1(.clk(clk),.rst(rst), .en(clk_2hz),.player_state(p1State_unpacked));
  // change_player_states player_2(.clk(clk),.rst(rst), .en(clk_2hz),.player_state(p2State_unpacked));
  
  // //change game_states game_s
  // change_game_states game_stater(.clk(clk),.rst(rst), .en(clk_2hz),.game_states(game_state_unpacked));

  // //change player positions 
  // change_player_1_positions player_1_positions(.clk(clk),.rst(rst), .en(clk_2hz),.x1(player_1_x_unpacked), .y1(player_1_y_unpacked));
  // change_player_2_positions player_2_positions(.clk(clk),.rst(rst), .en(clk_2hz),.x2(player_2_x_unpacked), .y2(player_2_y_unpacked));

  // //change player health
  // change_player_health player_1_health(.clk(clk),.rst(rst), .en(clk_2hz), .player_health(p1health_unpacked));

  // change_player_health player_2_health(.clk(clk),.rst(rst), .en(clk_2hz), .player_health(p2health_unpacked));
  
  // //address flipper
  // change_address rotate_addresses(.clk(clk),.rst(rst), .address(address));


  // //mimicks cpu packing
  // mock_dpuxcpu packer(.clk(clk), .rst(rst), .address(32'hFF000003), .data(mock_data), .gameState(game_state_unpacked), .p1State(p1State_unpacked), .p2State(p2State_unpacked), .p1health(p1health_unpacked), .p2health(p2health_unpacked), .x1(player_1_x_unpacked), .x2(player_2_x_unpacked), .y1(player_2_y_unpacked), .y2(player_1_y_unpacked));

endmodule