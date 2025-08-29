module t03_alphabet_decoder
(
    input logic  [2:0] game_state,
    output logic [71:0] alphabet,
    output logic [7:0] text_color,
    input logic [11:0] p1health,
    input logic [11:0] p2health,
    input logic clk,
    input logic rst
);

// logic [71:0] next_alphabet;
// always_ff @(posedge clk, posedge rst) begin
//     if(rst) begin
//         alphabet <= 0;
//     end
//     else begin
//         alphabet <= next_alphabet;
//     end 

// end




always_comb begin
text_color = 8'b11111111;
case (game_state)
    3'd0: begin // "PRESS START"
        alphabet = {6'd15, 6'd17, 6'd4, 6'd18, 6'd18, 6'd37, 6'd18, 6'd19, 6'd0, 6'd17, 6'd19, 6'd37};
        text_color = 8'b11111111;
    end

    3'd1: begin // "READY"
        alphabet = {6'd37, 6'd37, 6'd37, 6'd17, 6'd4, 6'd0, 6'd3, 6'd24, 6'd37, 6'd37, 6'd37, 6'd37};
        text_color = 8'b01011000;
    end

    3'd2: begin // "SET"
        alphabet = {6'd37, 6'd37, 6'd37, 6'd37, 6'd18, 6'd4, 6'd19, 6'd37, 6'd37, 6'd37, 6'd37, 6'd37};
        text_color = 8'b11111100;
    end

    3'd3: begin // "FIGHT"
        alphabet = {6'd37, 6'd37, 6'd37, 6'd5, 6'd8, 6'd6, 6'd7, 6'd19, 6'd37, 6'd37, 6'd37, 6'd37};
        text_color = 8'b11100100;
    end

    3'd4: begin // "FIGHT STATE
         alphabet = {p1health[11:6], p1health[5:0], 6'd37, 6'd37, 6'd37, 6'd37, 6'd37, 6'd37, 6'd37, 6'd37, p2health[11:6], p2health[5:0]};
         text_color = 8'b11111111;
    end

    3'd5: begin // "WINNER P1"
        alphabet = {6'd37, 6'd22, 6'd8, 6'd13, 6'd13, 6'd4, 6'd17, 6'd37, 6'd15, 6'd27, 6'd37, 6'd37};
        text_color = 8'b11100100;
    end

    3'd6: begin // "WINNER P2"
         alphabet = {6'd37, 6'd22, 6'd8, 6'd13, 6'd13, 6'd4, 6'd17, 6'd37, 6'd15, 6'd28, 6'd37, 6'd37};
         text_color = 8'b00000111;
    end

    default: begin // Blank or fallback
        alphabet = {12{6'd37}};
    end
endcase



end





endmodule