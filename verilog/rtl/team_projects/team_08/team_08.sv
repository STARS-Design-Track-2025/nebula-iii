// $Id: $
// File name:   team_08.sv
// Created:     
// Author:      
// Description: 

`default_nettype none

module team_08 (
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

    assign gpio_out = '0;
    assign gpio_oeb = '0;

    /*
    List of pins used: 

        0:  Interrupt from touchscreen          (Input)
        1:  SDA line for I2C with touchscreen   (Input and output)
        2:  SCL line for I2C with touchscreen   (Output)
     3-10:  SPI outputs                         (Output)
       11:  spi_wrx                             (Output)
       12:  spi_rdx                             (Output)
       13:  spi_csx                             (Output)
       14:  spi_dcx                             (Output)
    15-33:  Not used

    */

    t08_top top(
        .clk(clk), .nRst(nrst), .en(en),
        .touchscreen_interrupt(gpio_in[0]), 
        .SDAin(gpio_in[1]), .SDAout(gpio_out[1]), .SDAoeb(gpio_oeb[1]), 
        .touchscreen_scl(gpio_out[2]),

        .spi_outputs(gpio_out[3:10]), 
        .spi_wrx(gpio_out[11]), .spi_rdx(gpio_out[12]), .spi_csx(gpio_out[13]), .spi_dcx(gpio_out[14]),

        .wb_dat_i(DAT_I), .wb_ack_i(ACK_I), 
        .wb_adr_o(ADR_O), .wb_dat_o(DAT_O), .wb_sel_o(SEL_O), 
        .wb_we_o(WE_O), .wb_stb_o(STB_O), .wb_cyc_o(CYC_O)

        // .wb_dat_o(DAT_O), .wb_busy_o(BUSY_O), 
        // .wb_dat_i(DAT_I), .wb_adr_i(ADR_I), .wb_sel_i(SEL_I), 
        // .wb_write_i(WRITE_I), .wb_read_i(READ_I)
    );

    // wishbone_manager wm(
    //     .nRST(nRst), .CLK(clk),                                     //reset and clock

    //     .DAT_I(DAT_I), .ACK_I(ACK_I),                         //"input from wishbone interconnect"
                                                                  
    //     .CPU_DAT_I(DAT_I), .ADR_I(ADR_I),                   //"input from user design"
    //     .SEL_I(SEL_I),  
    //     .WRITE_I(WRITE_I), .READ_I(READ_I),    

    //     .ADR_O(ADR_O), .DAT_O(DAT_O), .SEL_O(SEL_O),       //"output to wishbone interconnect"
    //     .WE_O(WE_O), .STB_O(STB_O), .CYC_O(CYC_O),  

    //     .CPU_DAT_O(DAT_O), .BUSY_O(BUSY_O)       //"output to user design"
    // );

endmodule