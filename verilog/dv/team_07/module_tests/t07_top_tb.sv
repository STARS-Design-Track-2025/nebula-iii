`timescale 1ms / 1ps
module t07_top_tb();
    logic clk, nrst;
    logic [6:0] FPUFlag;
    logic invalError, chipSelectTFT, bitDataTFT, sclkTFT, misoDriver_i, FPUoverflow, FPUcarryout, ackSPI;

    logic [31:0] dataArToWM, ackToWM;

    logic [31:0] dataWMToAr, addrWMToAr;
    logic [3:0] selToAr;
    logic weToAr, stbToAr, cycToAr;

    t07_top top0(.clk(clk), .nrst(nrst), .invalError(invalError), .chipSelectTFT(chipSelectTFT), .bitDataTFT(bitDataTFT), .sclkTFT(sclkTFT), .misoDriver_i(misoDriver_i),
        .busyTFT_o(ackSPI), .dataArToWM(dataArToWM), .ackToWM(ackToWM), .dataWMToAr(dataWMToAr), .addrWMToAr(addrWMToAr),
        .selToAr(selToAr), .weToAr(weToAr), .stbToAr(stbToAr), .cycToAr(cycToAr));

    // SRAM Wrapper
    sram_WB_Wrapper sramWrapper(.wb_clk_i(clk), .wb_rst_i(~nrst), .wbs_stb_i(stbToAr), .wbs_cyc_i(cycToAr), .wbs_we_i(weToAr), .wbs_sel_i(selToAr),
    .wbs_dat_i(dataWMToAr), .wbs_adr_i(addrWMToAr), .wbs_ack_o(ackToWM), .wbs_dat_o(dataArToWM));

    task reset(); begin
        #10
        nrst = ~nrst;        
        #10
        nrst = ~nrst;
    end
    endtask

    always begin
        #10;
        clk = ~clk;
    end

    initial begin
        $dumpfile("t07_top.vcd");
        $dumpvars(0, t07_top_tb);
        clk = 0;
        nrst = 1;
        misoDriver_i = 1;
        reset();
        #500000
        $finish;
    end

endmodule