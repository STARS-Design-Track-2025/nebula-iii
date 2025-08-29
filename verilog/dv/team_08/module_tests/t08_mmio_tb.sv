`timescale 1ms/10ps
module t08_mmio_tb;

logic read;                       //command to read, source specified by address
logic write;                      //command to write, destination specified by address
logic getinst;
logic [31:0] address;             //location to read from or write to
logic [31:0] mh_data_i;           //data to write

logic [31:0] I2C_xy_i;
logic I2C_done_i;

logic spi_busy_i;

logic [31:0] mem_data_i;          //data read from memory
logic mem_busy_i;                 //whether memory is busy or not

logic [31:0] mh_data_o;          //data read
logic mmio_busy_o;               //whether mmio is busy or not
logic I2C_done_o;                //whether I2C data is ready to be read

logic [31:0] spi_parameters_o;   //
logic [7:0] spi_command_o;
logic [3:0] spi_counter_o;
logic spi_read_o;
logic spi_write_o;
logic spi_enable_o;

logic [31:0] mem_data_o;         //data to write to memory
logic [31:0] mem_address_o;      //address to put data
logic [3:0]  mem_select_o;       //hardwired to 1
logic        mem_write_o;        //tell memory to receive writing
logic        mem_read_o; 

t08_mmio mmio(.read(read), .write(write), .getinst(getinst), .address(address), 
              .mh_data_i(mh_data_i), .I2C_xy_i(I2C_xy_i), .I2C_done_i(I2C_done_i), 
              .spi_busy_i(spi_busy_i), .mem_data_i(mem_data_i), .mem_busy_i(mem_busy_i), 
              .mh_data_o(mh_data_o), .mmio_busy_o(mmio_busy_o), .I2C_done_o(I2C_done_o), 
              .spi_parameters_o(spi_parameters_o), .spi_command_o(spi_command_o), 
              .spi_counter_o(spi_counter_o), .spi_read_o(spi_read_o), .spi_write_o(spi_write_o), 
              .spi_enable_o(spi_enable_o), .mem_data_o(mem_data_o), .mem_address_o(mem_address_o), 
              .mem_select_o(mem_select_o), .mem_write_o(mem_write_o), .mem_read_o(mem_read_o));


initial begin
    $dumpfile("t08_mmio.vcd"); 
    $dumpvars(0, t08_mmio_tb);
  
    #2;

    //TEST 1: read from I2C, but mmio busy
    read = 1;
    write = 0;
    getinst = 0;
    address = 32'd923923;
    mh_data_i = 0;
    spi_busy_i = 1;
    mem_data_i = 32'h900d;
    mem_busy_i = 1;
    I2C_xy_i = 32'd32;
    I2C_done_i = 1;
    #4;
    //TEST 1: read from I2C, mmio not busy
    read = 1;
    write = 0;
    getinst = 0;
    address = 32'd923923;
    mh_data_i = 0;
    spi_busy_i = 0;
    mem_data_i = 32'h900d;
    mem_busy_i = 0;
    I2C_xy_i = 32'd32;
    I2C_done_i = 1;
    #4;
    //TEST 3: read from memory, but mmio busy
    read = 1;
    write = 0;
    getinst = 0;
    address = 32'd2000;
    mh_data_i = 0;
    spi_busy_i = 1;
    mem_data_i = 32'h900d;
    mem_busy_i = 1;
    I2C_xy_i = 32'd32;
    I2C_done_i = 1;
    #4;
    //TEST 4: read from memory, mmio not busy
    read = 0;
    write = 0;
    getinst = 1;
    address = 32'd2000;
    mh_data_i = 0;
    spi_busy_i = 0;
    mem_data_i = 32'h900d;
    mem_busy_i = 0;
    I2C_xy_i = 32'd32;
    I2C_done_i = 1;
    #4;
    //write to SPI: command and counter, but SPI is busy
    read = 0;
    write = 1;
    getinst = 0;
    address = 32'd121212;
    mh_data_i = {20'd0, 4'd4, 8'd30};
    spi_busy_i = 1;
    mem_data_i = 32'h900d;
    mem_busy_i = 1;
    I2C_xy_i = 32'd0;
    I2C_done_i = 0;
    #4;
    //write to SPI: command and counter, SPI not busy
    read = 0;
    write = 1;
    getinst = 0;
    address = 32'd121212;
    mh_data_i = {20'd0, 4'd4, 8'd30};
    spi_busy_i = 0;
    mem_data_i = 32'h900d;
    mem_busy_i = 1;
    I2C_xy_i = 32'd0;
    I2C_done_i = 0;
    #4;

    //write to SPI: parameters, but SPI is busy
    read = 0;
    write = 1;
    getinst = 0;
    address = 32'd333333;
    mh_data_i = {32'd34567};
    spi_busy_i = 1;
    mem_data_i = 32'h900d;
    mem_busy_i = 1;
    I2C_xy_i = 32'd0;
    I2C_done_i = 0;
    #4;
    //write to SPI: parameters, but SPI is no longer busy
    read = 0;
    write = 1;
    getinst = 0;
    address = 32'd333333;
    mh_data_i = {32'd34567};
    spi_busy_i = 0;
    mem_data_i = 32'h900d;
    mem_busy_i = 1;
    I2C_xy_i = 32'd0;
    I2C_done_i = 0;
    #4;
    //write to SPI again: commands and counter, to see spi_enable_o and spi_write_o reset
    read = 0;
    write = 1;
    getinst = 0;
    address = 32'd121212;
    mh_data_i = {20'd0, 4'd4, 8'd30};
    spi_busy_i = 1;
    mem_data_i = 32'h900d;
    mem_busy_i = 1;
    I2C_xy_i = 32'd0;
    I2C_done_i = 0;
    #4;
    //write to SPI again: parameters, to see spi_enable_o and spi_write_o signal properly
    read = 0;
    write = 1;
    getinst = 0;
    address = 32'd333333;
    mh_data_i = {32'd34567};
    spi_busy_i = 0;
    mem_data_i = 32'h900d;
    mem_busy_i = 1;
    I2C_xy_i = 32'd0;
    I2C_done_i = 0;
    #4;
    $finish;

    //write to SPI
end
endmodule