`timescale 1ns/1ns

module t08_spi_tb;
logic [7:0]  outputs;
logic enable_command,enable_parameter,  wrx,rdx,csx,dcx,  busy;
logic [31:0] inputs;
logic clk = 0, readwrite = 1, nrst = 1; 
task tfr;
   nrst = 0; #1;
   nrst = 1; #1;
endtask
    
always #1 clk = ~clk;


t08_spi spi(.busy(busy), .inputs(inputs),.enable_command(enable_command), .enable_parameter(enable_parameter), .clk(clk), .nrst(nrst), .readwrite(readwrite), .outputs(outputs), .wrx(wrx), .rdx(rdx), .csx(csx), .dcx(dcx));


initial begin
    $dumpfile("t08_spi.vcd"); 
    $dumpvars(0, t08_spi_tb);
    
    tfr; 
    inputs = {{16{1'b0}}, 8'b00000100, {8{1'b1}}}; 
    enable_command = 1; #2;
    enable_command = 0; #1;
    inputs  = 32'b10101010_00001111_11110000_00110011;
    enable_parameter = 1; #2;
    enable_parameter = 0;#1;

    #30;
    readwrite = 1;
    inputs = {{24{1'b0}},{8'b00101011}}; 
    enable_command = 1; #2;
    enable_command = 0; #1;
    inputs  = 32'b00001111_10101010_00110011_11110000;
    enable_parameter = 1; #2;
    enable_parameter = 0;#1;

    #30;

    readwrite = 0;
    inputs = {{24{1'b0}},{8'b00101001}};
    enable_command = 1; #2;
    enable_command = 0; #1;
    inputs = 32'b1111_0000_1010_0000_1111_0101_1111_1111;
    enable_parameter = 1; #2;
    enable_parameter = 0;#1;
    #30;

  
    #10;

    readwrite = 0;
    inputs = {{24{1'b0}},{8'b00101110}};
    enable_command = 1; #2;
    enable_command = 0; #1;
    inputs = 32'b1111_0000_1010_0000_1111_0101_1111_1111;
    enable_parameter = 1; #2;
    enable_parameter = 0;#1;
    #20;

    inputs = 32'h0001;
    enable_command = 1; #2;
    enable_command = 0; #1;
    inputs = 32'b1111_0000_1010_0000_1111_0101_1111_1111;
    enable_parameter = 1; #2;
    enable_parameter = 0;#1;
    #(2 * 5000000);

    // enable = 1;
    // #40;





    #5; $finish;
    end
endmodule
// outputs only on rising edge so its ok, but the actual output bus is outputting extra paarameter
//problems: need to send command only one time, when send continiously needs to ignore?
//turn registers to all0s at busy 0.
//doen . enable off: csx??? percount, count, busy. wtf.
