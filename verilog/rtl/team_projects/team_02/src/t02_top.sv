`default_nettype none
// Empty top module

module t02_top (
  // I/O ports
  input  logic hz100, reset,
  input  logic [20:0] pb,
  output logic [7:0] left, right, ss0,

  // UART ports
  output logic [7:0] txdata,
  input  logic [7:0] rxdata,
  output logic txclk, rxclk,
  input  logic txready, rxready
);
    
    logic reset_n;          // Active-low reset
    logic clk_en, pid_en;           // 1kHz clock enable

    logic [15:0] tilt_x, tilt_y, setpoint_x, next_setpoint_x, setpoint_y, next_setpoint_y; // from IMU & Setpoint Control

    logic [79:0] data_out, rx_data;
    logic [87:0] tx_data;
    logic [4:0] state_imu;

    logic signed [15:0] accel_x_raw, accel_y_raw, accel_z_raw, gyro_x_raw, gyro_y_raw;
    logic signed [15:0] timestep;

    logic [15:0] tilt_roll, tilt_pitch, pitch_prev, roll_prev;
    logic [2:0] state_filter;
    logic angle_valid, filter_ready, calculate_out, first_run;

    logic [5:0] ir_array; //N number of IR sensors
    logic ball_detected;
    logic [3:0] ball_pos_x, ball_pos_y;

    // Packed 7-segment display outputs
    logic [7:0] ss0_reg, ss1_reg, ss2_reg, ss3_reg;  // Individual digit registers

    // Display refresh counter 
    logic [1:0] digit_select;

    // Duty cycles for PWM
    logic [7:0] duty_x, duty_y;
    
    // Convert active-high reset to active-low
    assign reset_n = reset;

     // Instantiate clock divider for PID
    t02_clk_div1kHz clkdiv_inst (
        .clk_12mhz(hz100), //hz100 = 10Mhz
        .reset_n(reset_n),
        .pid_clk_en(clk_en),
        .sck(sclk)
    );

    logic sdo, en, cs, sdi, sclk, sclk_imu, data_ready;

    t02_edge_detector en_edge (
        .clk_en(clk_en),
        .clk(hz100),
        .n_rst(reset_n),
        .button(pb[18]),
        .button_edge(en)
    );
    // assign en = pb[18];
    assign sdo = pb[1]; // data from imu
    assign left[2] = cs; // select imu
    assign left[0] = sdi; // data into imu
    assign left[1] = sclk_imu; // serial clock
    
    assign right[4] = sclk;

    assign left[7] = en;
    // assign en = pb[18];

    t02_imu_addr test_imu (
        .hz100(hz100),
        .clk_en(clk_en),
        .n_rst(reset_n),
        .sdo(sdo),
        .en(en),
        .cs(cs),
        .sdi(sdi),
        .sclk(sclk_imu),
        .data_out(data_out),
        .filter_ready(1'b1),
        .data_ready(data_ready)
    );

    // assign filter_ready = 1'b1;

    t02_sensor_decoder formatRawData (
        .data_out(data_out),
        .accel_x(accel_x_raw),
        .accel_y(accel_y_raw),
        .accel_z(accel_z_raw),
        .gyro_x(gyro_x_raw),
        .gyro_y(gyro_y_raw)
    );



    logic signed [15:0] dbg_accel_x, dbg_accel_y, dbg_accel_z;

    t02_complementary_filter fuseData(
        .clk(hz100),
        .n_rst(reset_n),
        .data_ready(data_ready),
        .accel_x_raw(accel_x_raw),
        .accel_y_raw(accel_y_raw),
        .accel_z_raw(accel_z_raw),
        .gyro_x_raw(gyro_x_raw),
        .gyro_y_raw(gyro_y_raw),
        .tilt_roll_out(tilt_roll),
        .tilt_pitch_out(tilt_pitch),
        .angle_valid(angle_valid)
        // .dbg_accel_x(dbg_accel_x),
        // .dbg_accel_y(dbg_accel_y),
        // .dbg_accel_z(dbg_accel_z)
    );



    assign timestep = 16'h003a;

    logic [27:0] ssd_data;
    // // IR sensor processing (modified for 2D position) - Now uses 1kHz clock enable
    t02_filter_IR ir_sensor_array (
        .clk(hz100),                      // System clock
        .clk_en(clk_en),
        .n_rst(reset_n),              // Active-low reset
        
        // Shift register interface
        .sdi(pb[2]),                   // Serial data input from shift registers
        .sclk(),                 // Serial clock to shift registers
        .latch(right[5]),               // Latch signal to shift registers
        
        // Ball detection outputs
        .ball_detected(ball_detected),    // Detection flag
        .ball_pos_x(ball_pos_x),            // X position (0-4)
        .ball_pos_y(ball_pos_y),            // Y position (0-7)
        .ssd(ssd_data),              // Seven-segment display outputs
        .state_out(),
        .row_data(row_data)
    );

    logic [39:0] row_data;


  

    // Setpoint control (modified for 2D)
    t02_setpoint_control setpoint_inst (
        .clk(hz100),
        .clk_en(clk_en),
        .rst_n(reset_n),
        .ball_detected(ball_detected),
        .x_pos_calc(ball_pos_x),
        .y_pos_calc(ball_pos_y),
        .setpoint_x(setpoint_x),
        .setpoint_y(setpoint_y),

        .state_out()
    );

  
    // assign pid_en = 1'b1;
    // assign angle_valid = 1'b1;

    // assign setpoint_y = 16'd0;

    assign tilt_x = 0; // change for testing without IMU
    // PID controller
    t02_ball_balancer_pid_x pid_x (
        .clk(hz100),
        .clk_en(clk_en),
        .reset_n(reset_n),
        .angle_valid(angle_valid),
        .tilt(tilt_roll),       // X-axis tilt
        .setpoint(setpoint_x), // X setpoint
        .duty_a(duty_x)     // X-axis motor
        // .pid_en(pid_en)
    );

    assign tilt_y = 0;

  //   // Y-axis PID controller
    t02_ball_balancer_pid_y pid_y (
        .clk(hz100),
        .clk_en(clk_en),
        .reset_n(reset_n),
        .angle_valid(angle_valid),
        .tilt(tilt_pitch),       // X-axis tilt
        .setpoint(setpoint_y), // X setpoint
        .duty_a(duty_y)     // X-axis motor
        // .pid_en(pid_en)
    );

    assign pid_en = 1'b1;

    // assign duty_x = 8'd130;
    // assign duty_y = 8'd130;

    t02_microstepping microstep_x(.clk_12mhz(hz100), .reset_n(reset_n), .duty_x(duty_x), .actual_duty_x(actual_duty_x));
    t02_microstepping microstep_y(.clk_12mhz(hz100), .reset_n(reset_n), .duty_x(duty_y), .actual_duty_x(actual_duty_y));

    logic [7:0] actual_duty_x, actual_duty_y;

  //   // PWM generators
    t02_servo_pwm pwm_a_inst_x (.clk(hz100), .rst(reset_n), .duty_cycle(actual_duty_x), .pwm_out(right[2]));
    t02_servo_pwm pwm_a_inst_y (.clk(hz100), .rst(reset_n), .duty_cycle(actual_duty_y), .pwm_out(right[3]));


    logic [9:0] out_lcd;
    logic out_valid;
    // logic lcd_en, lcd_rw, lcd_rs;
    t02_driver_1602 #(
        .clk_div(24_000)
    ) lcd1602 (
    .clk(hz100),
    .rst(reset_n),      // active-high reset
    // 16 characters per row, each character is 8 bits, total 128 bits (row_1[127:120] is first char)

    .row_1({48'b01010100_01001001_01001100_01010100_00100000_01011000, 8'b00100000, tilt_x_ascii, 32'b00100000001000000010000000100000, ball_x_lcd}),
    // .row_1({row_data, 8'b00100000, 8'b00100000, tilt_x_ascii, 32'b00100000001000000010000000100000, ball_x_lcd}),
    .row_2({48'b01010100_01001001_01001100_01010100_00100000_01011001, 8'b00100000, tilt_y_ascii, 32'b00100000001000000010000000100000, ball_y_lcd}),
    // LCD interface signals
    .out(out_lcd),
    .out_valid(out_valid)
    );

    logic start_lcd, sdo_lcd, sclk_lcd, cs_n_lcd, busy_lcd, done_lcd;
    logic [9:0] data_in;

    assign start_lcd = out_valid;
    assign data_in = out_lcd;

    t02_1602_spi #(
        .WIDTH(10),                    // Number of bits to transmit
        .CLK_DIV(40)                   // Clock divider (system_clk / CLK_DIV = spi_clk)
    ) spi (
        .clk    (hz100),    // System clock
        .rst_n  (reset_n),   // Active low reset
        .start  (start_lcd),    // Start transmission (pulse)
        .data_in(data_in),  // Data to transmit
        .sdo    (sdo_lcd),      // Serial data out (MOSI)
        .sclk   (sclk_lcd),     // SPI clock
        .cs_n   (cs_n_lcd),     // Chip select (active low)
        .busy   (busy_lcd),     // Transmission in progress
        .done   (done_lcd)      // Transmission complete (pulse)
    );

    logic [31:0] tilt_x_ascii;
    logic [31:0] tilt_y_ascii;
    logic [7:0] ball_x_lcd, ball_y_lcd;

    t02_lcd_decoder getASCII (
        .tilt_x(tilt_roll),
        .tilt_y(tilt_pitch),
        .ball_x_pos(ball_pos_x),
        .ball_y_pos(ball_pos_y),
        .out_x(tilt_x_ascii),
        .out_y(tilt_y_ascii),
        .ball_x_lcd(ball_x_lcd),
        .ball_y_lcd(ball_y_lcd)
    );

    assign {ss0[1], right[0], ss0[7]} = {cs_n_lcd, sdo_lcd, sclk_lcd};






endmodule