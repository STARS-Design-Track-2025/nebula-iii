module t04_button_debounce (
    input logic clk, rst,
    input logic [3:0] row,
    output logic [3:0] row_d
);

logic [14:0] debounce;

//debounce portion
always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
        debounce <= 0;
    end else begin
        debounce <= {|row, debounce[14:1]}; // the reduction or is to see if a button has been pressed
    end
end
    
always_comb begin
    if (&debounce) begin
        row_d = row;
    end else begin
        row_d = 4'd0;
    end
end

endmodule
