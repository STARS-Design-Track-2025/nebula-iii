module t07_FPU (
    input logic [31:0] valA, valB, valC,
    input logic [31:0 ]fcsr_in,
    input logic [4:0] FPUOp,
    output logic [31:0] result,
    output logic [6:0] FPUflags,
    output logic carryout
);
    logic [2:0] frm; //page 41, last paragraph- check for static/dynamic rounding mode
    assign frm = fcsr_in [7:5];
    
    logic [4:0] fflags;
    assign fflags = fcsr_in[4:0];

    //choose operation- Page 51 RVALP
    always_comb begin
        case (FPUOp)
            5'd0: 
            5'd1: 
            5'd2: 
            5'd3: 
            5'd4: 
            5'd5: 
            5'd6: 
            5'd7: 
            5'd8: 
            5'd9: 
            5'd
            default: result = 32'b0;
        endcase
    end

    //rounding mode logic- Page 42 UCB RISCV manual
    always_comb begin
        case (frm)
            3'b000: 
            3'b001:
            3'b010:
            3'b011:
            3'b100:
            default: result = result;
        endcase
    end

    //flag logic- Page 58 RVALP

    always_comb begin
        FPUflags = 7'd0;
        if (result == 32'b0) begin FPUflags[0] = 1; end //zeroFlag
        if (valA >= valB) begin FPUflags[1] = 1; end //greater than or equal 
        if ($unsigned(valA) >= $unsigned(valB)) begin FPUflags[2] = 1; end //greater than or equal unsigned
        if (valA < valB) begin FPUflags[3] = 1; end //less than
        if ($unsigned(valA) < $unsigned(valB)) begin FPUflags[4] = 1; end //less than unsigned
        if (valA != valB) begin FPUflags[5] = 1; end //not equal
        if (valA == valB) begin FPUflags[6] = 1; end //equal
    end
endmodule