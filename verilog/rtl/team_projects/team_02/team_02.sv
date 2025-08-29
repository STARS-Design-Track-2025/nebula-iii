// $Id: $
// File name:   team_02.sv
// Created:     
// Author:      
// Description: 

`default_nettype none

module team_02 (
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
    // output wire [31:0] ADR_O,
    // output wire [31:0] DAT_O,
    // output wire [3:0]  SEL_O,
    // output wire        WE_O,
    // output wire        STB_O,
    // output wire        CYC_O,
    // input wire [31:0]  DAT_I,
    // input wire         ACK_I,

    // 34 out of 38 GPIOs (Note: if you need up to 38 GPIO, discuss with a TA)
    input  logic [33:0] gpio_in, // Breakout Board Pins
    output logic [33:0] gpio_out, // Breakout Board Pins
    output logic [33:0] gpio_oeb // Active Low Output Enable
    
    /*
    * Add other I/O ports that you wish to interface with the
    * Wishbone bus to the management core. For examples you can 
    * add registers that can be written to with the Wishbone bus
    */

);
    
    // Output assignments
    logic [7:0] left, right, ss0;
    assign {gpio_out[3], gpio_out[5], gpio_out[4]} = left[2:0];
    assign {gpio_out[8:7], gpio_out[10:9], gpio_out[12]} = {right[5:2], right[0]};
    assign {gpio_out[13], gpio_out[11]} = {ss0[7], ss0[1]};

    // Top Level Instance
    t02_top dut (
        .hz100(clk),
        .reset(en && nrst),
        .pb({2'b0, gpio_in[1], 15'b0, gpio_in[6], gpio_in[2], 1'b0}),
        .left(left),
        .right(right),
        .ss0(ss0)
    );

    // Unused outputs set to 0
    assign {gpio_out[33:14], gpio_out[6], gpio_out[2:0]} = '0;

    // OEBs
    assign {gpio_oeb[13:7], gpio_oeb[5:3]} = '0;  //Ouputs
    assign {gpio_oeb[6], gpio_oeb[2:1]} = '1;  //Inputs
    assign {gpio_oeb[33:14], gpio_oeb[0]} = '1; //set unused pins to inputs (doesn't really matter)

endmodule