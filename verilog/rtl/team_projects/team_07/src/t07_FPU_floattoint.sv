module t07_FPU_floattoint (
    input signed [31:0] in,
    input logic signSignal,
    input logic [2:0] frm,
    output logic [31:0] out,
    output logic invalidFlag
);

    logic sign; 
    assign sign = in[31];
    // logic testFlag;

    always_comb begin
    //rounding mode logic- Page 42 UCB RISCV manual
        out = 32'b0;
        invalidFlag = 1'b1;
        if (signSignal == 0) begin
            case (frm)
                3'b000: begin 
                    if ($unsigned(in[31:23]) % 2 == 0) begin 
                        invalidFlag = 1'b0;
                        out = {23'b0, $unsigned(in[31:23])};
                    end else begin 
                        invalidFlag = 1'b0;
                        out = {23'b0, $unsigned(in[31:23]) + 9'b1}; 
                    end
                end
                3'b001: begin 
                    // if(in[22:0] == '0) begin invalidFlag = 1'b0; out = {23'b0, $unsigned(in[31:23])}; end
                    // else begin invalidFlag = 1'b0; out = {23'b0, $unsigned(in[31:23])}; end
                    invalidFlag = 1'b0;
                    out = {23'b0, $unsigned(in[31:23])};
                end    
                3'b010: begin
                    // if(in[22:0] == '0) begin invalidFlag = 1'b0; out = {23'b0, $unsigned(in[31:23])}; end
                    // else begin invalidFlag = 1'b0; out = {23'b0, $unsigned(in[31:23])}; end
                    invalidFlag = 1'b0;
                    
                    out = {23'b0, $unsigned(in[31:23])};
                end
                3'b011: begin
                    if(in[22:0] == '0) begin invalidFlag = 1'b0; out = {23'b0, $unsigned(in[31:23])}; end
                    else begin invalidFlag = 1'b0; out = {23'b0, $unsigned(in[31:23]) + 9'b1}; end
                end
                3'b100: begin
                    if(in[22:0] == '0) begin invalidFlag = 1'b0; out = {23'b0, $unsigned(in[31:23])}; end
                    else if (in[22] == 0) begin 
                        invalidFlag = 1'b0;
                        out = {23'b0, $unsigned(in[31:23])};
                    end
                    else if (in[22] == 1) begin
                        invalidFlag = 1'b0;
                        out = {23'b0, $unsigned(in[31:23]) + 9'b1};
                    end
                end
                3'b101: begin invalidFlag = 1'b1; out = 32'b0; end
                3'b110: begin invalidFlag = 1'b1; out = 32'b0; end
                3'b111: begin invalidFlag = 1'b1; out = 32'b0; end
                default: begin invalidFlag = 1'b1; out = 32'b0; end
            endcase
        end
        else if (signSignal == 1) begin
            case (frm)
                3'b000: begin 
                    if (in[22:0] == '0) begin
                        invalidFlag = 1'b0;
                        out = {sign, 23'b0, in[30:23]};
                    end 
                    else if(sign == 0) begin
                        if (in[30:23] % 2 == 0) begin 
                            invalidFlag = 1'b0;
                            out = {sign, 23'b0, in[30:23]};
                        end else begin 
                            invalidFlag = 1'b0;
                            out = {sign, 23'b0, in[30:23] + 8'b1}; 
                        end
                    end else if (sign == 1) begin
                        if (in[30:23] % 2 == 0) begin 
                            invalidFlag = 1'b0;
                            out = {sign, 23'b0, in[30:23]};
                        end else begin 
                            invalidFlag = 1'b0;
                            out = {sign, 23'b0, ~((~in[30:23] + 8'b1) - 8'b1) + 8'b1}; 
                        end
                    end
                end
                3'b001: begin 
                    invalidFlag = 1'b0; 
                    out = {sign, 23'b0, in[30:23]};
                end    
                3'b010: begin
                    if(sign == 0) begin
                        invalidFlag = 1'b0; 
                        out = {sign, 23'b0, in[30:23]};
                    end else begin
                        if (in[22:0] == '0) begin invalidFlag = 1'b0; out = {sign, 23'b0, in[30:23]}; end 
                        else begin
                            invalidFlag = 1'b0;
                            out = {sign, 23'b0, ~((~in[30:23] + 8'b1) - 8'b1) + 8'b1};
                        end
                    end
                end
                3'b011: begin
                    if(sign == 0) begin
                        if(in[22:0] == '0) begin invalidFlag = 1'b0; out = {sign, 23'b0, in[30:23]}; end
                        else begin invalidFlag = 1'b0; out = {sign, 23'b0, in[30:23] + 8'b1}; end
                    end else begin 
                        if(in[22:0] == '0) begin invalidFlag = 1'b0; out = {sign, 23'b0, in[30:23]}; end
                        else begin invalidFlag = 1'b0; out = {sign, 23'b0, in[30:23]}; end
                    end
                end
                3'b100: begin
                    if(sign == 0) begin
                        if(in[22:0] == '0) begin invalidFlag = 1'b0; out = {sign, 23'b0, in[30:23]}; end
                        else if (in[22] == 0) begin 
                            invalidFlag = 1'b0;
                            out = {sign, 23'b0, in[30:23]};
                        end
                        else if (in[22] == 1) begin
                            invalidFlag = 1'b0;
                            out = {sign, 23'b0, in[30:23] + 8'b1};
                        end
                    end else begin
                        if(in[22:0] == '0) begin invalidFlag = 1'b0; out = {sign, 23'b0, in[30:23]}; end
                        else if (in[22] == 0) begin 
                            invalidFlag = 1'b0;
                            out = {sign, 23'b0, in[30:23]};
                        end
                        else if (in[22] == 1) begin
                            invalidFlag = 1'b0;
                            out = {sign, 23'b0, ~((~in[30:23] + 8'b1) - 8'b1) + 8'b1};
                        end
                    end
                end
                3'b101: begin invalidFlag = 1'b1; out = 32'b0; end
                3'b110: begin invalidFlag = 1'b1; out = 32'b0; end
                3'b111: begin invalidFlag = 1'b1; out = 32'b0; end
                default: begin invalidFlag = 1'b1; out = 32'b0; end
            endcase
        end
    end
    
endmodule