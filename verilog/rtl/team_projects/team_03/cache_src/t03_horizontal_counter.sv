`timescale 1ps/1ps
module t03_horizontal_counter
(
    output logic tc, //this is the terminal counter (turns on when full horizontal scan line has been completed)
    input logic rst,
    input logic clk,
    output logic [10:0] Hcnt
);
    logic [10:0] hcnt_max; 
    logic next_tc;
    logic [10:0] next_Hcnt;
    assign hcnt_max = 11'd208;

    parameter STRETCH_COUNTER = 4;
    
    always_ff @(posedge clk, posedge rst) begin
        if(rst) begin
           tc <= 0;
           Hcnt <= 0;

        end
        else begin
            tc  <= next_tc;
            Hcnt <= next_Hcnt;
        end
    end

    
    always_comb begin
        next_tc = tc;
        next_Hcnt = Hcnt;
        if(Hcnt < hcnt_max) begin
            next_Hcnt = Hcnt + 1;
            next_tc = 0;
        end
        else if(Hcnt >= hcnt_max) begin
            next_tc = 1;
            next_Hcnt = 0;
        end
    end



endmodule