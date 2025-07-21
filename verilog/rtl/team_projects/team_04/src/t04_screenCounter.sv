module t04_screenCounter (
  input logic clk, rst, enableEdge, ack,
  output logic [22:0] ct
);

  logic [22:0] nextCt, currentCt;
  logic ack1, ack2, ack3, ackEdge;

  always_comb begin

    ackEdge = ack2 && ~ack3;

    if (enableEdge) begin
      nextCt = 1;
    end else if (ackEdge) begin
      nextCt = 0;
    end else if (currentCt == 0) begin
      nextCt = 0;
    end else if (currentCt == 23'b11111111111111111111111) begin
      nextCt = currentCt;
    end else begin
      nextCt = currentCt + 1;
    end
  end

  always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
      currentCt <= 0;
      ack1 <= 0;
      ack2 <= 0;
      ack3 <= 0;
    end else begin
      currentCt <= nextCt;
      ack1 <= ack;
      ack2 <= ack1;
      ack3 <= ack2;
    end
  end

  assign ct = currentCt;

endmodule