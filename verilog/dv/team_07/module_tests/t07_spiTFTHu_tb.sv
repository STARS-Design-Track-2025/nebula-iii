// spi to tft testbench

`timescale 1ms / 10ns

module t07_spiTFTHu_tb;

//inputs
logic [31:0] in;
logic clk, nrst;
logic wi;
logic miso_in;

//outputs
logic ack;
logic bitData;
logic sclk;
logic chipSelect;
logic [31:0] miso_out;
// logic delay;

//instantiate the tft
  t07_spiTFTHu spitft (.clk(clk), .nrst(nrst), .MOSI_data(in), .read_in(1'b0), .write_in(wi), .MISO_out(miso_out), .ack(ack), .bitData(bitData), .chipSelect(chipSelect), .sclk(sclk), .MISO_in(miso_in)); 


always begin 
        clk = 0;
        #5; // Wait for 10 time units
        clk = 1;
        #5; // Wait for 10 time units
    end


initial begin

    $dumpfile("t07_spiTFTHu.vcd");
    $dumpvars(0, t07_spiTFTHu_tb);

    clk = 0;
    // nrst = 0;
    // wi = 0;
    // #40;

    #5
    nrst = 1;  // Deassert reset
    #5;
    nrst = 0;
    #5;
    nrst = 1;

    wi = 1;    // Now trigger transfer
    //expected = 32'hAAAA5555;

    in = {16'd40,16'h801D};
    miso_in = 1;
    
    #200
    in = {16'b0,16'h4000};
    #450;
    miso_in = 1;
    @(posedge sclk); 
    miso_in = 1;
    @(posedge sclk); ;
    miso_in = 1;
    @(posedge sclk); ;
    miso_in = 1;
    @(posedge sclk); ;
    miso_in = 1;
    @(posedge sclk); ;
    miso_in = 1;
    @(posedge sclk); ;
    miso_in = 1;
    @(posedge sclk); ;
    miso_in = 1;
    @(posedge sclk); ;
    miso_in = 1;
    @(posedge sclk); ;
    miso_in = 0;
    @(posedge sclk); ;
    miso_in = 1;
    @(posedge sclk); ;
    miso_in = 1;
    @(posedge sclk); ;
    miso_in = 0;
    @(posedge sclk); ;
    miso_in = 0;
    @(posedge sclk); ;
    miso_in = 0;
    @(posedge sclk); ;
    miso_in = 0;
    #40;

    $finish;
end


    

endmodule