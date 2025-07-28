module t04_keypad_register (
    input  logic        clk,
    input  logic        reset,
    input  logic [4:0]  button_pressed,
    input  logic [1:0]  app,              // Unused but reserved for future use
    input  logic        rising,           // Treated as sync signal (should already be edge-detector output)
    input  logic        key_en,
    input  logic        JAL_O,
    input  logic        BranchConditionFlag,
    output logic [31:0] data_out

);

    logic [31:0] key_reg, key_reg_n;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            key_reg <= 32'b0;
        end else begin
            key_reg <= key_reg_n;
        end
    end

    always_comb begin
        if (rising) begin
            key_reg_n = {25'b0, app[1:0], button_pressed};
        end else if (BranchConditionFlag) begin
            key_reg_n = 32'b0;
        end else begin
            key_reg_n = key_reg;
        end
    end
    assign data_out = key_reg;

endmodule
