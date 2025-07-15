module screenEnableEdge (
    input logic [31:0] xBus, yBus, control, 
    input logic clk, rst,
    output logic enableEdge
);

logic enableIn, enable1, enable2, enable3;

always_comb begin
    if (|control && |xBus && |yBus) begin
        enableIn = 1;
    end else begin
        enableIn = 0;
    end
end

always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
        enable1 <= 0;
        enable2 <= 0;
        enable3 <= 0;
    end else begin
        enable1 <= enableIn;
        enable2 <= enable1;
        enable3 <= enable2;
    end
end

assign enableEdge = enable2 && ~enable3;

endmodule