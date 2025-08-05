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

logic [7:0] outputs;

logic wrx,rdx,csx,dcx;

logic hz2=0, hz2_n = 0;

logic [21:0] clkdivcount = 0, clkdivcount_n;

assign left[4] = wrx; //F14

assign left[2:0] = {rdx, csx,dcx}; //P15, R2, R5 

assign red = hz2;

assign blue = hwclk;


//R1,R3,B2, L1, L3, M2, R4, R6
assign {right[5],ss4[4],right[0], ss1[5], ss1[4], right[4], ss4[5] , ss4[1]} = outputs;

logic inter, sda_in, sda_out, scl_in, scl_out;

assign left[6] = ~sda_out; //R15
assign left[7] = ~scl_out; //T1

assign sda_in = ~pb[4]; //A1
assign scl_in = ~pb[1]; //B3
assign inter = pb[2]; //C4


logic [31:0] wb_dat_i;
logic wb_ack_i;
logic [31:0] wb_adr_o;
logic [31:0] wb_dat_o;
logic [3:0] wb_sel_o;
logic wb_we_o, wb_stb_o, wb_cyc_o;

t08_top topmodule(

  .clk(hwclk), .nRst(~reset), .en(1'b1), 

  .touchscreen_interrupt(inter), .I2C_sda_in(sda_in), .I2C_scl_in(scl_in), .I2C_sda_out(sda_out), .I2C_scl_out(scl_out),
  .spi_outputs(outputs), .spi_wrx(wrx), .spi_rdx(rdx), .spi_csx(csx), .spi_dcx(dcx), 
  .wb_dat_i(wb_dat_i), .wb_ack_i(wb_ack_i), 
  .wb_adr_o(wb_adr_o), .wb_dat_o(wb_dat_o), .wb_sel_o(wb_sel_o), 
  .wb_we_o(wb_we_o), .wb_stb_o(wb_stb_o), .wb_cyc_o(wb_cyc_o)
    
  );

/*
SRAM Wishbone wrapper
*/

sram_WB_Wrapper sram_wb_w(
    .wb_clk_i(hwclk), .wb_rst_i(reset), 
    .wbs_stb_i(wb_stb_o), .wbs_cyc_i(wb_cyc_o), .wbs_we_i(wb_we_o), 
    .wbs_sel_i(wb_sel_o), .wbs_dat_i(wb_dat_o), .wbs_adr_i(wb_adr_o), 
    .wbs_ack_o(wb_ack_i), .wbs_dat_o(wb_dat_i)
);



endmodule