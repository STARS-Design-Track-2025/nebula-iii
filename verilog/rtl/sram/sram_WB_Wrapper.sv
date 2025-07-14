// SRAM Wishbone Wrapper

`timescale 1ns/1ps

module sram_WB_Wrapper #(
	parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 10
)
(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif
    // Wishbone slave ports
    input logic wb_clk_i,
    input logic wb_rst_i,
    input logic wbs_stb_i,
    input logic wbs_cyc_i,
    input logic wbs_we_i,
    input logic [3:0] wbs_sel_i,
    input logic [31:0] wbs_dat_i,
    input logic [31:0] wbs_adr_i,
    output logic  wbs_ack_o,
    output logic [31:0] wbs_dat_o
);
    // Declare SRAM ports
    // Write Port
	logic clk0, csb0;
    logic [DATA_WIDTH-1:0] din0;
    logic [ADDR_WIDTH-1:0] addr0;
    // Read Port
    logic clk1, csb1;
    logic [DATA_WIDTH-1:0] dout1;
    logic [ADDR_WIDTH-1:0] addr1;

	// Convert incoming byte address to word address
	logic [31:0] addr_shifted;
	assign addr_shifted = wbs_adr_i >> 2;

    // Indicate Valid Transaction
    logic wb_en;
    assign wb_en = wbs_stb_i & wbs_cyc_i;
	
	// Inputs to SRAM
    assign clk0 = wb_clk_i;
    assign clk1 = wb_clk_i;
    assign csb0 = ~(wb_en & wbs_we_i);  // active low write enable
    assign csb1 = ~(wb_en & ~wbs_we_i);  // active low read enable
    assign addr0 = addr_shifted[ADDR_WIDTH-1:0];
    assign addr1 = addr_shifted[ADDR_WIDTH-1:0];
    assign din0 = wbs_dat_i;

    // TODO: Will there be bit selection?
    // assign bit_en = {{8{wbs_sel_i[3]}}, {8{wbs_sel_i[2]}}, {8{wbs_sel_i[1]}}, {8{wbs_sel_i[0]}}};

    // Outputs from SRAM
    assign wbs_dat_o = dout1;
    always_ff @(posedge wb_clk_i, posedge wb_rst_i) begin
        if (wb_rst_i)
            wbs_ack_o <= 0;
        else if (wb_en & ~wbs_ack_o)
            wbs_ack_o <= 1'b1;
        else
            wbs_ack_o <= 1'b0;
    end

	// SRAM Instance
	sram_32_1024_sky130 sram_inst (
        `ifdef USE_POWER_PINS
            .vccd1(vccd1),	// User area 1 1.8V power
            .vssd1(vssd1),	// User area 1 digital ground
        `endif
        // Write Ports
        .clk0(clk0),
        .csb0(csb0),
        .addr0(addr0),
        .din0(din0),
        // Read Ports
        .clk1(clk1),
        .csb1(csb1),
        .addr1(addr1),
        .dout1(dout1)
	);

endmodule