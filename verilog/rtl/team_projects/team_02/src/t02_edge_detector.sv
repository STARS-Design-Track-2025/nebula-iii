`default_nettype none
module t02_edge_detector (
    input logic clk_en, clk, n_rst, button,
    output logic button_edge
);
    logic [1:0] state, next_state;
    
    always_ff @ (posedge clk, negedge n_rst) begin
        if (~n_rst) begin
            state <= 2'b00;
        end else if (clk_en) begin
            state <= next_state;
        end
    end
    
    always_comb begin
        next_state = {button, state[1]};
        button_edge = button && ~state[1];  // current && ~previous
    end
endmodule