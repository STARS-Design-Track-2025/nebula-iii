// $Id: $
// File name:   team_04.sv
// Created:     
// Author:      
// Description: 

`default_nettype none

module team_04 (
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

    // Uncommented the wishbone interface. These are the ports that
    // will use to connect our design to the Wishbone bus.
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

    logic [31:0] instruction;
    logic [31:0] memload;
  
    logic [31:0] final_address;
    logic [31:0] mem_store;

    logic i_ack, d_ack;
    logic MemRead, MemWrite;
    logic BranchConditionFlag;
    logic JAL_O;

    logic pulse_e;
    assign pc = final_address[7:0];
    logic [4:0] button;
    logic [1:0] app;
    logic rising;

    logic [31:0] display_address;
    logic [31:0] mem_store_display;
    logic WEN;
    logic d_ack_display;
    logic [9:0] cnt, ncnt;
  assign acks = {d_ack, d_ack_display};

  always_ff @(posedge clk, posedge rst) begin
    if(rst) begin
      cnt <= '0;
    end else begin
      cnt <= ncnt;
    end
  end

  always_comb begin
    if(cnt == 1000) begin
      ncnt = 0;
    end else begin
      ncnt = cnt + 1;
    end
  end

    // === Instantiate Datapath ===
    t04_datapath datapath (
        .clk(clk),
        .rst(rst),
        .i_ack(i_ack),
        .d_ack(d_ack),
        .instruction(instruction),
        .memload(memload),
        .final_address(final_address),
        .mem_store(mem_store),
        .MemRead_O(MemRead),
        .MemWrite_O(MemWrite),
        .BranchConditionFlag(BranchConditionFlag),
        .JAL_O(JAL_O)
    );

    // === Instantiate MMIO ===
    t04_mmio mmio (
        .clk(clk),
        .reset(rst), 
        .final_address(final_address),
        .mem_store(mem_store),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .i_ack(i_ack),
        .d_ack(d_ack),
        .instruction(instruction),
        .memload(memload),
        .BranchConditionFlag(BranchConditionFlag),
        .JAL_O(JAL_O),
        .button_pressed(button),
        .app(app),
        .rising(rising),
        .display_address(display_address),
        .mem_store_display(mem_store_display),
        .d_ack_display(d_ack_display),
        .WEN(WEN),
        .ack(ACK_I),
        .dat_i(DAT_O),
        .stb(STB_O),
        .cyc(CYC_O),
        .we(WE_O),
        .sel(SEL_O),
        .adr(ADR_O),
        .dat_o(DAT_I)
    );

    // === KEYPAD INTERFACE ===
    t04_counter_column columns (
        .clk(clk), .rst(rst),
        .column(column),
        .pulse_e(pulse_e)
    );

    t04_keypad_interface keypad (
        .clk(clk), .rst(rst),
        .column(column),
        .row(row),
        .pulse(pulse_e),
        .button(button),
        .app(app),
        .rising(rising)
    );

    // === DISPLAY INTERFACE ===
    t04_screen_top screen (
        .clk(clk),
        .rst(rst),
        .WEN(WEN),
        .mem_store_display(mem_store_display),
        .display_address(display_address),
        .d_ack_display(d_ack_display),
        .dcx(screenDcx),
        .csx(screenCsx),
        .wrx(screenWrx),
        .screenData(screenData),
    );

endmodule