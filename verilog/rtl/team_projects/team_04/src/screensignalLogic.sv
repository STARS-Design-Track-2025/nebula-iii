module screensignalLogic (
  input logic [31:0] controlBus, xBus, yBus,
  input logic [22:0] ct,
  input logic clk, rst,
  output logic ack, dcx, wrx, csx,
  output logic [7:0] data  
);
  logic [7:0] nextData, currentData;
  logic nextDcx, nextCsx, nextWrx, currentDcx, currentCsx, currentWrx, oeCt;
  logic [8:0] control;
  logic [16:0] pixel;
  logic [7:0] xCommand, yCommand, fullX3, fullX4, fullX1, fullX2, fullY1, fullY2, fullY3, fullY4, rgbParam, rgbCommand, oriCommand, oriParam, sleepoCommand, sleepiCommand, swrstCommand, dispoffCommand, disponCommand, memCommand;

  assign control = controlBus[8:0];

  //outputs
  assign csx = currentCsx;
  assign wrx = currentWrx;
  assign dcx = currentDcx;
  assign data = currentData;

  function automatic logic [11:0] signal_call (
    input logic [7:0] command,
    input logic [7:0] pat0,
    input logic [7:0] pat1,
    input int unsigned pixel_cnt
  );
    int unsigned total_bytes = pixel_cnt << 1;
    int unsigned byte_idx = (ct >= 5) ? ({8'b0, ct} - 5) : 0;

    case (ct)
      0 : signal_call = {1'b0, 1'b1, 1'b1, 1'b1, 8'b0};
      1 : signal_call = {1'b0, 1'b0, 1'b1, 1'b1, 8'b0};
      2 : signal_call = {1'b0, 1'b0, 1'b0, 1'b0, command};
      3 : signal_call = {1'b0, 1'b0, 1'b0, 1'b1, command};
      4 : signal_call = {1'b0, 1'b0, 1'b1, 1'b1, 8'b0};

      default : begin
        if (ct >= 5) begin
          signal_call = 12'b0;

          if (byte_idx < total_bytes) begin
            logic wrx = byte_idx[0];
            logic [7:0] data = wrx ? pat1 : pat0;

            signal_call = {1'b0, 1'b0, 1'b0, wrx, data};

            if (byte_idx == total_bytes - 1) begin
              signal_call[11] = 1'b1;
            end
          end
        end
      end
    endcase
  endfunction

  //reseton : swreset - 5ms - sleep out - 120ms - pixel format(3A set rgb565) - pixel param - orientation(36) - orientation param - dispOn - 5 commands total
  // clear : caset (full screen) paset (full screen) memwrite for all pixels send 8'b0 for black - 3 commands total
  // on : sleep out - 120 ms - disp on- 5 ms
  //off : disp off - 10 ms - sleep in - 10 ms 
  //r g b bl wh

  always_comb begin
    nextData = currentData;
    nextCsx = currentCsx;
    nextWrx = currentWrx;
    nextDcx = currentDcx;
    ack = 0;

    xCommand = 8'h2A;
    yCommand = 8'h2B;
    fullX3 = 8'd1;
    fullX4 = 8'b00111111;
    fullX1 = 8'b0;
    fullX2 = 8'b0;
    fullY1 = 8'b0;
    fullY2 = 8'b0;
    fullY3 = 8'd1;
    fullY4 = 8'b11100000;
    rgbParam = 8'b01010101;
    rgbCommand = 8'b00111010;
    oriParam = 8'b00110000;
    oriCommand = 8'h36;
    sleepoCommand = 8'h11;
    sleepiCommand = 8'h10;
    swrstCommand = 8'h01;
    disponCommand = 8'h29;
    dispoffCommand = 8'h28;
    memCommand = 8'h2C;

    oeCt = ct[0];

    case (control)
      9'b100000000: begin //clear
        case (ct)
          00: begin nextWrx = 1; nextDcx = 1; nextCsx = 1; nextData = 0; end
          01: begin nextCsx = 0; end
          02: begin nextDcx = 0; nextWrx = 0; nextData = xCommand; end
          03: begin nextWrx = 1; end
          04: begin nextDcx = 1; nextData = fullX1; nextWrx = 0; end
          05: begin nextWrx = 1; end
          06: begin nextWrx = 0; nextData = fullX2; end
          07: begin nextWrx = 1; end
          08: begin nextWrx = 0; nextData = fullX3; end
          09: begin nextWrx = 1; end
          10: begin nextWrx = 0;nextData = fullX4; end
          11: begin nextWrx = 1; end
          12: begin nextCsx = 1; end
          13: begin nextCsx = 0; end
          14: begin nextDcx = 1; nextWrx = 1; nextData = 8'b0; end
          15: begin nextDcx = 0; nextWrx = 0; nextData = yCommand; end
          16: begin nextWrx = 1; end
          17: begin nextWrx = 0; nextDcx = 1; nextData = fullY1; end
          18: begin nextWrx = 1; end
          19: begin nextWrx = 0; nextData = fullY2; end
          20: begin nextWrx = 1; end
          21: begin nextWrx = 0; nextData = fullY3; end
          22: begin nextWrx = 1; end
          23: begin nextWrx = 0; nextData = fullY4; end
          24: begin nextWrx = 1; end
          25: begin nextCsx = 1; end
          26: begin nextCsx = 0; end
          27: begin nextDcx = 1; nextData = 8'b0; nextWrx = 1; end
          28: begin nextDcx = 0; nextData = memCommand; nextWrx = 0; end
          29: begin nextWrx = 1; end
          30: begin nextDcx = 1; nextWrx = 0; nextData = 8'b0; end
          default: begin
            if (ct > 30 && ct < 307231) begin
              if (oeCt) begin
                nextWrx = 1;
              end else begin
                nextWrx = 0;
              end
            end else if (ct == 307231) begin
              nextCsx = 1;
            end else if (ct == 307232) begin
              ack = 1;
            end else if (ct == 307233) begin
              ack = 0;
            end
          end
        endcase
        
      end
      9'b10000000: begin //reseton
          case (ct) 
              0: begin 
                  nextCsx = 1;
                  nextWrx = 1;
                  nextDcx = 1;
                  nextData = 8'b0;
              end 
              1: begin
                  nextCsx = 0;
              end
              2: begin
                  nextWrx = 0;
                  nextDcx = 0;
                  nextData = swrstCommand;
              end 
              3: begin
                  nextWrx = 1;
              end
              200010: begin
                  nextWrx = 0;
                  nextData = sleepoCommand;
              end
              200011: begin
                  nextWrx = 1;
              end
              5000012: begin
                  nextWrx = 0;
                  nextData = rgbCommand;
              end
              5000013: begin
                  nextWrx = 1;
              end
              5000014: begin
                  nextWrx = 0;
                  nextDcx = 1;
                  nextData = rgbParam;
              end
              5000015: begin
                  nextWrx = 1;
              end
              5000016: begin
                  nextWrx = 0;
                  nextDcx = 0;
                  nextData = oriCommand;
              end
              5000017: begin
                  nextWrx = 1;
              end
              5000018: begin
                  nextWrx = 0;
                  nextDcx = 1;
                  nextData = oriParam;
              end
              5000019: begin
                  nextWrx = 1;
              end
              5000020: begin
                  nextWrx = 0;
                  nextData = disponCommand;
                  nextDcx = 0;
              end
              5000021: begin
                  nextWrx = 1;
              end
              5000022: begin
                  nextCsx = 1;
              end
              5000023: begin
                  ack = 1;
              end
              5000024: begin
                  ack = 0;
              end
          endcase
      end
      9'b100000: begin //dispoff
          case (ct)
              0: begin
                  nextCsx = 1;
                  nextData = 0;
                  nextDcx = 1;
                  nextWrx = 1;
              end
              1: begin
                  nextCsx = 0;
              end
              2: begin
                  nextWrx = 0;
                  nextData = dispoffCommand;
                  nextDcx = 0;
              end
              3: begin
                  nextWrx = 1;
              end
              400003: begin
                  nextWrx = 0;
                  nextData = sleepiCommand;
              end
              400004: begin
                  nextWrx = 1;
              end
              800004: begin
                  nextCsx = 1;
              end
              800005: begin
                  ack = 1;
              end
              800006: begin
                  ack = 0;
              end
          endcase
      end
      9'b1000000: begin //disp on
          case (ct)
              0: begin
                  nextCsx = 1;
                  nextWrx = 1;
                  nextDcx = 1;
                  nextData = 8'b0;
              end
              1: begin
                  nextCsx = 0;
              end
              2: begin
                  nextWrx = 0;
                  nextData = sleepoCommand;
                  nextDcx = 0;
              end
              3: begin
                  nextWrx = 1;
              end
              4800004: begin
                  nextWrx = 0;
                  nextData = disponCommand;
              end
              4800005: begin
                  nextWrx = 1;
              end
              5000000: begin
                  nextCsx = 1;
              end
              5000001: begin
                  ack = 1;
              end
              5000002: begin
                  ack = 0;
              end
          endcase
        end
        9'b10000: begin //red
          case (ct)
              0: begin 
                  nextWrx = 1;
                  nextDcx = 1;
                  nextCsx = 1;
                  nextData = 0;
              end
              1: begin
                  nextCsx = 0;
              end
              2: begin
                  nextDcx = 0;
                  nextWrx = 0;
                  nextData = xCommand;
              end
              3: begin
                  nextWrx = 1;
              end
              4: begin
                  nextDcx = 1;
                  nextData = xBus[31:24];
                  nextWrx = 0;
              end
              5: begin 
                  nextWrx = 1;
              end
              6: begin
                  nextWrx = 0;
                  nextData = xBus[23:16];
              end
              7: begin
                  nextWrx = 1;
              end
              8: begin
                  nextWrx = 0;
                  nextData = xBus[15:8];
              end
              9: begin
                  nextWrx = 1;
              end
              10: begin
                  nextWrx = 0;
                  nextData = xBus[7:0];
              end
              11: begin
                  nextWrx = 1;
              end
              12: begin 
                  nextCsx = 1;
                  nextData = 0;
              end
              13: begin
                  nextCsx = 0;
              end
              14: begin
                  nextDcx = 0;
                  nextWrx = 0;
                  nextData = yCommand;
              end
              15: begin
                  nextWrx = 1;
              end
              16: begin
                  nextDcx = 1;
                  nextData = yBus[31:24];
                  nextWrx = 0;
              end
              17: begin 
                  nextWrx = 1;
              end
              18: begin
                  nextWrx = 0;
                  nextData = yBus[23:16];
              end
              19: begin
                  nextWrx = 1;
              end
              20: begin
                  nextWrx = 0;
                  nextData = yBus[15:8];
              end
              21: begin
                  nextWrx = 1;
              end
              22: begin
                  nextWrx = 0;
                  nextData = yBus[7:0];
              end
              23: begin
                  nextWrx = 1;
              end
              24: begin
                  nextCsx = 1;
                  nextData = 0;
              end
              25: begin
                  nextCsx = 0;
              end
              26: begin
                  nextDcx = 0;
                  nextData = memCommand;
                  nextWrx = 0;
              end
              27: begin
                  nextWrx = 1;
              end
              28: begin
                  nextWrx = 0;
                  nextDcx = 1;
                  nextData = 8'b11111000;
              end
              29: begin
                  nextWrx = 1;
              end
              30: begin
                  nextWrx = 0;
                  nextData = 8'b0;
              end
              31: begin
                  nextWrx = 1;
              end
              32: begin
                  nextCsx = 1;
              end
              33: begin
                  ack = 1;
              end
              34: begin
                  ack = 0;
              end
          endcase
      end
        9'b100: begin //blue
          case (ct)
              0: begin 
                  nextWrx = 1;
                  nextDcx = 1;
                  nextCsx = 1;
                  nextData = 0;
              end
              1: begin
                  nextCsx = 0;
              end
              2: begin
                  nextDcx = 0;
                  nextWrx = 0;
                  nextData = xCommand;
              end
              3: begin
                  nextWrx = 1;
              end
              4: begin
                  nextDcx = 1;
                  nextData = xBus[31:24];
                  nextWrx = 0;
              end
              5: begin 
                  nextWrx = 1;
              end
              6: begin
                  nextWrx = 0;
                  nextData = xBus[23:16];
              end
              7: begin
                  nextWrx = 1;
              end
              8: begin
                  nextWrx = 0;
                  nextData = xBus[15:8];
              end
              9: begin
                  nextWrx = 1;
              end
              10: begin
                  nextWrx = 0;
                  nextData = xBus[7:0];
              end
              11: begin
                  nextWrx = 1;
              end
              12: begin 
                  nextCsx = 1;
                  nextData = 0;
              end
              13: begin
                  nextCsx = 0;
              end
              14: begin
                  nextDcx = 0;
                  nextWrx = 0;
                  nextData = yCommand;
              end
              15: begin
                  nextWrx = 1;
              end
              16: begin
                  nextDcx = 1;
                  nextData = yBus[31:24];
                  nextWrx = 0;
              end
              17: begin 
                  nextWrx = 1;
              end
              18: begin
                  nextWrx = 0;
                  nextData = yBus[23:16];
              end
              19: begin
                  nextWrx = 1;
              end
              20: begin
                  nextWrx = 0;
                  nextData = yBus[15:8];
              end
              21: begin
                  nextWrx = 1;
              end
              22: begin
                  nextWrx = 0;
                  nextData = yBus[7:0];
              end
              23: begin
                  nextWrx = 1;
              end
              24: begin
                  nextCsx = 1;
                  nextData = 0;
              end
              25: begin
                  nextCsx = 0;
              end
              26: begin
                  nextDcx = 0;
                  nextData = memCommand;
                  nextWrx = 0;
              end
              27: begin
                  nextWrx = 1;
              end
              28: begin
                  nextWrx = 0;
                  nextDcx = 1;
                  nextData = 8'b0;
              end
              29: begin
                  nextWrx = 1;
              end
              30: begin
                  nextWrx = 0;
                  nextData = 8'b00011111;
              end
              31: begin
                  nextWrx = 1;
              end
              32: begin
                  nextCsx = 1;
              end
              33: begin
                  ack = 1;
              end
              34: begin
                  ack = 0;
              end
          endcase
      end
        9'b10: begin //black
          case (ct)
              0: begin 
                  nextWrx = 1;
                  nextDcx = 1;
                  nextCsx = 1;
                  nextData = 0;
              end
              1: begin
                  nextCsx = 0;
              end
              2: begin
                  nextDcx = 0;
                  nextWrx = 0;
                  nextData = xCommand;
              end
              3: begin
                  nextWrx = 1;
              end
              4: begin
                  nextDcx = 1;
                  nextData = xBus[31:24];
                  nextWrx = 0;
              end
              5: begin 
                  nextWrx = 1;
              end
              6: begin
                  nextWrx = 0;
                  nextData = xBus[23:16];
              end
              7: begin
                  nextWrx = 1;
              end
              8: begin
                  nextWrx = 0;
                  nextData = xBus[15:8];
              end
              9: begin
                  nextWrx = 1;
              end
              10: begin
                  nextWrx = 0;
                  nextData = xBus[7:0];
              end
              11: begin
                  nextWrx = 1;
              end
              12: begin 
                  nextCsx = 1;
                  nextData = 0;
              end
              13: begin
                  nextCsx = 0;
              end
              14: begin
                  nextDcx = 0;
                  nextWrx = 0;
                  nextData = yCommand;
              end
              15: begin
                  nextWrx = 1;
              end
              16: begin
                  nextDcx = 1;
                  nextData = yBus[31:24];
                  nextWrx = 0;
              end
              17: begin 
                  nextWrx = 1;
              end
              18: begin
                  nextWrx = 0;
                  nextData = yBus[23:16];
              end
              19: begin
                  nextWrx = 1;
              end
              20: begin
                  nextWrx = 0;
                  nextData = yBus[15:8];
              end
              21: begin
                  nextWrx = 1;
              end
              22: begin
                  nextWrx = 0;
                  nextData = yBus[7:0];
              end
              23: begin
                  nextWrx = 1;
              end
              24: begin
                  nextCsx = 1;
                  nextData = 0;
              end
              25: begin
                  nextCsx = 0;
              end
              26: begin
                  nextDcx = 0;
                  nextData = memCommand;
                  nextWrx = 0;
              end
              27: begin
                  nextWrx = 1;
              end
              28: begin
                  nextWrx = 0;
                  nextDcx = 1;
                  nextData = 8'b0;
              end
              29: begin
                  nextWrx = 1;
              end
              30: begin
                  nextWrx = 0;
                  nextData = 8'b0;
              end
              31: begin
                  nextWrx = 1;
              end
              32: begin
                  nextCsx = 1;
              end
              33: begin
                  ack = 1;
              end
              34: begin
                  ack = 0;
              end
          endcase
      end
        9'b1000: begin //green
          case (ct)
              0: begin 
                  nextWrx = 1;
                  nextDcx = 1;
                  nextCsx = 1;
                  nextData = 0;
              end
              1: begin
                  nextCsx = 0;
              end
              2: begin
                  nextDcx = 0;
                  nextWrx = 0;
                  nextData = xCommand;
              end
              3: begin
                  nextWrx = 1;
              end
              4: begin
                  nextDcx = 1;
                  nextData = xBus[31:24];
                  nextWrx = 0;
              end
              5: begin 
                  nextWrx = 1;
              end
              6: begin
                  nextWrx = 0;
                  nextData = xBus[23:16];
              end
              7: begin
                  nextWrx = 1;
              end
              8: begin
                  nextWrx = 0;
                  nextData = xBus[15:8];
              end
              9: begin
                  nextWrx = 1;
              end
              10: begin
                  nextWrx = 0;
                  nextData = xBus[7:0];
              end
              11: begin
                  nextWrx = 1;
              end
              12: begin 
                  nextCsx = 1;
                  nextData = 0;
              end
              13: begin
                  nextCsx = 0;
              end
              14: begin
                  nextDcx = 0;
                  nextWrx = 0;
                  nextData = yCommand;
              end
              15: begin
                  nextWrx = 1;
              end
              16: begin
                  nextDcx = 1;
                  nextData = yBus[31:24];
                  nextWrx = 0;
              end
              17: begin 
                  nextWrx = 1;
              end
              18: begin
                  nextWrx = 0;
                  nextData = yBus[23:16];
              end
              19: begin
                  nextWrx = 1;
              end
              20: begin
                  nextWrx = 0;
                  nextData = yBus[15:8];
              end
              21: begin
                  nextWrx = 1;
              end
              22: begin
                  nextWrx = 0;
                  nextData = yBus[7:0];
              end
              23: begin
                  nextWrx = 1;
              end
              24: begin
                  nextCsx = 1;
                  nextData = 0;
              end
              25: begin
                  nextCsx = 0;
              end
              26: begin
                  nextDcx = 0;
                  nextData = memCommand;
                  nextWrx = 0;
              end
              27: begin
                  nextWrx = 1;
              end
              28: begin
                  nextWrx = 0;
                  nextDcx = 1;
                  nextData = 8'b00000111;
              end
              29: begin
                  nextWrx = 1;
              end
              30: begin
                  nextWrx = 0;
                  nextData = 8'b11100000;
              end
              31: begin
                  nextWrx = 1;
              end
              32: begin
                  nextCsx = 1;
              end
              33: begin
                  ack = 1;
              end
              34: begin
                  ack = 0;
              end
          endcase
      end
      9'b1: begin //white
          case (ct)
              0: begin 
                  nextWrx = 1;
                  nextDcx = 1;
                  nextCsx = 1;
                  nextData = 0;
              end
              1: begin
                  nextCsx = 0;
              end
              2: begin
                  nextDcx = 0;
                  nextWrx = 0;
                  nextData = xCommand;
              end
              3: begin
                  nextWrx = 1;
              end
              4: begin
                  nextDcx = 1;
                  nextData = xBus[31:24];
                  nextWrx = 0;
              end
              5: begin 
                  nextWrx = 1;
              end
              6: begin
                  nextWrx = 0;
                  nextData = xBus[23:16];
              end
              7: begin
                  nextWrx = 1;
              end
              8: begin
                  nextWrx = 0;
                  nextData = xBus[15:8];
              end
              9: begin
                  nextWrx = 1;
              end
              10: begin
                  nextWrx = 0;
                  nextData = xBus[7:0];
              end
              11: begin
                  nextWrx = 1;
              end
              12: begin 
                  nextCsx = 1;
                  nextData = 0;
              end
              13: begin
                  nextCsx = 0;
              end
              14: begin
                  nextDcx = 0;
                  nextWrx = 0;
                  nextData = yCommand;
              end
              15: begin
                  nextWrx = 1;
              end
              16: begin
                  nextDcx = 1;
                  nextData = yBus[31:24];
                  nextWrx = 0;
              end
              17: begin 
                  nextWrx = 1;
              end
              18: begin
                  nextWrx = 0;
                  nextData = yBus[23:16];
              end
              19: begin
                  nextWrx = 1;
              end
              20: begin
                  nextWrx = 0;
                  nextData = yBus[15:8];
              end
              21: begin
                  nextWrx = 1;
              end
              22: begin
                  nextWrx = 0;
                  nextData = yBus[7:0];
              end
              23: begin
                  nextWrx = 1;
              end
              24: begin
                  nextCsx = 1;
                  nextData = 0;
              end
              25: begin
                  nextCsx = 0;
              end
              26: begin
                  nextDcx = 0;
                  nextData = memCommand;
                  nextWrx = 0;
              end
              27: begin
                  nextWrx = 1;
              end
              28: begin
                  nextWrx = 0;
                  nextDcx = 1;
                  nextData = 8'b11111111;
              end
              29: begin
                  nextWrx = 1;
              end
              30: begin
                  nextWrx = 0;
                  nextData = 8'b11111111;
              end
              31: begin
                  nextWrx = 1;
              end
              32: begin
                  nextCsx = 1;
              end
              33: begin
                  ack = 1;
              end
              34: begin
                  ack = 0;
              end
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