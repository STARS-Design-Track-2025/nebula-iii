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

logic inputs = 

    t08_spi SPI(
        .inputs(inputs),
        .enable_parameter(enable_parameter), .enable_command(enable_command), .clk(clk), .nrst(nRst), 
        .readwrite(SPI_write), 
        .outputs(spi_outputs), 
        .wrx(spi_wrx), .rdx(spi_rdx), .csx(spi_csx), .dcx(spi_dcx), 
        .busy(SPI_busy)
    );

  /*Clock divider (12MHz to 2Hz)*/
 
  // GPIOs
  // Don't forget to assign these to the ports above as needed
//   logic [33:0] gpio_in, gpio_out, gpio_oeb;
  
  // logic [31:0] ADR_O, ADR_I, DAT_O, DAT_I;
  // logic [3:0] SEL_O, SEL_I;
  // logic WE_O, STB_O, CYC_O, ACK_I, BUSY_O, WRITE_I, READ_I;

  // assign gpio_in[1:0] = pb[1:0]; // {SDA Line (Input), Interrupt}
  // assign right = gpio_out[10:3];  // SPI Outputs
  // assign left[5:0] = {gpio_out[14:11], gpio_out[2:1]};  // {spi_dcx, spi_csx, spi_rdx, spi_wrx, SCL line, SDA line (output)}
  

  // assign right[0] = ~pb[3];
  /*Inputs*/

//   assign gpio_in[1] = ~pb[2]; //SDA line input = pb[2]
//   assign gpio_in[0] = ~pb[1]; //Interrupt from touchscreen = pb[1]

//   /*Outputs*/

//   assign left[1] = gpio_out[2]; //I2C SCL = left[1]
//   assign left[0] = ~gpio_out[1]; //SDA line output = left[0] (inverted because using open-drain MOSFET)

  /*Temporary I2C instantiation*/

//   logic [31:0] I2C_data_out;

//   t08_I2C_and_interrupt I2C(
//     .clk(hz2), .nRst(~reset), 
//     .SDAin(gpio_in[1]), .SDAout(gpio_out[1]), .SDAoeb(), 
//     .inter(gpio_in[0]), .scl(gpio_out[2]), 
//     .data_out(I2C_data_out), .done(left[7])
//   );

//   t08_ssdec s7(.in(I2C_data_out[31:28]), .enable(1'b1), .out(ss7[6:0]));
//   t08_ssdec s6(.in(I2C_data_out[27:24]), .enable(1'b1), .out(ss6[6:0]));
//   t08_ssdec s5(.in(I2C_data_out[23:20]), .enable(1'b1), .out(ss5[6:0]));
//   t08_ssdec s4(.in(I2C_data_out[19:16]), .enable(1'b1), .out(ss4[6:0]));
//   t08_ssdec s3(.in(I2C_data_out[15:12]), .enable(1'b1), .out(ss3[6:0]));
//   t08_ssdec s2(.in(I2C_data_out[11:8]), .enable(1'b1), .out(ss2[6:0]));
//   t08_ssdec s1(.in(I2C_data_out[7:4]), .enable(1'b1), .out(ss1[6:0]));
//   t08_ssdec s0(.in(I2C_data_out[3:0]), .enable(1'b1), .out(ss0[6:0]));

  // Team 08 Design Instance
  // team_08 team_08_inst (
  //   .clk(hz2),
  //   .nrst(~reset), //Reset set to Z button
  //   .en(1'b1),

  //   .gpio_in(gpio_in),
  //   .gpio_out(gpio_out),
  //   .gpio_oeb()  // don't really need it here since it is an output

  //   // Uncomment only if using LA
  //   // .la_data_in(),
  //   // .la_data_out(),
  //   // .la_oenb(),

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

  // );

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
