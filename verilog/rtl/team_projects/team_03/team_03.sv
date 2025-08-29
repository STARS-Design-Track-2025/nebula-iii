// $Id: $
// File name:   team_03.sv
// Created:     
// Author:      
// Description: 

`default_nettype none

module team_03 (
    `ifdef USE_POWER_PINS
        inout vccd1,	// User area 1 1.8V supply
        inout vssd1,	// User area 1 digital ground
    `endif
    // HW
    input logic clk, nrst,
    
    input logic en, //This signal is an enable signal for your chip. Your design should disable if this is low.
    
    // Logic Analyzer - Grant access to all 128 LA
    // input logic [31:0] la_data_in,
    // output logic [31:0] la_data_out,
    // input logic [31:0] la_oenb,


    // Wishbone master interface
    output wire [31:0] ADR_O,
    output wire [31:0] DAT_O,
    output wire [3:0]  SEL_O,
    output wire        WE_O,
    output wire        STB_O,
    output wire        CYC_O,
    input wire [31:0]  DAT_I,
    input wire         ACK_I,

    // 34 out of 38 GPIOs (Note: if you need up to 38 GPIO, discuss with a TA)
    input  logic [33:0] gpio_in, // Breakout Board Pins
    output logic [33:0] gpio_out, // Breakout Board Pins
    output logic [33:0] gpio_oeb // Active Low Output Enable

);

    logic rst;
    assign rst = ~nrst | ~en;

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

    // assign red = DEBUGALUsrc;
    // assign green = clk;
    // assign blue = DEBUGfreezePc;


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
    .x1(x1), .x2(x2), .y1(y1), .y2(y2), .p1Left(p1Left), .p2Left(p2Left),
    .DAT_I(DAT_I), .ACK_I(ACK_I), //WISHBONE INPUT SIGNALS
    .ADR_O(ADR_O), .DAT_O(DAT_O), .SEL_O(SEL_O), .WE_O(WE_O), .STB_O(STB_O), .CYC_O(CYC_O) //WISHBONE OUTPUT SIGNALS
    );
    
    logic latch; 
    logic pulse;
    logic player1, player2;
    t03_NESControllers NES(.clk(clk), .rst(rst), .confirm(NESConfirm), .packedOutput(NESData), .latch(latch), .pulse(pulse), .player_1_in(player1), .player_2_in(player2));
    t03_hardware_clock hardwareClk(.clk(clk), .rst(rst), .new_counter(new_counter));
    // assign ss0 = NESData[31:24]; //tests the states that we have
    // assign ss0 = NESData[23:16]; //tests the individual button inputs of just controller 1

    t03_DPUtop DPU(.clk(clk), .rst(rst), .gameState(gameState), .p1State(p1State), .p2State(p2State), .p1health(p1health),
    .p2health(p2health), .x1(x1), .x2(x2), .y1(y1), .y2(y2), .left(dpu_vga), .right(dpu_colors), .p1Left(p1Left), .p2Left(p2Left));

    logic [1:0] dpu_vga;
    logic [7:0] dpu_colors;

    // assign left = DPUleft;
    // assign right = DPUright;


    // Output Port Assignments
    assign gpio_out[12:1] = {latch, pulse, dpu_colors, dpu_vga};
    // Input Port Assignments
    assign {player2, player1} = gpio_in[14:13];

    // Set unused outputs to 0
    assign {gpio_out[33:13], gpio_out[0]} = '0;

    // Output enables
    assign gpio_oeb[12:1] = '0;  // Outputs
    assign gpio_oeb[14:13] = '1;  // Inputs
    assign {gpio_oeb[33:15], gpio_oeb[0]} = '1;  // Set unsued pins to inputs (gg could be anything tbh)

endmodule