`timescale 1ms/10ps
module t08_mmio_tb;
logic nRst, clk;

logic read;                       //command to read, source specified by address
logic write;                      //command to write, destination specified by address
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
t08_mmio 