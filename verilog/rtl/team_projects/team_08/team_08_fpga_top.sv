

`default_nettype none

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

//   /*Clock divider (12MHz to 2Hz)*/

//   logic hz2 = 0;                 //2 Hz clock
//   logic hz2_n = 0;
//   logic [21:0] clkdivcount = 0;  //Counter for clock divider
//   logic [21:0] clkdivcount_n = 0;

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
//       if (clkdivcount > 22'd3000000) begin
//           hz2_n = ~hz2;
//           clkdivcount_n = ~clkdivcount;
//       end else begin
//           hz2_n = hz2;
//           clkdivcount_n = clkdivcount + 1;
//       end
//   end

//   // GPIOs
//   // Don't forget to assign these to the ports above as needed
//   logic [33:0] gpio_in, gpio_out, gpio_oeb;
  
//   // logic [31:0] ADR_O, ADR_I, DAT_O, DAT_I;
//   // logic [3:0] SEL_O, SEL_I;
//   // logic WE_O, STB_O, CYC_O, ACK_I, BUSY_O, WRITE_I, READ_I;

//   // assign gpio_in[1:0] = pb[1:0]; // {SDA Line (Input), Interrupt}
//   // assign right = gpio_out[10:3];  // SPI Outputs
//   // assign left[5:0] = {gpio_out[14:11], gpio_out[2:1]};  // {spi_dcx, spi_csx, spi_rdx, spi_wrx, SCL line, SDA line (output)}
  

//   // assign right[0] = ~pb[3];
//   /*Inputs*/

//   assign gpio_in[1] = ~pb[2]; //SDA line input = pb[2]
//   assign gpio_in[0] = ~pb[1]; //Interrupt from touchscreen = pb[1]

//   /*Outputs*/

//   assign left[1] = gpio_out[2]; //I2C SCL = left[1]
//   assign left[0] = ~gpio_out[1]; //SDA line output = left[0] (inverted because using open-drain MOSFET)

//   /*Temporary I2C instantiation*/

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

//   // Team 08 Design Instance
//   // team_08 team_08_inst (
//   //   .clk(hz2),
//   //   .nrst(~reset), //Reset set to Z button
//   //   .en(1'b1),

//   //   .gpio_in(gpio_in),
//   //   .gpio_out(gpio_out),
//   //   .gpio_oeb()  // don't really need it here since it is an output

//   //   // Uncomment only if using LA
//   //   // .la_data_in(),
//   //   // .la_data_out(),
//   //   // .la_oenb(),

//     // Uncomment only if using WB Master Ports (i.e., CPU teams)
//     // You could also instantiate RAM in this module for testing
//     // .ADR_O(ADR_O),
//     // .DAT_O(DAT_O),
//     // .SEL_O(SEL_O),
//     // .WE_O(WE_O),
//     // .STB_O(STB_O),
//     // .CYC_O(CYC_O),
//     // .ACK_I(ACK_I),
//     // .DAT_I(DAT_I),

//     // Add other I/O connections to WB bus here

//   // );

//   //   t08_top top(
//   //     .clk(hwclk), .nRst(~reset), .en(1'b1),
//   //     .touchscreen_interrupt(gpio_in[0]), 
//   //     .SDAin(gpio_in[1]), .SDAout(gpio_out[1]), .SDAoeb(gpio_oeb[1]), 
//   //     .touchscreen_scl(gpio_out[2]),

//   //     .spi_outputs(gpio_out[3:10]), 
//   //     .spi_wrx(gpio_out[11]), .spi_rdx(gpio_out[12]), .spi_csx(gpio_out[13]), .spi_dcx(gpio_out[14])

//   //     // .wb_dat_i(DAT_I), .wb_ack_i(ACK_I), 
//   //     // .wb_adr_o(ADR_O), .wb_dat_o(DAT_O), .wb_sel_o(SEL_O), 
//   //     // .wb_we_o(WE_O), .wb_stb_o(STB_O), .wb_cyc_o(CYC_O),

//   //     // .wb_dat_o(DAT_O), .wb_busy_o(BUSY_O), 
//   //     // .wb_dat_i(DAT_I), .wb_adr_i(ADR_I), .wb_sel_i(SEL_I), 
//   //     // .wb_write_i(WRITE_I), .wb_read_i(READ_I)
//   // );

// endmodule

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

logic [31:0] controlBus, nextcontrolBus;
logic [31:0] xBus, nextxBus; //800-top 20 bits, 79 -lower 12bits
logic [31:0] yBus, nextyBus; //960 -top 20 bits, 89 lower 12 bits

// logic [31:0] xBus = 32'b1; //800-top 20 bits, 79 -lower 12bits
// logic [31:0] yBus = 32'b1; //960 -top 20 bits, 89 lower 12 bits
logic [22:0] ct, next_ct;
logic ack, dcx, wrx, csx, sig, rdx; 
logic [7:0] data;

assign rdx = 1;
assign left[4] = wrx; //F14
assign left[2:0] = {rdx, csx,dcx}; //P15, R2, R5 
assign red = hz2;
assign blue = sig;

assign {right[5],ss4[4],right[0], ss1[5], ss1[4], right[4], ss4[5] , ss4[1]} = data;

t08_display disptest (.controlBus(controlBus), .xBus(xBus), .yBus(yBus), .ct(ct), .clk(hz2), .rst(reset), .ack(ack), .dcx(dcx), .wrx(wrx), .csx(csx), .data(data));

always_ff @(posedge hz2, posedge reset) begin
    if (reset) begin
        ct <= 0;
        controlBus <= 32'b10000000;
        xBus <= 32'b1_00000000_00000010; //(2, 2)
        yBus <= 32'b1_00000000_00000010;

    end else begin
        ct <= next_ct;
        controlBus <= nextcontrolBus;
        xBus <= nextxBus;
        yBus <= nextyBus;
    end
end

always_comb begin
    next_ct = ct + 1;
    nextcontrolBus = controlBus;
    sig = 0;
    nextxBus = xBus;
    nextyBus = yBus;
    // xBus = 32'b11001_00000000_001001111; //800-top 20 bits, 79 -lower 12bits
    // yBus = 32'b1111000000_000001011001; //960 -top 20 bits, 89 lower 12 bits
    if (ct == 30 && controlBus == 32'b10000000) begin
        nextcontrolBus = 32'b100;
        next_ct = 0;
    end else if (ct == 37 && controlBus == 32'b100) begin
        nextcontrolBus = 32'b10000;
        next_ct = 0;
        nextxBus = 32'b1; 
        nextyBus = 32'b1; 
    end else if (ct == 37 && controlBus == 32'b10000) begin
        next_ct = 0;
    end
    if (controlBus == 32'b100) begin
        sig = 1;
    end else begin
        sig = 0;
    end
end

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

logic hz2, hz2_n;
logic [21:0] clkdivcount, clkdivcount_n;

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

  


endmodule


// // /////////////////////////////////////////////////////////////////////////////////////////
// // /*MANUAL Clock*/
// // /////////////////////////////////////////////////////

// // // logic hz2=0, hz2_n = 0;
// // // logic [21:0] clkdivcount = 0, clkdivcount_n;

// // // logic [5:0] count;

// // //   always_ff @ (posedge hwclk, posedge reset) begin : clock_divider_ff
// // //       if (reset) begin
// // //         hz2 <= 0;
// // //         clkdivcount <= 0;
// // //       end else begin
// // //         hz2 <= hz2_n;
// // //         clkdivcount <= clkdivcount_n;
// // //       end
// // //   end

// // //   always_comb begin : clock_divider
// // //       if (clkdivcount > 22'd300000) begin
// // //           hz2_n = ~hz2;
// // //           clkdivcount_n = 0;
// // //       end else begin
// // //           hz2_n = hz2;
// // //           clkdivcount_n = clkdivcount + 1;
// // //       end
// // //   end

































// // // module top (
// // //   // I/O ports
// // //   input  logic hwclk, reset,
// // //   input  logic [20:0] pb,
// // //   output logic [7:0] left, right,
// // //          ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
// // //   output logic red, green, blue,

// // //   // UART ports
// // //   output logic [7:0] txdata,
// // //   input  logic [7:0] rxdata,
// // //   output logic txclk, rxclk,
// // //   input  logic txready, rxready
// // // );
// // // logic clock;
// // // logic [31:0] controlBus;
// // // logic [31:0] xBus = 32'b1100100000_000001001111; //800-top 20 bits, 79 -lower 12bits
// // // logic [31:0] yBus = 32'b1111000000_000001011001; //960 -top 20 bits, 89 lower 12 bits
// // // logic [22:0] ct;
// // // logic ack, dcx, wrx, csx;
// // // logic [7:0] data;

// // // assign left[3:0] = {wrx, rdx, csx,dcx};
// // // assign red = hwclk;
// // // assign clock = Q1;

// // // assign {right[5],ss4[4],right[0], ss1[5], ss1[4], right[4], ss4[5] , ss4[1]} = data;
// // // logic hz2, hz2_n;
// // // logic clkdivcount, clkdivcount_n;

// // // t08_display disptest (.controlBus(controlBus), .xBus(xBus), .yBus(yBus), .ct(ct), .clk(clock), .rst(reset), .ack(ack), .dcx(dcx), .wrx(wrx), .csx(csx), .data(data));

// // // always_ff @(posedge clock, posedge reset) begin
// // //     if (reset) begin
// // //         ct <= 0;
// // //         controlBus <= 32'b10000000;
// // //     end else begin
// // //         ct <= next_ct;
// // //         controlBus <= nextcontrolBus;
// // //     end
// // // end

// // // always_comb begin
// // //     next_ct = ct + 1;
// // //     nextcontrolBus = controlBus;
// // //     if (ct == 30 && controlBus == 32'b10000000) begin
// // //         nextcontrolBus = 32'b10;
// // //         next_ct = 0;
// // //     end else if (ct == 36 && controlBus == 32'b10) begin
// // //         next_ct = 0;
// // //     end
// // // end

// // // // logic Q0, Q1;

// // // always_ff@(posedge hwclk, posedge reset) begin
// // //   if(reset) begin
// // //     Q0 <= 0;
// // //     Q1<= 0;
// // //   end
// // //   else begin
// // //    Q0  <= pb[0];
// // //    Q1 <= Q0&~pb[0]; //~~pb19
// // //   end 
// // // end

// // //   always_ff @ (posedge hwclk, posedge reset) begin 
// // //       if (reset) begin
// // //         hz2 <= 0;
// // //         clkdivcount <= 0;
// // //       end else begin
// // //         hz2 <= hz2_n;
// // //         clkdivcount <= clkdivcount_n;
// // //       end
// // //   end

// // //   always_comb begin 
// // //       if (clkdivcount > 1) begin
// // //           hz2_n = ~hz2;
// // //           clkdivcount_n = 0;
// // //       end else begin
// // //           hz2_n = hz2;
// // //           clkdivcount_n = clkdivcount + 1;
// // //       end
// // //   end


// // // endmodule



// // // // logic hz2=0, hz2_n = 0;
// // // // logic [21:0] clkdivcount = 0, clkdivcount_n;

// // // // logic [5:0] count;

// // // //   always_ff @ (posedge hwclk, posedge reset) begin : clock_divider_ff
// // // //       if (reset) begin
// // // //         hz2 <= 0;
// // // //         clkdivcount <= 0;
// // // //       end else begin
// // // //         hz2 <= hz2_n;
// // // //         clkdivcount <= clkdivcount_n;
// // // //       end
// // // //   end

// // // //   always_comb begin : clock_divider
// // // //       if (clkdivcount > 22'd300000) begin
// // // //           hz2_n = ~hz2;
// // // //           clkdivcount_n = 0;
// // // //       end else begin
// // // //           hz2_n = hz2;
// // // //           clkdivcount_n = clkdivcount + 1;
// // // //       end
// // // //   end

// // // // logic Q0, Q1;