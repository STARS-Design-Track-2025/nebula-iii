`default_nettype none
module t03_MMIOInterface (
	rst,
	clk,
	data,
	address,
	write,
	read,
	NESData,
	NESConfirm,
	new_counter,
	dataOut,
	ack,
	p1Left,
	p2Left,
	gameState,
	p1State,
	p2State,
	p1health,
	p2health,
	x1,
	x2,
	y1,
	y2,
	ADR_O,
	DAT_O,
	SEL_O,
	WE_O,
	STB_O,
	CYC_O,
	DAT_I,
	ACK_I
);
	input wire rst;
	input wire clk;
	input wire [31:0] data;
	input wire [31:0] address;
	input wire write;
	input wire read;
	input wire [31:0] NESData;
	input wire NESConfirm;
	input wire [31:0] new_counter;
	output wire [31:0] dataOut;
	output wire ack;
	output wire p1Left;
	output wire p2Left;
	output wire [2:0] gameState;
	output wire [1:0] p1State;
	output wire [1:0] p2State;
	output wire [3:0] p1health;
	output wire [3:0] p2health;
	output wire [10:0] x1;
	output wire [10:0] x2;
	output wire [10:0] y1;
	output wire [10:0] y2;
	output wire [31:0] ADR_O;
	output wire [31:0] DAT_O;
	output wire [3:0] SEL_O;
	output wire WE_O;
	output wire STB_O;
	output wire CYC_O;
	input wire [31:0] DAT_I;
	input wire ACK_I;
	wire n_rst;
	assign n_rst = ~rst;
	wire busy;
	wire [31:0] wb_di;
	wire wb_ack;
	wire [31:0] NES_din;
	wire NES_ack;
	assign NES_din = NESData;
	assign NES_ack = NESConfirm;
	wire collide_ack;
	wire [31:0] collide_din;
	wire [31:0] wb_do;
	wire [31:0] wb_addro;
	wire [3:0] wb_sel;
	wire wb_wen;
	wire wb_ren;
	wire [31:0] dpu_addro;
	wire [31:0] dpu_d;
	wire [31:0] hardwareClk_to_CPU;
	wire hardware_ack;
	t03_dpuxmmio dpummio(
		.addr(dpu_addro),
		.data(dpu_d),
		.clk(clk),
		.rst(rst),
		.gameState(gameState),
		.p1State(p1State),
		.p2State(p2State),
		.p1health(p1health),
		.p2health(p2health),
		.x1(x1),
		.y1(y1),
		.x2(x2),
		.y2(y2),
		.p1Left(p1Left),
		.p2Left(p2Left)
	);
	t03_MMIO mmio(
		.clk(clk),
		.rst(rst),
		.wb_di(wb_di),
		.wb_ack(wb_ack),
		.cpu_din(data),
		.cpu_addr(address),
		.cpu_wen(write),
		.cpu_ren(read),
		.NES_din(NES_din),
		.NES_ack(NES_ack),
		.hardwareClk(new_counter),
		.hardware_ack(1'b1),
		.wb_do(wb_do),
		.wb_addro(wb_addro),
		.wb_sel(wb_sel),
		.wb_wen(wb_wen),
		.wb_ren(wb_ren),
		.cpu_do(dataOut),
		.cpu_ack(ack),
		.dpu_addro(dpu_addro),
		.dpu_do(dpu_d)
	);
	t03_wishbone_manager manager(
		.nRST(n_rst),
		.CLK(clk),
		.DAT_I(DAT_I),
		.ACK_I(ACK_I),
		.CPU_DAT_I(wb_do),
		.ADR_I({8'h33, wb_addro[23:0]}),
		.SEL_I(wb_sel),
		.WRITE_I(wb_wen),
		.READ_I(wb_ren),
		.ADR_O(ADR_O),
		.DAT_O(DAT_O),
		.SEL_O(SEL_O),
		.WE_O(WE_O),
		.STB_O(STB_O),
		.CYC_O(CYC_O),
		.CPU_DAT_O(wb_di),
		.BUSY_O(busy),
		.ACK_O(wb_ack)
	);
endmodule
