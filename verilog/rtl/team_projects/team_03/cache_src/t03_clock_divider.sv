`default_nettype none
`timescale 1ps/1ps
module t03_clock_divider
(
    input logic hwclk,
    output logic clkdiv,
    input rst
);
    logic [22:0] ctr;
    logic [22:0] next_ctr;
    logic next_clk;

    always_ff @ (posedge hwclk, posedge rst) begin
      if(rst) begin
        ctr <= 0;
        clkdiv <= 0;
      end
      else begin
        ctr <= next_ctr;
        clkdiv <= next_clk;
        end
    end

    always_comb begin 
        next_clk = hwclk;
        next_ctr = ctr;

        //5000000
        if(next_ctr == 5000000) begin
            next_ctr = 0;
            next_clk = 1;
        end
        else begin
            next_ctr = next_ctr + 1;
            next_clk = 0;
        end

    end




endmodule 