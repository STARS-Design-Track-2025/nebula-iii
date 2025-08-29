`default_nettype none
`timescale 1ps/1ps
module t03_color_out_logic(

    //add inputs accordingly for more sprites, etc
    input logic [7:0] player_1_sprite,
    input logic [7:0] player_2_sprite,
    input logic [10:0] Vcnt,
    input logic [10:0] Hcnt,
    input logic [7:0] text_sprite,
    input logic [7:0] text_color,
    output logic [7:0] color_out
);

    logic [10:0] min_x_to_display;
    logic [10:0] min_y_to_display;
    assign min_x_to_display = 37; //min x before it can even display anything
    assign min_y_to_display = 29; //min y before it can even display anthing.
    logic [7:0] background_color; 

    always_comb begin
    background_color = 0;
     if((Hcnt > min_x_to_display && Hcnt < 11'd600)) begin
            if (Vcnt > min_y_to_display && Vcnt < 600) begin
                background_color = 8'b01010111;
            end
            if (Vcnt >= 600 && Vcnt < 800) begin
                background_color = 8'b00010100;
            end
        end
        else begin
            background_color = 8'b0000000;
        end

    if((player_1_sprite != 8'd0) && (player_2_sprite != 8'd0)) begin
        color_out = player_1_sprite;
    end
    else if(player_1_sprite != 8'd0) begin
         color_out = player_1_sprite;
         
    end
    else if(player_2_sprite != 8'd0) begin
         color_out = player_2_sprite;
    end
    else if(text_sprite != 8'd0) begin
         color_out = text_color;
    end
    else begin
        color_out = background_color;
    end

end




endmodule