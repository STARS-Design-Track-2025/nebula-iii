module t04_keypad_interface(
    input logic clk, rst,
    input logic [3:0] column,
    input logic [3:0] row,
    output logic [4:0] button,
    output logic [1:0] app,
    output logic rising
);

logic alpha;
logic debounced;
logic pulse;
logic [3:0] row_d;


// t04_counter_column columns(.clk(clk), .rst(rst), .column(column), .pulse_e(pulse));
// between these two modules is the physical keypad
t04_button_debounce debounce(.clk(clk), .rst(rst), .row(row), .row_d(row_d));
t04_button_decoder_edge_detector decode(.clk(clk), .rst(rst), .alpha(alpha), .row(row_d), .column(column), .button(button), .rising(rising), .pulse(pulse));
t04_app_alpha_fsm apps(.clk(clk), .rst(rst), .alpha(alpha), .rising(rising), .button(button), .app(app));

endmodule
