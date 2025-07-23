module t08_top(
    input logic clk, nRst,                              //Clock and active-low reset
    input logic en,                                     //Active high enable (NOT IMPLEMENTED YET)

    input logic touchscreen_interrupt,                  //I2C inputs and outputs with touchscreen
    input logic SDAin, 
    output logic SDAout, SDAoeb,
    output logic touchscreen_scl,

    output logic [7:0] spi_outputs,                     //SPI outputs to display screen
    output logic spi_wrx, spi_rdx, spi_csx, spi_dcx

    // input logic [31:0] wb_dat_i,                        //Wishbone manager inputs and outputs with wishbone interconnect
    // input logic wb_ack_i,
    // output logic [31:0] wb_adr_o, 
    // output logic [31:0] wb_dat_o,
    // output logic [3:0] wb_sel_o,
    // output logic wb_we_o, wb_stb_o, wb_cyc_o

    // input logic [31:0] wb_dat_o,                    //TEMPORARILY TRYING TO MOVE WISHBONE MANAGER OUT OF TOP
    // input logic wb_busy_o,
    // output logic [31:0] wb_dat_i,
    // output logic [31:0] wb_adr_i,
    // output logic [3:0] wb_sel_i,
    // output logic wb_write_i, wb_read_i
);

    /*
    CPU
    */

    logic [31:0] CPU_data_in, CPU_data_out;
    logic [31:0] CPU_mem_address_out;
    logic CPU_read_out, CPU_write_out, getinst, wb_read;

    t08_CPU CPU(
        .gdone(mmio_done_o),
        .clk(clk), .nRst(nRst),                             //clock and reset
        .data_in(CPU_data_in),                              //mmio to memory handler: data in
        .done(mmio_done_from_I2C), .busy(mmio_busy),        //from mmio, if it's busy, if data from I2C is done
        .data_out(CPU_data_out),                            //memory handler to mmio: data outputted
        .addressnew(CPU_mem_address_out),                  //memory handler to mmio: address in memory
        .read_out(CPU_read_out), .write_out(CPU_write_out), .getinst(getinst), .wb_read(wb_read)  //memory handler to mmio: read and write enable
    );

    /*
    I2C
    */
    
    logic [31:0] I2C_data_out;
    logic I2C_done;

    t08_I2C_and_interrupt I2C(
        .clk(clk), .nRst(nRst),                               //clock and reset
        .SDAin(SDAin), .SDAout(SDAout), .SDAoeb(SDAoeb),      //SDA line
        .inter(touchscreen_interrupt), .scl(touchscreen_scl), //interrupt from touchscreen and SCL to touchscreen
        .data_out(I2C_data_out), .done(I2C_done)              //outputs to mmio
    );

    /*
    SPI
    */

    logic [7:0] screen_command;             //Command sent to the display screen. 
    logic [31:0] screen_command_parameters; //Parameters for the command sent to the display screen. 
    logic SPI_enable, SPI_read, SPI_write;  //Enable, read, and write signals for SPI
    logic SPI_busy;                         //Busy signal from SPI

    t08_spi SPI(
        .command(screen_command), .parameters(screen_command_parameters), 
        .enable(SPI_enable), .clk(clk), .nrst(nRst), 
        .readwrite(SPI_write), 
        .counter(mmio_counter_to_spi), 
        .outputs(spi_outputs), 
        .wrx(spi_wrx), .rdx(spi_rdx), .csx(spi_csx), .dcx(spi_dcx), 
        .busy(SPI_busy)
    );

    /*
    MMIO
    */

    logic [3:0] mmio_counter_to_spi;
    logic [31:0] mmio_data_to_wb;            //Data written from mmio to the wishbone manager
    logic [31:0] mmio_address_to_wb;         //Memory address sent from mmio to wishbone mananger
    logic [3:0] mmio_select_to_wb;           //Select signal from mmio to wishbone manager
    logic mmio_write_to_wb, mmio_read_to_wb; //Read and write signals from mmio to wishbone manager
    logic mmio_busy, mmio_done_o, mmio_done_from_I2C;

    t08_mmio mmio(
        .clk(clk), .nRst(nRst),
        .read(CPU_read_out), .write(CPU_write_out),  .getinst(getinst), .wb_read(wb_read),                                 //From memory handler
        .address(CPU_mem_address_out), .mh_data_i(CPU_data_out), 
        
        .I2C_xy_i(I2C_data_out), .I2C_done_i(I2C_done),                                    //From I2C
        
        .spi_busy_i(SPI_busy),                                                             //From SPI
        
        .mem_data_i(wb_data_to_mmio), .mem_busy_i(wb_busy_o),                        //From memory: data
        
        .mh_data_o(CPU_data_in), .mmio_busy_o(mmio_busy), .I2C_done_o(mmio_done_from_I2C), .mmio_done_o(mmio_done_o),//To memory handler
        
        .spi_parameters_o(screen_command_parameters), .spi_command_o(screen_command),      //To SPI
        .spi_counter_o(mmio_counter_to_spi),
        .spi_read_o(SPI_read), .spi_write_o(SPI_write), .spi_enable_o(SPI_enable),          
                   
        .mem_data_o(mmio_data_to_wb), .mem_address_o(mmio_address_to_wb),                  //To memory: data/wishbone    
        .mem_select_o(mmio_select_to_wb), 
        .mem_write_o(mmio_write_to_wb), .mem_read_o(mmio_read_to_wb) 
    );

    /*
    Wishbone manager
    */

    logic [31:0] wb_data_to_mmio; //Data read into mmio from wishbone manager
            

    logic [31:0] wb_dat_i;                     
    logic wb_ack_i;
    logic [31:0] wb_adr_o;
    logic [31:0] wb_dat_o;
    logic [3:0] wb_sel_o;
    logic wb_we_o, wb_stb_o, wb_cyc_o;
    logic wb_busy_o;                //Busy signal sent from wishbone manager to mmio

    wishbone_manager wm(
        .nRST(nRst), .CLK(clk),                                     //reset and clock

        .DAT_I(wb_dat_i), .ACK_I(wb_ack_i),                         //"input from wishbone interconnect"
                                                                  
        .CPU_DAT_I(mmio_data_to_wb), .ADR_I(mmio_address_to_wb),    //"input from user design"
        .SEL_I(mmio_select_to_wb),  
        .WRITE_I(mmio_write_to_wb), .READ_I(mmio_read_to_wb),    

        .ADR_O(wb_adr_o), .DAT_O(wb_dat_o), .SEL_O(wb_sel_o),       //"output to wishbone interconnect"
        .WE_O(wb_we_o), .STB_O(wb_stb_o), .CYC_O(wb_cyc_o),  

        .CPU_DAT_O(wb_data_to_mmio), .BUSY_O(wb_busy_o)       //"output to user design"
    );

    /*
    SRAM Wishbone wrapper
    */

    sram_WB_Wrapper sram_wb_w(
        .wb_clk_i(clk), .wb_rst_i(!nRst), 
        .wbs_stb_i(wb_stb_o), .wbs_cyc_i(wb_cyc_o), .wbs_we_i(wb_we_o), 
        .wbs_sel_i(wb_sel_o), .wbs_dat_i(wb_dat_o), .wbs_adr_i(wb_adr_o), 
        .wbs_ack_o(wb_ack_i), .wbs_dat_o(wb_dat_i)
    );

endmodule
