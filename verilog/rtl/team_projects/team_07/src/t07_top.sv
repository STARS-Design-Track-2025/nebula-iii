module t07_top (
    input logic clk, nrst,
    input logic misoDriver_i, //for SPITFT from RA8875
    output logic invalError, chipSelectTFT, bitDataTFT, sclkTFT, //GPIO
    //output logic [6:0] FPUFlags,

    //inputs & outputs for SRAM
    input logic [31:0] dataArToWM,
    input logic ackToWM,

    output logic [31:0] dataWMToAr, addrWMToAr, 
    output logic [3:0] selToAr,
    output logic weToAr, stbToAr, cycToAr
);

//FPU_overflowFlag, FPUcarryout,

logic [31:0] programCounter_o;

logic [1:0] rwiToWB;
logic read, write, idle;

//inputs/outputs from CPU
logic busyCPU; //sent from MMIO to CPU
logic [31:0] instr, memData_in, memData_out, exMemData_CPU, exMemAddr_CPU;
logic [1:0] rwi_in; //read = 10, write = 01, idle = 00
logic fetchReadToMMIO, addrControl, busy_edge, FPUbusy_o;

//outputs of MMIO
logic [31:0] addrToSRAM, dataToSRAM; //addr_out in MMIO 
logic fetchReadToWB, addrControlWB; //makes sure fetch doesnt run twice

//wishbone manager output to wishbone arbitrator
// logic [31:0] addrWMToAr, dataWMToAr;
// // logic [191:0] addrWMToAr;
// logic [3:0] selToAr;
// logic weToAr, stbToAr, cycToAr;

//wishbone arbitrator output to wishbone decoder
logic cycToDec, stbToDec, weToDec;
logic [31:0] addrToDec, dataToDec; 
logic [3:0] selToDec;

//wishbone arbitrator output to wishbone manger
// logic [31:0] dataArToWM;
// logic ackToWM;
//wishbone decoder output to wishbone arbitrator
logic ackToAr;
logic [31:0] dataDecToAr;

//wishbone manager output to user design
logic [31:0] dataToMMIO;
logic busyToMMIO;
logic busyTFT_o;

//outputs of WB decoder
logic cyc_out;
logic stb_out;
logic we_out;
logic [31:0] addr_out; 
logic [31:0] data_out;
logic [3:0] sel_out;

//input SRAM to decoder
logic ackDec_in; //acknowledge
logic [31:0] dataDec_in; //data from SRAM to WB Dec

//outputs to SPI->TFT
logic [31:0] dataToTFT, addrToTFT, MISOtoMMIO;
logic displayWrite, displayRead;

// assign pc2 = programCounter_o[2];
// assign pc3 = programCounter_o[3];


t07_CPU CPU(.busy(busyCPU), .externalMemAddr(exMemAddr_CPU), .exMemData_out(exMemData_CPU), .exInst(instr), .memData_in(memData_in), 
.rwi(rwi_in), .invalError(invalError), .clk(clk), .nrst(nrst), .busy_edge_o(busy_edge));

t07_MMIO MMIO(.clk(clk), .nrst(nrst), .addr_in(exMemAddr_CPU), .memData_i(exMemData_CPU), .rwi_in(rwi_in), .WBData_i(dataToMMIO), 
 .busyTFT_i(busyTFT_o), .CPUData_out(memData_in), .CPU_busy_o(busyCPU), .instr_out(instr), 
 .displayData(dataToTFT), .displayWrite(displayWrite), .displayRead(displayRead), .dataTFT_i(MISOtoMMIO), 
 .WB_read_o(read), .WB_write_o(write), .addr_out(addrToSRAM), .WBData_out(dataToSRAM), .WB_busy_i(busyToMMIO),
 .WB_busy_edge_i(busy_edge));

wishbone_manager wishbone0(.nRST(nrst), .CLK(clk), .DAT_I(dataArToWM), .ACK_I(ackToWM), .CPU_DAT_I(dataToSRAM), 
.ADR_I(addrToSRAM), .SEL_I(4'hF), .WRITE_I(write), .READ_I(read), .ADR_O(addrWMToAr), .DAT_O(dataWMToAr), 
.SEL_O(selToAr), .WE_O(weToAr), .STB_O(stbToAr), .CYC_O(cycToAr), .CPU_DAT_O(dataToMMIO), .BUSY_O(busyToMMIO));

t07_spiTFTHu display(.clk(clk), .nrst(nrst), .MOSI_data(dataToTFT), .read_in(displayRead), .write_in(displayWrite), .MISO_out(MISOtoMMIO), 
.ack(busyTFT_o), .MISO_in(misoDriver_i), .chipSelect(chipSelectTFT), .bitData(bitDataTFT), .sclk(sclkTFT));

endmodule