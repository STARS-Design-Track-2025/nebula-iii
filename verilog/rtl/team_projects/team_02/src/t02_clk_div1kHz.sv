`default_nettype none
module t02_clk_div1kHz (
    input logic clk_12mhz, // 12MHz system clock
    input logic reset_n, // Active-low reset
    output logic pid_clk_en, // 1kHz clock enable pulse
    output logic sck
);

// Counter for 1kHz generation (12MHz/12,000 = 1kHz)
logic [16:0] counter; // 14-bit counter (max 16,383 > 11,999)


// count before imu test was 11_999


always_ff @(posedge clk_12mhz or negedge reset_n) begin
    if (!reset_n) begin
        counter <= 0;
        pid_clk_en <= 0;
    end else begin
        // Default assignment
        pid_clk_en <= 0;
        
        // 2kHz clock divider (for enabling other modules)
        if (counter == 17'd4999) begin
            counter <= 0;
            pid_clk_en <= 1; // Single-cycle enable pulse
        end else begin
            counter <= counter + 1;
        end
    end
end

always_comb begin
    sck = 0;
    if (counter < 3000) begin
        sck = 1;
    end
end

endmodule