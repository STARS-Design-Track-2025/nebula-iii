`default_nettype none

// FPGA top module for Team 04

module t04_top1 (
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

  t04_top team_04_inst (
    .clk(hwclk),
    .rst(reset),
    .row(pb[3:0]),
    .screenCsx(right[0]),
    .screenDcx(right[1]),
    .screenWrx(right[2]),
    .screenData(left[7:0]),
    .checkC(red),
    .checkX(green),
    .checkY(blue)
  );

endmodule
