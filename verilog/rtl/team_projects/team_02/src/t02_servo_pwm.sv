`default_nettype none

module t02_servo_pwm (
    input  logic        clk,         // 12 MHz clock
    input  logic        rst,         // Active-low reset
    input  logic [7:0]  duty_cycle,  // From PID (100-200 = 1.0-2.0ms)
    output logic        pwm_out      // PWM signal to servo
);

// Timing parameters for 12MHz clock
localparam PERIOD_TICKS = 240_000;   // 20ms period (240,000 ticks @12MHz)
localparam MIN_TICKS    = 12_000;    // 1.0ms minimum pulse
localparam MAX_TICKS    = 24_000;    // 2.0ms maximum pulse

logic [19:0] counter;                // 20-bit counter for 240,000 ticks
logic [19:0] high_ticks;             // Calculated high time
logic pwm_signal;


always_comb begin
    // Convert duty_cycle (100-200) to ticks (12,000-24,000)
    // Using fixed-point scaling for precision: (duty_cycle * 120)


    high_ticks = !rst ? 12_000 : // 1.0ms on reset
    (duty_cycle * 120); // Normal operation


    // high_ticks = 12_000;
    // Generate PWM signal

        // // Force 0° during reset OR when duty=100
        // if (rst || (duty_cycle <= 100)) begin
        //     high_ticks = MIN_TICKS; // 1.0ms pulse (0°)
        // end else begin
        //     high_ticks = MIN_TICKS + ( (20'(duty_cycle) - 20'd100 ) * 20'd120);
        // end



    pwm_signal = (counter < high_ticks);
end

always_ff @(posedge clk or negedge rst) begin
    if (!rst) begin
        counter <= 20'b0;
    end else begin
            if (counter < 240_000) begin // 20 ms period (50 Hz)
                counter <= counter + 1'b1;
            end else begin
                counter <= 20'b0;
            end
    end
end

assign pwm_out = pwm_signal;

endmodule