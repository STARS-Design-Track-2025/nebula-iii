module screenCounter (
    input logic clk, rst, enableEdge,
    output logic [17:0] ct
);

logic [17:0] nextCt, currentCt;

always_comb begin
    if (enableEdge) begin
        nextCt = 0;
    end else if (currentCt == 18'b111111111111111111) begin
        nextCt = currentCt;
    end else begin
        nextCt = currentCt + 1;
    end
end

always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
        currentCt <= 0;
    end else begin
        currentCt <= nextCt;
    end
end

assign ct = currentCt;

endmodule