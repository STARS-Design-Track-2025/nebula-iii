module t07_ALU (
    input signed [31:0] valA, valB,
    input logic [3:0] ALUOp,
    output logic [31:0] result,
    output logic [6:0] ALUflags
);
<<<<<<< HEAD
//choose operation- Page 51 RVALP
=======


    //choose operation- Page 51 RVALP
>>>>>>> 2c644b69f6c18819601bb5187109e4e3bafe5846
    always_comb begin
        case (ALUOp)
            4'd0: result = valA + valB; //add 
            4'd1: result = valA & valB; //and
            4'd2: result = valA | valB; //or
            4'd3: result = valA << valB[4:0]; //sll
            4'd4: if(valA < valB) begin result = 1; end else begin result = 0; end //slt
            4'd5: if($unsigned(valA) < $unsigned(valB)) begin result = 1; end else begin result = 0; end //sltu
            4'd6: result = valA >>> valB[4:0]; //sra
            4'd7: result = valA >> valB[4:0]; //srl
            4'd8: result = valA - valB; //sub
            4'd9: result = valA ^ valB; //xor
            default: result = 32'b0;
        endcase

        if ($size(result) > 31) begin
            result = 32'b0;
        end
    end

    //flag logic- Page 58 RVALP
<<<<<<< HEAD
    always_comb begin
        ALUflags = 7'd0;
=======

    always_comb begin
        ALUflags = 7'd0;

>>>>>>> 2c644b69f6c18819601bb5187109e4e3bafe5846
        if (result == 32'b0) begin ALUflags[0] = 1; end //zeroFlag
        if (valA >= valB) begin ALUflags[1] = 1; end //greater than or equal 
        if ($unsigned(valA) >= $unsigned(valB)) begin ALUflags[2] = 1; end //greater than or equal unsigned
        if (valA < valB) begin ALUflags[3] = 1; end //less than
        if ($unsigned(valA) < $unsigned(valB)) begin ALUflags[4] = 1; end //less than unsigned
        if (valA != valB) begin ALUflags[5] = 1; end //not equal
        if (valA == valB) begin ALUflags[6] = 1; end //equal
    end
endmodule