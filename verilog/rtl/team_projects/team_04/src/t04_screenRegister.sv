module t04_screenRegister(
    input logic [31:0] data, address,
    input logic wen, rst, clk, ack,
    output logic [31:0] control, xBus, yBus,
    output logic finalAck
);

logic [31:0] nextControl, currentControl, nextXbus, currentXbus, nextYbus, currentYbus, controlAd, xAd, yAd;
logic controlFill, xFill, xFill1, xFill2, xFill3, cFill1, cFill2, cFill3, xEdge, cEdge;

assign controlAd = 32'd4;
assign xAd = 32'd8;
assign yAd = 32'd12;

always_comb begin

    nextControl = currentControl;
    nextXbus = currentXbus;
    nextYbus = currentYbus;
    xEdge = xFill2 && ~xFill3;
    cEdge = cFill2 && ~cFill3;

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

    if (|currentControl) begin
        controlFill = 1;
    end else begin
        controlFill = 0;
    end

    if (|currentXbus) begin
        xFill = 1;
    end else begin
        xFill = 0;
    end

end

always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
        currentControl <= 32'b0;
        currentXbus <= 32'b0;
        currentYbus <= 32'b0;
        cFill1 <= 0;
        cFill2 <= 0;
        cFill3 <= 0;
        xFill1 <= 0;
        xFill2 <= 0;
        xFill3 <= 0;
    end else begin
        currentControl <= nextControl;
        currentXbus <= nextXbus;
        currentYbus <= nextYbus;
        cFill1 <= controlFill;
        cFill2 <= cFill1;
        cFill3 <= cFill2;
        xFill1 <= xFill;
        xFill2 <= xFill1;
        xFill3 <= xFill2;
    end
end

assign control = currentControl;
assign xBus = currentXbus;
assign yBus = currentYbus;
assign finalAck = xEdge || cEdge || ack;

endmodule