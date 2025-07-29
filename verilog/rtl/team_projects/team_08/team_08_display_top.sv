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

// logic [31:0] controlBus;
// logic [31:0] xBus = 32'b1100100000_000001001111; //800-top 20 bits, 79 -lower 12bits
// logic [31:0] yBus = 32'b1111000000_000001011001; //960 -top 20 bits, 89 lower 12 bits
// logic [22:0] ct;
// logic ack, dcx, wrx, csx;
// logic [7:0] data;

// assign left[3:0] = {wrx, rdx, csx,dcx};
// assign red = hwclk;

// assign {right[5],ss4[4],right[0], ss1[5], ss1[4], right[4], ss4[5] , ss4[1]} = data;
// logic hz2, hz2_n;
// logic clkdivcount, clkdivcount_n;

// t08_display_testing disptest (.controlBus(controlBus), .xBus(xBus), .yBus(yBus), .ct(ct), .clk(hwclk), .rst(Q1), .ack(ack), .dcx(dcx), .wrx(wrx), .csx(csx), .data(data));

// always_ff @(posedge hwclk, posedge Q1) begin
//     if (Q1) begin
//         ct <= 0;
//         controlBus <= 32'b10000000;
//     end else begin
//         ct <= next_ct;
//         controlBus <= nextcontrolBus;
//     end
// end

// always_comb begin
//     next_ct = ct + 1;
//     nextcontrolBus = controlBus;
//     if (ct == 1200028 && controlBus == 32'b10000000) begin
//         nextcontrolBus = 32'b10;
//         next_ct = 0;
//     end else if (ct == 36 && controlBus == 32'b10) begin
//         next_ct = 0;
//     end
// end

// logic Q0, Q1;

// always_ff@(posedge hwclk, posedge reset) begin
//   if(reset) begin
//     Q0 <= 0;
//     Q1<= 0;
//   end
//   else begin
//    Q0  <= ~pb[19];
//    Q1 <= Q0&pb[19]; //~~pb19
//   end 
// end

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
//       if (clkdivcount > 1) begin
//           hz2_n = ~hz2;
//           clkdivcount_n = 0;
//       end else begin
//           hz2_n = hz2;
//           clkdivcount_n = clkdivcount + 1;
//       end
//   end


// endmodule



// // logic hz2=0, hz2_n = 0;
// // logic [21:0] clkdivcount = 0, clkdivcount_n;

// // logic [5:0] count;

// //   always_ff @ (posedge hwclk, posedge reset) begin : clock_divider_ff
// //       if (reset) begin
// //         hz2 <= 0;
// //         clkdivcount <= 0;
// //       end else begin
// //         hz2 <= hz2_n;
// //         clkdivcount <= clkdivcount_n;
// //       end
// //   end

// //   always_comb begin : clock_divider
// //       if (clkdivcount > 22'd300000) begin
// //           hz2_n = ~hz2;
// //           clkdivcount_n = 0;
// //       end else begin
// //           hz2_n = hz2;
// //           clkdivcount_n = clkdivcount + 1;
// //       end
// //   end

// // logic Q0, Q1;