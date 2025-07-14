module screensignalLogic (
    input logic [31:0] controlBus, paramBus,
    input logic [22:0] ct,
    input logic clk, rst,
    output logic ack, dcx, wrx, csx,
    output logic [7:0] data  
);

logic [7:0] nextData, currentData;
logic nextDcx, nextCsx, nextWrx, currentDcx, currentCsx, currentWrx, oeCt;
logic [10:0] control;
logic [16:0] pixel;
logic [7:0] xCommand, yCommand, fullX3, fullX4, fullX1, fullX2, fullY1, fullY2, fullY3, fullY4, rgbParam, rgbCommand, oriCommand, oriParam, sleepoCommand, sleepiCommand, swrstCommand, dispoffCommand, disponCommand, memCommand;

assign control = controlBus[10:0];
assign pixel = paramBus[16:0];
assign csx = currentCsx;
assign wrx = currentWrx;
assign dcx = currentDcx;
assign data = currentData;

 function automatic logic [11:0] caller (
    input logic [7:0] command,
    input byte unsigned params[]
  );

    case (ct)
      0: begin caller = {1'b0, 1'b1, 1'b1, 1'b1, 8'b0}; end
      1: begin caller = {1'b0, 1'b0, 1'b1, 1'b1, 8'b0}; end
      2: begin caller = {1'b0, 1'b0, 1'b0, 1'b0, command}; end
      3: begin caller = {1'b0, 1'b0, 1'b0, 1'b1, command}; end
      4: begin caller = {1'b0, 1'b0, 1'b1, 1'b1, 8'b0}; end
      default: begin
        if (ct >= 5) begin
          int unsigned size = params.size();
          logic [22:0] counter = ct - 5;

          if ({9'b0, counter} < size * 2) begin
            logic [22:0] idx = counter >> 1;
            logic wrx = counter[0];
            caller = {1'b0, 1'b0, 1'b1, wrx, params[idx]};
          end
          
          if ({9'b0, counter} == (5 + size * 2)) begin
            caller[11] = 1'b1;
          end
        end
      end
    endcase

  endfunction

  function automatic int build_load (
    input logic [31:0] count,
    input byte unsigned pattern[],
    output byte unsigned load[]
  );
    int size = count * pattern.size();
    load = new[size];

    for (int i = 0; i < count; i++) begin
      for (int j = 0; j < pattern.size(); j++) begin
        load[i * pattern.size() + j] = pattern[j];
      end
    end

    build_load = 1;
    
  endfunction


// clear x y on off r g b bl wh

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
        11'b01000000000: begin //clear
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
                    nextData = fullX1;
                    nextWrx = 0;
                end
                5: begin 
                    nextWrx = 1;
                end
                6: begin
                    nextWrx = 0;
                    nextData = fullX2;
                end
                7: begin
                    nextWrx = 1;
                end
                8: begin
                    nextWrx = 0;
                    nextData = fullX3;
                end
                9: begin
                    nextWrx = 1;
                end
                10: begin
                    nextWrx = 0;
                    nextData = fullX4;
                end
                11: begin
                    nextWrx = 1;
                end
                12: begin
                    nextCsx = 1;
                end
                13: begin
                    nextCsx = 0;
                end
                14: begin
                    nextDcx = 1;
                    nextWrx = 1;
                    nextData = 8'b0;
                end
                15: begin
                    nextDcx = 0;
                    nextWrx = 0;
                    nextData = yCommand;
                end
                16: begin
                    nextWrx = 1;
                end
                17: begin
                    nextWrx = 0;
                    nextDcx = 1;
                    nextData = fullY1;
                end
                18: begin
                    nextWrx = 1;
                end
                19: begin
                    nextWrx = 0;
                    nextData = fullY2;
                end
                20: begin
                    nextWrx = 1;
                end
                21: begin
                    nextWrx = 0;
                    nextData = fullY3;
                end
                22: begin
                    nextWrx = 1;
                end
                23: begin
                    nextWrx = 0;
                    nextData = fullY4;
                end
                24: begin
                    nextWrx = 1;
                end
                25: begin
                    nextCsx = 1;
                end
                26: begin
                    nextCsx = 0;
                end
                27: begin
                    nextDcx = 1;
                    nextData = 8'b0;
                    nextWrx = 1;
                end
                28: begin
                    nextDcx = 0;
                    nextData = memCommand;
                    nextWrx = 0;
                end
                29: begin
                    nextWrx = 1;
                end
                30: begin
                    nextDcx = 1;
                    nextWrx = 0;
                    nextData = 8'b0;
                end
                default: begin
                    if (ct > 30 && ct < 614431) begin
                        if (oeCt) begin
                            nextWrx = 1;
                        end else begin
                            nextWrx = 0;
                        end
                    end else if (ct == 614431) begin
                        nextCsx = 1;
                    end else if (ct == 614432) begin
                        ack = 1;
                    end else if (ct == 614433) begin
                        ack = 0;
                    end
                end
            endcase
        end
        11'b00100000000: begin
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
                    nextData = paramBus[31:24];
                    nextWrx = 0;
                end
                5: begin 
                    nextWrx = 1;
                end
                6: begin
                    nextWrx = 0;
                    nextData = paramBus[23:16];
                end
                7: begin
                    nextWrx = 1;
                end
                8: begin
                    nextWrx = 0;
                    nextData = paramBus[15:8];
                end
                9: begin
                    nextWrx = 1;
                end
                10: begin
                    nextWrx = 0;
                    nextData = paramBus[7:0];
                end
                11: begin
                    nextWrx = 1;
                end
                12: begin
                    nextCsx = 1;
                end
                13: begin
                    ack = 1;
                end
                14: begin
                    ack = 0;
                end
            endcase
        end
        11'b00010000000: begin
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
                    nextData = yCommand;
                end
                3: begin
                    nextWrx = 1;
                end
                4: begin
                    nextDcx = 1;
                    nextData = paramBus[31:24];
                    nextWrx = 0;
                end
                5: begin 
                    nextWrx = 1;
                end
                6: begin
                    nextWrx = 0;
                    nextData = paramBus[23:16];
                end
                7: begin
                    nextWrx = 1;
                end
                8: begin
                    nextWrx = 0;
                    nextData = paramBus[15:8];
                end
                9: begin
                    nextWrx = 1;
                end
                10: begin
                    nextWrx = 0;
                    nextData = paramBus[7:0];
                end
                11: begin
                    nextWrx = 1;
                end
                12: begin
                    nextCsx = 1;
                end
                13: begin
                    ack = 1;
                end
                14: begin
                    ack = 0;
                end
            endcase
        end
        11'b10000000000: begin
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
        11'b00000100000: begin
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
        11'b00001000000: begin
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
        11'b00000010000: begin
          byte unsigned load[];
          int chain = build_load(paramBus, '{8'b11111000, 8'b0}, load);
          //void'(build_load(controlBus, '{8'b11111000, 8'b0}, load));
          logic [11:0] out = caller(8'h2C, load);
          {ack, nextCsx, nextDcx, nextWrx, nextData} = out;
        end

        11'b00000001000: begin
          byte unsigned load[];
          int chain = build_load(paramBus, '{8'b00000111, 8'b11100000}, load);
          logic [11:0] out = caller(8'h2C, load);
          {ack, nextCsx, nextDcx, nextWrx, nextData} = out;
        end

        11'b00000000100: begin
          byte unsigned load[];
          int chain = build_load(paramBus, '{8'b0, 8'b00011111}, load);
          logic [11:0] out = caller(8'h2C, load);
          {ack, nextCsx, nextDcx, nextWrx, nextData} = out;
        end

        11'b00000000010: begin
          byte unsigned load[];
          int chain = build_load(paramBus, '{8'b0, 8'b0}, load);
          logic [11:0] out = caller(8'h2C, load);
          {ack, nextCsx, nextDcx, nextWrx, nextData} = out;
        end

        11'b00000000001: begin
          byte unsigned load[];
          int chain = build_load(paramBus, '{8'b11111111, 8'b11111111}, load);
          logic [11:0] out = caller(8'h2C, load);
          {ack, nextCsx, nextDcx, nextWrx, nextData} = out;
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