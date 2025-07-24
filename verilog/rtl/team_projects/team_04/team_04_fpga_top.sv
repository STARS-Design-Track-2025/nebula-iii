`default_nettype none

// FPGA top module for Team 04

module top (
  // I/O ports
  input  logic hwclk, reset,
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

  // GPIOs
  // Don't forget to assign these to the ports above as needed
  //logic [33:0] gpio_in, gpio_out;
  
  
  // Team 04 Design Instance
  // team_04 team_04_inst (
  //   .clk(hwclk),
  //   .nrst(~reset),
  //   .en(1'b1),

  //   .gpio_in(gpio_in),
  //   .gpio_out(gpio_out),
  //   .gpio_oeb(),  // don't really need it her since it is an output

    // Uncomment only if using LA
    // .la_data_in(),
    // .la_data_out(),
    // .la_oenb(),

    // Uncomment only if using WB Master Ports (i.e., CPU teams)
    // You could also instantiate RAM in this module for testing
    // .ADR_O(ADR_O),
    // .DAT_O(DAT_O),
    // .SEL_O(SEL_O),
    // .WE_O(WE_O),
    // .STB_O(STB_O),
    // .CYC_O(CYC_O),
    // .ACK_I(ACK_I),
    // .DAT_I(DAT_I),

    // Add other I/O connections to WB bus here

  //);

  t04_top team_04_inst (
  .clk(pb[0]),
  .rst(pb[19]),
  .column(ss0[3:0]),
  .button(ss1[4:0]),
  .row({pb[15], pb[11], pb[7], pb[3]}),
  .screenCsx(right[0]),
  .screenDcx(right[1]),
  .screenWrx(right[2]),
  .screenData(left[7:0]),
  .checkC(red),
  .checkX(green),
  .checkY(blue)
);

// // === Internal signals for datapath-MMIO connections ===
// logic [4:0] button_pressed;
// logic [1:0] app;
// logic rising;
// logic [31:0] display_address;
// logic [31:0] mem_store_display;
// logic d_ack_display;
// logic WEN;

// // === Example: assign buttons to keypad input ===
// // (You can adjust these assignments based on actual wiring)
// assign button_pressed = pb[4:0];    // 5 keypad lines
// assign app            = pb[6:5];    // 2-bit app select
// assign rising         = pb[7];      // rising edge flag
// assign d_ack_display  = pb[8];      // d_ack feedback (e.g., from display-ready)

// // === Instantiate datapath + MMIO system ===
// t04_datapathxmmio team_04_inst (
//     .clk(hwclk),
//     .rst(reset),  // or use pb[19] if that is your reset button

//     // === Keypad ===
//     .button_pressed(button_pressed),
//     .app(app),
//     .rising(rising),

//     // === Display ===
//     .display_address({left [7:0],display_address[23:0]}),
//     .mem_store_display(mem_store_display),
//     .d_ack_display(d_ack_display),
//     .WEN(red)
// );



// always begin
//    $display("x2  = %0h ", dut.datapath.rf.registers[2]);   // loaded from 0x24
// end

// verilator --lint-only --top-module top -Werror-latch -y $$TEAM_DIR/*.sv $$SRC_DIR/*.sv $$USER_PROJECT_VERILOG/rtl/wishbone_manager/wishbone_manager.sv $$SRAM_WRAPPER $$USER_PROJECT_VERILOG/rtl/sram/sram_for_FPGA.v &&\

endmodule
