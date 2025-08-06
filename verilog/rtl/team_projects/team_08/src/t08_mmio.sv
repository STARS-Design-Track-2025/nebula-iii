`default_nettype none
//memory map input/ output: [description]


//interface with wishbone
module t08_mmio (
    input logic         nRst, 
                       clk,
    //from memory handler
    input logic         read,                       //command to read, source specified by address
    input logic         write,                      //command to write, destination specified by address
    input logic         wb_read, 
    input logic         wb_write,
    input logic [31:0]  address,                    //location to read from or write to
    input logic [31:0]  mh_data_i,                  //data to write
    //from I2C
    input logic [31:0]  I2C_xy_i,
    input logic         I2C_done_i,
    //from SPI
    input logic         spi_busy_i,
    //from Memory: data
    input logic [31:0]  mem_data_i,          //data read from memory
    input logic         mem_busy_i,                 //whether memory is busy or not
    //to memory handler
    output logic [31:0] mh_data_o,          //data read
    output logic        mmio_busy_o,               //whether mmio is busy or not
    output logic        I2C_done_o,                //whether I2C data is ready to be read
    output logic        mmio_done_o,                //edge detector on mmio busy low
    //to SPI
    output logic [31:0] spi_data_o,
    output logic        spi_writeread_o,

    output logic        spi_comm_enable_o,
    output logic        spi_param_enable_o,
    //to Memory: data / wishbone
    output logic [31:0] mem_data_o,         //data to write to memory
    output logic [31:0] mem_address_o,      //address to put data
    output logic [3:0]  mem_select_o,       //hardwired to 1
    output logic        mem_write_o,        //tell memory to receive writing
    output logic        mem_read_o          //tell memory to output reading
);

localparam [31:0] SPI_ADDRESS_C = 32'd121212; //SPI write command + counter
localparam [31:0] SPI_ADDRESS_P = 32'd333333; //SPI write parameter
localparam [31:0] I2C_ADDRESS = 32'd923923;

//assign mmio_busy_o = mem_busy_i;
assign mmio_busy_o = spi_busy_i | mem_busy_i | !(I2C_done_i); 
assign I2C_done_o = I2C_done_i;
assign mem_select_o = 4'b1111;
assign mem_read_o = wb_read;
//assign mem_write_o = wb_write;

logic m1, m2, s1, s2;

always_ff @(posedge clk, negedge nRst) begin
    if (~nRst) begin
        m1 <= 0;
        m2 <= 0;
        s1 <= 0;
        s2 <= 0;
    end
    else begin
        m1 <= mmio_busy_o; //registered busy signal
        m2 <= m1;
        s1 <= spi_busy_i;
        s2 <= s1; 
    end
end

assign mmio_done_o = ((!spi_busy_i)&(m1 & m2))|(!s1 & s2);

always_comb begin
    mh_data_o = 0;                                             
    spi_data_o = 0;
    spi_writeread_o = 0;
    spi_comm_enable_o = 0;
    spi_param_enable_o = 0;      
    mem_data_o = 0;     
    mem_address_o = 0;      
    mem_write_o = 0;   
        
        if (!write && read) begin //read operation
            if (address == I2C_ADDRESS) begin // read from I2C
                if (I2C_done_i) begin
                    mh_data_o = I2C_xy_i;
                end
            end 
            else if (address < 32'd2048) begin//read from memory
                if (mem_busy_i) begin
                    mh_data_o = 32'hDEADBEEF;
                end 
                else begin
                    if (mem_data_i != 32'hBAD1BAD1) begin
                        mh_data_o = mem_data_i;
                    end
                    mem_address_o = address;
                end
            end
        end

    else
    if (write && !read) begin //write operation
            if (address == SPI_ADDRESS_C) begin //write comand to display
                if (!spi_busy_i) begin        
                    spi_data_o = mh_data_i;
                    spi_comm_enable_o = 1;
                    spi_writeread_o = 1;
                end
            end else if (address == SPI_ADDRESS_P) begin //write parameter to display
                spi_data_o = mh_data_i;
                spi_writeread_o = 1;
                spi_param_enable_o = 1;
            end else if (address < 32'd2048) begin //write to memory
                if (!mem_busy_i) begin
                    mem_write_o = wb_write;
                    mem_data_o = mh_data_i;     
                    mem_address_o = address;            
                end
            end
        end
    end
endmodule

