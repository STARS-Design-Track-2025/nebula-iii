`default_nettype none
module t03_MMIO (
	clk,
	rst,
	wb_di,
	wb_ack,
	cpu_din,
	cpu_addr,
	cpu_wen,
	cpu_ren,
	NES_din,
	NES_ack,
	hardwareClk,
	hardware_ack,
	wb_do,
	wb_addro,
	wb_sel,
	wb_wen,
	wb_ren,
	cpu_do,
	cpu_ack,
	dpu_addro,
	dpu_do
);
	reg _sv2v_0;
	input wire clk;
	input wire rst;
	input wire [31:0] wb_di;
	input wire wb_ack;
	input wire [31:0] cpu_din;
	input wire [31:0] cpu_addr;
	input wire cpu_wen;
	input wire cpu_ren;
	input wire [31:0] NES_din;
	input wire NES_ack;
	input wire [31:0] hardwareClk;
	input wire hardware_ack;
	output reg [31:0] wb_do;
	output reg [31:0] wb_addro;
	output wire [3:0] wb_sel;
	output reg wb_wen;
	output reg wb_ren;
	output wire [31:0] cpu_do;
	output reg cpu_ack;
	output reg [31:0] dpu_addro;
	output reg [31:0] dpu_do;
	reg address_enable;
	reg [31:0] peripheral_output;
	assign cpu_do = (address_enable ? peripheral_output : wb_di);
	assign wb_sel = 4'b1111;
	reg n_address_enable;
	reg [31:0] n_peripheral_output;
	always @(posedge clk or posedge rst)
		if (rst) begin
			address_enable <= 1'b0;
			peripheral_output <= 32'b00000000000000000000000000000000;
		end
		else begin
			address_enable <= n_address_enable;
			peripheral_output <= n_peripheral_output;
		end
	always @(*) begin
		if (_sv2v_0)
			;
		cpu_ack = 0;
		dpu_addro = cpu_addr;
		dpu_do = cpu_din;
		wb_addro = 32'b00000000000000000000000000000000;
		wb_ren = 1'b0;
		wb_wen = 1'b0;
		wb_do = 32'b00000000000000000000000000000000;
		cpu_ack = 1'b0;
		n_address_enable = address_enable;
		n_peripheral_output = peripheral_output;
		case (cpu_addr)
			32'hff000000: begin
				cpu_ack = NES_ack;
				n_peripheral_output = NES_din;
				if (NES_ack)
					n_address_enable = 1'b1;
			end
			32'hff000004: cpu_ack = 1'b1;
			32'hff000008: cpu_ack = 1'b1;
			32'hff00000c: begin
				cpu_ack = hardware_ack;
				n_peripheral_output = hardwareClk;
				if (hardware_ack)
					n_address_enable = 1'b1;
			end
			default: begin
				wb_addro = cpu_addr;
				wb_ren = cpu_ren;
				wb_wen = cpu_wen;
				wb_do = cpu_din;
				cpu_ack = wb_ack;
				if (wb_ack)
					n_address_enable = 1'b0;
			end
		endcase
	end
	initial _sv2v_0 = 0;
endmodule
