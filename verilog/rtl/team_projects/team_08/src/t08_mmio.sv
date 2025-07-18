`default_nettype none
//memory map input/ output: [description]


//interface with wishbone
module t08_mmio (
    input logic nRst, clk,
    //from memory handler
    input logic read,                       //command to read, source specified by address
    input logic write,                      //command to write, destination specified by address
    input logic [31:0] address,             //location to read from or write to
    input logic [31:0] mh_data_i,           //data to write
    //from I2C
    input logic [31:0] I2C_xy_i,
    input logic I2C_done_i,
    //from SPI
    input logic spi_busy_i,
    //from Memory: data
    input logic [31:0] mem_data_i,          //data read from memory
    input logic mem_busy_i,                 //whether memory is busy or not
    //to memory handler
    output logic [31:0] mh_data_o,          //data read
    output logic mmio_busy_o,               //whether mmio is busy or not
    output logic I2C_done_o,                //whether I2C data is ready to be read
    //to SPI
    output logic [31:0] spi_parameters_o,   //
    output logic [7:0] spi_command_o,
    output logic [3:0] spi_counter_o,
    output logic spi_read_o,
    output logic spi_write_o,
    output logic spi_enable_o,
    //to Memory: data / wishbone
    output logic [31:0] mem_data_o,         //data to write to memory
    output logic [31:0] mem_address_o,      //address to put data
    output logic [3:0]  mem_select_o,       //hardwired to 1
    output logic        mem_write_o,        //tell memory to receive writing
    output logic        mem_read_o          //tell memory to output reading
);

typedef enum logic[1:0] {
    IDLE,
    BUSY,
    MEMREAD
 } state;

localparam [31:0] SPI_ADDRESS_C = 32'd121212; //SPI write command + counter
localparam [31:0] SPI_ADDRESS_P = 32'd333333; //SPI write parameter
localparam [31:0] I2C_ADDRESS = 32'd923923;

assign I2C_done_o = I2C_done_i;
assign mem_select_o = 4'b1111;

logic [31:0] mh_data_o_next;         
logic        mmio_busy_o_next;                  
logic        I2C_done_o_next;                

logic [31:0] spi_parameters_o_next;     
logic [7:0]  spi_command_o_next;
logic [3:0]  spi_counter_o_next;
logic        spi_read_o_next;
logic        spi_write_o_next;
logic        spi_enable_o_next;

logic [31:0] mem_data_o_next;     
logic [31:0] mem_address_o_next;        
logic        mem_write_o_next;      
logic        mem_read_o_next; 

state curr_state, next_state;


always_ff@(posedge clk, negedge nRst) begin
    if (!nRst) begin
        curr_state <= IDLE;
    end else begin
        curr_state <= next_state;
        mh_data_o <= mh_data_o_next;          
        mmio_busy_o <= mmio_busy_o_next;                                     
        spi_parameters_o <= spi_parameters_o_next;     
        spi_command_o <= spi_command_o_next;
        spi_counter_o <= spi_counter_o_next;
        spi_read_o <= spi_read_o_next;
        spi_write_o <= spi_write_o_next;
        spi_enable_o <= spi_enable_o_next;      
        mem_data_o <= mem_data_o_next;     
        mem_address_o <= mem_address_o_next;         
        mem_write_o <= mem_write_o_next;      
        mem_read_o <= mem_read_o_next;  
    end
end

always_comb begin
    next_state = IDLE;
    mh_data_o_next = 0;         
    mmio_busy_o_next = 0;                         
    
    spi_parameters_o_next = spi_parameters_o;     
    spi_command_o_next = spi_command_o;
    spi_counter_o_next = spi_counter_o;
    spi_read_o_next = 0;
    spi_write_o_next = spi_write_o;
    spi_enable_o_next = spi_enable_o;

    mem_data_o_next = 0;     
    mem_address_o_next = 0;           
    mem_write_o_next = 0;      
    mem_read_o_next = 0;

    case (curr_state)
        IDLE: begin
            if (!write && read) begin
                mmio_busy_o_next = 1;
                if (address == I2C_ADDRESS) begin
                    if (I2C_done_i) begin
                        next_state = BUSY;
                        mh_data_o_next = I2C_xy_i;
                    end else begin
                        next_state  = IDLE; 
                    end
                end else if (address < 32'd2048) begin
                    if (mem_busy_i) begin
                        next_state  = IDLE; 
                    end else begin 
                        next_state = MEMREAD;
                        mem_address_o_next = address;          
                        mem_read_o_next = 1;
                    end
                end
            end else if (write && !read) begin
                mmio_busy_o_next = 1;
                if (address == SPI_ADDRESS_C) begin
                    next_state = BUSY;
                    spi_command_o_next = mh_data_i[7:0];
                    spi_counter_o_next = mh_data_i[11:8];
                    spi_enable_o_next = 0;
                    spi_write_o_next = 0;
                end else if (address == SPI_ADDRESS_P) begin
                    if (spi_busy_i) begin
                        next_state  = IDLE; 
                    end else begin
                        next_state = BUSY;
                        spi_parameters_o_next = mh_data_i;
                        spi_write_o_next = 1;
                        spi_enable_o_next = 1;
                    end
                end else if (address < 32'd2048) begin
                    if (mem_busy_i) begin
                        next_state  = IDLE; 
                    end else begin
                        next_state = BUSY;
                        mem_data_o_next = mh_data_i;     
                        mem_address_o_next = address;          
                        mem_write_o_next = 1;      
                    end
                end
            end
        end
        BUSY: begin
           next_state = IDLE;
           mmio_busy_o_next = 1'b0;
        end
        MEMREAD: begin
            next_state = BUSY;
            mmio_busy_o_next = 1'b1;
            mh_data_o_next = mem_data_i; 
        end
    endcase
end

endmodule

