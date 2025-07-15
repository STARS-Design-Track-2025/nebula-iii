module screenRegister(
    input logic [31:0] data, address,
    input logic wen, rst, clk, ack,
    output logic [31:0] control, xBus, yBus
);

logic [31:0] nextControl, currentControl, nextXbus, currentXbus, nextYbus, currentYbus, controlAd, xAd, yAd;

assign controlAd = 32'd4;
assign xAd = 32'd8;
assign yAd = 32'd12;

always_comb begin
    nextControl = currentControl;
    nextXbus = currentXbus;
    nextYbus = currentYbus;
    if (ack) begin
        nextControl = 32'b0;
        nextXbus = 32'b0;
        nextYbus = 32'b0;
    end else if (wen) begin
        if (address == controlAd) begin
            nextControl = data;
        end else if (address == xAd) begin
            nextXbus = data;
        end else if (address == yAd) begin
            nextYbus = data;
        end
    end
end

always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
        currentControl <= 32'b0;
        currentXbus <= 32'b0;
        currentYbus <= 32'b0;
    end else begin
        currentControl <= nextControl;
        currentXbus <= nextXbus;
        currentYbus <= nextYbus;
    end
end

assign control = currentControl;
assign xBus = currentXbus;
assign yBus = currentYbus;

endmodule