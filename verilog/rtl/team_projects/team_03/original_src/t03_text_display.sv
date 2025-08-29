`default_nettype none
`timescale 1ps/1ps

module t03_text_display
(
  input logic [10:0] Hcnt,
  input logic [10:0] Vcnt,
  input logic [863:0] text,
  output logic [7:0] color, //Even if it's white because we are just accepting it 8 bit to keep consistency 
  input logic [10:0] x,
  input logic [10:0] y,
  input clk, 
  input rst 

);
   
   //constant paramaters
   logic [10:0] min_x_to_display;
   logic [10:0] min_y_to_display;
   assign min_x_to_display = 37; //min x before it can even display anything
   assign min_y_to_display = 29; //min y before it can even display anthing.
   parameter y_length = 8; //8 Bits Tall
   parameter x_length = 108; //9 Bits Wide, 12 Characters, don't do 9 * 12 or length * width because multiplcation stuff because it goes to 32 bit unsigned. 

   //Changeable Paramaters
   logic [10:0] x_text_placement; 
   logic [10:0] y_text_placement;
   assign x_text_placement = x + min_x_to_display;
   assign y_text_placement = y + min_y_to_display; //place holders
   logic [7:0] next_color;

   
   always_ff @(posedge clk, posedge rst) begin
      if(rst) begin
         color <= 0;
      end
      else begin
         color <= next_color;

      end

   end
   logic [10:0] displacement;
 
   //10 bits 1024
   
   always @ (*) begin
      next_color = color;
      displacement = 0;
      if (Vcnt > y_text_placement && Vcnt < (y_text_placement + y_length * 5) && (Hcnt > x_text_placement && Hcnt <= (x_text_placement + x_length))) begin
                  displacement = (x_length * y_length) - (((Vcnt - y_text_placement) / 5) * x_length + (Hcnt - x_text_placement));
                  if(text[displacement[9:0]]) begin //change the displacement index correspondingly;
                  next_color[7:0] = 8'b11111111;
               end
               else begin
                  next_color[7:0] = 8'b00000000;
               end
         end
      else begin
           next_color[7:0] = 8'd0;
      end
   end  
endmodule