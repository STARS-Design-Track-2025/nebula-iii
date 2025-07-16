`default_nettype none
//memory map input/ output: [description]


//interface with wishbone
module t08_mmio (
    input logic nRst, clk,
    //from memory handler
    input logic read,                   //command to read, source specified by address
    input logic write,                  //command to write, destination specified by address
    input logic [31:0] address,         //location to read from or write to
    input logic [31:0] mh_data,         //data to write
    //from I2C
    input logic [31:0] xy,
    input logic done,
    //from SPI
    input logic spi_busy,
    //from Memory: data
    input logic [31:0] mem_data_i,      //data read from memory
    input logic mem_busy,               //whether memory is busy or not
    //to memory handler
    output logic [31:0] mh_data_o,      //data read
    output logic busy,                  //whether mmio is busy or not
    output logic done_o,                //whether I2C data is ready to be read
    //to SPI
    output logic [31:0] parameters,     //
    output logic [7:0] command,
    output logic readwrite,
    output logic enable,
    //to Memory: data / wishbone
    output logic [31:0] mem_data_o,     //data to write to memory
    output logic [31:0] mem_address,    //address to put data
    output logic [3:0]  select,         //
    output logic        mem_write,      //tell memory to receive writing
    output logic        mem_read        //tell memory to output reading
);

typedef enum logic[1:0] {
    IDLE,
    WRITE,
    READ
 } state;

assign done_o = done;
logic [31:0] data, next_data;
assign mh_data_o = data;
state curr_state, next_state;
logic next_busy;

logic [31:0][9:0] sr;

always_ff@(posedge clk, posedge reset) begin
    if (reset) begin
        curr_state <= IDLE;
    end else begin
        curr_state <= next_state;
        busy <= next_busy;
        data <= next_data;
    end
end

always_comb begin
    next_busy = 0;
    next_state = IDLE;
    next_data = 0;
    case (curr_state)
        IDLE: begin
            if (write && !read) begin
                next_busy = 1'b1;
                next_state  = WRITE;
            end else if (!write && read) begin
                next_busy= 1'b1;
                next_state  = READ;
            end
        end
        READ: begin
           if (address == I2C) begin
                next_data = {xh, xl, yh, yl};
            end else if (address == MEM) begin
                //wishbone shenanigans
            end  
        end     
        WRITE: begin
            if (address == SPI) begin
                if (!spi_busy) begin
                    //why not just send 40 bits??
                end
            end else if (address == MEM) begin
                //wishbone shenanigans
            end
        end
    endcase
end

endmodule

