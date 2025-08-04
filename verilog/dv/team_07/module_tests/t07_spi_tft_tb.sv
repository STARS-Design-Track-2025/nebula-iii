// spi to tft testbench

`timescale 1ns / 1ps

module t07_spi_tft_tb;

//inputs
logic [31:0] data;
logic [31:0] address;
logic clk, nrst;
logic wi;
//outputs
logic ack;
logic bitData;
logic sclk;
logic chipSelect;
logic [15:0] expected;

//instantiate the tft
t07_spi_tft ex (
    .clk(clk),
    .bitData(bitData),
    .data(data),
    .address(address),
    .nrst(nrst),
    .wi(wi),
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

    $dumpfile("t07_spi_tft.vcd");
    $dumpvars(0, t07_spi_tft_tb);

    clk = 0;
    nrst = 0;
    wi = 0;
    #40;

    nrst = 1;  // Deassert reset
    #20;

    wi = 1;    // Now trigger transfer
    expected = 32'hAAAA5555;
    address = 32'b10100101001001010011101;
    data    = 32'b01111100010001001000100;
    #1000;
    #1000;

    $finish;
end


    

endmodule