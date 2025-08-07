`default_nettype none

// FPGA top module for Team 07

module top (
  // I/O ports
  input  logic hwclk, reset, //hwclk = 10 MHz
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
  logic [33:0] gpio_in, gpio_out;

  logic wi;
  logic newclk, newclk_n; 
  logic [22:0] count, count_n;
  logic [31:0] in;
  logic delay;

  logic invalError;
  logic [6:0] FPUFlag; 

  logic [31:0] dataArToWM, ackToWM, dataDecToAr;

  //for SRAM & wishbone
  logic [31:0] dataWMToAr, addrWMToAr;
  logic [3:0] selToAr;
  logic weToAr, stbToAr, cycToAr, ackToAr;
  logic cycToDec, stbToDec, weToDec;
  logic [31:0] addrToDec, dataToDec; 
  logic [3:0] selToDec;
  logic [6 + 3:0] cyc_out;
  logic [6 + 3:0] stb_out;
  logic [6 + 3:0] we_out;
  logic [(32 * (10)) - 1:0] addr_out; 
  logic [(32 * (10)) - 1:0] data_out;
  logic [(4 * (10)) - 1:0] sel_out;
  logic [6 + 3:0] ackDec_in; //acknowledge
  logic [(32 * (10)) - 1:0] dataDec_in; //data from SRAM to WB Dec


  always_ff @(posedge hwclk, negedge reset) begin //
    if (!reset) begin
      count <= '0;
      newclk <= '0;
    end else begin
      count <= count_n;
      newclk <= newclk_n;
    end
  end

  always_comb begin
    count_n = count;
    newclk_n = newclk;
    if (count < 23'd40) begin //clock divider to 200 kHz
      count_n = count + 1;
    end else begin
      count_n = '0;
      newclk_n = !newclk;
    end

  end

  assign left[4] = newclk; 
  assign left[5] = reset;

  t07_top top0(.clk(newclk), .nrst(reset), .invalError(invalError), .chipSelectTFT(right[3]), .bitDataTFT(right[1]), .sclkTFT(right[2]), .misoDriver_i(pb[4]),
  .dataArToWM(dataArToWM), .ackToWM(ackToWM), .dataWMToAr(dataWMToAr), .addrWMToAr(addrWMToAr), .selToAr(selToAr), .weToAr(weToAr), .stbToAr(stbToAr), .cycToAr(cycToAr), 
  .busyTFT_o(right[7]), .pc2(left[1]), .pc3(left[2]), .freezePC(left[3]), .busyToMMIO(left[6]));

  // t07_display tft (.clk(newclk), .nrst(reset), .out(in), .ack(left[3]));
  // t07_spiTFTHu spitft (.clk(newclk), .nrst(reset), .MOSI_data(in), .read_in(1'b0), .write_in(1'b1), .MISO_out(), .ack(right[7]), .bitData(right[1]), .chipSelect(right[3]), .sclk(right[2]), .MISO_in(pb[4])); 

  
  //spitft (.clk(newclk), .nrst(~reset), .in(in), .wi(wi), .miso_in(pb[4]), .miso_out(right[4]), .ack(right[7]), .bitData(right[1]), .chipSelect(right[3]), .sclk(right[2]));
  
  assign wi = 1'b1;  

  sram_WB_Wrapper sramWrapper(.wb_clk_i(newclk), .wb_rst_i(~reset), .wbs_stb_i(stbToAr), .wbs_cyc_i(cycToAr), .wbs_we_i(weToAr), .wbs_sel_i(selToAr),
  .wbs_dat_i(dataWMToAr), .wbs_adr_i(addrWMToAr), .wbs_ack_o(ackToWM), .wbs_dat_o(dataArToWM));

  // sram_WB_Wrapper sramWrapper(.wb_clk_i(newclk), .wb_rst_i(reset), .wbs_stb_i(stb_out), .wbs_cyc_i(cyc_out), .wbs_we_i(we_out), .wbs_sel_i(sel_out),
  // .wbs_dat_i(dataWMToAr), .wbs_adr_i(addrWMToAr), .wbs_ack_o(ackToWM), .wbs_dat_o(dataArToWM)); 
  // //fsm to draw
  // //states: 
  // logic [2:0] state, next_state;


  // always_ff @(posedge newclk, posedge reset) begin
  //   if (reset) begin
  //     state <= 3'b0;
  //   end else begin
  //     state <= next_state;
  //   end
  // end

  // always_comb begin
  //   next_state = state;
  //   state = 3'b000;
  //   in = 16'b0;
  //   case (state) 
  //     3'b000: begin in = 16'h80_00; next_state = 3'b001; end
  //     3'b001: begin in = 16'h40_00; next_state = 3'b010; end
  //     3'b010: begin in = 16'h80_88; next_state = 3'b011; end
  //     3'b011: begin in = 16'h00_0A; next_state = 3'b100; end
  //     3'b100: begin in = 16'h80_89; next_state = 3'b101; end
  //     3'b101: begin in = 16'h00_02; next_state = 3'b000; end
  //     3'b110: begin in = 16'h 
  //     default: begin address = 32'b0; data = 32'b0; end
  //   endcase
  // end


  // // assign address = 32'b01000000010000000100000001000000;
  // // assign data = 32'b00000000100000100000000010000010;

  // Team 07 Design Instance
  // team_07 team_07_inst (
  //   .clk(hwclk),
  //   .nrst(~reset),
  //   .en(1'b1),

  //   .gpio_in(gpio_in),
  //   .gpio_out(gpio_out),
  //   .gpio_oeb(),  // don't really need it here since it is an output

  //   // Uncomment only if using LA
  //   // .la_data_in(),
  //   // .la_data_out(),
  //   // .la_oenb(),

  //   // Uncomment only if using WB Master Ports (i.e., CPU teams)
  //   // You could also instantiate RAM in this module for testing
  //   // .ADR_O(ADR_O),
  //   // .DAT_O(DAT_O),
  //   // .SEL_O(SEL_O),
  //   // .WE_O(WE_O),
  //   // .STB_O(STB_O),
  //   // .CYC_O(CYC_O),
  //   // .ACK_I(ACK_I),
  //   // .DAT_I(DAT_I),

  //   // Add other I/O connections to WB bus here

  // );

  // assign clk = hwclk;
  // assign nrst = pb[19];
  // assign ESP_in = pb[3:0];
  // assign ChipSelectIn = pb[4];
  // assign rwi_in = 2'b10;
  // assign addr_in = 32'd1025;

endmodule