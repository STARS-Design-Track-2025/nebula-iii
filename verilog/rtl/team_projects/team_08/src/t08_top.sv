module t08_top();

    t08_CPU();
    
    logic [31:0] I2C_data_out;
    logic I2C_done;

    t08_I2C_and_interrupt I2C(
        .clk(clk), .nRst(nRst), //clock and reset
        .SDAin(), .SDAout(), .SDAoeb(), //SDA line
        .inter(), .scl(), //interrupt from touchscreen and SCL to touchscreen
        .data_out(I2C_data_out), .done(I2C_done) //outputs to mmio
    );

    t08_spi SPI(
        .command(), .parameters(), 
        .enable(), .clk(), .nrst(), 
        .readwrite(), 
        .counter(), 
        .outputs(), 
        .wrx(), .rdx(), .csx(), .dcx(), .busy()
    );

    t08_mmio mmio(
        .nRst(nRst), .clk(clk), //clock and reset
        .read(), .write(), .address(), .mh_data(), //from memory handler
        .xy(I2C_data_out), .done(I2C_done), //from I2C
        .spi_busy(), //from SPI
        .mem_data_i(), .mem_busy(), //from memory: data
        .mh_data_o(), .busy(), .done_o(), //to memory handler
        .parameters(), .command(), .readwrite(), .enable(), //to SPI
        .mem_data_o(), .mem_address(), .select(), .mem_write(), .mem_read() //to memory: data/wishbone
    );

    wishbone_manager wm(
        .nRST(nRst), .CLK(clk), //reset and clock
        .DAT_I(), .ACK_I(), //"input from wishbone interconnect"
        .CPU_DAT_I(), .ADR_I(), .SEL_I(), .WRITE_I(), .READ_I(), //"input from user design"
        .ADR_O(), .DAT_O(), .SEL_O(), .WE_O(), .STB_O(), .CYC_O(), //"output to wishbone interconnect"
        .CPU_DAT_O(), .BUSY_O() //"output to user design"
    );

endmodule