module top (
  // I/O ports
  input  logic hwclk, reset,
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

logic [31:0] controlBus = 32'b10000000;
logic [31:0] xBus, yBus;
logic [22:0] ct;
logic ack, dcx, wrx, csx;
logic [7:0] data;


t08_display_testing disptest (.controlBus(controlBus), xBus(xBus), yBus(yBus), .ct(ct), .clk(hwclk), .rst(reset), .ack(ack), .dcx(dcx), .wrx(wrx), .csx(csx), .data(left))
  input logic clk, rst,
  output logic ack, dcx, wrx, csx,
  output logic [7:0] data  )