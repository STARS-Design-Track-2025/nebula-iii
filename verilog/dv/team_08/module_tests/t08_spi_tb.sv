module t08_spi_tb;
logic [7:0] command, outputs;
logic enable,  nrst, wrx,rdx,csx,dcx,  busy;
logic [31:0] parameters;
logic clk = 0, readwrite = 0;
logic [3:0] counter = 4;
task tfr;
   nrst = 1; #1;
   nrst = 0; #1;
endtask
    
always #1 clk = ~clk;


t08_spi spi(.busy(busy), .command(command), .enable(enable), .clk(clk), .nrst(nrst), .readwrite(readwrite), .outputs(outputs), .wrx(wrx), .rdx(rdx), .csx(csx), .dcx(dcx), .counter(counter), .parameters(parameters));


initial begin
    $dumpfile("waves/t08_spi.vcd"); 
    $dumpvars(0, t08_spi_tb);
    
    tfr; #1;
    command = {8{1'b1}}; 
    enable = 1;
    parameters  = 32'b10101010000011111111000000110011;
;
    #10;
    readwrite = 1;
    command = {8'b00101011}; 
    #10;






    #5; $finish;
    end
endmodule
