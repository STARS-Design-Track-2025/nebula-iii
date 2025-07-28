module t07_ALU (
    input signed [31:0] valA, valB,
    input logic [3:0] ALUOp,
    output logic [31:0] result,
    output logic [6:0] ALUflags
);


    //choose operation- Page 51 RVALP
    always_comb begin
        case (ALUOp)
            4'd0: result = valA + valB; //add, has overflow 
            4'd1: result = valA & valB; //and
            4'd2: result = valA | valB; //or
            4'd3: result = valA << valB[4:0]; //sll
            4'd4: if(valA < valB) begin result = 1; end else begin result = 0; end //slt
            4'd5: if($unsigned(valA) < $unsigned(valB)) begin result = 1; end else begin result = 0; end //sltu
            4'd6: result = valA >>> valB[4:0]; //sra
            4'd7: result = valA >> valB[4:0]; //srl
            4'd8: result = valA - valB; //sub, has overflow
            4'd9: result = valA ^ valB; //xor
            default: result = 32'b0;
        endcase


        //overflow
        if (ALUOp == 4'd0) begin
            if(((valA > $signed(32'b0)) && (valB > $signed(32'b0)) && ($signed(result) < $signed(32'b0))) || ((valA < $signed(32'b0)) && (valB < $signed(32'b0)) && ($signed(result) > $signed(32'b0)))) begin
                result = 32'b0;
            end
        end else if (ALUOp == 4'd8) begin
            if(((valA > $signed(32'b0)) && (valB < $signed(32'b0)) && ($signed(result) < $signed(32'b0))) || ((valA < $signed(32'b0)) && (valB > $signed(32'b0)) && ($signed(result) > $signed(32'b0)))) begin
                result = 32'b0;
            end
        end
    end

    //flag logic- Page 58 RVALP
    always_comb begin
        ALUflags = 7'd0;
        if (result == 32'b0) begin ALUflags[0] = 1; end //zeroFlag
        if (valA >= valB) begin ALUflags[1] = 1; end //greater than or equal 
        if ($unsigned(valA) >= $unsigned(valB)) begin ALUflags[2] = 1; end //greater than or equal unsigned
        if (valA < valB) begin ALUflags[3] = 1; end //less than
        if ($unsigned(valA) < $unsigned(valB)) begin ALUflags[4] = 1; end //less than unsigned
        if (valA != valB) begin ALUflags[5] = 1; end //not equal
        if (valA == valB) begin ALUflags[6] = 1; end //equal
    end
endmodule