module t07_top (
    input logic clk, nrst,
    output logic FPUFlag, invalError
);

logic [31:0] inst, memData_in, memData_out, pcData_out, exMemAddr;
logic busy;
//inst from data mem/instr -> to fetch in CPU
//memData_in from MMIO -> to internal mem
//memData_out from MMIO -> to internal mem
//pcData_out, from PC -> thru MMIO -> next instr addr for data mem/instr
//exMemAddr, from interal mem -> to MMIO 


logic [1:0] rwi; //read = 10, write = 01, idle = 00

t07_CPU CPU(.busy(busy), .externalMemAddr(exMemAddr), .pcData_out(pcData_out), .exInst(inst), .memData_in(memData_in), .memData_out(memData_out), .rwi(rwi), .FPUFlag(FPUFlag), .invalError(invalError), .clk(clk), .nrst(nrst));
wishbone_manager wishbone0(.nRST(nrst), .CLK(clk), .DAT_I(), .ACK_I(), .CPU_DATA_I(), .ADI_I(), .SEL_I(), .WRITE_I(), .READ_I(), .ADR_O(), .DAT_O(), .SEL_O(), .WE_O(), .STB_O(), .CYC_O(), .CPU_DAT_O(), .BUSY_O());

endmodule