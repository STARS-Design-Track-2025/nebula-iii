module t04_screensignalLogic (
  input logic [31:0] controlBus, xBus, yBus,
  input logic [22:0] ct,
  input logic clk, rst,
  output logic ack, dcx, wrx, csx,
  output logic [7:0] data  
);
  logic [7:0] nextData, currentData;
  logic nextDcx, nextCsx, nextWrx, currentDcx, currentCsx, currentWrx;
  logic [16:0] pixel;
  logic [7:0] xCommand, yCommand, rgbParam, rgbCommand, oriCommand, oriParam, sleepoCommand, sleepiCommand, swrstCommand, dispoffCommand, disponCommand, memCommand;

  //outputs
  assign csx = currentCsx;
  assign wrx = currentWrx;
  assign dcx = currentDcx;
  assign data = currentData;

  always_comb begin
    nextData = currentData;
    nextCsx = currentCsx;
    nextWrx = currentWrx;
    nextDcx = currentDcx;
    ack = 0;

    xCommand = 8'h2A;
    yCommand = 8'h2B;
    rgbParam = 8'b01010101;
    rgbCommand = 8'b00111010;
    oriParam = 8'b10111000;
    oriCommand = 8'h36;
    sleepoCommand = 8'h11;
    sleepiCommand = 8'h10;
    swrstCommand = 8'h01;
    disponCommand = 8'h29;
    dispoffCommand = 8'h28;
    memCommand = 8'h2C;

    case (controlBus)
      
      32'b10000000: begin //reseton
        case (ct) 
          0: begin nextCsx = 1; nextWrx = 1; nextDcx = 1; nextData = 8'b0; end 
          1: begin nextCsx = 0; end
          2: begin nextDcx = 0; end
          3: begin nextWrx = 0; nextData = swrstCommand; end 
          4: begin nextWrx = 1; end
          20010: begin nextWrx = 0; nextData = sleepoCommand; end
          20011: begin nextWrx = 1; end
          1200012: begin nextWrx = 0; nextData = rgbCommand; end
          1200013: begin nextWrx = 1; end
          1200014: begin nextDcx = 1; end
          1200015: begin nextWrx = 0; nextData = rgbParam; end
          1200016: begin nextWrx = 1; end
          1200017: begin nextDcx = 0; end
          1200018: begin nextWrx = 0; nextData = oriCommand; end
          1200019: begin nextWrx = 1; end
          1200020: begin nextDcx = 1; end
          1200021: begin nextWrx = 0; nextData = oriParam; end
          1200022: begin nextWrx = 1; end
          1200023: begin nextDcx = 0; end
          1200024: begin nextWrx = 0; nextData = disponCommand; end
          1200025: begin nextWrx = 1; end
          1200026: begin nextCsx = 1; end
          1200027: begin ack = 1; end
          1200028: begin ack = 0; end 
        endcase
      end

      32'b100000: begin //display off
        case (ct)
          0: begin nextCsx = 1; nextData = 0; nextDcx = 1; nextWrx = 1; end
          1: begin nextCsx = 0; end
          2: begin nextDcx = 0; end
          3: begin nextWrx = 0; nextData = dispoffCommand; end
          4: begin nextWrx = 1; end
          100003: begin nextWrx = 0; nextData = sleepiCommand; end
          100004: begin nextWrx = 1; end
          200004: begin nextCsx = 1; end
          200005: begin ack = 1; end
          200006: begin ack = 0; end
        endcase
      end

      32'b1000000: begin //display on
        case (ct)
          0: begin nextCsx = 1; nextWrx = 1; nextDcx = 1; nextData = 8'b0; end
          1: begin nextCsx = 0; end
          2: begin nextDcx = 0; end
          3: begin nextWrx = 0; nextData = sleepoCommand; end
          4: begin nextWrx = 1; end
          1200004: begin nextWrx = 0; nextData = disponCommand; end
          1200005: begin nextWrx = 1; end
          1250000: begin nextCsx = 1; end
          1250001: begin ack = 1; end
          1250002: begin ack = 0; end
        endcase
      end

      32'b10000: begin //red
        case (ct)
          00: begin nextWrx = 1; nextDcx = 1; nextCsx = 1; nextData = 0; end
          01: begin nextCsx = 0; end
          02: begin nextDcx = 0; end
          03: begin nextWrx = 0; nextData = xCommand; end
          04: begin nextWrx = 1; end
          05: begin nextDcx = 1; end
          06: begin nextData = xBus[31:24]; nextWrx = 0; end
          07: begin nextWrx = 1; end
          08: begin nextWrx = 0; nextData = xBus[23:16]; end
          09: begin nextWrx = 1; end
          10: begin nextWrx = 0; nextData = xBus[15:8]; end
          11: begin nextWrx = 1; end
          12: begin nextWrx = 0; nextData = xBus[7:0]; end
          13: begin nextWrx = 1; end
          14: begin nextDcx = 0; end
          15: begin nextWrx = 0; nextData = yCommand; end
          16: begin nextWrx = 1; end
          17: begin nextDcx = 1; end
          18: begin nextData = yBus[31:24]; nextWrx = 0; end
          19: begin nextWrx = 1; end
          20: begin nextWrx = 0; nextData = yBus[23:16]; end
          21: begin nextWrx = 1; end
          22: begin nextWrx = 0; nextData = yBus[15:8]; end
          23: begin nextWrx = 1; end
          24: begin nextWrx = 0; nextData = yBus[7:0]; end
          25: begin nextWrx = 1; end
          26: begin nextDcx = 0; end
          27: begin nextData = memCommand; nextWrx = 0; end
          28: begin nextWrx = 1; end
          29: begin nextDcx = 1; end
          30: begin nextWrx = 0; nextData = 8'b11111000; end
          31: begin nextWrx = 1; end
          32: begin nextWrx = 0; nextData = 8'b0; end
          33: begin nextWrx = 1; end
          34: begin nextCsx = 1; end
          35: begin ack = 1; end
          36: begin ack = 0; end
        endcase
      end

      32'b100: begin //blue
        case (ct)
          00: begin nextWrx = 1; nextDcx = 1; nextCsx = 1; nextData = 0; end
          01: begin nextCsx = 0; end
          02: begin nextDcx = 0; end
          03: begin nextWrx = 0; nextData = xCommand; end
          04: begin nextWrx = 1; end
          05: begin nextDcx = 1; end
          06: begin nextData = xBus[31:24]; nextWrx = 0; end
          07: begin nextWrx = 1; end
          08: begin nextWrx = 0; nextData = xBus[23:16]; end
          09: begin nextWrx = 1; end
          10: begin nextWrx = 0; nextData = xBus[15:8]; end
          11: begin nextWrx = 1; end
          12: begin nextWrx = 0; nextData = xBus[7:0]; end
          13: begin nextWrx = 1; end
          14: begin nextDcx = 0; end
          15: begin nextWrx = 0; nextData = yCommand; end
          16: begin nextWrx = 1; end
          17: begin nextDcx = 1; end
          18: begin nextData = yBus[31:24]; nextWrx = 0; end
          19: begin nextWrx = 1; end
          20: begin nextWrx = 0; nextData = yBus[23:16]; end
          21: begin nextWrx = 1; end
          22: begin nextWrx = 0; nextData = yBus[15:8]; end
          23: begin nextWrx = 1; end
          24: begin nextWrx = 0; nextData = yBus[7:0]; end
          25: begin nextWrx = 1; end
          26: begin nextDcx = 0; end
          27: begin nextData = memCommand; nextWrx = 0; end
          28: begin nextWrx = 1; end
          29: begin nextDcx = 1; end
          30: begin nextWrx = 0; nextDcx = 1; nextData = 8'b0; end
          31: begin nextWrx = 1; end
          32: begin nextWrx = 0; nextData = 8'b00011111; end
          33: begin nextWrx = 1; end
          34: begin nextCsx = 1; end
          35: begin ack = 1; end
          36: begin ack = 0; end
        endcase
      end

      32'b10: begin //black
        case (ct)
          00: begin nextWrx = 1; nextDcx = 1; nextCsx = 1; nextData = 0; end
          01: begin nextCsx = 0; end
          02: begin nextDcx = 0; end
          03: begin nextWrx = 0; nextData = xCommand; end
          04: begin nextWrx = 1; end
          05: begin nextDcx = 1; end
          06: begin nextData = xBus[31:24]; nextWrx = 0; end
          07: begin nextWrx = 1; end
          08: begin nextWrx = 0; nextData = xBus[23:16]; end
          09: begin nextWrx = 1; end
          10: begin nextWrx = 0; nextData = xBus[15:8]; end
          11: begin nextWrx = 1; end
          12: begin nextWrx = 0; nextData = xBus[7:0]; end
          13: begin nextWrx = 1; end
          14: begin nextDcx = 0; end
          15: begin nextWrx = 0; nextData = yCommand; end
          16: begin nextWrx = 1; end
          17: begin nextDcx = 1; end
          18: begin nextData = yBus[31:24]; nextWrx = 0; end
          19: begin nextWrx = 1; end
          20: begin nextWrx = 0; nextData = yBus[23:16]; end
          21: begin nextWrx = 1; end
          22: begin nextWrx = 0; nextData = yBus[15:8]; end
          23: begin nextWrx = 1; end
          24: begin nextWrx = 0; nextData = yBus[7:0]; end
          25: begin nextWrx = 1; end
          26: begin nextDcx = 0; end
          27: begin nextData = memCommand; nextWrx = 0; end
          28: begin nextWrx = 1; end
          29: begin nextDcx = 1; end
          30: begin nextWrx = 0; nextData = 8'b0; end
          31: begin nextWrx = 1; end
          32: begin nextWrx = 0; nextData = 8'b0; end
          33: begin nextWrx = 1; end
          34: begin nextCsx = 1; end
          35: begin ack = 1; end
          36: begin ack = 0; end
        endcase
      end

      32'b1000: begin //green
        case (ct)
          00: begin nextWrx = 1; nextDcx = 1; nextCsx = 1; nextData = 0; end
          01: begin nextCsx = 0; end
          02: begin nextDcx = 0; end
          03: begin nextWrx = 0; nextData = xCommand; end
          04: begin nextWrx = 1; end
          05: begin nextDcx = 1; end
          06: begin nextData = xBus[31:24]; nextWrx = 0; end
          07: begin nextWrx = 1; end
          08: begin nextWrx = 0; nextData = xBus[23:16]; end
          09: begin nextWrx = 1; end
          10: begin nextWrx = 0; nextData = xBus[15:8]; end
          11: begin nextWrx = 1; end
          12: begin nextWrx = 0; nextData = xBus[7:0]; end
          13: begin nextWrx = 1; end
          14: begin nextDcx = 0; end
          15: begin nextWrx = 0; nextData = yCommand; end
          16: begin nextWrx = 1; end
          17: begin nextDcx = 1; end
          18: begin nextData = yBus[31:24]; nextWrx = 0; end
          19: begin nextWrx = 1; end
          20: begin nextWrx = 0; nextData = yBus[23:16]; end
          21: begin nextWrx = 1; end
          22: begin nextWrx = 0; nextData = yBus[15:8]; end
          23: begin nextWrx = 1; end
          24: begin nextWrx = 0; nextData = yBus[7:0]; end
          25: begin nextWrx = 1; end
          26: begin nextDcx = 0; end
          27: begin nextData = memCommand; nextWrx = 0; end
          28: begin nextWrx = 1; end
          29: begin nextDcx = 1; end
          30: begin nextWrx = 0; nextData = 8'b00000111; end
          31: begin nextWrx = 1; end
          32: begin nextWrx = 0; nextData = 8'b11100000; end
          33: begin nextWrx = 1; end
          34: begin nextCsx = 1; end
          35: begin ack = 1; end
          36: begin ack = 0; end
        endcase
      end

      32'b1: begin //white
        case (ct)
          00: begin nextWrx = 1; nextDcx = 1; nextCsx = 1; nextData = 0; end
          01: begin nextCsx = 0; end
          02: begin nextDcx = 0; end
          03: begin nextWrx = 0; nextData = xCommand; end
          04: begin nextWrx = 1; end
          05: begin nextDcx = 1; end
          06: begin nextData = xBus[31:24]; nextWrx = 0; end
          07: begin nextWrx = 1; end
          08: begin nextWrx = 0; nextData = xBus[23:16]; end
          09: begin nextWrx = 1; end
          10: begin nextWrx = 0; nextData = xBus[15:8]; end
          11: begin nextWrx = 1; end
          12: begin nextWrx = 0; nextData = xBus[7:0]; end
          13: begin nextWrx = 1; end
          14: begin nextDcx = 0; end
          15: begin nextWrx = 0; nextData = yCommand; end
          16: begin nextWrx = 1; end
          17: begin nextDcx = 1; end
          18: begin nextData = yBus[31:24]; nextWrx = 0; end
          19: begin nextWrx = 1; end
          20: begin nextWrx = 0; nextData = yBus[23:16]; end
          21: begin nextWrx = 1; end
          22: begin nextWrx = 0; nextData = yBus[15:8]; end
          23: begin nextWrx = 1; end
          24: begin nextWrx = 0; nextData = yBus[7:0]; end
          25: begin nextWrx = 1; end
          26: begin nextDcx = 0; end
          27: begin nextData = memCommand; nextWrx = 0; end
          28: begin nextWrx = 1; end
          29: begin nextDcx = 1; end
          30: begin nextWrx = 0; nextData = 8'b11111111; end
          31: begin nextWrx = 1; end
          32: begin nextWrx = 0; nextData = 8'b11111111; end
          33: begin nextWrx = 1; end
          34: begin nextCsx = 1; end
          35: begin ack = 1; end
          36: begin ack = 0; end
        endcase
      end

      default:;

    endcase
  end

  always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
      currentCsx <= 1;
      currentWrx <= 1;
      currentDcx <= 1;
      currentData <= 8'b0;
    end else begin
      currentCsx <= nextCsx;
      currentWrx <= nextWrx;
      currentDcx <= nextDcx;
      currentData <= nextData;
    end
  end

endmodule