`default_nettype none

// FPGA top module for Team 01

module team_01_fpga_top (
  // I/O ports
  input  logic hwclk, reset,
  input  logic [20:0] pb,
  input logic J39_b15, J39_c15,
  input logic [7:0] left, 
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
  logic [2:0] grid_color, score_color, starboy_color, final_color, grid_color_movement, grid_color_hold, credits;  
  logic onehuzz;
  logic [9:0] current_score;
  logic finish, gameover;
  logic [3:0] gamestate;

  logic [24:0] scoremod;
  logic [19:0][9:0] new_block_array;
  logic speed_mode_o;
logic [19:0][9:0][2:0] final_display_color;
// Color priority logic: starboy and score display take priority over grid
always_comb begin
  if (starboy_color != 3'b000) begin  // If starboy display has color (highest priority)
    final_color = starboy_color;
  end else if (score_color != 3'b000) begin  // If score display has color
    final_color = score_color;
  end else if (credits != 3'b000) begin
    final_color = credits;
  end else begin
    final_color = grid_color_movement;
    end
end



// ai vs human player
typedef enum logic [1:0]{
  TOP_IDLE = 'b0, 
  TOP_HUMAN_PLAY = 'b1, 
  TOP_AI_PLAY = 'b10
} top_level_state_t; 

top_level_state_t c_top_state, n_top_state; 
logic [1:0] top_level_state = c_top_state; // input for the Tetris FSM 

// testing 
// assign J40_p5 = top_level_state[1]; 
// assign J40_n5 = top_level_state[0]; 
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
          tetris_speed_up = J39_c15;  
        end
    end
    TOP_AI_PLAY: begin 
      if (gamestate == 'd8) begin // gameover state 
        n_top_state = TOP_IDLE; 
      end else begin 
          tetris_right = ai_right; 
          tetris_left = ai_left; 
          tetris_rotate_r = ai_rotate;
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
  logic human_player, ai_player; 

  t01_debounce NIRAJMENONFANCLUB (.clk(clk_25m), .pb(pb[0]), .button(right_i));
  t01_debounce BENTANAYAYAYAYAYAY (.clk(clk_25m), .pb(pb[3]), .button(left_i));
  t01_debounce nandyhu (.clk(clk_25m), .pb(pb[4]), .button(rotate_r));
  t01_debounce benmillerlite (.clk(clk_25m), .pb(pb[7]), .button(rotate_l));
  t01_debounce tetris_human_game (.clk(clk_25m), .pb(J39_b15), .button(human_player));
  t01_debounce tetris_ai_game (.clk(clk_25m), .pb(J39_b20), .button(ai_player));

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
    
    // Game Logic - UPDATED WITH NEW OUTPUTS
    t01_tetrisFSM plait (
      .c_top_state(c_top_state),
      .clk(clk_25m), 
      .reset(rst), 
      .onehuzz(onehuzz), 
      .right_i(right_i), 
      .left_i(left_i), 
      .start_i(pb[19]),
      .rotate_r(rotate_r), 
      .rotate_l(rotate_l), 
      .speed_up_i(pb[8]), 
      .display_array(new_block_array), 
      .final_display_color(final_display_color),
      .gameover(gameover), 
      .score(current_score), 
      .speed_mode_o(speed_mode_o),
      .gamestate(gamestate),
      //AI
        .top_level_state(top_level_state), 
        .ai_done(ofm_layer_done), 
        .ai_new_spawn(ai_new_spawn), 
        .ai_col_left(ai_col_left), 
        .ai_col_right(ai_col_right), 
        .ai_blockX(ai_blockX), 
        .ofm_blockX(ofm_blockX), 
        .current_block_type(current_layer_block_type), 
        .ai_block_type(ai_block_type), 
        .ai_need_rotate(ai_need_rotate), 
        .ai_rotated(ai_rotated), 
        .ofm_block_type_input(ofm_block_type_input), 
        .ofm_block_type(ofm_block_type), 
        .next_block_type_o(next_block_type),        // LOOK AHEAD OUTPUT
        .next_block_preview(next_block_preview)   
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

    logic [2:0] next_block_color;

    t01_lookahead justinjiang (
        .x(x),
        .y(y),
        .next_block_data(next_block_preview),
        .display_color(next_block_color)
    );

    // STARBOY Display
    t01_starboyDisplay silly (
      .clk(onehuzz),
      .rst(rst),
      .x(x),
      .y(y),
      .shape_color(starboy_color)
    );

    t01_tetrisCredits nebulabubu (
        .x(x),
        .y(y),
        .text_color(credits)
    );

  logic [15:0] lfsr_reg;

    t01_counter chchch (
      .clk(clk10k),
      .rst(rst),
      .enable('1),
      .lfsr_reg(lfsr_reg),
      .block_type()
    );

  logic clk10k;

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
    logic ai_col_right, ai_col_left, ai_left, ai_right, ai_rotate, ai_new_spawn, ai_need_rotate; 
    logic ai_rotated; 
    t01_ai_game_engine ai_game_engine (
      .clk(clk_25m), 
      .rst(rst), 
      .gamestate(gamestate), 
      .col_right(ai_col_right), 
      .col_left(ai_col_left), 
      .ai_right(ai_right), 
      .ai_left(ai_left), 
      .ai_rotate(), 
      .blockX(), 
      .extract_start(extract_start), 
      .ofm_done(ofm_layer_done), 
      .current_block_type(current_layer_block_type),
      .ai_new_spawn(ai_new_spawn), 
      .c_piece_done(), 
      .need_rotate(ai_need_rotate), 
      .rotate_block_type(ai_block_type), 
      .ai_rotated(ai_rotated)
    );

    logic extract_start, extract_ready;
    logic [7:0]           lines_cleared;
    logic [7:0]           holes;
    logic [7:0]           bumpiness;
    logic [7:0]           height_sum;
    logic [199:0] fe_board; 
    logic [2:0] fe_state; 
    
    t01_ai_feature_extract_new fe (
    .clk           (clk_25m),
    .rst         (rst),
    .extract_start (extract_start),
    .tetris_grid    (new_block_array),
    .extract_ready (extract_ready),
    .lines_cleared (lines_cleared),
    .holes         (holes),
    .bumpiness     (bumpiness),
    .height_sum    (height_sum), 
    .state(fe_state), 
    .ofm_done(ofm_layer_done)
    );

  logic mmu_done;
  logic [3:0] ofm_blockX; 
  logic ofm_layer_done; 
  logic [4:0] ofm_block_type; 
  logic        mmu_res_valid;
  logic [17:0] mmu_res_out;

  // --- 
// ai without mmu 
// --- 
  // assign mmu_done = extract_ready; 
//   always_ff @(posedge clk_25m, posedge rst) begin 
//     if (rst) begin 
//     mmu_done <= 0;
//     end else begin 
//       if (extract_ready) begin 
//         mmu_done <= 1;
//       end else begin 
//         mmu_done <= 0; 
//       end  
//     end
//   end 
//   // the less score the better without mmu 
//   // assign mmu_res_out = lines_cleared > 0 ? 0 : // line clear is so good that it's the best
//   //        {10'b0, height_sum} + {10'b0, holes} +  {10'b0, bumpiness}; 
//   assign mmu_res_out = {10'b0, bumpiness}; 

//   t01_ai_ofm ofm (
//     .clk(clk_25m), 
//     .rst(rst || (ai_new_spawn && gamestate == 'd1)), 
//     .gamestate(gamestate), 
//     .mmu_done(mmu_done), 
//     .mmu_result_i(mmu_res_out), 
//     .blockX_i(ai_blockX), 
//     .block_type_i(current_layer_block_type), 
//     .blockX_o(ofm_blockX), 
//     .block_type_o(ofm_block_type), 
//     .done(ofm_layer_done) 
//   );
// endmodule 
// ==== 
// ai with mmu 
// ===

// original fsm mmu  
 typedef enum logic [2:0] {
  IDLE,
  LAYER0_PROCESS,
  LAYER1_PROCESS,
  LAYER2_PROCESS,
  LAYER3_PROCESS,
  DONE
} ai_state_t;

ai_state_t ai_state, next_ai_state;
logic [1:0] current_layer_sel;
logic mmu_start;
logic [7:0] layer0_features [4]; // Store the 4 input features
logic [7:0] layer_outputs [32]; // Store outputs from current layer
logic [4:0] output_counter;
logic layer_input_ready;

// Store your input features
always_ff @(posedge clk_25m or posedge rst) begin
  if (rst) begin
    layer0_features[0] <= 8'd0;
    layer0_features[1] <= 8'd0;
    layer0_features[2] <= 8'd0;
    layer0_features[3] <= 8'd0;
  end else if (extract_ready) begin
    layer0_features[0] <= lines_cleared;
    layer0_features[1] <= holes;
    layer0_features[2] <= bumpiness;
    layer0_features[3] <= height_sum;
  end
end

// AI state machine
always_ff @(posedge clk_25m or posedge rst) begin
  if (rst) begin
    ai_state <= IDLE;
    current_layer_sel <= 2'b00;
    output_counter <= 5'd0;
  end else begin
    ai_state <= next_ai_state;
   
    case (ai_state)
      LAYER0_PROCESS: current_layer_sel <= 2'b00;
      LAYER1_PROCESS: current_layer_sel <= 2'b01;
      LAYER2_PROCESS: current_layer_sel <= 2'b10;
      LAYER3_PROCESS: current_layer_sel <= 2'b11;
      default current_layer_sel <= 2'b00;
    endcase
   
    // Count outputs received
    if (mmu_res_valid) begin
      output_counter <= output_counter + 1;
      layer_outputs[output_counter] <= mmu_res_out[7:0]; // Truncate to 8 bits for next layer
    end else if (mmu_start) begin
      output_counter <= 5'd0;
    end
  end
end

// AI state machine logic
always_comb begin
  next_ai_state = ai_state;
  mmu_start = 1'b0;
 
  case (ai_state)
    IDLE: begin
      if (extract_ready) begin
        next_ai_state = LAYER0_PROCESS;
        mmu_start = 1'b1;
      end
    end
   
    LAYER0_PROCESS: begin
      if (mmu_done) begin
        next_ai_state = LAYER1_PROCESS;
        mmu_start = 1'b1;
      end
    end
   
    LAYER1_PROCESS: begin
      if (mmu_done) begin
        next_ai_state = LAYER2_PROCESS;
        mmu_start = 1'b1;
      end
    end
   
    LAYER2_PROCESS: begin
      if (mmu_done) begin
        next_ai_state = LAYER3_PROCESS;
        mmu_start = 1'b1;
      end
    end
   
    LAYER3_PROCESS: begin
      if (mmu_done) begin
        next_ai_state = DONE;
      end
    end
   
    DONE: begin
      // AI computation complete, result available
      next_ai_state = IDLE;
    end
    default next_ai_state = IDLE;
  endcase
end

// Data streaming logic for MMU input
logic [7:0] mmu_act_value;
logic [5:0] input_counter;
logic mmu_act_valid_internal;

// Track input counter during MAC phase
always_ff @(posedge clk_25m or posedge rst) begin
  if (rst) begin
    input_counter <= 6'd0;
  end else if (mmu_start) begin
    input_counter <= 6'd0;
  end else if (mmu_act_valid_internal) begin
    input_counter <= input_counter + 1;
  end
end

    // Generic Algorithm (GA) Approximation 
    logic [99:0] ga_line, ga_hei, ga_hol, ga_bum, mmu_in_temp; 
    assign ga_line = lines_cleared * 100'd76; 
    assign ga_hei = height_sum * 100'd50; 
    assign ga_hol = holes * 100'd36; 
    assign ga_bum = bumpiness * 100'd18; 
    // assign mmu_res_out = ga_line[17:0] + ga_hei[17:0] + ga_hol[17:0] + ga_bum[17:0]; 
    assign mmu_in_temp = (ga_line + ga_hei + ga_hol + ga_bum) / 100'd100;
    // assign mmu_act_value = mmu_in_temp[7:0];  

// Generate input data based on current layer and input counter
always_comb begin
  mmu_act_value = 8'd0;
 
  case (current_layer_sel)
    2'b00: begin // Layer 0: Feed the 4 features
      if (input_counter < 6'd4) begin
        // mmu_act_value = layer0_features[input_counter[1:0]];
              mmu_act_value = mmu_in_temp[7:0];  
              // mmu_act_value = bumpiness; 
      end
      // else: feed zeros for remaining inputs (counter 4-31)

    end
   
    2'b01, 2'b10, 2'b11: begin // Layers 1,2,3: Feed previous layer outputs
      if (input_counter < 6'd32) begin
        mmu_act_value = layer_outputs[input_counter[4:0]];
      end
    end
  endcase
end
assign mmu_act_valid_internal = (ai_state != IDLE) && (ai_state != DONE) && !mmu_done;

// MMU Instantiation
t01_ai_MMU mmu (
  .clk       (clk_25m),
  .rst_n     (!rst),
  .start     (mmu_start),
  .layer_sel (current_layer_sel),
  .act_valid (mmu_act_valid_internal),
  .act_in    (mmu_act_value),
  .res_valid (mmu_res_valid),
  .res_out   (mmu_res_out),
  .done      (mmu_done)
);

  // t01_ai_ofm ofm (
  //   .clk(clk_25m), 
  //   .rst(rst || (ai_new_spawn && gamestate == 'd1)), 
  //   .gamestate(gamestate), 
  //   .mmu_done(mmu_done && current_layer_sel == 'd2), 
  //   .mmu_result_i(mmu_res_out), 
  //   .blockX_i(ai_blockX), 
  //   .block_type_i(ofm_block_type_input), 
  //   .blockX_o(ofm_blockX), 
  //   .block_type_o(ofm_block_type), 
  //   .done(ofm_layer_done) 
  // );

  // tmp 
    t01_ai_ofm_tmp ofm_tmp (
    .clk(clk_25m), 
    .rst(rst || (ai_new_spawn && gamestate == 'd1)), 
    .gamestate(gamestate), 
    .mmu_done(mmu_done && current_layer_sel == 'd2), 
    .mmu_result_i(), 
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
