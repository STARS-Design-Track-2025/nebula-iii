module t07_display(
    input logic clk, nrst,
    
    output logic [15:0] out,
    output logic delay 
);

    logic [10:0] counter, next_ctr;

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
        11'd0: out = 16'h80_00; 
        11'd3: out = 16'h40_00;
        11'd6: out = 16'h80_88;
        11'd9: out = 16'h00_0B;

        11'd139: out = 16'h80_89;
        11'd143: out = 16'h00_02;

        11'd273: out = 16'h80_10;
        11'd276: out = 16'h00_0C;
        11'd279: out = 16'h80_04;
        11'd282: out = 16'h00_81;

        11'd412: out = 16'h80_14;
        11'd415: out = 16'h00_63;
        11'd418: out = 16'h80_15;
        11'd421: out = 16'h00_00;
        11'd424: out = 16'h80_16;
        11'd427: out = 16'h00_03;
        11'd430: out = 16'h80_17;
        11'd433: out = 16'h00_03;
        11'd436: out = 16'h80_18;
        11'd439: out = 16'h00_0B;
        11'd442: out = 16'h80_19;
        11'd445: out = 16'h00_DF;
        11'd458: out = 16'h80_1A;
        11'd461: out = 16'h00_01;
        11'd464: out = 16'h80_1B;
        11'd467: out = 16'h00_1F;
        11'd470: out = 16'h80_1C;
        11'd473: out = 16'h00_00;
        11'd476: out = 16'h80_1D;
        11'd479: out = 16'h00_16;
        11'd482: out = 16'h80_1E;
        11'd485: out = 16'h00_00;
        11'd488: out = 16'h80_1F;
        11'd491: out = 16'h00_01;
        11'd494: out = 16'h80_30;
        11'd497: out = 16'h00_00;
        11'd500: out = 16'h80_31;
        11'd503: out = 16'h00_00;
        11'd506: out = 16'h80_34;
        11'd509: out = 16'h00_1F;
        11'd512: out = 16'h80_35;
        11'd515: out = 16'h00_03;
        11'd518: out = 16'h80_32;
        11'd521: out = 16'h00_00;
        11'd524: out = 16'h80_33;
        11'd527: out = 16'h00_00;
        11'd530: out = 16'h80_36;
        11'd533: out = 16'h00_DF;
        11'd536: out = 16'h80_37;
        11'd539: out = 16'h00_01;
        11'd542: out = 16'h80_8E;
        11'd545: out = 16'h00_80;
        default: begin
            delay = 1;
            out = 0;
        end 
    endcase
  end
endmodule