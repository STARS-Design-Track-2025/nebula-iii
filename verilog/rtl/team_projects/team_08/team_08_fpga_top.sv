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



// assign rdx = 1;

assign left[4] = wrx; //F14

assign left[2:0] = {rdx, csx,dcx}; //P15, R2, R5 

assign red = hz2;

// assign blue = sig;

assign blue = hwclk;



assign {right[5],ss4[4],right[0], ss1[5], ss1[4], right[4], ss4[5] , ss4[1]} = outputs;







logic [5:0] count;

logic [31:0] program_counter;

logic [2:0] state;



assign ss7= program_counter [7:0]; // E14,F16

assign ss6[2:0] = state; // from 2 to 0 K15, J14, K14

//ss2 ss3 = G16 B16

t08_top topmodule(



  .clk(hwclk), .nRst(~reset), .en(1'b1), 

  .touchscreen_interrupt(0), .SDAin(0), .SDAout(), .SDAoeb(), .touchscreen_scl(),

  .spi_outputs(outputs), .spi_wrx(wrx), .spi_rdx(rdx), .spi_csx(csx), .spi_dcx(dcx), .program_counter(program_counter));



//assign {right[5],ss4[4],right[0], ss1[5], ss1[4], right[4], ss4[5] , ss4[1]}= outputs;

//R1,R3,B2, L1, L3, M2, R4, R6





//assign left[3:0] = {wrx, rdx, csx,dcx};

//assign red = hz2;







  always_ff @ (posedge hwclk, posedge reset) begin 

      if (reset) begin

        hz2 <= 0;

        clkdivcount <= 0;

      end else begin

        hz2 <= hz2_n;

        clkdivcount <= clkdivcount_n;

      end

  end



  always_comb begin

      if (clkdivcount > 1) begin

          hz2_n = ~hz2;

          clkdivcount_n = 0;

      end else begin

          hz2_n = hz2;

          clkdivcount_n = clkdivcount + 1;

      end

  end



logic Q0, Q1;









endmodule