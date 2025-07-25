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

  localparam logic [22:0] RANGE = 537630;
  logic [22:0] wct = ct - 30;

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
      32'b100000000: begin
        case (ct)
          00: begin nextWrx = 1; nextDcx = 1; nextCsx = 1; nextData = 0; end
          01: begin nextCsx = 0; end
          02: begin nextDcx = 0; end
          03: begin nextWrx = 0; nextData = xCommand; end
          04: begin nextWrx = 1; end
          05: begin nextDcx = 1; nextData = 8'b0; nextWrx = 0; end
          06: begin nextWrx = 1; end
          07: begin nextWrx = 0; nextData = 8'b0; end
          08: begin nextWrx = 1; end
          09: begin nextWrx = 0; nextData = 8'b1; end
          10: begin nextWrx = 1; end
          11: begin nextWrx = 0; nextData = 8'b00111111; end
          12: begin nextWrx = 1; end
          13: begin nextCsx = 1; nextData = 0; end // new com
          14: begin nextCsx = 0; end
          15: begin nextDcx = 0; end
          16: begin nextWrx = 0; nextData = yCommand; end
          17: begin nextWrx = 1; end
          18: begin nextDcx = 1; nextData = 8'b0; nextWrx = 0; end
          19: begin nextWrx = 1; end
          20: begin nextWrx = 0; nextData = 8'd0; end
          21: begin nextWrx = 1; end
          22: begin nextWrx = 0; nextData = 8'b0; end
          23: begin nextWrx = 1; end
          24: begin nextWrx = 0; nextData = 8'd239; end
          25: begin nextWrx = 1; end
          26: begin nextCsx = 1; nextData = 0; end // new com
          27: begin nextCsx = 0; end
          28: begin nextDcx = 0; end
          29: begin nextData = memCommand; nextWrx = 0; end
          
          default: begin
            if (ct >= 30 && ct < RANGE) begin
              case (wct % 7)
                0: begin nextWrx = 1; end
                2: begin nextWrx = 0; nextDcx = 1; nextData = 8'b11111111; end
                4: begin nextWrx = 1; end
                6: begin nextWrx = 0; nextData = 8'b11111111; end
              endcase
            end
          end

          RANGE: begin nextWrx = 1; nextData = 0; end
          RANGE + 1: begin nextCsx = 1; end
          RANGE + 2: begin ack = 1; end
          RANGE + 3: begin ack = 0; end
        endcase
      end

      32'b10000000: begin //reseton
        case (ct)           
          2: begin nextCsx = 1; nextWrx = 1; nextDcx = 1; nextData = 8'b0; end 
          4: begin nextCsx = 0; end
          6: begin nextDcx = 0; end
          8: begin nextWrx = 0; nextData = sleepiCommand; end
          10: begin nextWrx = 1; end
          1200012: begin nextWrx = 0; nextData = swrstCommand; end
          1200014: begin nextWrx = 1; end
          2400016: begin nextWrx = 0; nextData = sleepoCommand; end
          2400018: begin nextWrx = 1; end
          2450020: begin nextWrx = 0; nextData = rgbCommand; end
          2450022: begin nextWrx = 1; end
          2450024: begin nextDcx = 1; end
          2450026: begin nextWrx = 0; nextData = rgbParam; end
          2450028: begin nextWrx = 1; end
          2450030: begin nextDcx = 0; end
          2450032: begin nextWrx = 0; nextData = oriCommand; end
          2450034: begin nextWrx = 1; end
          2450036: begin nextDcx = 1; end
          2450038: begin nextWrx = 0; nextData = oriParam; end
          2450040: begin nextWrx = 1; end
          2450042: begin nextDcx = 0; end
          2450044: begin nextWrx = 0; nextData = disponCommand; end
          2450046: begin nextWrx = 1; end
          2450048: begin nextCsx = 1; end
          2450050: begin ack = 1; end
          2450052: begin ack = 0; end 
        endcase
      end

      // 32'b10000000: begin //reseton
      //   case (ct) 
      //     0: begin nextCsx = 1; nextWrx = 1; nextDcx = 1; nextData = 8'b0; end 
      //     1: begin nextCsx = 0; end
      //     2: begin nextDcx = 0; end
      //     3: begin nextWrx = 0; nextData = sleepiCommand; end 
      //     4: begin nextWrx = 1; end
      //     5: begin nextWrx = 0; nextData = swrstCommand; end
      //     6: begin nextWrx = 1; end
      //     7: begin nextWrx = 0; nextData = sleepoCommand; end
      //     8: begin nextWrx = 1; end
      //     9: begin nextWrx = 0; nextData = rgbCommand; end
      //     10: begin nextWrx = 1; end
      //     11: begin nextDcx = 1; end
      //     12: begin nextWrx = 0; nextData = rgbParam; end
      //     13: begin nextWrx = 1; end
      //     14: begin nextDcx = 0; end
      //     15: begin nextWrx = 0; nextData = oriCommand; end
      //     16: begin nextWrx = 1; end
      //     17: begin nextDcx = 1; end
      //     18: begin nextWrx = 0; nextData = oriParam; end
      //     19: begin nextWrx = 1; end
      //     20: begin nextDcx = 0; end
      //     21: begin nextWrx = 0; nextData = disponCommand; end
      //     22: begin nextWrx = 1; end
      //     23: begin nextCsx = 1; end
      //     24: begin ack = 1; end
      //     25: begin ack = 0; end 
      //   endcase
      // end

      32'b100000: begin //display off
        case (ct)
          2: begin nextCsx = 1; nextData = 0; nextDcx = 1; nextWrx = 1; end
          4: begin nextCsx = 0; end
          6: begin nextDcx = 0; end
          8: begin nextWrx = 0; nextData = dispoffCommand; end
          10: begin nextWrx = 1; end
          50012: begin nextWrx = 0; nextData = sleepiCommand; end
          50014: begin nextWrx = 1; end
          1250016: begin nextCsx = 1; end
          1250018: begin ack = 1; end
          1250020: begin ack = 0; end
        endcase
      end

      32'b01000000: begin //display on
        case (ct)
          2: begin nextCsx = 1; nextWrx = 1; nextDcx = 1; nextData = 8'b0; end
          4: begin nextCsx = 0; end
          6: begin nextDcx = 0; end
          8: begin nextWrx = 0; nextData = sleepoCommand; end
          10: begin nextWrx = 1; end
          50012: begin nextWrx = 0; nextData = disponCommand; end
          50014: begin nextWrx = 1; end
          100016: begin nextCsx = 1; end
          100018: begin ack = 1; end
          100020: begin ack = 0; end
        endcase
      end

      32'b10000: begin //red
        case (ct)
          02: begin nextWrx = 1; nextDcx = 1; nextCsx = 1; nextData = 0; end
          04: begin nextCsx = 0; end
          06: begin nextDcx = 0; end
          08: begin nextWrx = 0; nextData = xCommand; end
          10: begin nextWrx = 1; end
          12: begin nextDcx = 1; end
          14: begin nextData = xBus[31:24]; nextWrx = 0; end
          16: begin nextWrx = 1; end
          18: begin nextWrx = 0; nextData = xBus[23:16]; end
          20: begin nextWrx = 1; end
          22: begin nextWrx = 0; nextData = xBus[15:8]; end
          24: begin nextWrx = 1; end
          26: begin nextWrx = 0; nextData = xBus[7:0]; end
          28: begin nextWrx = 1; end
          30: begin nextDcx = 0; end
          32: begin nextWrx = 0; nextData = yCommand; end
          34: begin nextWrx = 1; end
          36: begin nextDcx = 1; end
          38: begin nextData = yBus[31:24]; nextWrx = 0; end
          40: begin nextWrx = 1; end
          42: begin nextWrx = 0; nextData = yBus[23:16]; end
          44: begin nextWrx = 1; end
          46: begin nextWrx = 0; nextData = yBus[15:8]; end
          48: begin nextWrx = 1; end
          50: begin nextWrx = 0; nextData = yBus[7:0]; end
          52: begin nextWrx = 1; end
          54: begin nextDcx = 0; end
          56: begin nextData = memCommand; nextWrx = 0; end
          58: begin nextWrx = 1; end
          60: begin nextDcx = 1; end
          62: begin nextWrx = 0; nextData = 8'b11111000; end
          64: begin nextWrx = 1; end
          66: begin nextWrx = 0; nextData = 8'b0; end
          68: begin nextWrx = 1; end
          70: begin nextCsx = 1; end
          72: begin ack = 1; end
          74: begin ack = 0; end
        endcase
      end

      32'b100: begin //blue
        case (ct)
          02: begin nextWrx = 1; nextDcx = 1; nextCsx = 1; nextData = 0; end
          04: begin nextCsx = 0; end
          06: begin nextDcx = 0; end
          08: begin nextWrx = 0; nextData = xCommand; end
          10: begin nextWrx = 1; end
          12: begin nextDcx = 1; end
          14: begin nextData = xBus[31:24]; nextWrx = 0; end
          16: begin nextWrx = 1; end
          18: begin nextWrx = 0; nextData = xBus[23:16]; end
          20: begin nextWrx = 1; end
          22: begin nextWrx = 0; nextData = xBus[15:8]; end
          24: begin nextWrx = 1; end
          26: begin nextWrx = 0; nextData = xBus[7:0]; end
          28: begin nextWrx = 1; end
          30: begin nextDcx = 0; end
          32: begin nextWrx = 0; nextData = yCommand; end
          34: begin nextWrx = 1; end
          36: begin nextDcx = 1; end
          38: begin nextData = yBus[31:24]; nextWrx = 0; end
          40: begin nextWrx = 1; end
          42: begin nextWrx = 0; nextData = yBus[23:16]; end
          44: begin nextWrx = 1; end
          46: begin nextWrx = 0; nextData = yBus[15:8]; end
          48: begin nextWrx = 1; end
          50: begin nextWrx = 0; nextData = yBus[7:0]; end
          52: begin nextWrx = 1; end
          54: begin nextDcx = 0; end
          56: begin nextData = memCommand; nextWrx = 0; end
          58: begin nextWrx = 1; end
          60: begin nextDcx = 1; end
          62: begin nextWrx = 0; nextDcx = 1; nextData = 8'b0; end
          64: begin nextWrx = 1; end
          68: begin nextWrx = 0; nextData = 8'b00011111; end
          70: begin nextWrx = 1; end
          72: begin nextCsx = 1; end
          74: begin ack = 1; end
          76: begin ack = 0; end
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
          02: begin nextWrx = 1; nextDcx = 1; nextCsx = 1; nextData = 0; end
          04: begin nextCsx = 0; end
          06: begin nextDcx = 0; end
          08: begin nextWrx = 0; nextData = xCommand; end
          10: begin nextWrx = 1; end
          12: begin nextDcx = 1; end
          14: begin nextData = xBus[31:24]; nextWrx = 0; end
          16: begin nextWrx = 1; end
          18: begin nextWrx = 0; nextData = xBus[23:16]; end
          20: begin nextWrx = 1; end
          22: begin nextWrx = 0; nextData = xBus[15:8]; end
          24: begin nextWrx = 1; end
          26: begin nextWrx = 0; nextData = xBus[7:0]; end
          28: begin nextWrx = 1; end
          30: begin nextDcx = 0; end
          32: begin nextWrx = 0; nextData = yCommand; end
          34: begin nextWrx = 1; end
          36: begin nextDcx = 1; end
          38: begin nextData = yBus[31:24]; nextWrx = 0; end
          40: begin nextWrx = 1; end
          42: begin nextWrx = 0; nextData = yBus[23:16]; end
          44: begin nextWrx = 1; end
          46: begin nextWrx = 0; nextData = yBus[15:8]; end
          48: begin nextWrx = 1; end
          50: begin nextWrx = 0; nextData = yBus[7:0]; end
          52: begin nextWrx = 1; end
          54: begin nextDcx = 0; end
          56: begin nextData = memCommand; nextWrx = 0; end
          58: begin nextWrx = 1; end
          60: begin nextDcx = 1; end
          62: begin nextWrx = 0; nextData = 8'b00000111; end
          64: begin nextWrx = 1; end
          66: begin nextWrx = 0; nextData = 8'b11100000; end
          68: begin nextWrx = 1; end
          70: begin nextCsx = 1; end
          72: begin ack = 1; end
          74: begin ack = 0; end
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