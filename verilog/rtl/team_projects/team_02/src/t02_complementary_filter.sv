`default_nettype none

module t02_complementary_filter(
    input logic clk, n_rst, data_ready,
    input logic signed [15:0] accel_x_raw, accel_y_raw, accel_z_raw, gyro_x_raw, gyro_y_raw,
    output logic signed [15:0] tilt_roll_out, tilt_pitch_out,
    output logic angle_valid

    // // Debug outputs
    // output logic signed [15:0] dbg_accel_x, dbg_accel_y, dbg_accel_z
    // output logic signed [15:0] dbg_gyro_x, dbg_gyro_y,
    // output logic signed [15:0] dbg_pitch_accel, dbg_roll_accel,
    // output logic signed [15:0] dbg_pitch_gyro, dbg_roll_gyro,
    // output logic signed [15:0] dbg_tilt_pitch, dbg_tilt_roll,
    // output logic signed [15:0] dbg_tilt_pitch_prev, dbg_tilt_roll_prev
    );

    // convert to physical values
    logic signed [15:0] accel_x, accel_y, accel_z, gyro_x, gyro_y;
    logic signed [15:0] roll_prev, pitch_prev, tilt_roll, tilt_roll_temp, tilt_pitch, tilt_pitch_temp;
    logic [31:0] dt;

    assign dt = 32'd58; // Q16.16, ~0.000889s

    assign accel_x = accel_x_raw / 32;
    assign accel_y = accel_y_raw / 32;
    assign accel_z = (accel_z_raw == 0) ? 16'sd256 : accel_z_raw / 32;

    // assign gyro_x = (gyro_x_raw * 256) / 65.5;
    // assign gyro_y = (gyro_y_raw * 256) / 65.5;
// 256 / 65.5 ≈ 3.908 → Q8.8 = 3.908 * 256 ≈ 1000
    localparam logic signed [15:0] GYRO_SCALE_Q8 = 16'sd1000;
    localparam logic signed [15:0] GYRO_DIVISOR = 16'sd16768;

    assign gyro_x = (gyro_x_raw * GYRO_SCALE_Q8) / GYRO_DIVISOR;
    assign gyro_y = (gyro_y_raw * GYRO_SCALE_Q8) / GYRO_DIVISOR;


    // Magnitude squared of acceleration vector
    logic [31:0] ax2, ay2, az2, accel_magnitude_sq;
    assign ax2 = accel_x * accel_x;
    assign ay2 = accel_y * accel_y;
    assign az2 = accel_z * accel_z;
    assign accel_magnitude_sq = ax2 + ay2 + az2;

    // Accel magnitude threshold for trusting accelerometer
    localparam logic [31:0] G_SQ_MIN = 32'd52428; // ~0.8g²
    localparam logic [31:0] G_SQ_MAX = 32'd78643; // ~1.2g²

    logic use_accel;
    assign use_accel = (accel_magnitude_sq >= G_SQ_MIN) && (accel_magnitude_sq <= G_SQ_MAX);

    // pitch path
    logic signed [15:0] pitch_accel, pitch_gyro;
    logic [31:0] gyro_y_delta;
    logic signed [31:0] pitch_accel_temp;
    assign gyro_y_delta = gyro_y * dt;
    assign pitch_accel_temp = ((-{{16{accel_x[15]}}, accel_x} <<< 16) / {{16{accel_z[15]}}, accel_z}) >>> 8;
    assign pitch_accel = pitch_accel_temp[15:0];
    assign pitch_gyro = pitch_prev - gyro_y_delta[23:8];
    assign tilt_pitch_temp = use_accel ? ((pitch_gyro * 251 + pitch_accel * 5) >> 8) : pitch_gyro;
    always_comb begin
        if (tilt_pitch_temp < -16'sd70) begin
            tilt_pitch = tilt_pitch_temp + 16'sd70;
        end else if (tilt_pitch_temp > 16'sd70) begin
            tilt_pitch = tilt_pitch_temp - 16'sd70;
        end else begin
            tilt_pitch = tilt_pitch_temp;
        end

        if (tilt_roll_temp < -16'sd70) begin
            tilt_roll = tilt_roll_temp + 16'sd70;
        end else if (tilt_roll_temp > 16'sd70) begin
            tilt_roll = tilt_roll_temp - 16'sd70;
        end else begin
            tilt_roll = tilt_roll_temp;
        end
    end


    // assign tilt_pitch = (tilt_pitch_temp < -16'sd70 || tilt_pitch_temp > 16'sd70) ? 16'sd0 : tilt_pitch_temp;

    // roll path
    logic signed [15:0] roll_accel, roll_gyro;
    logic [31:0] gyro_x_delta;
    logic signed [31:0] roll_accel_temp;
    assign gyro_x_delta = gyro_x * dt;
    assign roll_accel_temp = ((-{{16{accel_y[15]}}, accel_y} <<< 16) / {{16{accel_z[15]}}, accel_z}) >>> 8;
    assign roll_accel = roll_accel_temp[15:0];
    assign roll_gyro = roll_prev - gyro_x_delta[23:8];
    assign tilt_roll_temp = use_accel ? ((roll_gyro * 252 + roll_accel * 4) >> 8) : roll_gyro;
    // assign tilt_roll = (tilt_roll_temp > -16'sd30 && tilt_roll_temp < 16'sd30) ? 16'sd0 : tilt_roll_temp;

    // Previous state tracking
    logic first_run;

    always_ff @(posedge clk) begin
        if (!n_rst) begin
            pitch_prev <= 16'sd0;
            roll_prev <= 16'sd0;
            first_run <= 1'b1;
        end else if (data_ready) begin
            if (first_run) begin
                pitch_prev <= pitch_accel;
                roll_prev <= roll_accel;
                first_run <= 1'b0;
            end else begin
                pitch_prev <= tilt_pitch;
                roll_prev <= tilt_roll;
            end
        end
    end

    // Output registration
    always_ff @ (posedge clk or negedge n_rst) begin
        if (~n_rst) begin
            tilt_pitch_out <= 16'd0;
            tilt_roll_out <= 16'd0;
        end else if (data_ready) begin
            tilt_pitch_out <= tilt_pitch;
            tilt_roll_out <= tilt_roll;
        end
    end

    assign angle_valid = data_ready;

    // Debug assignments
    // assign dbg_accel_x = accel_x;
    // assign dbg_accel_y = accel_y;
    // assign dbg_accel_z = accel_z;

    // assign dbg_gyro_x = gyro_x;
    // assign dbg_gyro_y = gyro_y;

    // assign dbg_pitch_accel = pitch_accel;
    // assign dbg_roll_accel = roll_accel;

    // assign dbg_pitch_gyro = pitch_gyro;
    // assign dbg_roll_gyro = roll_gyro;

    // assign dbg_tilt_pitch = tilt_pitch;
    // assign dbg_tilt_roll = tilt_roll;

    // assign dbg_tilt_pitch_prev = pitch_prev;
    // assign dbg_tilt_roll_prev = roll_prev;

endmodule

