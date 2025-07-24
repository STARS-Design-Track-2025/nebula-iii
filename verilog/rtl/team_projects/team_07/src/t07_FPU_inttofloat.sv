module t07_FPU_inttofloat (
    input signed [31:0] in,
    input logic signSignal,
    output logic [31:0] out,
    output logic overflow
);
    logic [31:0] temp;

    always_comb begin
        out = 32'b0;
        temp = in - 32'b1;
     
        overflow = 0; 
            
        if (signSignal == 1 && in[31] == 0 && in[30:8] == 23'b0) begin
            out = {in[31], in[7:0], 23'b0};
        end else if (signSignal == 1 && in[31] == 1 &&  temp[30:8] == '1) begin
            out = {in[31], in[7:0], 23'b0};
        end else if (signSignal == 0 && in[31:9] == 23'b0) begin
            out = {$unsigned(in[8:0]), 23'b0};
        end
    
        else begin
            overflow = 1; 
            out = 32'b0;
        end 
    end
    
endmodule