module t07_top (
    input logic clk, nrst,
    output logic FPUFlag, invalError
);

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

//outputs from CPU
logic [31:0] instr, memData_in, memData_out, exMemData_CPU, exMemAddr_CPU;
logic busyFromCPU; 
logic [1:0] rwi_in; //read = 10, write = 01, idle = 00

//outputs of MMIO
logic [31:0] addrToSRAM, dataToSRAM; //addr_out in MMIO 

//wishbone manager output to wishbone arbitrator
logic [31:0] addrWMToAr, dataWMToAr;
logic [3:0] selToAr;
logic weToAr, stbToAr, cycToAr;

//wishbone arbitrator output to wishbone decoder
logic cycToDec, stbToDec, weToDec;
logic [31:0] addrToDec, dataToDec; 
logic [3:0] selToDec;

//wishbone arbitrator output to wishbone manger
logic [31:0] ackToWM, dataArToWM;

//wishbone decoder output to wishbone arbitrator
logic ackToAr;
logic [31:0] dataDecToAr;

//wishbone manager output to user design
logic [31:0] dataToMMIO;
logic busyToMMIO;

//outputs of WB decoder
logic [6 + 3:0] cyc_out;
logic [6 + 3:0] stb_out;
logic [6 + 3:0] we_out;
logic [(32 * (10)) - 1:0] addr_out;
logic [(32 * (10)) - 1:0] data_out;
logic [(4 * (10)) - 1:0] sel_out;

//input SRAM to decoder
logic [6 + 3:0] ackDec_in;
logic [(32 * (10)) - 1:0] dataDec_in;

t07_CPU CPU(.busy(busyFromCPU), .externalMemAddr(exMemAddr_CPU), .exMemData_out(exMemData_CPU), .exInst(instr), .memData_in(memData_in), .rwi(rwi), .FPUFlag(FPUFlag), .invalError(invalError), .clk(clk), .nrst(nrst));
t07_MMIO MMIO(.addr_in(exMemAddr_CPU), .memData_in(exMemData_CPU), .rwi_in(rwi_in), .inst(instr), .ExtData_in(dataToMMIO), .regData_in(), .ack_REG(), .ack_TFT(), .ri_out(), .addr_outREG(), .ExtData_out(), .busy(), .writeInstruction_out(), .writeData_outTFT(), .wi_out(), .addr_outTFT(), .rwi_out(), .addr_out(addrToSRAM), .writeData_out(dataToSRAM), .busy_o());
wishbone_manager wishbone0(.nRST(nrst), .CLK(clk), .DAT_I(dataArToWM), .ACK_I(ackToWM), .CPU_DATA_I(dataToSRAM), .ADR_I(addrToSRAM), .SEL_I('1), .WRITE_I(write), .READ_I(read), .ADR_O(addrWMToAr), .DAT_O(dataWMToAr), .SEL_O(selToAr), .WE_O(weToAr), .STB_O(stbToAr), .CYC_O(cycToAr), .CPU_DAT_O(dataToMMIO), .BUSY_O(busy));
//SRAM
wishbone_arbitrator wishboneA0(.CLK(clk), .nRST(nrst), .A_ADR_I(addrWMToAr), .A_DAT_I(dataWMToAr), .A_SEL_I(selToAr), .A_WE_I(weToAr), .A_STB_I(stbToAr), .A_CYC_I(cycToAr), .A_DAT_O(dataArToWM), .A_ACK_O(ackToWM), .DAT_I(dataDecToAr), .ACK_I(ackToAr), .ADR_O(addrToDec), .DAT_O(dataToDec), .SEL_O(selToDec), .WE_O(weToDec), .STB_O(stbToDec), .CYC_O(cycToDec));
wishbone_decoder wishboneD0(.CLK(clk), .nRST(nrst), .wbs_ack_i_peroph(ackDec_in), .wbs_dat_i_peroph(dataDec_in), .wbs_ack_o_m(ackToAr), .wbs_dat_o_m(dataDecToAr), .wbs_cyc_i_m(cycToDec), .wbs_stb_i_m(stbToDec), .wbs_we_i_m(weToDec), .wbs_adr_i_m(addrToDec), .wbs_dat_i_m(dataToDec), .wbs_sel_i_m(selToDec), .wbs_cyc_o_periph(cyc_out), .wbs_stb_o_periph(stb_out), .wbs_we_o_periph(we_out), .wbs_adr_o_periph(addr_out), .wbs_dat_o_periph(data_out), .wbs_sel_o_periph(sel_out));

endmodule