// dont use this -- try to use 12 mhz system clock. fix spi. keep pwm the same

/* NEVER CHANGE PWM */

`default_nettype none

module t02_servo_pwm (
    input  logic        clk,         // 12 MHz clock
    input  logic        rst,         // Active-low reset
    input  logic [7:0]  duty_cycle,  // From PID (100-200 = 1.0-2.0ms)
    output logic        pwm_out      // PWM signal to servo
);

// given parameters
localparam CLK_FRQ = 10_000_000,
    PWM_FREQ = 50,
    MIN_PULSE_PER = 1000, //in ns (1ms)
    MAX_PULSE_PER = 2000, //in ns (2ms)
//calculated
    PWM_CYCLES = CLK_FRQ / PWM_FREQ,
    MIN_PULSE_CYCLES = (CLK_FRQ / 1_000_000) * MIN_PULSE_PER,
    MAX_PULSE_CYCLES = (CLK_FRQ / 1_000_000) * MAX_PULSE_PER;

//PWM counter
logic [19:0] count_d, count_q;

always_ff @(posedge clk, negedge rst) begin
    if (!rst) begin
        count_q <= '0;
    end else begin
        count_q <= count_d;
    end
end

always_comb begin
    count_d = count_q + 1;
    if (count_q < PWM_CYCLES[19:0]) begin
        if (count_q < MIN_PULSE_CYCLES[19:0]) begin
            pwm_out = 1;
        end else if (count_q < MAX_PULSE_CYCLES[19:0]) begin
            if ((count_q - MIN_PULSE_CYCLES[19:0]) < (duty_cycle * ((MAX_PULSE_CYCLES[19:0] - MIN_PULSE_CYCLES[19:0]) / 256))) begin
                pwm_out = 1;
            end else begin
                pwm_out = 0;
            end
        end else begin
            pwm_out = 0;
        end
    end else begin
        pwm_out = 0;
        count_d = 0;
    end
end
//     PWM_FREQ     = 50,        // 20ms period (240,000 ticks @12MHz)
//     MIN_TICKS    = 12_000,    // 1.0ms minimum pulse
//     MAX_TICKS    = 24_000;    // 2.0ms maximum pulse

// logic [19:0] counter;                // 20-bit counter for 240,000 ticks
// logic [19:0] high_ticks;             // Calculated high time
// logic pwm_signal;


// always_comb begin
//     // Convert duty_cycle (100-200) to ticks (12,000-24,000)
//     // Using fixed-point scaling for precision: (duty_cycle * 120)


//     high_ticks = !rst ? MIN_TICKS : // 1.0ms on reset
//     (duty_cycle * CLK_FRQ ); // Normal operation


//     // high_ticks = 12_000;
//     // Generate PWM signal

//         // // Force 0° during reset OR when duty=100
//         // if (rst || (duty_cycle <= 100)) begin
//         //     high_ticks = MIN_TICKS; // 1.0ms pulse (0°)
//         // end else begin
//         //     high_ticks = MIN_TICKS + ( (20'(duty_cycle) - 20'd100 ) * 20'd120);
//         // end



//     pwm_signal = (counter < high_ticks);
// end

// always_ff @(posedge clk or negedge rst) begin
//     if (!rst) begin
//         counter <= 20'b0;
//     end else begin
//             if (counter < 240_000) begin // 20 ms period (50 Hz)
//                 counter <= counter + 1'b1;
//             end else begin
//                 counter <= 20'b0;
//             end
//     end
// end

// assign pwm_out = pwm_signal;

endmodule