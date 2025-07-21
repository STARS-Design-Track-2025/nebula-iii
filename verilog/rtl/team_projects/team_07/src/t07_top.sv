module t07_top (
    input logic clk, nrst,
    output logic FPUFlag, invalError
);

//outputs from CPU
logic [31:0] instr, memData_in, memData_out, exMemData_CPU, exMemAddr_CPU;
logic busy; //from wishbone to MMIO
logic [1:0] rwi_in; //read = 10, write = 01, idle = 00

//outputs of MMIO
logic [31:0] addrtoInstr;

logic read, write, idle;
always_comb begin
    if(rwi == 10) begin
        read = 1;
        write = 0;
        idle = 0;
    end
    else if(rwi == 01) begin
        read = 0;
        write = 1;
        idle = 0;
    end else begin 
        read = 0;
        write = 0;
        idle = 1;
    end
end

//wishbone manager output to wishbone interconnect
logic [31:0] addrToIntr, dataToIntr;

//wishbone manager output to user design
logic [31:0] dataToMMIO;
logic busyToMMIO;

t07_CPU CPU(.busy(busyFromCPU), .externalMemAddr(exMemAddr_CPU), .exMemData_out(exMemData_CPU), .exInst(instr), .memData_in(memData_in), .rwi(rwi), .FPUFlag(FPUFlag), .invalError(invalError), .clk(clk), .nrst(nrst));
t07_MMIO MMIO(.addr_in(exMemAddr_CPU), .memData_in(exMemData_CPU), .rwi_in(rwi_in), .inst(instr), .ExtData_in(exMemData_CPU), .regData_in(), .PC_address(), .ri_out(), .addr_outREG(), .ExtData_out(), .busy(), .writeInstruction_out(), .writeData_outTFT(), .wi_out(), .rwi_out(), .addr_out(), .writeData_out());
wishbone_manager wishbone0(.nRST(nrst), .CLK(clk), .DAT_I(), .ACK_I(), .CPU_DATA_I(exMemData_CPU /*check*/), .ADR_I(addrToInstr), .SEL_I('1), .WRITE_I(write), .READ_I(read), .ADR_O(), .DAT_O(), .SEL_O(), .WE_O(), .STB_O(), .CYC_O(), .CPU_DAT_O(), .BUSY_O(busy));


endmodule