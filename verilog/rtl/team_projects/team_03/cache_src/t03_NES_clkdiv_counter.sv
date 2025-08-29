`default_nettype none
`timescale 1ps/1ps

module t03_NES_clkdiv_counter

 //its the clock divider for the counter used for NES controller 
(
    input logic clk ,rst,
    output logic clkdiv, 
    output logic finished, button_en, latch, pulse,
    output logic [15:0] counter // signal that controls every other output essentially
);
    logic [3:0] count_div;
    logic [15:0] n_counter;
    logic [3:0] en_counter;

    parameter LATCH_LENGTH = 16'd41667; //change based on whatever we want to clock as - for 60 HZ, this number should be 4167

    
always_ff @ (posedge clk, posedge rst) begin
  if (rst) begin
    clkdiv <= 0;
    count_div <= 0;
    counter <= 0;
    en_counter <= 0;
  end else begin
   if (count_div == 3) // produces a 2.5MHz clk signal --> change to 15 when at 40MHz
        begin
          count_div <= 0;
          clkdiv <= ~clkdiv;
          counter <= n_counter;
        end
      else begin
        count_div <= count_div + 1;
        counter <= counter;
      end
    en_counter <= en_counter + 1;
  end 
end

always_comb begin


  if (counter == LATCH_LENGTH) begin //might need to change this number
    n_counter = 0;
  end else begin
    n_counter = counter + 1;
  end
  
  if(counter > 16'd264) begin
    finished = 1;
  end else begin
    finished = 0;
  end

  if(counter < 30) begin
    latch = 1;
  end else begin
    latch = 0;
  end

  if(counter > 16'd44 && counter < 16'd285) begin
    if(((counter - 45) % 30) <= 14) begin
      pulse = 1;
    end else begin
      pulse = 0;
    end
  end else begin
    pulse = 0;
  end

  if(count_div == 3 && counter % 16'd30 == 29 && !finished) begin
     //the 13'd30 might have to change in order to get the correct clock speed for NES controller to not overclock
    button_en = 1;
  end else begin
    button_en = 0;
  end

end

endmodule

// module NES_clkdiv_counter

//  //its the clock divider for the counter used for NES controller controller
// (
//     input logic clk ,rst,
//     output logic clkdiv, 
//     output logic finished, button_en, latch, pulse,
//     output logic [12:0] counter // signal that controls every other output essentially

// );
//     logic [3:0] count_div;
//     logic [12:0] n_counter;

    
// always @ (posedge clk, posedge rst) begin
//   if (rst) begin
//     clkdiv <= 0;
//     count_div <= 0;
//     counter <= 0;
//   end else begin
//    if (count_div == 15) // produces a 2.5MHz clk signal
//         begin
//           count_div <= 0;
//           clkdiv <= ~clkdiv;
//           counter <= n_counter;
//         end
//       else begin
//         count_div <= count_div + 1;
//         counter <= counter;
//       end
//   end 
// end

// always_comb begin

//   if (counter == 13'd300) begin //might need to change this number
//     n_counter = 0;
//   end else begin
//     n_counter = counter + 1;
//   end
  
//   if(counter > 13'd270) begin
//     finished = 1;
//   end else begin
//     finished = 0;
//   end

//   if(counter < 30) begin
//     latch = 1;
//   end else begin
//     latch = 0;
//   end

//   if(counter > 13'd44 && counter < 13'd285) begin
//     if(((counter - 45) % 30) <= 14) begin
//       pulse = 1;
//     end else begin
//       pulse = 0;
//     end
//   end else begin
//     pulse = 0;
//   end

//   if(counter % 13'd30 == 0 && counter != 0) begin
//      //the 13'd30 might have to change in order to get the correct clock speed for NES controller to not overclock
//     button_en = 1;
//   end else begin
//     button_en = 0;
//   end

// end

// endmodule






