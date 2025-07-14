module t04_keypad_register (
    input  logic        clk,
    input  logic        reset,
    input  logic [4:0]  button_pressed,
    input  logic [1:0]  app,              // Unused but reserved for future use
    input  logic        rising,           // Treated as sync signal (should already be edge-detector output)
    input  logic        key_en,
    output logic [31:0] data_out,
    output logic key_ack
);

    logic [31:0] key_reg;

    always_ff @(posedge clk, posedge reset) begin
        if (reset)
            key_reg <= 32'b0;
        else if (key_en && rising)
            key_reg <= {27'b0, button_pressed};  
    end

    assign key_ack = rising;
    assign data_out = key_reg;

endmodule
