module t07_FPU_fixtofloat (
    input logic [31:0] in,
    input logic sign,
    output logic [31:0] out
);
    
    

    //parsing float
    logic [7:0] exponent = out[30:23];
    logic [22:0] mantissa = out[22:0];

    
endmodule