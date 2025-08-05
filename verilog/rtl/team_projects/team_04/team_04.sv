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

    // === Keypad ===
    logic [3:0] row;
    logic [3:0] column; // good boy (can I have this column be named the same as an internal signal)

    // === Display ===
    logic screenCsx;
    logic screenDcx;
    logic screenWrx;
    logic [7:0] screenData;
    logic [7:0] pc;
    logic [1:0] acks;

    // === Internal Wires ===
    logic [31:0] instruction;
    logic [31:0] memload;
  
    logic [31:0] final_address;
    logic [31:0] mem_store;

    logic i_ack, d_ack;
    logic MemRead, MemWrite;
    logic BranchConditionFlag;
    logic JAL_O;

    logic pulse_e;
    logic [4:0] button;
    logic [1:0] app;
    logic rising;

    logic [31:0] display_address;
    logic [31:0] mem_store_display;
    logic WEN;
    logic d_ack_display;
    logic [9:0] cnt, ncnt;

    assign pc = final_address[7:0];
    assign acks = {d_ack, d_ack_display};

    // === GPIO Pin Assignments ===
    assign gpio_oeb = 34'b1111000011111111111111111111111111;

    assign column[0] = gpio_out[01];
    assign column[1] = gpio_out[02];
    assign column[2] = gpio_out[03];
    assign column[3] = gpio_out[04];
    assign row[0] = gpio_in[05];
    assign row[1] = gpio_in[06];
    assign row[2] = gpio_in[07];
    assign row[3] = gpio_in[08];
    assign screenCsx = gpio_out[09];
    assign screenDcx = gpio_out[10];
    assign screenWrx = gpio_out[11];
    assign screenData[0] = gpio_out[12];
    assign screenData[1] = gpio_out[13];
    assign screenData[2] = gpio_out[14];
    assign screenData[3] = gpio_out[15];
    assign screenData[4] = gpio_out[16];
    assign screenData[5] = gpio_out[17];
    assign screenData[6] = gpio_out[18];
    assign screenData[7] = gpio_out[19];

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