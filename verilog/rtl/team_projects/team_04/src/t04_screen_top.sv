module t04_screen_top (
  input logic [31:0] mem_store_display, display_address,
  input logic WEN, clk, rst,
  output logic d_ack_display, dcx, csx, wrx, 
  output logic [7:0] screenData
);

  logic internalAck, enableEdge;
  logic [31:0] controlBus, xBus, yBus;
  logic [22:0] ct;

  t04_screenRegister register(
    .wen(WEN), 
    .clk(clk), 
    .rst(rst), 
    .ack(internalAck), 
    .data(mem_store_display), 
    .address(display_address), 
    .control(controlBus), 
    .xBus(xBus),
    .yBus(yBus),
    .finalAck(d_ack_display)
    );

  t04_screenEnableEdge screenEdge(
    .clk(clk),
    .rst(rst),
    .xBus(xBus),
    .yBus(yBus),
    .control(controlBus),
    .enableEdge(enableEdge)
  );

  t04_screenCounter counter(
    .clk(clk), 
    .rst(rst),
    .enableEdge(enableEdge),
    .ct(ct),
    .ack(internalAck)
  );

  t04_screensignalLogic screenLogic(
    .controlBus(controlBus),
    .xBus(xBus),
    .yBus(yBus),
    .ct(ct),
    .clk(clk),
    .rst(rst),
    .ack(internalAck),
    .dcx(dcx),
    .csx(csx),
    .wrx(wrx),
    .data(screenData)
  );

endmodule
