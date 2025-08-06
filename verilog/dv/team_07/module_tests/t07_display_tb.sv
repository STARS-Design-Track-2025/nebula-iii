`default_nettype none
`timescale 1ms/10ns
// FPGA top module for Team 07

module top (
  // I/O ports
  input  logic hwclk, reset, //hwclk = 10 MHz
  input  logic [20:0] pb,
  output logic [7:0] left, right,
         ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
  output logic red, green, blue,

  // UART ports
  output logic [7:0] txdata,
  input  logic [7:0] rxdata,
  output logic txclk, rxclk,
  input  logic txready, rxready
);

  // GPIOs
  // Don't forget to assign these to the ports above as needed
  logic [33:0] gpio_in, gpio_out;

  logic wi;
  logic newclk, newclk_n; 
  logic [4:0] count, count_n;
  logic [15:0] in;
  logic delay;

  t07_display tft (.clk(newclk), .nrst(~reset), .out(in), .delay(delay));
  t07_spitft spitft (.clk(newclk), .nrst(~reset), .in(in), .wi(wi), .delay(delay), .ack(right[7]), .bitData(right[1]), .chipSelect(right[3]), .sclk(right[2]));
  
    always begin
         
    end

  always_ff @(posedge hwclk, posedge reset) begin
    if (reset) begin
      count <= '0;
      newclk <= '0;
    end else begin
      count <= count_n;
      newclk <= newclk_n;
    end
  end

  always_comb begin
    count_n = count;
    newclk_n = newclk;
    if (count < 5'd18) begin //clock divider
      count_n = count + 1;
    end else begin
      count_n = '0;
      newclk_n = !newclk;
    end
  end

endmodule
