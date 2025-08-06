// $Id: $
// File name:   team_01.sv
// Created:     
// Author:      
// Description: 

`default_nettype none

module team_01 (
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

    // You can also have input registers controlled by the Caravel Harness's on chip processor
);

   // Assignments for left
   logic [7:0] left;
   assign {gpio_out[8], gpio_out[9], gpio_out[13]} = left[7:5];

   // Unused outputs
   assign {gpio_out[33:14], gpio_out[7:0]} = '0;

   // OEBs
   assign gpio_oeb[13:8] = '0;  // Outputs
   assign gpio_oeb[7:1] = '1;  //Inputs
   assign {gpio_oeb[33:14], gpio_oeb[0]} = '1; // Unused pins (set to inputs, doesn't really matter)


    team_01_fpga_top top01 (
  // I/O ports
    .hwclk(clk), .reset(~nrst | ~en),
    .pb({1'b0, gpio_in[6], 2'b0, gpio_in[7], 7'b0, gpio_in[5], gpio_in[3], 2'b0, gpio_in[4], gpio_in[1], 2'b0, gpio_in[2]}),
    .J39_b15(),
    .J39_c15(),
    .left(left), 
    .right(),
    .red(gpio_out[10]),
    .green(gpio_out[11]),
    .blue(gpio_out[12])
   );

endmodule