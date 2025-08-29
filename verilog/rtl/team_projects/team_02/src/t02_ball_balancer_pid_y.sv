`default_nettype none

module t02_ball_balancer_pid_y (
    input  logic        clk,         // System clock
    input logic clk_en,
    input  logic        reset_n,     // Active-low reset
    input  logic        angle_valid,
    input  logic signed [15:0] tilt,  // Platform tilt X (Q8.8 format)
    input  logic signed [15:0] setpoint, // Desired X tilt (default=0)
    output logic [7:0] duty_a   // Output for Motor A (0°)
    // output logic pid_en
);

// PID Parameters (Q8.8 fixed-point)
localparam KP = 16'd900;  // 1.0
localparam KI = 16'd0;  // 0.0625
localparam KD = 16'd64;  // 0.25

// PID outputs
logic signed [15:0] pid_x;

logic [15:0] error;

assign error = setpoint - tilt;

// Instantiate PID controllers
t02_pid_controller y_pid (
    .clk(clk),
    .clk_en(clk_en),
    .reset_n(reset_n),
    .pid_en(angle_valid),
    .error(error),  // Invert for correction direction // error = setpoint - angle
    .kp(KP),
    .ki(KI),
    .kd(KD),
    .out(pid_x)
);


logic signed [16:0] duty_temp_debug;
logic [7:0] duty_x_debug;

always_comb begin
    // Start with neutral (150) and add the fake PID output
    duty_temp_debug = $signed(17'd150) - $signed(pid_x);
    
    // Clamp to valid PWM range (100-200) - same pattern as your IR code
    duty_x_debug = (duty_temp_debug < 17'd100) ? 8'd100 :
                   (duty_temp_debug > 17'd200) ? 8'd200 :
                   duty_temp_debug[7:0];
end

assign duty_a = duty_temp_debug[7:0];

endmodule