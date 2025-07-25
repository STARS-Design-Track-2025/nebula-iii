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
    output logic        spi_read_o,
    output logic        spi_write_o,
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
assign mem_write_o = wb_write;

logic m1, m2;

always_ff @(posedge clk, negedge nRst) begin
    if (~nRst) begin
        // mmio_done_o <= 0;
        m1 <=0;
        m2 <= 0;
    end
    else begin
        m1 <= mmio_busy_o;
        m2 <= m1;
    end
end

assign mmio_done_o = (!spi_busy_i)&(m1 & m2);

always_comb begin
    mh_data_o = 0;                                             
    spi_data_o = 0;
    spi_read_o = 0;
    spi_write_o = 0;
    spi_comm_enable_o = 0;
    spi_param_enable_o = 0;      
    mem_data_o = 0;     
    mem_address_o = 0;         
    //mem_write_o = 0;      
    //mem_read_o = 0;
    // if (!mmio_busy_o) begin
        
        if (!write && read) begin
            if (address == I2C_ADDRESS) begin
                if (I2C_done_i) begin
                    mh_data_o = I2C_xy_i;
                end
            end 
            else if (address < 32'd2048) begin
                if (mem_busy_i) begin
                    mh_data_o = 32'hDEADBEEF;
                end 
                else begin
                    if (mem_data_i != 32'hBAD1BAD1) begin
                        mh_data_o = mem_data_i;
                    end
                    mem_address_o = address;
                    //mem_read_o = wb_read;
                end
            end
        //     else if (address < 32'd2048) begin
        //         mh_data_o = mem_data_i;
        //         mem_address_o = address;
        //         mem_read_o = 1; end


        end

    else
    if (write && !read) begin
            if (address == SPI_ADDRESS_C) begin
                if (!spi_busy_i) begin        
                    spi_data_o = mh_data_i;
                    spi_comm_enable_o = 1;
                    spi_write_o = 1;
                end
            end else if (address == SPI_ADDRESS_P) begin
                spi_data_o = mh_data_i;
                spi_write_o = 1;
                spi_param_enable_o = 1;
            end else if (address < 32'd2048) begin
                if (!mem_busy_i) begin
                    mem_data_o = mh_data_i;     
                    mem_address_o = address;          
                    //mem_write_o = 1;      
                end
            end
        end
    end
// end

/* 
typedef enum logic[2:0] {
    IDLE,       //state that reads mh input at every posedge clock
    BUSY,       //state that's outputting info to mh
    MEMWAIT,    //state that's waits a cycle for mem_busy_i to activate since it's the exit signal for leaving the next states MEMREAD and MEMWRITE
    MEMREAD,    //state that is waiting for memory to get the right memory, exits when mem_busy_i go low
    MEMWRITE    //state that is waiting for memory to finish being busy, exits when mem_busy_i go low
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
        mh_data_o <= 0;          
        mmio_busy_o <= 0;                                     
        spi_parameters_o <= 0;     
        spi_command_o <= 0;
        spi_counter_o <= 0;
        spi_read_o <= 0;
        spi_write_o <= 0;
        spi_enable_o <= 0;      
        mem_data_o <= 0;     
        mem_address_o <= 0;         
        mem_write_o <= 0;      
        mem_read_o <= 0;
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
    mh_data_o_next = mh_data_o;         
    mmio_busy_o_next = 0;                         
    
    spi_parameters_o_next = spi_parameters_o;     
    spi_command_o_next = spi_command_o;
    spi_counter_o_next = spi_counter_o;
    spi_read_o_next = 0;
    spi_write_o_next = spi_write_o;
    spi_enable_o_next = spi_enable_o;

    mem_data_o_next = mem_data_o;     
    mem_address_o_next = mem_address_o;           
    mem_write_o_next = mem_write_o;      
    mem_read_o_next = mem_read_o;

    case (curr_state)
        IDLE: begin
            if (!write && read || getinst) begin
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
                        next_state = MEMWAIT;
                        mem_address_o_next = address;          
                        mem_read_o_next = 1;
                    end
                end
            end else if (write && !read && !getinst) begin
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
                        next_state = MEMWRITE;
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
        MEMWAIT: begin
            mmio_busy_o_next = 1'b1;
            mem_write_o_next = 0;
            mem_read_o_next = 0;
            if (mem_read_o) begin   
                next_state = MEMREAD;
            end else if (mem_write_o) begin
                next_state = MEMWRITE;
            end
        end
        MEMREAD: begin
            mmio_busy_o_next = 1'b1;
            if (mem_busy_i) begin
                next_state = MEMREAD;
            end else begin
                next_state = BUSY;
                mh_data_o_next = mem_data_i; 
                mem_read_o_next = 0;
            end
        end
        MEMWRITE: begin
            mmio_busy_o_next = 1'b1;
            if (mem_busy_i) begin
                next_state = MEMWRITE;
            end else begin
                next_state = IDLE;
                mmio_busy_o_next = 1'b0;
            end
        end
    endcase
end
*/
endmodule

