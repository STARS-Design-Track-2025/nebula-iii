`default_nettype none

// FPGA top module for Team 01

module team_01_fpga_top (
  // I/O ports
  input  logic hwclk, reset,
  input  logic [20:0] pb,
  input logic J39_b15, J39_c15,
  output logic [7:0] left, 
  output logic [1:0] right,
  output logic red, green, blue

  // UART ports
  // output logic [7:0] txdata,
  // input  logic [7:0] rxdata,
  // output logic txclk, rxclk,
  // input  logic txready, rxready
);

  // GPIOs
  // Don't forget to assign these to the ports above as needed
  // logic [33:0] gpio_in, gpio_out;
  
  
  // Team 01 Design Instance
  // team_01 team_01_inst (
  //   .clk(hwclk),
  //   .nrst(~reset),
  //   .en(1'b1),

  //   .gpio_in(gpio_in),
  //   .gpio_out(gpio_out),
  //   .gpio_oeb(),  // don't really need it her since it is an output

    // Uncomment only if using LA
    // .la_data_in(),
    // .la_data_out(),
    // .la_oenb(),

    // Uncomment only if using WB Master Ports (i.e., CPU teams)
    // You could also instantiate RAM in this module for testing
    // .ADR_O(ADR_O),
    // .DAT_O(DAT_O),
    // .SEL_O(SEL_O),
    // .WE_O(WE_O),
    // .STB_O(STB_O),
    // .CYC_O(CYC_O),
    // .ACK_I(ACK_I),
    // .DAT_I(DAT_I),

    // Add other I/O connections to WB bus here

  // );

  // Unused pins
  assign left[4:0] = '0;
  assign right[1:0] = '0;

  // New signals for next block preview
  logic [4:0] next_block_type;
  logic [3:0][3:0][2:0] next_block_preview;
  
  // Internal signals
  logic clk_25m;
  logic rst;
  assign rst = reset;
  assign clk_25m = hwclk;
  logic  J40_n4;

  logic [9:0] x, y;
  logic [2:0] grid_color, score_color, starboy_color, final_color, grid_color_movement, grid_color_hold, credits, next_block_color;  
  logic onehuzz;
  logic [9:0] current_score;
  logic finish, gameover;
  logic [3:0] gamestate;
  logic clk10k;
  logic [15:0] lfsr_reg;

  logic [24:0] scoremod;
  logic [19:0][9:0] new_block_array;
  logic speed_mode_o;
  logic [19:0][9:0][2:0] final_display_color;



//Color priority logic: starboy and score display take priority over grid
always_comb begin
  if (starboy_color != 3'b000) begin  // If starboy display has color (highest priority)
    final_color = starboy_color;
  end else if (score_color != 3'b000) begin  // If score display has color
    final_color = score_color;
  end else if (next_block_color != 3'b000) begin  // If next block display has color
    final_color = next_block_color;
  end else if (credits != 3'b000) begin
    final_color = credits;
  end else begin
    final_color = grid_color_movement;
    end
end


// ai vs human player
typedef enum logic [1:0]{
  TOP_IDLE, 
  TOP_HUMAN_PLAY, 
  TOP_AI_PLAY
} top_level_state_t; 

top_level_state_t c_top_state, n_top_state; 
logic [1:0] top_level_state;
assign top_level_state = c_top_state; // input for the Tetris FSM 


always_ff @(posedge clk_25m, posedge rst) begin 
  if (rst) begin 
    c_top_state <= TOP_IDLE; 
  end else begin 
    c_top_state <= n_top_state; 
  end
end

// tetris movement pins 
logic tetris_right, tetris_left, tetris_rotate_r, tetris_rotate_l, tetris_speed_up;
always_comb begin 
  n_top_state = c_top_state; 
  // movement default instantiation 
  tetris_right = 0; 
  tetris_left = 0; 
  tetris_rotate_r = 0;
  tetris_rotate_l = 0;
  tetris_speed_up = 0; 

  case(c_top_state)
    TOP_IDLE: begin 
      // enable tetris state change from GAMEOVER to RESTART 
      tetris_right = right_i; // even when the last play was AI we can restart with right_i user input 
      if (gamestate == 0 || gamestate == 'd9) begin  // INIT or RESTART 
          if (pb[16]) begin 
            n_top_state = TOP_AI_PLAY; 
          end else if (pb[19]) begin 
            n_top_state = TOP_HUMAN_PLAY; 
          end
      end
    end 
    TOP_HUMAN_PLAY: begin 
      if (gamestate == 'd8) begin // gameover state 
        n_top_state = TOP_IDLE; 
      end else begin 
          tetris_right = right_i; 
          tetris_left = left_i; 
          tetris_rotate_r = rotate_r;
          tetris_rotate_l = rotate_l;
          tetris_speed_up = pb[8];  
        end
    end
    TOP_AI_PLAY: begin 
      if (gamestate == 'd8) begin // gameover state 
        n_top_state = TOP_IDLE; 
      end else begin 
          tetris_right = ai_right; 
          tetris_left = ai_left; 
          tetris_rotate_r = 0; // ai rotation is done by changing block types 
          tetris_rotate_l = 0;
          tetris_speed_up = 1'b1;  
        end
    end
    default: ;
  endcase
end

//=================================================================================
// MODULE INSTANTIATIONS
//=================================================================================

  logic right_i, left_i, rotate_r, rotate_l;

  t01_debounce NIRAJMENONFANCLUB (.clk(clk_25m), .pb(pb[0]), .button(right_i));
  t01_debounce BENTANAYAYAYAYAYAY (.clk(clk_25m), .pb(pb[3]), .button(left_i));
  t01_debounce nandyhu (.clk(clk_25m), .pb(pb[4]), .button(rotate_r));
  t01_debounce benmillerlite (.clk(clk_25m), .pb(pb[7]), .button(rotate_l));

    //=============================================================================
    // tetris game !!!
    //=============================================================================
    
    // VGA driver 
    t01_vgadriver ryangosling (
      .clk(clk_25m), 
      .rst(rst),  
      .color_in(final_color),  
      .red(red),  
      .green(green), 
      .blue(blue), 
      .hsync(left[7]),  
      .vsync(left[6]),  
      .x_out(x), 
      .y_out(y)
    );
  
    // Clock Divider (gurt)
    t01_clkdiv1hz yo (
      .clk(clk_25m), 
      .rst(rst), 
      .newclk(onehuzz), 
      .speed_up(speed_mode_o),
      .top_level_state(top_level_state), 
      .ai_new_spawn(ai_new_spawn), 
      .scoremod(scoremod)
    );

    // Speed Controller
    t01_speed_controller jorkingtree (
      .clk(clk_25m),
      .reset(rst),
      .current_score(current_score),
      .scoremod(scoremod),
      .gamestate(gamestate)
    );
    
    // Game Logic
    t01_ai_tetrisFSM plait (
      .clk(clk_25m), 
      .reset(rst), 
      .onehuzz(onehuzz), 
      .right_i(right_i), 
      .left_i(left_i), 
      .start_i(pb[19]),
      .rotate_r(rotate_r), 
      .rotate_l(rotate_l), 
      .speed_up_i(tetris_speed_up), 
      .display_array(new_block_array), 
      .final_display_color(final_display_color),
      .gameover(gameover), 
      .score(current_score), 
      .speed_mode_o(speed_mode_o),
      .gamestate(gamestate),
      .next_block_type_o(next_block_type),        // LOOK AHEAD OUTPUT
      .next_block_preview(next_block_preview) ,
      //AI  
        .top_level_state(top_level_state), 
        .ai_done(ofm_layer_done), 
        .ai_new_spawn(ai_new_spawn), 
        .ai_col_right(ai_col_right), 
        .ai_blockX(ai_blockX), 
        .ofm_blockX(ofm_blockX), 
        .current_block_type(current_layer_block_type), 
        .ai_block_type(ai_block_type), 
        .ai_need_rotate(ai_need_rotate), 
        .ai_rotated(ai_rotated), 
        .ofm_block_type_input(ofm_block_type_input), 
        .ofm_block_type(ofm_block_type), 
        .ai_force_right(ai_force_right)
    );
        // Tetris Grid Display
    t01_tetrisGrid miguelohara (
      .x(x),  
      .y(y),  
      .shape_color(grid_color_movement), 
      .final_display_color(final_display_color),
      .gameover(gameover),
      .top_level_state(top_level_state)
    );

    // Score Display
    t01_scoredisplay ralsei (
      .clk(onehuzz),
      .rst(rst),
      .score(current_score),
      .x(x),
      .y(y),
      .shape_color(score_color)
    );

    // STARBOY Display
    t01_starboyDisplay silly (
      .clk(onehuzz),
      .rst(rst),
      .x(x),
      .y(y),
      .shape_color(starboy_color)
    );

    // Credits Display
    t01_tetrisCredits nebulabubu (
        .x(x),
        .y(y),
        .text_color(credits)
    );

    t01_lookahead justinjiang (
        .x(x),
        .y(y),
        .next_block_data(next_block_preview),
        .display_color(next_block_color)
    );


    t01_counter chchch (
      .clk(clk10k),
      .rst(rst),
      .enable('1),
      .lfsr_reg(lfsr_reg),
      .block_type()
    );


    t01_clkdiv10k thebackofmyfavoritestorespencers(
      .clk(clk_25m),
      .rst(rst),
      .newclk(clk10k)
    );

    // assign J40_n4 = lfsr_reg[0];

    t01_musicman piercetheveil (
      .clk(clk_25m),
      .rst(rst),
      .square_out(left[5]),
      .lfsr(lfsr_reg),
      .gameover(gameover)
    );


    //=============================================================================
    // agentic ai accelerator bsb saas yc startup bay area matcha lababu stussy !!!
    //=============================================================================

    logic [4:0] current_layer_block_type, ai_block_type, ofm_block_type_input; 
    logic [3:0] ai_blockX; 
    logic c_piece_done, mmu_all_done; 
    logic ai_col_right, ai_left, ai_right, ai_new_spawn, ai_need_rotate; 
    logic ai_rotated, ai_force_right; 
    logic mmu_done;
    logic [3:0] ofm_blockX; 
    logic ofm_layer_done; 
    logic [4:0] ofm_block_type; 
    logic extract_start, extract_ready, potential_force_right;
    logic [7:0] lines_cleared;
    logic [7:0] holes;
    logic [7:0] bumpiness;
    logic [7:0] height_sum;
    
    // placement/general ai engine 
    t01_ai_game_engine ai_game_engine (
      .clk(clk_25m), 
      .rst(rst), 
      .gamestate(gamestate), 
      .col_right(ai_col_right), 
      .ai_right(ai_right), 
      .ai_left(ai_left), 
      .falling_blockX(ai_blockX), 
      .extract_start(extract_start), 
      .ofm_done(ofm_layer_done), 
      .current_block_type(current_layer_block_type),
      .ai_new_spawn(ai_new_spawn), 
      .need_rotate(ai_need_rotate), 
      .rotate_block_type(ai_block_type), 
      .ai_rotated(ai_rotated), 
      .force_right(ai_force_right)
    );
    
    // feature extract from simulated moves 
    t01_ai_feature_extract fe (
      .clk (clk_25m),
      .rst (rst),
      .extract_start (extract_start),
      .tetris_grid (new_block_array),
      .extract_ready (extract_ready),
      .lines_cleared (lines_cleared),
      .holes (holes),
      .bumpiness (bumpiness),
      .height_sum (height_sum), 
      .ofm_done(ofm_layer_done)
    );

    // output feature, choose best move 
    t01_ai_ofm ofm (
      .clk(clk_25m), 
      .rst(rst || (ai_new_spawn && gamestate == 'd1)), 
      .gamestate(gamestate), 
      .mmu_done(extract_ready), 
      .blockX_i(ai_blockX), 
      .block_type_i(ofm_block_type_input), 
      .blockX_o(ofm_blockX), 
      .block_type_o(ofm_block_type), 
      .done(ofm_layer_done), 
      .lines_cleared_i(lines_cleared), 
      .bumpiness_i(bumpiness), 
      .heights_i(height_sum), 
      .holes_i(holes)
    );
  endmodule
