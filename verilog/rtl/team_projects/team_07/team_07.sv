// $Id: $
// File name:   team_07.sv
// Created:     
// Author:      
// Description: 

`default_nettype none

module team_07 (
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
    
    /*
    * Add other I/O ports that you wish to interface with the
    * Wishbone bus to the management core. For examples you can 
    * add registers that can be written to with the Wishbone bus
    */

    // You can also have input registers controlled by the Caravel Harness's on chip processor
);

    logic newclk, newclk_n; 
    logic [22:0] count, count_n;
    
    // Some registers 
    always_ff @(posedge clk, negedge nrst) begin
    if (~nrst) begin
      count <= '0;
      newclk <= '0;
    end else begin
      count <= count_n;
      newclk <= newclk_n;
    end
  end

  // 125 kHz clock  divider 
  always_comb begin
    count_n = count;
    newclk_n = newclk;
    if (count < 23'd40) begin
      count_n = count + 1;
    end else begin
      count_n = '0;
      newclk_n = !newclk;
    end

  end
   
   // Top Instantiation
   t07_top top0(.clk(newclk), .nrst(nrst & en), .invalError(gpio_out[5]), .chipSelectTFT(gpio_out[4]), .bitDataTFT(gpio_out[3]), .sclkTFT(gpio_out[1]), .misoDriver_i(gpio_in[2]),
   .dataArToWM(DAT_I), .ackToWM(ACK_I), .dataWMToAr(DAT_O), .addrWMToAr(ADR_O), .selToAr(SEL_O), .weToAr(WE_O), .stbToAr(STB_O), .cycToAr(CYC_O));


   // Unused Outputs are set to 0
   assign {gpio_out[33:6], gpio_out[2], gpio_out[0]} = '0;

   // OEBs
   assign {gpio_oeb[5:3], gpio_oeb[1]} = '0; // Outputs
   assign gpio_oeb[2] = '1; // Inputs
   assign {gpio_oeb[33:6], gpio_oeb[0]} = '1; // Unused pins set to inputs (doesn't really matter)

endmodule