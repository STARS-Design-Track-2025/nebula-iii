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
  logic [4:0] count, count_n;
  logic [15:0] in;
  logic delay;

  always_ff @(posedge hwclk, posedge reset) begin //
    if (reset) begin
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
    if (count < 5'd18) begin //clock divider
      count_n = count + 1;
    end else begin
      count_n = '0;
      newclk_n = !newclk;
    end
  end

  t07_display tft (.clk(newclk), .nrst(~reset), .out(in), .delay(delay));
  t07_spitft spitft (.clk(newclk), .nrst(~reset), .in(in), .wi(wi), .delay(delay), .ack(right[7]), .bitData(right[1]), .chipSelect(right[3]), .sclk(right[2]));
  
  // assign wi = 1'b1;  

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

<<<<<<< HEAD
  assign clk = hwclk;
  assign nrst = pb[19];
  assign ESP_in = pb[3:0];
  assign ChipSelectIn = pb[4];
  assign rwi_in = 2'b10;
  assign addr_in = 32'd1025;

  // Inputs
  logic clk;
  logic nrst;
  logic [4:0] ReadRegister;
  logic [31:0] write_data;
  logic ri;
  logic [4:0] SPIAddress; // Address for the SPI TFT
  logic busy;
  // Outputs
  logic [31:0] read_data;
  logic ack_REG; // Acknowledge signal to the memory handler
  logic [1:0] rwi_in; // Read/Write/Idle signal from the memory handler
  logic [31:0] ExtData_out; // Data to internal memory
  logic [31:0] addr_in; // Address for the external register
  logic [31:0] inst; // Instruction to fetch module in CPU
  logic [31:0] writeData_outTFT; // Data to write to instruction/Data memory
  logic [31:0] addr_outTFT; // Address to write to SPI TFT
  logic wi_out; // Write or idle to SPI TFT
  logic read, write; // Read/Write/Idle to instruction/Data memory
  logic [31:0] addr_out; // Address to instruction/Data memory
  logic [31:0] writeData_out; // Data to write to instruction/Data memory
  logic fetchRead_out, addrControl_out, fetchRead_in, addrControl_in;
  t07_MMIO mmio (
      .memData_in(32'b0), // Not used in this test
      .rwi_in(rwi_in), // Not used in this test
      .ExtData_in(32'b0), // Not used in this test
      .busy_o(1'b0), // Not used in this test
      .fetchRead_in(fetchRead_in),
      .addrControl_in(addrControl_in),
      .regData_in(read_data),
      .ack_REG(ack_REG),
      .ack_TFT(1'b0), // Not used in this test
      .addr_in(addr_in), //address for the external register
      .ri_out(ri),
      .addr_outREG(ReadRegister), // Address to external register
      .ExtData_out(ExtData_out),
      .busy(busy), 
      .writeInstruction_out(inst), // Not used in this test
      .writeData_outTFT(writeData_outTFT), // Not used in this test
      .addr_outTFT(addr_outTFT), // Not used in this test
      .wi_out(wi_out), // Not used in this test
      .read(read), // Not used in this test
      .write(write),
      .addr_out(addr_out), // Not used in this test
      .fetchRead_out(fetchRead_out),
      .addrControl_out(addrControl_out),
      .writeData_out(writeData_out) // Not used in this test
  );
  // Instantiate the Unit Under Test (UUT)
  t07_ExternalRegister uut (
      .clk(clk),
      .nrst(nrst),
      .ReadRegister(ReadRegister),
      .SPIAddress(SPIAddress),
      .write_data(write_data),
      .ri(ri),
      .read_data(read_data),
      .ack_REG(ack_REG)
  );

  logic [3:0] ESP_in; // Input from the ESP32
  logic SCLK_out; // Clock signal for the ESP32
  logic ChipSelectIn;
  logic dataForExtReg;
  
  t07_SPI_ESP32 spi (
      .dataForExtReg(dataForExtReg),
      .ESP_in(ESP_in), 
      .clk(clk),
      .ChipSelectIn(ChipSelectIn),
      .nrst(nrst),
      .SPI_Address(SPIAddress),
      .dataForExtReg(write_data),
      .SCLK_out(SCLK_out) // Not used in this test
  );

=======
>>>>>>> 1547289101454f7c499da60d41d66a006666ece7
endmodule
