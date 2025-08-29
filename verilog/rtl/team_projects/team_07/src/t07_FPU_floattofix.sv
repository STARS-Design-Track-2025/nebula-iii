module t07_FPU_floattofix (
    input logic [31:0] in,
    output logic [31:0] out,
    output logic sign
    //output logic [8:0] decimal
);

    //parsing float
    assign sign = in[31];
    logic [7:0] exponent = in[30:23];
    logic [22:0] mantissa = in[22:0];

    //values for fixed point conversion
    logic [31:0] fixed;

    always_comb begin
        fixed = 32'b0;
        if(exponent <= 127) begin
            fixed = {8'b0, 1'b1, mantissa} >> (127 - exponent);
        end else if (exponent > 127) begin
            fixed = {8'b0, 1'b1, mantissa} << (exponent - 127);
        end
    end

    
    assign out = fixed;
    
endmodule