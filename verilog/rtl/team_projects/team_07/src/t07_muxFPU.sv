module t07_muxFPU(
    input logic [31:0] regValA_i, regValB_i, 
    input logic [31:0] fpuRegValA_i, fpuRegValB_i, 
    input logic [4:0] FPUOp,
    output logic [31:0] FPUValA_o, FPUValB_o,
    output logic fcsrEnable_o
);
    always_comb begin
        if(FPUOp == 5'd21 || FPUOp == 5'd22) begin //int to float
            FPUValA_o = regValA_i;
            FPUValB_o = regValB_i;
            fcsrEnable_o = 1;
        end else if(FPUOp == 5'd14 || FPUOp == 5'd15) begin
            FPUValA_o = fpuRegValA_i;
            FPUValB_o = fpuRegValB_i;
            fcsrEnable_o = 1;
        end else begin
            FPUValA_o = fpuRegValA_i;
            FPUValB_o = fpuRegValB_i;
            fcsrEnable_o = 0;
        end
    end
endmodule