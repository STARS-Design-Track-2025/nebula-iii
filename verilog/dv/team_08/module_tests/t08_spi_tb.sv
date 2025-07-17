module t08_spi_tb;
logic [7:0] command, outputs;
logic enable,  nrst = 1, wrx,rdx,csx,dcx,  busy;
logic [31:0] parameters;
logic clk = 0, readwrite = 1;
logic [3:0] counter = 4;
task tfr;
   nrst = 0; #1;
   nrst = 1; #1;
endtask
    
always #1 clk = ~clk;


t08_spi spi(.busy(busy), .command(command), .enable(enable), .clk(clk), .nrst(nrst), .readwrite(readwrite), .outputs(outputs), .wrx(wrx), .rdx(rdx), .csx(csx), .dcx(dcx), .counter(counter), .parameters(parameters));


initial begin
    $dumpfile("t08_spi.vcd"); 
    $dumpvars(0, t08_spi_tb);
    
    tfr; 
    command = {8{1'b1}}; 
    enable = 1;
    parameters  = 32'b10101010_00001111_11110000_00110011;

    #15;
    readwrite = 1;
    command = {8'b00101011}; 
    parameters  = 32'b00001111_10101010_00110011_11110000;
    #30;

    readwrite = 0;
    command = 8'b00101001;
    parameters = 32'b1111_0000_1010_0000_1111_0101_1111_1111;
    #30;

    enable= 0;
    #10

    readwrite = 0;
    command = 8'b00101110;
    parameters = 32'b1111_0000_1010_0000_1111_0101_1111_1111;
    #20;

    enable = 1;
    #40;





    #5; $finish;
    end
endmodule
// outputs only on rising edge so its ok, but the actual output bus is outputting extra paarameter
//problems: need to send command only one time, when send continiously needs to ignore?
//turn registers to all0s at busy 0.
//doen . enable off: csx??? percount, count, busy. wtf.
