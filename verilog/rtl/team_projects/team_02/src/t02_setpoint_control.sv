`default_nettype none
module t02_setpoint_control(
    input logic clk,
    input logic rst_n,
    input logic clk_en,
    input logic ball_detected,
    input logic [3:0] x_pos_calc, // 0-7 sensor position (0=bottom, 7=top)
    input logic [3:0] y_pos_calc, // 0-4 sensor position (0=right, 4=left)
    output logic signed [15:0] setpoint_x, // Q8.8 format
    output logic signed [15:0] setpoint_y, // Q8.8 format
    output logic [1:0] state_out
);

// State indication: ball detected or not
assign state_out = ball_detected ? 2'b01 : 2'b00;

// Previous position tracking for jerk detection
logic [3:0] x_pos_prev, y_pos_prev;
logic ball_detected_prev;
logic entering_deadzone;

// Jerk counter for temporary opposite motion
logic [7:0] jerk_counter;
logic signed [15:0] jerk_x, jerk_y;

// Jerk timer for periodic disturbance
logic [15:0] jerk_timer;
logic jerk_active;
logic signed [15:0] jerk_magnitude;

// Parameters for jerk timing
parameter JERK_PERIOD = 16'd32000; // Adjust this value to change jerk frequency
parameter JERK_DURATION = 8'd50;   // How long the jerk lasts
logic [7:0] jerk_duration_counter;

// assign jerk_magnitude = 16'd10;

// Track previous positions on clock edge
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        x_pos_prev <= 4'b0;
        y_pos_prev <= 4'b0;
        ball_detected_prev <= 1'b0;
        jerk_counter <= 8'b0;
        jerk_active <= 1'b0;
        jerk_x <= 16'sd0;
        jerk_y <= 16'sd0;
    end else if (clk_en) begin
        x_pos_prev <= x_pos_calc;
        y_pos_prev <= y_pos_calc;
        ball_detected_prev <= ball_detected;

        if (jerk_timer >= JERK_PERIOD) begin
            jerk_timer <= 16'b0;
            if (ball_detected) begin // Only jerk if ball is detected
                jerk_active <= 1'b1;
                jerk_duration_counter <= JERK_DURATION;
            end
        end else begin
            jerk_timer <= jerk_timer + 1;
        end
        
        // Count down jerk duration
        if (jerk_active && jerk_duration_counter > 0) begin
            jerk_duration_counter <= jerk_duration_counter - 1;
        end else if (jerk_duration_counter == 0) begin
            jerk_active <= 1'b0;
            jerk_magnitude <= 16'sd0;
        end
    end
end

    always_comb begin
        // Edge midpoint cases - single axis control (adjusted for weighted center)
        if (x_pos_calc == 0 && y_pos_calc == 2) begin
            // Bottom edge midpoint → tilt only in Y direction (push toward center)
            setpoint_x = 16'sd0; 
            setpoint_y = 16'sd10;
            if (jerk_active) begin
                // setpoint_x = jerk_magnitude;
            end
        end else if (x_pos_calc == 7 && y_pos_calc == 2) begin
            // Top edge midpoint → tilt only in Y direction (push toward center)
            setpoint_x = 16'sd0; 
            setpoint_y = -16'sd10;
            if (jerk_active) begin
                // setpoint_x = jerk_magnitude;
            end
        end
        else if (y_pos_calc == 0 && x_pos_calc >= 3 && x_pos_calc <= 4) begin
            // Right edge midpoint → tilt only in X direction (push toward center)
            setpoint_y = 16'sd0; 
            setpoint_x = -16'sd10;
            if (jerk_active) begin
                // setpoint_x = jerk_magnitude;
            end
        end
        else if (y_pos_calc == 4 && x_pos_calc >= 3 && x_pos_calc <= 4) begin
            // Left edge midpoint → tilt only in X direction (push toward center)
            setpoint_y = 16'sd0; 
            setpoint_x = 16'sd10;
            if (jerk_active) begin
                // setpoint_x = jerk_magnitude;
            end
        end
        
        // Original quadrant cases (adjusted bounds for weighted center)
        else if (x_pos_calc <= 2 && y_pos_calc <= 1) begin
            // Bottom-right quadrant → push left & up
            setpoint_x = -16'sd10; 
            setpoint_y = 16'sd10;
            if (jerk_active) begin
                // setpoint_x = jerk_magnitude;
                // setpoint_y = jerk_magnitude;
            end 
        end
        else if (x_pos_calc >= 4 && y_pos_calc <= 2) begin
            // Top-right quadrant → push left & down
            setpoint_x = -16'sd10; 
            setpoint_y = -16'sd10;
            if (jerk_active) begin
                // setpoint_x = jerk_magnitude;
                // setpoint_y = jerk_magnitude;
            end  
        end
        else if (x_pos_calc <= 2 && y_pos_calc >= 3) begin
            // Bottom-left quadrant → push right & up
            setpoint_x = 16'sd10; 
            setpoint_y = 16'sd10;
            if (jerk_active) begin
                // setpoint_x = jerk_magnitude;
                // setpoint_y = jerk_magnitude;
            end  
        end
        else if (x_pos_calc >= 4 && y_pos_calc >= 2) begin
            // Top-left quadrant → push right & down
            setpoint_x = -16'sd10; 
            setpoint_y = 16'sd10; 
            if (jerk_active) begin
                // setpoint_x = jerk_magnitude;
                // setpoint_y = jerk_magnitude;
            end  
        end else begin
            setpoint_x = 16'sd0;
            setpoint_y = 16'sd0;
        end
    end



endmodule