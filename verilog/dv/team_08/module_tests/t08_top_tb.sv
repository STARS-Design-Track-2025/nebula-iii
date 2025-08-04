`timescale 1ns/10ps

module t08_top_tb;

    logic clk, nRst;
    logic touchscreen_interrupt;

    always begin
        clk = 0;
        #10;
        clk = 1;
        #10;
    end

    logic [31:0] wb_dat_i;                     
    logic wb_ack_i;
    logic [31:0] wb_adr_o;
    logic [31:0] wb_dat_o;
    logic [3:0] wb_sel_o;
    logic wb_we_o, wb_stb_o, wb_cyc_o;

    t08_top top(
        .clk(clk), .nRst(nRst), .en(1'b1),

        .touchscreen_interrupt(touchscreen_interrupt), 
        .I2C_sda_in(1'b1), .I2C_sda_out(), .I2C_sda_oeb(),
        .I2C_scl_out(), .I2C_scl_in(1'b1),

        .spi_outputs(), 
        .spi_wrx(), .spi_rdx(), .spi_csx(), .spi_dcx(),

        .wb_dat_o(wb_dat_o), .wb_dat_i(wb_dat_i), .wb_adr_o(wb_adr_o), 
        .wb_sel_o(wb_sel_o), .wb_ack_i(wb_ack_i),
        .wb_we_o(wb_we_o), .wb_stb_o(wb_stb_o), .wb_cyc_o(wb_cyc_o) 
    );

    sram_WB_Wrapper sram_wb_w(
        .wb_clk_i(clk), .wb_rst_i(!nRst), 
        .wbs_stb_i(wb_stb_o), .wbs_cyc_i(wb_cyc_o), .wbs_we_i(wb_we_o), 
        .wbs_sel_i(wb_sel_o), .wbs_dat_i(wb_dat_o), .wbs_adr_i(wb_adr_o), 
        .wbs_ack_o(wb_ack_i), .wbs_dat_o(wb_dat_i)
);


    initial begin

        $dumpfile("t08_top.vcd");
        $dumpvars(0, t08_top_tb);

        touchscreen_interrupt = 1;

        nRst = 1;
        #(0.1);

        nRst = 0; #5;
        @(negedge clk);
        nRst = 1;
        //data_in = 0;

        repeat (10000) @ (negedge clk);

        touchscreen_interrupt = 0; #4; @(negedge clk); touchscreen_interrupt = 1;

        #20000000

        //  nRst = 1;
        // #(0.1);

        // nRst = 0; #10;
        // @(negedge clk);
        // nRst = 1;


        // repeat (200) @ (negedge clk);

        //         nRst = 1;
        // #(0.1);

        // nRst = 0; #10;
        // @(negedge clk);
        // nRst = 1;


        // repeat (200) @ (negedge clk);


        //         nRst = 1;
        // #(0.1);

        // nRst = 0; #10;
        // @(negedge clk);
        // nRst = 1;


        // repeat (200) @ (negedge clk);
        // nRst = 0; #4;
        // @(negedge clk);
        // nRst = 1;

    //     // repeat (200) @ (negedge clk);
    //     nRst = 1;
    //     #(0.1);

    //     nRst = 0; #4;
    //     @(negedge clk);
    // nRst = 1;

      //  repeat (2000) @ (negedge clk);

        #1 $finish;

    end

endmodule