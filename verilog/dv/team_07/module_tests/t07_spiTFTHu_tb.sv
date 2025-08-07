// spi to tft testbench

`timescale 1ms / 10ns

module t07_spiTFTHu_tb;

//inputs
logic [15:0] in;
logic clk, nrst;
logic wi;
logic delay;
logic miso_in;

//outputs
logic ack;
logic bitData;
logic sclk;
logic chipSelect;
logic [7:0] miso_out;

//instantiate the tft
t07_spiTFTHu ex (
    .clk(clk),
    .bitData(bitData),
    .MOSI_data(in),
    .nrst(nrst),
    .write_in(wi),
    .MISO_in(miso_in),
    .MISO_out(miso_out),
    .chipSelect(chipSelect),
    .sclk(sclk),
    .ack(ack)
);

always begin 
        clk = 0;
        #5; // Wait for 10 time units
        clk = 1;
        #5; // Wait for 10 time units
    end


initial begin

    $dumpfile("t07_spiTFTHu.vcd");
    $dumpvars(0, t07_spiTFTHu_tb);

    // clk = 0;
    // nrst = 0;
    // wi = 0;
    // #40;
    delay = 1'b0;

    #5
    nrst = 1;  // Deassert reset
    #5;
    nrst = 0;
    #5;
    nrst = 1;

    wi = 1;    // Now trigger transfer
    //expected = 32'hAAAA5555;
    in = 16'h801D;
    miso_in = 1;
    #400;
    // delay = 1'b1;
    // miso_in = 1;
    #50;
    //miso_in = 1;
    // delay = 1'b0;
    in = 16'h4000;
    #20;
    miso_in = 1;
    #10;
    miso_in = 1;
    #10;
    miso_in = 1;
    #10;
    miso_in = 1;
    #10;
    miso_in = 1;
    #10;
    miso_in = 1;
    #10;
    miso_in = 1;
    #10;
    miso_in = 1;
    #10;
    miso_in = 1;
    #10;
    miso_in = 0;
    #10;
    miso_in = 1;
    #10;
    miso_in = 1;
    #10;
    miso_in = 0;
    #10;
    miso_in = 0;
    #10;
    miso_in = 0;
    #10;
    miso_in = 0;
    #40;
    // delay = 1'b1;
    #100;
    // delay = 1'b0;

    $finish;
end


    

endmodule