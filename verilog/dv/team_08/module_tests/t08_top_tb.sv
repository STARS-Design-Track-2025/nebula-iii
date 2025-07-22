`timescale 1ms/10ps

module t08_top_tb;

    logic clk, nRst;
    always begin
        clk = 0;
        #1;
        clk = 1;
        #1;
    end

    t08_top top(
        .clk(clk), .nRst(nRst), .en(1'b1),

        .touchscreen_interrupt(1'b0), 
        .SDAin(1'b0), .SDAout(), .SDAoeb(),
        .touchscreen_scl(),

        .spi_outputs(), 
        .spi_wrx(), .spi_rdx(), .spi_csx(), .spi_dcx()

        // .wb_dat_o(dat_o), .wb_busy_o(busy_o),
        // .wb_dat_i(dat_i), .wb_adr_o(adr_o), 
        // .wb_sel_o(sel_o), 
        // .wb_we_o(we_o), .wb_stb_o(stb_o), .wb_cyc_o(cyc_o) 
    );

    // wishbone_manager wm(
    //     .nRST(nRst), .CLK(clk),                                     //reset and clock

    //     .dat_i(), .ack_i(),                         //"input from wishbone interconnect"
                                                                  
    //     .CPU_DAT_I(dat_i), .ADR_I(ADR_I),               //"input from user design"
    //     .SEL_I(SEL_I),  
    //     .WRITE_I(WRITE_I), .READ_I(READ_I),    

    //     .adr_o(adr_o), .dat_o(dat_o), .sel_o(sel_o),       //"output to wishbone interconnect"
    //     .we_o(we_o), .stb_o(stb_o), .cyc_o(cyc_o),  

    //     .CPU_DAT_O(dat_o), .BUSY_O(busy_o)       //"output to user design"
    // );

    initial begin

        $dumpfile("t08_top.vcd");
        $dumpvars(0, t08_top_tb);

        nRst = 1;
        #(0.1);

        nRst = 0; #4;
        @(negedge clk);
        nRst = 1;
        //data_in = 0;

        repeat (200) @ (negedge clk);
        
        nRst = 0; #4;
        @(negedge clk);
        nRst = 1;

        repeat (200) @ (negedge clk);
        #1 $finish;

    end

endmodule