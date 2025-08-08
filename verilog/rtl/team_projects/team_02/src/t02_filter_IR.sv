`default_nettype none
module t02_filter_IR(
    input logic clk, n_rst, sdi, clk_en,
    output logic sclk, latch,
    output logic [1:0] state_out,
    output logic [39:0] row_data,  // Changed to 40 bits for 5x8 array
    output logic ball_detected,
    output logic [3:0] ball_pos_x,
    output logic [3:0] ball_pos_y,
    output logic [27:0] ssd
);
    logic [39:0] sensor_data, next_sensor_data;  // 40 bits for 5x8 array
    logic [5:0] bit_count, next_bit_count;       // Count up to 39
    assign state_out = state;

    typedef enum logic [1:0] {
        IDLE = 0,
        LATCH_DATA = 1,
        SHIFT_DATA = 2
    } state_t;

    state_t state, next_state;
    assign row_data = sensor_data;
    assign sclk = (state == SHIFT_DATA) ? clk : 1'b1;
    // assign ball_detected = (total_sensors > 0);
    assign ball_pos_x = x_pos_calc;
    assign ball_pos_y = y_pos_calc;


    logic [5:0] x_sum, next_x_sum;
    logic [5:0] y_sum, next_y_sum;
    logic [5:0] total_sensors, next_total_sensors;
    logic [3:0] x_pos_calc, next_x_pos_calc;
    logic [3:0] y_pos_calc, next_y_pos_calc;

    always_ff @ (posedge clk, negedge n_rst) begin
        if (~n_rst) begin
            state <= IDLE;
            sensor_data <= 40'b0;
            bit_count <= 6'b0;
            x_sum <= 0;
            y_sum <= 0;
            total_sensors <= 0;
            x_pos_calc <= 0;
            y_pos_calc <= 0;
        end else if (clk_en) begin
            state <= next_state;
            sensor_data <= next_sensor_data;
            bit_count <= next_bit_count;
            x_sum <= next_x_sum;
            y_sum <= next_y_sum;
            total_sensors <= next_total_sensors;
            x_pos_calc <= next_x_pos_calc;
            y_pos_calc <= next_y_pos_calc;
        end
    end

// Calculate final sensor data (for when we need it)
    logic [39:0] final_sensor_data;
    assign final_sensor_data = {sensor_data[38:0], ~sdi};;

    always_comb begin
    next_state = state;
    next_sensor_data = sensor_data;
    next_bit_count = bit_count;
    latch = 1'b1;
    next_x_sum = x_sum;
    next_y_sum = y_sum;
    next_total_sensors = total_sensors;
    next_x_pos_calc = x_pos_calc;
    next_y_pos_calc = y_pos_calc;
    ball_detected = (total_sensors > 0);

    case(state)
    IDLE: begin
            latch = 1'b1;
            next_state = LATCH_DATA;
            ball_detected = (total_sensors > 0);
    end
    LATCH_DATA: begin
            latch = 1'b0;
            next_state = SHIFT_DATA;
            // Reset calculations for new data
            next_x_sum = 0;
            next_y_sum = 0;
            next_total_sensors = total_sensors;
            ball_detected = (total_sensors > 0);
    end
    SHIFT_DATA: begin
        latch = 1'b1;
        ball_detected = (total_sensors > 0);
        if (bit_count < 38) begin  // Need 40 bits total (0-39)
            next_bit_count = bit_count + 1;
            next_sensor_data = {sensor_data[38:0], ~sdi};
        end else begin
        // All 40 bits received, calculate position
        next_state = IDLE;
        next_bit_count = 6'b0;
        next_sensor_data = final_sensor_data;
        // Calculate position using priority encoder - structured to avoid latches
        next_x_pos_calc = 4'd0;
        next_y_pos_calc = 4'd0;
        next_total_sensors = 6'd0;

    // Row 0 (bits 39:32)
    if (final_sensor_data[32]) begin next_x_pos_calc = 4'd0; next_y_pos_calc = 4'd0; next_total_sensors = 6'd1; end
    else if (final_sensor_data[33]) begin next_x_pos_calc = 4'd1; next_y_pos_calc = 4'd0; next_total_sensors = 6'd1; end
    else if (final_sensor_data[34]) begin next_x_pos_calc = 4'd2; next_y_pos_calc = 4'd0; next_total_sensors = 6'd1; end
    else if (final_sensor_data[35]) begin next_x_pos_calc = 4'd3; next_y_pos_calc = 4'd0; next_total_sensors = 6'd1; end
    else if (final_sensor_data[36]) begin next_x_pos_calc = 4'd4; next_y_pos_calc = 4'd0; next_total_sensors = 6'd1; end
    else if (final_sensor_data[37]) begin next_x_pos_calc = 4'd5; next_y_pos_calc = 4'd0; next_total_sensors = 6'd1; end
    else if (final_sensor_data[38]) begin next_x_pos_calc = 4'd6; next_y_pos_calc = 4'd0; next_total_sensors = 6'd1; end
    else if (final_sensor_data[39]) begin next_x_pos_calc = 4'd7; next_y_pos_calc = 4'd0; next_total_sensors = 6'd1; end
    // Row 1 (bits 31:24)
    else if (final_sensor_data[24]) begin next_x_pos_calc = 4'd0; next_y_pos_calc = 4'd1; next_total_sensors = 6'd1; end
    else if (final_sensor_data[25]) begin next_x_pos_calc = 4'd1; next_y_pos_calc = 4'd1; next_total_sensors = 6'd1; end
    else if (final_sensor_data[26]) begin next_x_pos_calc = 4'd2; next_y_pos_calc = 4'd1; next_total_sensors = 6'd1; end
    else if (final_sensor_data[27]) begin next_x_pos_calc = 4'd3; next_y_pos_calc = 4'd1; next_total_sensors = 6'd1; end
    else if (final_sensor_data[28]) begin next_x_pos_calc = 4'd4; next_y_pos_calc = 4'd1; next_total_sensors = 6'd1; end
    else if (final_sensor_data[29]) begin next_x_pos_calc = 4'd5; next_y_pos_calc = 4'd1; next_total_sensors = 6'd1; end
    else if (final_sensor_data[30]) begin next_x_pos_calc = 4'd6; next_y_pos_calc = 4'd1; next_total_sensors = 6'd1; end
    else if (final_sensor_data[31]) begin next_x_pos_calc = 4'd7; next_y_pos_calc = 4'd1; next_total_sensors = 6'd1; end
    // Row 2 (bits 23:16)
    else if (final_sensor_data[16]) begin next_x_pos_calc = 4'd0; next_y_pos_calc = 4'd2; next_total_sensors = 6'd1; end
    else if (final_sensor_data[17]) begin next_x_pos_calc = 4'd1; next_y_pos_calc = 4'd2; next_total_sensors = 6'd1; end
    else if (final_sensor_data[18]) begin next_x_pos_calc = 4'd2; next_y_pos_calc = 4'd2; next_total_sensors = 6'd1; end
    else if (final_sensor_data[19]) begin next_x_pos_calc = 4'd3; next_y_pos_calc = 4'd2; next_total_sensors = 6'd1; end
    else if (final_sensor_data[20]) begin next_x_pos_calc = 4'd4; next_y_pos_calc = 4'd2; next_total_sensors = 6'd1; end
    else if (final_sensor_data[21]) begin next_x_pos_calc = 4'd5; next_y_pos_calc = 4'd2; next_total_sensors = 6'd1; end
    else if (final_sensor_data[22]) begin next_x_pos_calc = 4'd6; next_y_pos_calc = 4'd2; next_total_sensors = 6'd1; end
    else if (final_sensor_data[23]) begin next_x_pos_calc = 4'd7; next_y_pos_calc = 4'd2; next_total_sensors = 6'd1; end
    // Row 3 (bits 15:8)
    else if (final_sensor_data[8]) begin next_x_pos_calc = 4'd0; next_y_pos_calc = 4'd3; next_total_sensors = 6'd1; end
    else if (final_sensor_data[9]) begin next_x_pos_calc = 4'd1; next_y_pos_calc = 4'd3; next_total_sensors = 6'd1; end
    else if (final_sensor_data[10]) begin next_x_pos_calc = 4'd2; next_y_pos_calc = 4'd3; next_total_sensors = 6'd1; end
    else if (final_sensor_data[11]) begin next_x_pos_calc = 4'd3; next_y_pos_calc = 4'd3; next_total_sensors = 6'd1; end
    else if (final_sensor_data[12]) begin next_x_pos_calc = 4'd4; next_y_pos_calc = 4'd3; next_total_sensors = 6'd1; end
    else if (final_sensor_data[13]) begin next_x_pos_calc = 4'd5; next_y_pos_calc = 4'd3; next_total_sensors = 6'd1; end
    else if (final_sensor_data[14]) begin next_x_pos_calc = 4'd6; next_y_pos_calc = 4'd3; next_total_sensors = 6'd1; end
    else if (final_sensor_data[15]) begin next_x_pos_calc = 4'd7; next_y_pos_calc = 4'd3; next_total_sensors = 6'd1; end
    // Row 4 (bits 7:0)
    else if (final_sensor_data[0]) begin next_x_pos_calc = 4'd0; next_y_pos_calc = 4'd4; next_total_sensors = 6'd1; end
    else if (final_sensor_data[1]) begin next_x_pos_calc = 4'd1; next_y_pos_calc = 4'd4; next_total_sensors = 6'd1; end
    else if (final_sensor_data[2]) begin next_x_pos_calc = 4'd2; next_y_pos_calc = 4'd4; next_total_sensors = 6'd1; end
    else if (final_sensor_data[3]) begin next_x_pos_calc = 4'd3; next_y_pos_calc = 4'd4; next_total_sensors = 6'd1; end
    else if (final_sensor_data[4]) begin next_x_pos_calc = 4'd4; next_y_pos_calc = 4'd4; next_total_sensors = 6'd1; end
    else if (final_sensor_data[5]) begin next_x_pos_calc = 4'd5; next_y_pos_calc = 4'd4; next_total_sensors = 6'd1; end
    else if (final_sensor_data[6]) begin next_x_pos_calc = 4'd6; next_y_pos_calc = 4'd4; next_total_sensors = 6'd1; end
    else if (final_sensor_data[7]) begin next_x_pos_calc = 4'd7; next_y_pos_calc = 4'd4; next_total_sensors = 6'd1; end
    // No sensors active - defaults already set above
    end
    end
    default: next_state = state;
    endcase
    end

function [6:0] seven_seg_decode(input [3:0] digit);
    case (digit)
        4'h0: seven_seg_decode = 7'b0111111;
        4'h1: seven_seg_decode = 7'b0000110;
        4'h2: seven_seg_decode = 7'b1011011;
        4'h3: seven_seg_decode = 7'b1001111;
        4'h4: seven_seg_decode = 7'b1100110;
        4'h5: seven_seg_decode = 7'b1101101;
        4'h6: seven_seg_decode = 7'b1111101;
        4'h7: seven_seg_decode = 7'b0000111;
        4'h8: seven_seg_decode = 7'b1111111;
        4'h9: seven_seg_decode = 7'b1101111;
        default: seven_seg_decode = 7'b1000000;  // Display '-' for invalid
    endcase
endfunction

// Update display - show X and Y position
always_ff@(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        ssd <= 28'h0;
    end else if (clk_en) begin
        if (ball_detected) begin
            // Display format: "XYXY" where first XY is position, second XY is repeated
            // Or use format: "X-Y-" 
            ssd[27:21] <= seven_seg_decode(x_pos_calc);      // First digit: X position
            ssd[20:14] <= seven_seg_decode(10);              // Second digit: dash (separator)
            ssd[13:7] <= seven_seg_decode(y_pos_calc);       // Third digit: Y position  
            ssd[6:0] <= seven_seg_decode(10);                // Fourth digit: dash
        end else begin
            // Display "----" when no ball detected
            // ssd <= {7'b0000000, 7'b0000000, 7'b0000000, 7'b0000000};
            ssd[27:21] <= seven_seg_decode(x_pos_calc);      // First digit: X position
            ssd[20:14] <= seven_seg_decode(10);              // Second digit: dash (separator)
            ssd[13:7] <= seven_seg_decode(y_pos_calc);       // Third digit: Y position  
            ssd[6:0] <= seven_seg_decode(10);                // Fourth digit: dash
        end
    end
end

endmodule