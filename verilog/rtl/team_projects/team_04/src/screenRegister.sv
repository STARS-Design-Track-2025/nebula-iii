module screenRegister(
    input logic [31:0] data, address,
    input logic wen, rst, clk, ack,
    output logic [31:0] control, coord
);

logic [31:0] nextControl, currentControl, nextCoord, currentCoord, controlAd, coordAd;

assign controlAd = 32'd4;
assign coordAd = 32'd8;

always_comb begin
    nextControl = currentControl;
    nextCoord = currentCoord;
    if (ack) begin
        nextControl = 32'b0;
        nextCoord = 32'b0;
    end else if (wen) begin
        if (address == controlAd) begin
            nextControl = data;
        end else if (address == coordAd) begin
            nextCoord = data;
        end
    end
end

always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
        currentControl <= 32'b0;
        currentCoord <= 32'b0;
    end else begin
        currentControl <= nextControl;
        currentCoord <= nextCoord;
    end
end

assign control = currentControl;
assign coord = currentCoord;

endmodule