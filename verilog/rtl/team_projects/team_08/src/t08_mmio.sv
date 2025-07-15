`default_nettype none
//memory map input/ output: [description]


//interface with wishbone
module t08_mmio (
    //from memory handler
    input logic read,                   //command to read, source specified by address
    input logic write,                  //command to write, destination specified by address
    input logic [31:0] address,         //location to read from or write to
    input logic [31:0] mh_data,         //data to write
    //from I2C
    input logic [7:0] xh,               //
    input logic [7:0] xl,         
    input logic [7:0] yh,
    input logic [7:0] yl,
    input logic done,
    //from Memory: data
    input logic [31:0] mem_data,
    //to memory handler
    output logic [31:0] mh_data_o,      //data read
    output logic busy,
    //to SPI
    output logic [31:0] parameters,
    output logic [7:0] command,
    output logic readwrite,
    output logic enable 
);

typedef enum logic[1:0] {
    IDLE,
    WRITE,
    READ
 } state;

state curr_state, next_state;
logic next_busy;

always_ff@(posedge clk, posedge reset) begin
    if (reset) begin
        curr_state <= IDLE;
    end else if (done) begin
        curr_State <= next_state;
        busy <= next_busy;
    end
end

always_comb begin
   case(curr_state)
        IDLE: begin
            if(WRITE_I && !READ_I) begin
                next_BUSY_O = 1'b1;
                next_state  = WRITE;
            end
            if(!WRITE_I && READ_I) begin
                next_BUSY_O = 1'b1;
                next_state  = READ;
            end
        end     
        WRITE: begin
            next_ADR_O  = ADR_I;
            next_DAT_O  = CPU_DAT_I;
            next_SEL_O  = SEL_I;
            next_WE_O   = 1'b1;
            next_STB_O  = 1'b1;
            next_CYC_O  = 1'b1;
            next_BUSY_O = 1'b1;

            if(ACK_I) begin
                next_state = IDLE;

                next_ADR_O  = '0;
                next_DAT_O  = '0;
                next_SEL_O  = '0;
                next_WE_O   = '0;
                next_STB_O  = '0;
                next_CYC_O  = '0;
                next_BUSY_O = '0;
            end
        end
        READ: begin 
end



endmodule

