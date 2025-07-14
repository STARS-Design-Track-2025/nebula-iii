module t07_ALU (
    input logic [31:0] valA, valB,
    input logic [2:0] func3,
    output logic [31:0] result,
    output logic [5:0] ALUflags
);

    //two's complement -> converting signed to unsigned- Page 13 RVALP
    logic unsigned_val [30:0];

    task automatic convert(val);
        if(val[31] == 0) begin unsigned_val = val[30:0]; end
        else begin unsigned_val = (~val[30:0] + 1'b1); end
    endtask //automatic

    //choose operation- Page 51 RVALP
    always_comb begin
        case (func3)
            3'd0: result = valA + valB;
            3'd1: result = valA & valB;
            3'd2: result = valA | valB;
            3'd3: result = valA << valB[4:0];
            3'd4: if(valA < valB) begin result = 1; end else begin result = 0; end 
            3'd5: if(convert(valA) < convert(valB)) begin result = 1; end else begin result = 0; end
            3'd6: if (valA < valB) begin result = 1; end else begin result = 0; end
            3'd7: result = valA >>> valB[4:0];
            3'd8: result = valA >> valB[4:0];
            3'd9: result = valA - valB;
            3'd10: result = valA ^ valB;
            default: result = 32'b0;
        endcase
    end

    //flag logic- Page 58 RVALP
    assign ALUflags = 6'd0;

    always_comb begin
        if (result == 32'b0) begin ALUflags[0] = 1; end
        if (valA >= valB) begin ALUflags[1] = 1; end
        if (valA[30:0] >= valB[30:0]) begin ALUflags[2] = 1; end
        if (valA < valB) begin ALUflags[3] = 1; end
        if (valA[30:0] < valB[30:0]) begin ALUflags[4] = 1; end
        if (valA != valB) begin ALUflags[5] = 1; end     
    end

endmodule