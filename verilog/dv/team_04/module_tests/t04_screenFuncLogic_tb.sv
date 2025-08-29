`timescale 1ns/1ps

module tb;
  // Parameters
  parameter CLK_PERIOD = 10; // Clock period in ns
  parameter SIM_TIME = 500000; // Simulation time in ns

  // Signals
  logic [31:0] controlBus, xBus, yBus;
  logic [22:0] ct;
  logic clk, rst;
  logic ack, dcx, wrx, csx;
  logic [7:0] data;

  // Instantiate the DUT (Device Under Test)
  screensignalLogic dut (
    .controlBus(controlBus),
    .xBus(xBus),
    .yBus(yBus),
    .ct(ct),
    .clk(clk),
    .rst(rst),
    .ack(ack),
    .dcx(dcx),
    .wrx(wrx),
    .csx(csx),
    .data(data)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end

  // Counter increment
  always @(posedge clk) begin
    if (rst)
      ct <= 0;
    else
      ct <= ct + 1;
  end

  // Test stimulus
  initial begin
    // Initialize signals
    controlBus = 0;
    xBus = 0;
    yBus = 0;
    rst = 1;
    ct = 0;

    // Create VCD file for waveform analysis
    $dumpfile("waves/t04_screenFuncLogic.vcd");
    $dumpvars(0, tb);
    
    // Reset sequence
    #20 rst = 0;
    
    // Test case 1: clear screen (control = 9'b100000000)
    #10 controlBus = 32'b100000000;
    xBus = 32'h0;
    yBus = 32'h0;
    
    // Monitor outputs for specific counter values in clear operation
    wait(ct == 5);
    $display("Time=%0t, ct=%0d, ack=%b, dcx=%b, wrx=%b, csx=%b, data=%h", 
             $time, ct, ack, dcx, wrx, csx, data);
    
    wait(ct == 10);
    $display("Time=%0t, ct=%0d, ack=%b, dcx=%b, wrx=%b, csx=%b, data=%h", 
             $time, ct, ack, dcx, wrx, csx, data);

    wait(ct == 20);
    $display("Time=%0t, ct=%0d, ack=%b, dcx=%b, wrx=%b, csx=%b, data=%h", 
             $time, ct, ack, dcx, wrx, csx, data);
    
    // Test case 2: reseton (control = 9'b10000000)
    wait(ct == 100);
    controlBus = 32'b10000000;
    
    wait(ct == 105);
    $display("Time=%0t, ct=%0d, ack=%b, dcx=%b, wrx=%b, csx=%b, data=%h", 
             $time, ct, ack, dcx, wrx, csx, data);
    
    // Test case 3: caset (control = 9'b1000)
    wait(ct == 200);
    controlBus = 32'b1000;
    xBus = 32'h00010000; // Set some X coordinates
    yBus = 32'h00200030; // Set some Y coordinates
    
    wait(ct == 205);
    $display("Time=%0t, ct=%0d, ack=%b, dcx=%b, wrx=%b, csx=%b, data=%h", 
             $time, ct, ack, dcx, wrx, csx, data);

    // Test case 4: paset (control = 9'b10)
    wait(ct == 300);
    controlBus = 32'b10;
    xBus = 32'h00400050; // Set some X coordinates
    yBus = 32'h00600070; // Set some Y coordinates
    
    wait(ct == 305);
    $display("Time=%0t, ct=%0d, ack=%b, dcx=%b, wrx=%b, csx=%b, data=%h", 
             $time, ct, ack, dcx, wrx, csx, data);

    // Test case 5: display on (control = 9'b1000000)
    wait(ct == 400);
    controlBus = 32'b1000000;
    
    wait(ct == 405);
    $display("Time=%0t, ct=%0d, ack=%b, dcx=%b, wrx=%b, csx=%b, data=%h", 
             $time, ct, ack, dcx, wrx, csx, data);
    
    // Test case 6: display off (control = 9'b100000)
    wait(ct == 450);
    controlBus = 32'b100000;
    
    wait(ct == 455);
    $display("Time=%0t, ct=%0d, ack=%b, dcx=%b, wrx=%b, csx=%b, data=%h", 
             $time, ct, ack, dcx, wrx, csx, data);
    
    // Run for a while to see behavior after display off command
    wait(ct == 500);
    $display("Time=%0t, ct=%0d, ack=%b, dcx=%b, wrx=%b, csx=%b, data=%h", 
             $time, ct, ack, dcx, wrx, csx, data);
    
    // Check for ack during display off sequence
    wait(ct == 800005);
    $display("Time=%0t, ct=%0d, ack=%b, dcx=%b, wrx=%b, csx=%b, data=%h - ack should be high", 
             $time, ct, ack, dcx, wrx, csx, data);

    // End test cases - removed color test as requested

    // End simulation
    #SIM_TIME $display("Simulation finished at time %0t", $time);
    $finish;
  end
  
  // // Monitor for changes
  // always @(posedge clk) begin
  //   if (ack) begin
  //     $display("ACK asserted at time %0t, ct=%0d", $time, ct);
  //   end
  // end
  
  // // Verify expected outputs for specific counter values
  // // We'll check that the outputs match expected values based on the module logic
  // // For example, for clear operation:
  // always @(posedge clk) begin
  //   if (controlBus == 32'b100000000) begin // Clear operation
  //     case (ct)
  //       1: if (csx != 0)
  //            $display("Error at ct=%0d: csx expected 0, got %b", ct, csx);
        
  //       2: if (dcx != 0 || wrx != 0 || data != 8'h2A) // xCommand
  //            $display("Error at ct=%0d: expected dcx=0,wrx=0,data=2A, got dcx=%b,wrx=%b,data=%h", 
  //                     ct, dcx, wrx, data);
        
  //       3: if (wrx != 1)
  //            $display("Error at ct=%0d: wrx expected 1, got %b", ct, wrx);
        
  //       4: if (dcx != 1 || wrx != 0)
  //            $display("Error at ct=%0d: expected dcx=1,wrx=0, got dcx=%b,wrx=%b", ct, dcx, wrx);
  //     endcase
  //   end
  // end

endmodule
