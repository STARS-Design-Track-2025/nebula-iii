`default_nettype none
`timescale 1ps/1ps
//6718863,
module t03_player_FSM_new #(
    parameter MAX_COUNT = 26'd6718863,
                HALF_COUNT = 26'd3359432,
                THREE_QUARTER_COUNT = 26'd5039147
)(
    input logic clk, rst, finished,
    input logic buttonAPress,
    input logic buttonBPress,
    output logic [1:0] player_state,
    output logic resting
);

logic [25:0] counter, n_counter; //does the counting for when we should assert attack/block and when we should deassert
logic attack, n_attack, block, n_block; //does the logic for when we should attack and not attack
logic [1:0] n_player_state; //this is next state logic for our output
logic counting, n_counting; //this is the counting for when we should deassert our attack and block

typedef enum logic [1:0] { 
    INIT = 2'b0,
    PUNCHING = 2'b01,
    BLOCKING = 2'b10
} STATE;

always_ff @( posedge clk, posedge rst ) begin
    if (rst) begin
        counter <= '0;
        player_state <= INIT;
        block <= '0;
        attack <= '0;
        counting <= '1;
    end else if (finished) begin
        counter <= n_counter;
        attack <= n_attack;
        block <= n_block;
        player_state <= n_player_state;
        counting <= n_counting;
    end
end

always @(*) begin
    // defaults
    n_attack = 0;
    n_block = 0;
    n_player_state = player_state;
    n_counting = counting;
    n_counter = counter;

    if (counting)
        n_counter = counter + 1;

    if (counter <= HALF_COUNT) begin
        n_block = 1;
    end
    if (counter <= THREE_QUARTER_COUNT) begin
        n_attack = 1;
    end
    case (player_state)
        INIT: begin
            resting = 1;
            if (!buttonAPress) begin
                n_player_state = PUNCHING;
                n_counting = 1;
                n_counter = 0;
            end else if (!buttonBPress) begin
                n_player_state = BLOCKING;
                n_counting = 1;
                n_counter = 0;
            end
        end
        PUNCHING: begin
            if (buttonAPress && (counter >= MAX_COUNT)) begin
                n_counter = 0;
                n_counting = 0;
                n_player_state = INIT;
            end
              
            if(!buttonAPress || counter >= HALF_COUNT) begin
                resting = 1;
            end
            else begin
                resting = 0;
            end
        end
        BLOCKING: begin
            if (buttonBPress && counter >= THREE_QUARTER_COUNT) begin
                n_counter = 0;
                n_counting = 0;
                n_player_state = INIT;
            end
              
            if(!buttonBPress) begin
                resting = 1;
            end
            else begin
                resting = 0;
            end
        end
        default begin
             n_player_state = INIT;
             resting = 0;
        end

    endcase
end

// always_comb begin //RESTING LOGIC
//     case(player_state)
//         INIT: begin
//             resting = 0;
//         end
//         PUNCHING: begin
//             resting = 0;
//             if(counter >= HALF_COUNT) begin
//                 resting = 1;
//             end else if(buttonAPress && counter < HALF_COUNT) begin
//                 resting = 0;
//             end
//             else begin
//                 resting = 1;
//             end
//         end
//         BLOCKING: begin
//             resting = 0;
//             if(counter >= QUARTER_COUNT) begin
//                 resting = 1;
//             end else if(buttonBPress && counter < QUARTER_COUNT) begin
//                 resting = 0;
//             end
//             else begin
//                 resting = 1;
//             end
//         end
//         default: begin
//             resting = 0;
//         end
//     endcase
// end


endmodule