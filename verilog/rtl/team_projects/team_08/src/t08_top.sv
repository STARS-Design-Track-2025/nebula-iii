module t08_top(
    input logic clk, nRst
);

    /*
    CPU
    */

    logic [31:0] CPU_data_in, CPU_data_out;
    logic [31:0] CPU_mem_address_out;
    logic mmio_busy, mmio_done_from_I2C;
    logic CPU_read_out, CPU_write_out;

    t08_CPU CPU(
        .clk(clk), .nRst(nRst),                             //clock and reset
        .data_in(CPU_data_in),                              //memory to memory handler: data in
        .done(mmio_done_from_I2C), .busy(mmio_busy),        //from mmio, if it's busy, if data from I2C is done
        .data_out(CPU_data_out),                            //memory handler to mmio: data outputted
        .mem_address(CPU_mem_address_out),                  //memory handler to mmio: address in memory
        .read_out(CPU_read_out), .write_out(CPU_write_out)  //memory handler to mmio: read and write enable
    );

    /*
    I2C
    */
    
    logic [31:0] I2C_data_out;
    logic I2C_done;

    t08_I2C_and_interrupt I2C(
        .clk(clk), .nRst(nRst),                  //clock and reset
        .SDAin(), .SDAout(), .SDAoeb(),          //SDA line
        .inter(), .scl(),                        //interrupt from touchscreen and SCL to touchscreen
        .data_out(I2C_data_out), .done(I2C_done) //outputs to mmio
    );

    /*
    SPI
    */

    logic [7:0] screen_command;             //Command sent to the display screen. 
    logic [31:0] screen_command_parameters; //Parameters for the command sent to the display screen. 
    logic SPI_enable;
    logic SPI_readwrite;
    logic SPI_busy;

    t08_spi SPI(
        .command(screen_command), .parameters(screen_command_parameters), 
        .enable(SPI_enable), .clk(clk), .nrst(nRst), 
        .readwrite(SPI_readwrite), 
        .counter(), 
        .outputs(), 
        .wrx(), .rdx(), .csx(), .dcx(), 
        .busy(SPI_busy)
    );

    /*
    MMIO
    */

    logic [31:0] mmio_data_to_wb;            //Data written from mmio to the wishbone manager
    logic [31:0] mmio_address_to_wb;         //Memory address sent from mmio to wishbone mananger
    logic [3:0] mmio_select_to_wb;           //Select signal from mmio to wishbone manager
    logic mmio_write_to_wb, mmio_read_to_wb; //Read and write signals from mmio to wishbone manager

    t08_mmio mmio(
        .nRst(nRst), .clk(clk),                                                 //Clock and reset
        
        .read(CPU_read_out), .write(CPU_write_out),                             //From memory handler
        .address(CPU_mem_address_out), .mh_data(CPU_data_out), 
        
        .xy(I2C_data_out), .done(I2C_done),                                     //From I2C
        
        .spi_busy(SPI_busy),                                                    //From SPI
        
        .mem_data_i(wb_data_to_mmio), .mem_busy(wb_busy_to_mmio),               //From memory: data
        
        .mh_data_o(CPU_data_in), .busy(mmio_busy), .done_o(mmio_done_from_I2C), //To memory handler
        
        .parameters(screen_command_parameters), .command(screen_command),       //To SPI
        .readwrite(SPI_readwrite), .enable(SPI_enable),          
                   
        .mem_data_o(mmio_data_to_wb), .mem_address(mmio_address_to_wb),         //To memory: data/wishbone    
        .select(mmio_select_to_wb), 
        .mem_write(mmio_write_to_wb), .mem_read(mmio_read_to_wb) 
    );

    /*
    Wishbone manager
    */

    logic [31:0] wb_data_to_mmio; //Data read into mmio from wishbone manager
    logic wb_busy_to_mmio;        //Busy signal sent from wishbone manager to mmio

    wishbone_manager wm(
        .nRST(nRst), .CLK(clk),                                     //reset and clock

        .DAT_I(), .ACK_I(),                                         //"input from wishbone interconnect"
                                                                  
        .CPU_DAT_I(mmio_data_to_wb), .ADR_I(mmio_address_to_wb),    //"input from user design"
        .SEL_I(mmio_select_to_wb),  
        .WRITE_I(mmio_write_to_wb), .READ_I(mmio_read_to_wb),    

        .ADR_O(), .DAT_O(), .SEL_O(), .WE_O(), .STB_O(), .CYC_O(),  //"output to wishbone interconnect"

        .CPU_DAT_O(wb_data_to_mmio), .BUSY_O(wb_busy_to_mmio)       //"output to user design"
    );

endmodule