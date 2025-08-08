`default_nettype none
module t02_microstepping (
    input logic clk_12mhz, // 12MHz system clock
    input logic reset_n, // Active-low reset
    input logic [7:0] duty_x,
    output logic [7:0] actual_duty_x
);

    logic [29:0] ctr = 0;
    logic clk_en;
    
    // Clock divider to create clock enable
    always_ff @ (posedge clk_12mhz, negedge reset_n) begin
        if (~reset_n) begin
            ctr <= 0;
            clk_en <= 1'b0;
        end else if (ctr == 239999) begin // 119999 = 100Hz, 239999 = 50 Hz, 599999 = 20 Hz
            ctr <= 0;
            clk_en <= 1'b1; // Pulse high for one cycle
        end else begin
            ctr <= ctr + 1;
            clk_en <= 1'b0;
        end
    end

    parameter STEP_SIZE = 3; // Larger = faster response, less smoothing
    
    // Microstepping only happens when clk_en is high
    always_ff @(posedge clk_12mhz or negedge reset_n) begin
        if (!reset_n) begin
            actual_duty_x <= 8'd150;
        end else if (clk_en) begin // Only step when clock enable is active
            // X-axis
            if (duty_x > actual_duty_x + STEP_SIZE)
                actual_duty_x <= actual_duty_x + STEP_SIZE;
            else if (duty_x < actual_duty_x - STEP_SIZE)
                actual_duty_x <= actual_duty_x - STEP_SIZE;
            else
                actual_duty_x <= duty_x; // Snap to target when close
        end
        // When clk_en is low, actual_duty_x holds its current value
    end

endmodule