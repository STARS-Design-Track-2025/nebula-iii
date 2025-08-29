module testcpu (
  input logic controlPress, xPress, yPress, wrtPress, clk, rst,
  data1Press, data2Press, data3Press, data4Press, data5Press, data6Press, data7Press, data8Press, 
  data9Press, data10Press, data11Press, data12Press, data13Press,
  output logic [31:0] data, address,
  output logic wrtEdge
);

  logic wrt1, wrt2, wrt3;
  logic [31:0] nextData, nextAddress, currentData, currentAddress;

  localparam int data9 = 32'b100000000; //clear
  localparam int data8 = 32'b10000000; // sw reset on
  localparam int data7 = 32'b1000000; // display on
  localparam int data6 = 32'b100000; //display off
  localparam int data5 = 32'b10000; // red
  localparam int data4 = 32'b1000; // green
  localparam int data3 = 32'b100; // blue
  localparam int data2 = 32'b10; // white
  localparam int data1 = 32'b1; // black
  localparam int data10 = {16'd50, 16'd50};
  localparam int data11 = {16'd100, 16'd100};
  localparam int data12 = {16'd150, 16'd150};
  localparam int data13 = {16'd200, 16'd200};

  always_comb begin

    nextData = 32'b0;
    nextAddress = 32'b0;

    if (data1Press) begin
      nextData = data1;
    end else if (data2Press) begin
      nextData = data2;
    end else if (data3Press) begin
      nextData = data3;
    end else if (data4Press) begin
      nextData = data4;
    end else if (data5Press) begin
      nextData = data5;
    end else if (data6Press) begin
      nextData = data6;
    end else if (data7Press) begin
      nextData = data7;
    end else if (data8Press) begin
      nextData = data8;
    end else if (data9Press) begin
      nextData = data9;
    end else if (data10Press) begin
      nextData = data10;
    end else if (data11Press) begin
      nextData = data11;
    end else if (data12Press) begin
      nextData = data12;
    end else if (data13Press) begin
      nextData = data13;
    end

    if (controlPress) begin
      nextAddress = 32'd4;
    end else if (xPress) begin
      nextAddress = 32'd8;
    end else if (yPress) begin
      nextAddress = 32'd12;
    end 

  end
  
  always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
      wrt1 <= 0;
      wrt2 <= 0;
      wrt3 <= 0;
      currentAddress <= 0;
      currentData <= 0;
    end else begin
      wrt1 <= wrtPress;
      wrt2 <= wrt1;
      wrt3 <= wrt2;
      currentAddress <= nextAddress;
      currentData <= nextData;
    end
  end

  assign wrtEdge = wrt2 && ~wrt3;
  assign data = currentData;
  assign address = currentAddress;



endmodule