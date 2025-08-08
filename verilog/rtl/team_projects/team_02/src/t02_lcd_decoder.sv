`default_nettype none

module t02_lcd_decoder(
    input  logic signed [15:0] tilt_x,
    input  logic signed [15:0] tilt_y,
    input  logic        [3:0]  ball_x_pos,    // 0–7
    input  logic        [3:0]  ball_y_pos,    // 0–4
    output logic       [31:0] out_x,
    output logic       [31:0] out_y,
    output logic [7:0] ball_x_lcd,
    output logic [7:0] ball_y_lcd
);

    // Internal signals for processing each axis
    logic [31:0] ascii_x, ascii_y;
    
    // Generate ASCII for X axis
    t02_q8_8_to_ascii x_converter (
        .q8_8_in(tilt_x),
        .ascii_out(ascii_x)
    );
    
    // Generate ASCII for Y axis  
    t02_q8_8_to_ascii y_converter (
        .q8_8_in(tilt_y),
        .ascii_out(ascii_y)
    );
    
    assign out_x = ascii_x;
    assign out_y = ascii_y;

        // clamp & convert ball-pos → ASCII '0'..'9'
    logic [3:0] bx = (ball_x_pos <= 4'd7 ? ball_x_pos : 4'd7);
    logic [3:0] by = (ball_y_pos <= 4'd4 ? ball_y_pos : 4'd4);
    logic [7:0] ball_x_ascii = 8'h30 + {4'b0, bx};
    logic [7:0] ball_y_ascii = 8'h30 + {4'b0, by};

    // pack into final outputs: [tens][ones][dot][ball-pos]
    assign ball_x_lcd = ball_x_ascii;       // new X ball-pos;
    assign ball_y_lcd = ball_y_ascii;       // new X ball-pos;
endmodule

