// `default_nettype none

// // FPGA top module for Team 08

// module top (
//   // I/O ports
//   input  logic hwclk, reset,
//   input  logic [20:0] pb,
//   output logic [7:0] left, right,
//          ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
//   output logic red, green, blue,

//   // UART ports
//   output logic [7:0] txdata,
//   input  logic [7:0] rxdata,
//   output logic txclk, rxclk,
//   input  logic txready, rxready
// );
// logic [7:0] outputs;
// logic wrx,rdx,csx,dcx;
// logic hz2=0, hz2_n = 0;
// logic [21:0] clkdivcount = 0, clkdivcount_n;

// // assign rdx = 1;
// assign left[4] = wrx; //F14
// assign left[2:0] = {rdx, csx,dcx}; //P15, R2, R5 
// assign red = hz2;
// // assign blue = sig;

// assign {right[5],ss4[4],right[0], ss1[5], ss1[4], right[4], ss4[5] , ss4[1]} = outputs;



// logic [5:0] count;
// t08_top topmodule(
//   .clk(hz2), .nRst(Q1), .en(1'b1), 
//   .touchscreen_interrupt(0), .SDAin(0), .SDAout(), .SDAoeb(), .touchscreen_scl(),
//   .spi_outputs(outputs), .spi_wrx(wrx), .spi_rdx(rdx), .spi_csx(csx), .spi_dcx(dcx));

// //assign {right[5],ss4[4],right[0], ss1[5], ss1[4], right[4], ss4[5] , ss4[1]}= outputs;
// //R1,R3,B2, L1, L3, M2, R4, R6


// //assign left[3:0] = {wrx, rdx, csx,dcx};
// //assign red = hz2;


//   always_ff @ (posedge hwclk, posedge reset) begin : clock_divider_ff
//       if (reset) begin
//         hz2 <= 0;
//         clkdivcount <= 0;
//       end else begin
//         hz2 <= hz2_n;
//         clkdivcount <= clkdivcount_n;
//       end
//   end

//   always_comb begin : clock_divider
//       if (clkdivcount > 22'd3000) begin
//           hz2_n = ~hz2;
//           clkdivcount_n = 0;
//       end else begin
//           hz2_n = hz2;
//           clkdivcount_n = clkdivcount + 1;
//       end
//   end

// logic Q0, Q1;

// always_ff@(posedge hwclk, posedge reset) begin
//   if(reset) begin
//     Q0 <= 0;
//     Q1<= 0;
//   end
//   else begin
//    Q0  <= ~pb[19];
//    Q1 <= Q0&pb[19]; //~~pb19
//   end end



// endmodule