`default_nettype none
`timescale 1ms/10ps

module t03_ssdec(input [3:0] in,
              input enable,
              output [7:0] out);
  
  logic [7:0] SEG7 [15:0];
  
  assign SEG7[4'h0] = 8'b0111111;
  assign SEG7[4'h1] = 8'b0000110;
  assign SEG7[4'h2] = 8'b1011011;
  assign SEG7[4'h3] = 8'b1001111;
  assign SEG7[4'h4] = 8'b1100110;
  assign SEG7[4'h5] = 8'b1101101;
  assign SEG7[4'h6] = 8'b1111101;
  assign SEG7[4'h7] = 8'b0000111;
  assign SEG7[4'h8] = 8'b1111111;
  assign SEG7[4'h9] = 8'b1100111;
  assign SEG7[4'ha] = 8'b1110111;
  assign SEG7[4'hb] = 8'b1111100;
  assign SEG7[4'hc] = 8'b0111001;
  assign SEG7[4'hd] = 8'b1011110;
  assign SEG7[4'he] = 8'b1111001;
  assign SEG7[4'hf] = 8'b1110001;

  assign out = enable ? SEG7[in[3:0]] : 8'b0000000;
  
endmodule
