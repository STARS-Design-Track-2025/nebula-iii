`timescale 1ms / 1ps
module t07_top_tb();
    logic clk, nrst;
    logic [7:0] ESP_in;
    logic FPUFlag, invalError, chipSelectTFT, bitDataTFT, sclkTFT;

    t07_top top0(.clk(clk), .nrst(nrst), .FPUFlag(FPUFlag), .invalError(invalError), .ESP_in(ESP_in), .chipSelectTFT(chipSelectTFT), .bitDataTFT(bitDataTFT), .sclkTFT(sclkTFT));

    task reset(); begin
        #2
        nrst = ~nrst;        
        #2
        nrst = ~nrst;
    end
    endtask

    always begin
        #2
        clk = ~clk;
    end

    initial begin
        $dumpfile("t07_top.vcd");
        $dumpvars(0, t07_top_tb);
        clk = 0;
        nrst = 1;
        ESP_in = '0;
        reset();

        #500
        $finish;
    end

endmodule