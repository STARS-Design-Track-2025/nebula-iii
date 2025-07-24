`default_nettype none

// FPGA top module for Team 08

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
  logic [33:0] gpio_in, gpio_out, gpio_oeb;
  
  // logic [31:0] ADR_O, ADR_I, DAT_O, DAT_I;
  // logic [3:0] SEL_O, SEL_I;
  // logic WE_O, STB_O, CYC_O, ACK_I, BUSY_O, WRITE_I, READ_I;

  /*Clock divider (12MHz to 2Hz)*/

  logic [21:0] clkdivcount = 0;
  logic [21:0] clkdivcount_n = 0;

  always_ff @ (posedge hwclk, posedge reset) begin
      if (reset) begin
        clkdivcount <= 0;
      end else begin
        clkdivcount <= clkdivcount_n;
      end
  end

  // assign gpio_in[1:0] = pb[1:0]; // {SDA Line (Input), Interrupt}
  // assign right = gpio_out[10:3];  // SPI Outputs
  // assign left[5:0] = {gpio_out[14:11], gpio_out[2:1]};  // {spi_dcx, spi_csx, spi_rdx, spi_wrx, SCL line, SDA line (output)}
  
  /*Inputs*/

  assign gpio_in[1] = pb[1]; //SDA line input = pb[1]
  assign gpio_in[0] = pb[0]; //Interrupt from touchscreen = pb[0]

  /*Outputs*/



  // Team 08 Design Instance
  team_08 team_08_inst (
    .clk(hwclk),
    .nrst(~pb[19]), //Reset set to Z button
    .en(1'b1),

    .gpio_in(gpio_in),
    .gpio_out(gpio_out),
    .gpio_oeb()  // don't really need it here since it is an output

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

  );

  //   t08_top top(
  //     .clk(hwclk), .nRst(~reset), .en(1'b1),
  //     .touchscreen_interrupt(gpio_in[0]), 
  //     .SDAin(gpio_in[1]), .SDAout(gpio_out[1]), .SDAoeb(gpio_oeb[1]), 
  //     .touchscreen_scl(gpio_out[2]),

  //     .spi_outputs(gpio_out[3:10]), 
  //     .spi_wrx(gpio_out[11]), .spi_rdx(gpio_out[12]), .spi_csx(gpio_out[13]), .spi_dcx(gpio_out[14])

  //     // .wb_dat_i(DAT_I), .wb_ack_i(ACK_I), 
  //     // .wb_adr_o(ADR_O), .wb_dat_o(DAT_O), .wb_sel_o(SEL_O), 
  //     // .wb_we_o(WE_O), .wb_stb_o(STB_O), .wb_cyc_o(CYC_O),

  //     // .wb_dat_o(DAT_O), .wb_busy_o(BUSY_O), 
  //     // .wb_dat_i(DAT_I), .wb_adr_i(ADR_I), .wb_sel_i(SEL_I), 
  //     // .wb_write_i(WRITE_I), .wb_read_i(READ_I)
  // );

endmodule
