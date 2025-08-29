module t04_screenCounter (
  input logic clk, rst, enableEdge, ack,
  output logic [22:0] ct
);

  logic [22:0] nextCt, currentCt, nextFinal, currentFinal;
  logic ack1, ack2, ack3, ackEdge, nextEnable, currentEnable;

  always_comb begin

    ackEdge = ack2 && ~ack3;
    nextEnable = currentEnable;
    nextFinal = currentFinal;

    if (enableEdge) begin
      nextEnable = 1;
    end else if (ackEdge) begin
      nextEnable = 0;
    end 
    
    if (currentFinal == 23'b11111111111111111111111) begin
      nextFinal = currentFinal;
      nextCt = currentCt;
    end else if (currentCt == 2) begin
      nextFinal = currentFinal + 1;
      nextCt = 0;
    end else if (~currentEnable) begin
      nextCt = 0;
      nextFinal = 0;
    end else begin
      nextCt = currentCt + 1;
    end
  end
    
  //   else if (currentFinal == 0) begin
  //     nextCt = 0;
  //     nextFinal = 0;
  //   end else if (currentFinal == 23'b11111111111111111111111) begin
  //     nextCt = currentCt;
  //   end else if (currentCt == 20) begin
  //     nextFinal = currentFinal + 1;
  //     nextCt = 0;
    
  //   else begin
  //     nextCt = currentCt + 1;
  //   end
  // end

  always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
      currentCt <= 0;
      ack1 <= 0;
      ack2 <= 0;
      ack3 <= 0;
      currentEnable <= 0;
      currentFinal <= 0;
    end else begin
      currentCt <= nextCt;
      ack1 <= ack;
      ack2 <= ack1;
      ack3 <= ack2;
      currentEnable <= nextEnable;
      currentFinal <= nextFinal;
    end
  end

  assign ct = currentFinal;

endmodule