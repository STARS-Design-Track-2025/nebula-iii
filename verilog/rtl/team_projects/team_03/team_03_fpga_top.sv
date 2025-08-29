`default_nettype none
`timescale 1ps/1ps

// Empty top module

module top (
  // I/O ports
  input  logic hz100, reset, //hz100 is currently 10MHz, check PPL in ice40hx8k.sv to change it 
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
  // Your code goes here...

    logic clk;
    logic rst;

    assign clk = hz100;
    assign rst = reset;

    logic ack;
    logic [31:0] dataOut;
    logic [31:0] data;
    logic [31:0] address;
    logic write;
    logic read;
    logic NESConfirm;
    logic [31:0] NESData;
    logic [31:0] new_counter;
    logic DEBUGALUsrc;
    logic DEBUGfreezePc;

    assign red = DEBUGALUsrc;
    assign green = clk;
    assign blue = DEBUGfreezePc;


    t03_cputop CPU(.clk(clk), .rst(rst),
    .ack(ack), .dataOut(dataOut), //Inputs from MMIO
    .data(data), .address(address), //Outputs into MMIO
    .write(write), .read(read), //Outputs into MMIO
    .ALUsrc(DEBUGALUsrc), .freezePc(DEBUGfreezePc));

    logic [2:0] gameState;
    logic [1:0] p1State;
    logic [1:0] p2State;
    logic [3:0] p1health;
    logic [3:0] p2health;
    logic [10:0] x1, x2, y1, y2;
    logic p1Left, p2Left;

    t03_MMIOInterface MMIOInterface(.rst(rst), .clk(clk),
    .data(data), .address(address), .write(write), .read(read), .dataOut(dataOut), .ack(ack), //CPU Inputs/Outputs
    .new_counter(new_counter), //From Hardware Counter
    .NESData(NESData), .NESConfirm(NESConfirm), //NES Inputs
    .gameState(gameState), .p1State(p1State), .p2State(p2State), .p1health(p1health), .p2health(p2health), //To DPU
    .x1(x1), .x2(x2), .y1(y1), .y2(y2), .p1Left(p1Left), .p2Left(p2Left)
    );
    //pb[0] pb[3]  pb[16]
    //C3
    //C5
    //B9 

    t03_NESControllers NES(.clk(clk), .rst(rst), .pb(pb), .confirm(NESConfirm), .packedOutput(NESData), .ss7(ss7));
    t03_hardware_clock hardwareClk(.clk(clk), .rst(rst), .new_counter(new_counter));
    // assign ss0 = NESData[31:24]; //tests the states that we have
    // assign ss0 = NESData[23:16]; //tests the individual button inputs of just controller 1

    t03_DPUtop DPU(.clk(clk), .rst(rst), .gameState(gameState), .p1State(p1State), .p2State(p2State), .p1health(p1health),
    .p2health(p2health), .x1(x1), .x2(x2), .y1(y1), .y2(y2), .left(DPUleft), .right(DPUright), .p1Left(p1Left), .p2Left(p2Left));

    logic [7:0] DPUleft;
    logic [7:0] DPUright;

    assign left = DPUleft;
    assign right = DPUright;

    //For debugging
    //assign right = {x2[7:0]};
    //assign left = {x1[7:0]};

    // ssdec decoder1(NESData[3:0], 1'b1, ss0);
    // ssdec decoder2(NESData[7:4], 1'b1, ss1);
    // ssdec decoder3(NESData[11:8], 1'b1, ss2);
    // ssdec decoder4(NESData[15:12], 1'b1, ss3);
    // ssdec decoder5(NESData[19:16], 1'b1, ss4);
    // ssdec decoder6(NESData[23:20], 1'b1, ss5);
    // ssdec decoder7(NESData[27:24], 1'b1, ss6);
    // ssdec decoder8(NESData[31:28], 1'b1, ss7);
endmodule