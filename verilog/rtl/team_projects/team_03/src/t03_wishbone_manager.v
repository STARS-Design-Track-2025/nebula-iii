`default_nettype none
module t03_wishbone_manager (
	nRST,
	CLK,
	DAT_I,
	ACK_I,
	CPU_DAT_I,
	ADR_I,
	SEL_I,
	WRITE_I,
	READ_I,
	ADR_O,
	DAT_O,
	SEL_O,
	WE_O,
	STB_O,
	CYC_O,
	CPU_DAT_O,
	BUSY_O,
	ACK_O
);
	reg _sv2v_0;
	input wire nRST;
	input wire CLK;
	input wire [31:0] DAT_I;
	input wire ACK_I;
	input wire [31:0] CPU_DAT_I;
	input wire [31:0] ADR_I;
	input wire [3:0] SEL_I;
	input wire WRITE_I;
	input wire READ_I;
	output reg [31:0] ADR_O;
	output reg [31:0] DAT_O;
	output reg [3:0] SEL_O;
	output reg WE_O;
	output reg STB_O;
	output reg CYC_O;
	output reg [31:0] CPU_DAT_O;
	output reg BUSY_O;
	output wire ACK_O;
	reg [1:0] curr_state;
	reg [1:0] next_state;
	reg [31:0] next_ADR_O;
	reg [31:0] next_DAT_O;
	reg [3:0] next_SEL_O;
	reg next_WE_O;
	reg next_STB_O;
	reg next_CYC_O;
	reg [31:0] next_CPU_DAT_O;
	reg next_BUSY_O;
	assign ACK_O = ACK_I;
	always @(posedge CLK or negedge nRST) begin : All_ffs
		if (~nRST) begin
			curr_state <= 2'd0;
			CPU_DAT_O <= 1'sb0;
			BUSY_O <= 1'sb0;
			ADR_O <= 1'sb0;
			DAT_O <= 1'sb0;
			SEL_O <= 1'sb0;
			WE_O <= 1'sb0;
			STB_O <= 1'sb0;
			CYC_O <= 1'sb0;
		end
		else begin
			curr_state <= next_state;
			CPU_DAT_O <= next_CPU_DAT_O;
			BUSY_O <= next_BUSY_O;
			ADR_O <= next_ADR_O;
			DAT_O <= next_DAT_O;
			SEL_O <= next_SEL_O;
			WE_O <= next_WE_O;
			STB_O <= next_STB_O;
			CYC_O <= next_CYC_O;
		end
	end
	always @(*) begin
		if (_sv2v_0)
			;
		next_state = curr_state;
		next_ADR_O = ADR_O;
		next_DAT_O = DAT_O;
		next_SEL_O = SEL_O;
		next_WE_O = WE_O;
		next_STB_O = STB_O;
		next_CYC_O = CYC_O;
		next_BUSY_O = BUSY_O;
		case (curr_state)
			2'd0: begin
				if (WRITE_I && !READ_I) begin
					next_BUSY_O = 1'b1;
					next_state = 2'd1;
				end
				if (!WRITE_I && READ_I) begin
					next_BUSY_O = 1'b1;
					next_state = 2'd2;
				end
			end
			2'd1: begin
				next_ADR_O = ADR_I;
				next_DAT_O = CPU_DAT_I;
				next_SEL_O = SEL_I;
				next_WE_O = 1'b1;
				next_STB_O = 1'b1;
				next_CYC_O = 1'b1;
				next_BUSY_O = 1'b1;
				if (ACK_I) begin
					next_state = 2'd0;
					next_ADR_O = 1'sb0;
					next_DAT_O = 1'sb0;
					next_SEL_O = 1'sb0;
					next_WE_O = 1'sb0;
					next_STB_O = 1'sb0;
					next_CYC_O = 1'sb0;
					next_BUSY_O = 1'sb0;
				end
			end
			2'd2: begin
				next_ADR_O = ADR_I;
				next_DAT_O = 1'sb0;
				next_SEL_O = SEL_I;
				next_WE_O = 1'sb0;
				next_STB_O = 1'b1;
				next_CYC_O = 1'b1;
				next_BUSY_O = 1'b1;
				if (ACK_I) begin
					next_state = 2'd0;
					next_ADR_O = 1'sb0;
					next_DAT_O = 1'sb0;
					next_SEL_O = 1'sb0;
					next_WE_O = 1'sb0;
					next_STB_O = 1'sb0;
					next_CYC_O = 1'sb0;
					next_BUSY_O = 1'sb0;
				end
			end
			default: next_state = curr_state;
		endcase
	end
	reg prev_BUSY_O;
	wire BUSY_O_edge;
	always @(posedge CLK or negedge nRST) begin : BUSY_O_edge_detector
		if (!nRST)
			prev_BUSY_O <= 1'sb0;
		else
			prev_BUSY_O <= BUSY_O;
	end
	assign BUSY_O_edge = !BUSY_O && prev_BUSY_O;
	always @(*) begin
		if (_sv2v_0)
			;
		next_CPU_DAT_O = 32'hbad1bad1;
		if ((curr_state == 2'd2) && ACK_I)
			next_CPU_DAT_O = DAT_I;
		else if (BUSY_O_edge)
			next_CPU_DAT_O = CPU_DAT_O;
	end
	initial _sv2v_0 = 0;
endmodule
