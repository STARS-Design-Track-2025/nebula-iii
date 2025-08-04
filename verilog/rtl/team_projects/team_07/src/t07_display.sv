module t07_display(
    input logic clk, nrst,
    
    output logic [15:0] out,
    output logic delay 
);

    logic [17:0] counter, next_ctr;

    always_ff @(posedge clk, negedge nrst) begin 
        if (~nrst) begin
            counter <= '0;
        end else begin
            counter <= next_ctr;
        end
    end

  always_comb begin
    next_ctr = counter + 1;
    delay = 0;
    // out = '0;
    case (counter) 
        18'd0: out = 16'h80_00; 
        18'd3: out = 16'h40_00;
        18'd6: out = 16'h80_88;
        18'd9: out = 16'h00_0B;

        18'd139: out = 16'h80_89;
        18'd143: out = 16'h00_02;

        18'd273: out = 16'h80_10;
        18'd276: out = 16'h00_0C;
        18'd279: out = 16'h80_04;
        18'd282: out = 16'h00_81;

        18'd412: out = 16'h80_14;
        18'd415: out = 16'h00_63;
        18'd418: out = 16'h80_15;
        18'd421: out = 16'h00_00;
        18'd424: out = 16'h80_16;
        18'd427: out = 16'h00_03;
        18'd430: out = 16'h80_17;
        18'd433: out = 16'h00_03;
        18'd436: out = 16'h80_18;
        18'd439: out = 16'h00_0B;
        18'd442: out = 16'h80_19;
        18'd445: out = 16'h00_DF;
        18'd458: out = 16'h80_1A;
        18'd461: out = 16'h00_01;
        18'd464: out = 16'h80_1B;
        18'd467: out = 16'h00_1F;
        18'd470: out = 16'h80_1C;
        18'd473: out = 16'h00_00;
        18'd476: out = 16'h80_1D;
        18'd479: out = 16'h00_16;
        18'd482: out = 16'h80_1E;
        18'd485: out = 16'h00_00;
        18'd488: out = 16'h80_1F;
        18'd491: out = 16'h00_01;
        18'd494: out = 16'h80_30;
        18'd497: out = 16'h00_00;
        18'd500: out = 16'h80_31;
        18'd503: out = 16'h00_00;
        18'd506: out = 16'h80_34;
        18'd509: out = 16'h00_1F;
        18'd512: out = 16'h80_35;
        18'd515: out = 16'h00_03;
        18'd518: out = 16'h80_32;
        18'd521: out = 16'h00_00;
        18'd524: out = 16'h80_33;
        18'd527: out = 16'h00_00;
        18'd530: out = 16'h80_36;
        18'd533: out = 16'h00_DF;
        18'd536: out = 16'h80_37;
        18'd539: out = 16'h00_01;
        18'd542: out = 16'h80_8E;
        18'd545: out = 16'h00_80;

        18'd63045: 



        default: begin
            delay = 1;
            out = 0;
        end 
    endcase
  end
endmodule