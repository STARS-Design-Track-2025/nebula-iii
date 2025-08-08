`default_nettype none
module t02_pid_controller (
    input logic clk,
    input logic clk_en,
    input logic reset_n,
    input logic pid_en,
    input logic signed [15:0] error,
    input logic signed [15:0] kp, ki, kd,
    output logic signed [15:0] out
);

    logic signed [15:0] integral, last_error;
    logic signed [15:0] p_term, i_term, d_term;
    logic signed [17:0] total;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            integral <= 16'h0000;
            last_error <= 16'h0000;
        end else if (clk_en) begin
            // Simple integral with basic saturation
            integral <= integral + error;
            last_error <= error;
        end
    end

    always_comb begin
        // Simple multiplication (assumes gains are small integers)
        p_term = (kp * error) >>> 8;
        i_term = (ki * integral) >>> 8; 
        d_term = (kd * (error - last_error)) >>> 8;
        
        // Add terms with 18-bit intermediate (explicit width casting)
        total = $signed({2'b00, p_term}) + $signed({2'b00, i_term}) + $signed({2'b00, d_term});
        out = total[17:2];
    end

endmodule