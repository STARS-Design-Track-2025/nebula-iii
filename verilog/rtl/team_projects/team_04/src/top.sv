`default_nettype none
// Empty top module

module top (
  // I/O ports
  input  logic hz100, reset,
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

  logic [31:0] data, address, controlBus, xBus, yBus;
  logic wrtEdge, ack, enableEdge, enable;
  logic [22:0] ct;

  testcpu cpu(.wrtEdge(wrtEdge), .data(data), .address(address), .clk(hz100), .rst(reset), .wrtPress(pb[16]), 
    .controlPress(pb[19]), .xPress(pb[17]), .yPress(pb[18]), 
    .data1Press(pb[1]), .data2Press(pb[2]), .data3Press(pb[3]), .data4Press(pb[4]), .data5Press(pb[5]), .data6Press(pb[6]), 
    .data7Press(pb[7]), .data8Press(pb[8]), .data9Press(pb[9]), .data10Press(pb[10]), .data11Press(pb[11]), .data12Press(pb[12]), .data13Press(pb[13]));
  t04_screenRegister register(.data(data), .address(address), .wen(wrtEdge), .rst(reset), .clk(hz100), .ack(ack), .control(controlBus), .xBus(xBus), .yBus(yBus), .finalAck(red));
  t04_screenEnableEdge toggle(.xBus(xBus), .yBus(yBus), .control(controlBus), .clk(hz100), .rst(reset), .enableEdge(enableEdge));
  t04_screenCounter counter(.clk(hz100), .rst(reset), .enableEdge(enableEdge), .ct(ct), .ack(ack));
  t04_screensignalLogic screenOutput(.controlBus(controlBus), .xBus(xBus), .yBus(yBus), .ct(ct), .clk(hz100), .rst(reset), .ack(ack), .data(left[7:0]), .csx(right[0]), .dcx(right[1]), .wrx(right[2]));

endmodule
