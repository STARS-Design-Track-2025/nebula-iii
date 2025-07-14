module t04_button_storage (
    input logic clk, rst, rising,
    input logic [4:0] button,
    output logic [4:0] button_o
);

logic [4:0] button_c, button_n;

always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
        button_c <= 0;
    end else begin
        button_c <= button_n;
    end
end


always_comb begin
    if (rising) begin
        button_o = button_c;
        button_n = button;
    end else begin
        button_o = 0;
        button_n = 0;
    end
end

endmodule