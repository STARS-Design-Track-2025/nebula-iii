module t07_FPU_fixtofloat (
    input logic [31:0] in,
    input logic sign,
    output logic [31:0] out
);
    
    //logic [5:0] count; 

    always_comb begin
        for(integer i = 0; i < 16; i++) begin
            if (in[i] == 1) begin 
                //count = i;
                i = 16; 
            end
        end

    end
    

    //parsing float
    logic [7:0] exponent = out[30:23];
    logic [22:0] mantissa = out[22:0];

    
endmodule