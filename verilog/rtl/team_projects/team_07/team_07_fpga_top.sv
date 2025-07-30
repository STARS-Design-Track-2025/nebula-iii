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
  logic [31:0] address, data;

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
    if (count < 5'd20) begin //set to 1 MHz for screen to work, min spi clk = 100kHz, max spi clk = (system clk / 3)
      count_n = count + 1;
    end else begin
      count_n = '0;
      newclk_n = !newclk;
    end
  end
  

  t07_spi_tft spitft (.clk(newclk), .nrst(~reset), .data(data), .address(address), .wi(wi), .ack(right[7]), .bitData(right[1]), .chipSelect(right[3]), .sclk(right[2]));
  
  assign wi = 1'b1;  

  assign data = 32'b01000000010000000100000001000000;
  assign address = 32'b00000000001011000000000110000000;
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
  //   address = 32'b0; data = 32'b0;
  //   case (state) 
  //     3'b000: begin address = 32'h90919293; next_state = 3'b001; end
  //     3'b001: begin data = 32'b10110000011001000000000000110010; next_state = 3'b010; end//90h, 91h, 92h, 93h
  //     3'b010: begin address = 32'h94959697; next_state = 3'b011; end
  //     3'b011: begin data = 32'b00000000001011000000000110000000; next_state = 3'b100; end// 94h, 95h, 96h, 97h //top left corner coordinate of rectangle, both x = 100 and y = 50
  //     3'b100: begin address = 32'h98909090; next_state = 3'b101; end
  //     3'b101: begin data = 32'b00000001000000000000000000000000 ; next_state = 3'b000; end//98h
  //     default: begin address = 32'b0; data = 32'b0; end
  //   endcase
  // end


  // assign address = 32'b01000000010000000100000001000000;
  // assign data = 32'b00000000100000100000000010000010;

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

endmodule
