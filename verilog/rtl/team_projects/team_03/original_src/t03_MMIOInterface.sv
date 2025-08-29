`default_nettype none
`timescale 1ps/1ps

module t03_MMIOInterface(
    input logic rst,
    input logic clk,
    input logic [31:0] data,
    input logic [31:0] address,
    input logic write,
    input logic read,
    input logic [31:0] NESData,
    input logic NESConfirm,
    input logic [31:0] new_counter,

    output logic [31:0] dataOut,
    output logic ack, p1Left, p2Left,

    output logic [2:0] gameState,
    output logic [1:0] p1State,
    output logic [1:0] p2State,
    output logic [3:0] p1health,
    output logic [3:0] p2health,
    output logic [10:0] x1,x2,y1,y2,

    // WISHBONE SIGNALS
    output logic [31:0] ADR_O,
    output logic [31:0] DAT_O,
    output logic [3:0]  SEL_O,
    output logic        WE_O,
    output logic        STB_O,
    output logic        CYC_O,
    input logic [31:0]  DAT_I,
    input logic         ACK_I
);
    logic n_rst;
    assign n_rst = ~rst;

    logic busy; //We don't really use this

    //wishbone inputs
    logic  [31:0] wb_di; //wishbone data in
    logic  wb_ack;

    //NES controller inputs
    logic [31:0] NES_din;
    logic NES_ack; 

    assign NES_din = NESData; //NES data
    assign NES_ack = NESConfirm; //NES confirm

    //DPU inputs
    logic collide_ack;
    logic [31:0] collide_din;

    //output to wishbone
    logic [31:0] wb_do;
    logic [31:0] wb_addro;
    logic [3:0]  wb_sel; //assign to 4'b1111  
    logic        wb_wen;
    logic        wb_ren;

    //output to DPU
    logic [31:0] dpu_addro; //address that is decoded in dpu to go to either positional or not positional
    logic [31:0] dpu_d;

    //Hardware Clk to MMIO
    logic [31:0] hardwareClk_to_CPU;
    logic hardware_ack;

    // logic [1:0] gameState, p1State, p2State;
    // logic [4:0] p1health, p2health;
    
    
    //DPU Data Path
    t03_dpuxmmio dpummio(.addr(dpu_addro), .data(dpu_d), .clk(clk), .rst(rst), 
    .gameState(gameState), .p1State(p1State), .p2State(p2State), .p1health(p1health), .p2health(p2health), .x1(x1), .y1(y1), .x2(x2), .y2(y2), .p1Left(p1Left), .p2Left(p2Left));

    t03_MMIO mmio(.clk(clk), .rst(rst),
    .wb_di(wb_di), .wb_ack(wb_ack), //Wishbone inputs
    .cpu_din(data), .cpu_addr(address), .cpu_wen(write), .cpu_ren(read), //cpu inputs
    .NES_din(NES_din), .NES_ack(NES_ack), //NES controller inputs
    .hardwareClk(new_counter), .hardware_ack(1'b1), //Hardware Clk input
    .wb_do(wb_do), .wb_addro(wb_addro), .wb_sel(wb_sel), .wb_wen(wb_wen), .wb_ren(wb_ren), //Wishbone outputs
    .cpu_do(dataOut), .cpu_ack(ack), //CPU Outputs
    .dpu_addro(dpu_addro), .dpu_do(dpu_d)
    );

    t03_wishbone_manager manager(.nRST(n_rst), .CLK(clk), 
    .DAT_I(DAT_I), .ACK_I(ACK_I), //WISHBONE INPUT SIGNALS
    .CPU_DAT_I(wb_do), .ADR_I({8'h33, wb_addro[23:0]}), .SEL_I(wb_sel), .WRITE_I(wb_wen), .READ_I(wb_ren), //input from user design
    .ADR_O(ADR_O), .DAT_O(DAT_O), .SEL_O(SEL_O), .WE_O(WE_O), .STB_O(STB_O), .CYC_O(CYC_O),  //WISHBONE OUTPUT SIGNALS
    .CPU_DAT_O(wb_di), .BUSY_O(busy), .ACK_O(wb_ack) //output to user design
    );

    // sram_WB_Wrapper SRAM (.wb_clk_i(clk), .wb_rst_i(rst), .wbs_stb_i(STB_O), .wbs_cyc_i(CYC_O), //Inputs
    // .wbs_we_i(WE_O), .wbs_sel_i(SEL_O), .wbs_dat_i(DAT_O), .wbs_adr_i(ADR_O), //Inputs
    // .wbs_ack_o(ACK_I), .wbs_dat_o(DAT_I) //Outputs
    // );

endmodule