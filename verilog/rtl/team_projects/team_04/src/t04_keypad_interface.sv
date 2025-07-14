module t04_keypad_interface(
    input logic clk, rst,
    input logic [3:0] row,
    output logic [4:0] button,
    output logic [1:0] app,
    output logic rising
);

logic [3:0] column;
logic alpha;
logic debounced;
logic [4:0] button_o;


t04_counter_column columns(.clk(clk), .rst(rst), .column(column));
// between these two modules is the physical keypad
t04_button_decoder_edge_detector decode(.clk(clk), .rst(rst), .alpha(alpha), .row(row), .column(column), .button(button), .rising(rising), .debounced(debounced));
t04_app_alpha_fsm apps(.clk(clk), .rst(rst), .alpha(alpha), .rising(rising), .button(button), .app(app));
// t04_button_storage store(.clk(clk), .rst(rst), .button(button), .button_o(button_o), .rising(rising));

endmodule
