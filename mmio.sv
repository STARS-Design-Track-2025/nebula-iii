`default_nettype none
//memory map input/ output: [description]

module mmio (
    //from memory handler
    input read,
    input write,
    input [31:0] address,
    input [31:0] mh_data,
    //from I2C
    input [7:0] xh,         
    input [7:0] xl,         
    input [7:0] yh,
    input [7:0] yl,
    input done,
    //from Memory: data
    input [31:0] mem_data,
    //to memory handler
    output [31:0] mh_data_o,
    //to SPI
    output [31:0] parameters,
    output [7:0] command,
    output readwrite,
    output enable 
);

always_comb begin
    if
end



endmodule

