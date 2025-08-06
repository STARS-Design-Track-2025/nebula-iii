`default_nettype none
module t05_top (
	hwclk,
	reset,
	mosi,
	miso,
	wbs_stb_o,
	wbs_cyc_o,
	wbs_we_o,
	wbs_sel_o,
	wbs_dat_o,
	wbs_adr_o,
	wbs_ack_i,
	wbs_dat_i
);
	reg _sv2v_0;
	input wire hwclk;
	input wire reset;
	output wire mosi;
	input wire miso;
	output wire wbs_stb_o;
	output wire wbs_cyc_o;
	output wire wbs_we_o;
	output wire [3:0] wbs_sel_o;
	output wire [31:0] wbs_dat_o;
	output wire [31:0] wbs_adr_o;
	input wire wbs_ack_i;
	input wire [31:0] wbs_dat_i;
	wire serial_clk;
	wire sclk;
	wire [8:0] least1_FLV;
	wire [8:0] least2_FLV;
	wire [63:0] sum;
	wire [5:0] op_fin;
	wire cont_en;
	wire finished_signal;
	wire [3:0] en_state;
	wire [1:0] wr;
	wire readEn;
	wire spi_confirm_out;
	wire read_in_pulse;
	wire [6:0] in;
	wire [31:0] sram_in;
	wire [31:0] sram_out;
	wire [7:0] hist_addr;
	wire out_of_init;
	wire busy_o;
	wire nextChar;
	wire init;
	assign mosi = 0;
	wire [31:0] totChar;
	wire [6:0] max_index;
	wire [63:0] nulls;
	wire SRAM_finished;
	wire [70:0] node_reg;
	wire [6:0] nullSumIndex;
	wire WorR;
	wire [70:0] h_element;
	wire char_found;
	wire [7:0] char;
	wire [7:0] char_index;
	wire write_finish;
	wire [127:0] char_path;
	wire [6:0] track_length;
	wire [8:0] least1_CB;
	wire [8:0] least2_CB;
	wire [7:0] cw1;
	wire [7:0] cw2;
	wire [8:0] histo_index;
	wire [63:0] compVal;
	wire flv_r_wr;
	wire [127:0] path;
	wire [6:0] curr_index;
	wire SRAM_enable;
	wire cb_r_wr;
	wire writeBit_HS;
	wire writeBit_TL;
	wire flag;
	reg [6:0] read_out;
	wire HT_fin_reg;
	wire fin_state_idle;
	wire fin_state_HG;
	wire fin_state_FLV;
	wire fin_state_HT;
	wire fin_state_CB;
	wire fin_state_TL;
	wire fin_state_SPI;
	assign fin_state_idle = 1;
	wire nextCharEn;
	wire writeEn_HS;
	wire writeEn_TL;
	wire [7:0] fin_State;
	assign fin_State = {fin_state_idle, fin_state_HG, fin_state_FLV, HT_fin_reg, fin_state_HT, fin_state_CB, fin_state_TL, 1'sb0};
	assign fin_state_SPI = 0;
	wire write_i;
	wire read_i;
	wire [31:0] addr_i;
	wire [3:0] sel_i;
	wire [31:0] data_i_wish;
	wire [31:0] data_o_wish;
	wishbone_manager WB(
		.nRST(!reset),
		.CLK(hwclk),
		.DAT_I(wbs_dat_i),
		.ACK_I(wbs_ack_i),
		.CPU_DAT_I(data_i_wish),
		.ADR_I(addr_i),
		.SEL_I(sel_i),
		.WRITE_I(write_i),
		.READ_I(read_i),
		.ADR_O(wbs_adr_o),
		.DAT_O(wbs_dat_o),
		.SEL_O(wbs_sel_o),
		.WE_O(wbs_we_o),
		.STB_O(wbs_stb_o),
		.CYC_O(wbs_cyc_o),
		.CPU_DAT_O(data_o_wish),
		.BUSY_O(busy_o)
	);
	wire hist_read_latch;
	wire pulse_FLV;
	wire nextChar_FLV;
	wire FLV_done;
	wire wipe_the_char_1;
	wire wipe_the_char_2;
	wire write_HT_fin;
	wire pulse_HTREE;
	wire HT_complete;
	wire [3:0] HT_state;
	wire sum_2;
	wire HT_read_complete;
	wire CB_read_complete;
	wire CB_write_complete;
	wire pulse_CB;
	wire HT_over_complete;
	wire [7:0] TRN_char_index;
	wire pulse_TRN;
	wire TRN_sram_complete;
	wire [5:0] ctrl_state;
	wire [31:0] hist_data_o;
	wire [3:0] word_cnt;
	t05_sram_interface sram_interface(
		.clk(hwclk),
		.rst(reset),
		.histogram(sram_out),
		.histgram_addr(hist_addr),
		.hist_r_wr(wr),
		.find_least(histo_index),
		.charwipe1(cw1),
		.charwipe2(cw2),
		.flv_r_wr(flv_r_wr),
		.pulse_FLV(pulse_FLV),
		.FLV_done(FLV_done),
		.wipe_the_char_1(wipe_the_char_1),
		.wipe_the_char_2(wipe_the_char_2),
		.new_node(node_reg),
		.htreeindex(nullSumIndex),
		.htree_write(max_index),
		.htree_r_wr(WorR),
		.hist_read_latch(hist_read_latch),
		.pulse_HTREE(pulse_HTREE),
		.HT_state(HT_state),
		.least1_HTREE(least1_FLV),
		.least2_HTREE(least2_FLV),
		.curr_index({1'd0, curr_index}),
		.char_index(char_index),
		.codebook_path(char_path),
		.cb_r_wr(cb_r_wr),
		.pulse_CB(pulse_CB),
		.translation(TRN_char_index),
		.pulse_TRN(pulse_TRN),
		.state(en_state),
		.data_o(data_o_wish),
		.busy_o(busy_o),
		.wr_en(write_i),
		.r_en(read_i),
		.select(sel_i),
		.addr(addr_i),
		.data_i(data_i_wish),
		.nulls(nulls),
		.ht_done(SRAM_finished),
		.write_HT_fin(write_HT_fin),
		.HTREE_complete(HT_complete),
		.HT_read_complete(HT_read_complete),
		.HT_over_complete(HT_over_complete),
		.sum_2(sum_2),
		.old_char(hist_data_o),
		.init(init),
		.nextChar(nextChar),
		.comp_val(compVal),
		.nextChar_FLV(nextChar_FLV),
		.word_cnt(word_cnt),
		.h_element(h_element),
		.cb_done(SRAM_enable),
		.CB_read_complete(CB_read_complete),
		.CB_write_complete(CB_write_complete),
		.path(path),
		.TRN_complete(TRN_sram_complete),
		.ctrl_done(ctrl_state)
	);
	localparam [0:0] sv2v_uu_controller_ext_restart_en_0 = 1'sb0;
	t05_controller controller(
		.clk(hwclk),
		.rst(reset),
		.cont_en(cont_en),
		.restart_en(sv2v_uu_controller_ext_restart_en_0),
		.finState(fin_State),
		.op_fin(ctrl_state),
		.fin_idle(fin_state_idle),
		.fin_HG(fin_state_HG),
		.fin_FLV(fin_state_FLV),
		.fin_HT(HT_fin_reg),
		.fin_FINISHED(fin_state_HT),
		.fin_CBS(fin_state_CB),
		.fin_TRN(fin_state_TL),
		.fin_SPI(fin_state_SPI),
		.state_reg(en_state),
		.finished_signal(finished_signal)
	);
	wire [7:0] out;
	wire out_valid;
	wire [2:0] leftover_count;
	wire [6:0] leftover_data;
	t05_bytecount dut(
		.clk(hwclk),
		.en(1'd1),
		.nrst(!reset),
		.pulse(read_in_pulse),
		.in(in),
		.out(out),
		.out_valid(out_valid),
		.leftover_data(leftover_data),
		.leftover_count(leftover_count)
	);
	always @(*) begin
		if (_sv2v_0)
			;
		read_out = 1'sb0;
		if (read_in_pulse)
			read_out = in;
	end
	t05_histogram histogram(
		.clk(hwclk),
		.rst(reset),
		.busy_i(busy_o),
		.init(init),
		.pulse(read_in_pulse),
		.en_state(en_state),
		.spi_in({1'd0, read_out}),
		.write_i(write_i),
		.read_i(read_i),
		.sram_in(hist_data_o),
		.eof(fin_state_HG),
		.out_valid(out_valid),
		.out(out),
		.complete(readEn),
		.total(totChar),
		.sram_out(sram_out),
		.hist_addr(hist_addr),
		.wr_r_en(wr),
		.get_data(hist_read_latch),
		.confirm(spi_confirm_out),
		.out_of_init(out_of_init)
	);
	t05_findLeastValue findLeastValue(
		.clk(hwclk),
		.rst(reset),
		.compVal(compVal),
		.en_state(en_state),
		.sum(sum),
		.charWipe1(cw1),
		.charWipe2(cw2),
		.least1(least1_FLV),
		.least2(least2_FLV),
		.histo_index(histo_index),
		.fin_state(fin_state_FLV),
		.flv_r_wr(flv_r_wr),
		.pulse_FLV(pulse_FLV),
		.nextChar(nextChar_FLV),
		.word_cnt(word_cnt),
		.FLV_done(FLV_done),
		.wipe_the_char_1(wipe_the_char_1),
		.wipe_the_char_2(wipe_the_char_2),
		.HTREE_complete(HT_complete),
		.HT_fin(HT_fin_reg)
	);
	t05_hTree hTree(
		.clk(hwclk),
		.rst_n(reset),
		.least1(least1_FLV),
		.least2(least2_FLV),
		.sum(sum),
		.nulls(nulls),
		.HT_en(en_state),
		.SRAM_finished(SRAM_finished),
		.node_reg(node_reg),
		.clkCount(max_index),
		.nullSumIndex(nullSumIndex),
		.WriteorRead(WorR),
		.HT_Finished(fin_state_HT),
		.HT_fin_reg(HT_fin_reg),
		.write_HT_fin(write_HT_fin),
		.pulse(pulse_HTREE),
		.sram_complete(HT_complete),
		.state(HT_state),
		.read_complete(HT_read_complete),
		.sum_2(sum_2),
		.over_complete(HT_over_complete)
	);
	wire [127:0] curr_path;
	wire left;
	wire [7:0] num_lefts;
	wire [8:0] header;
	wire state_3;
	t05_cb_synthesis cb_syn(
		.clk(hwclk),
		.rst(reset),
		.max_index(max_index),
		.h_element(h_element),
		.write_finish(write_finish),
		.en_state(en_state),
		.char_found(char_found),
		.char_path(char_path),
		.char_index(char_index),
		.curr_index(curr_index),
		.state_3(state_3),
		.curr_path(curr_path),
		.num_lefts(num_lefts),
		.left(left),
		.finished(fin_state_CB),
		.track_length(track_length),
		.SRAM_enable(SRAM_enable),
		.read_complete(CB_read_complete),
		.write_complete(CB_write_complete),
		.pulse(pulse_CB),
		.cb_r_wr(cb_r_wr)
	);
	t05_header_synthesis header_synthesis(
		.clk(hwclk),
		.rst(reset),
		.char_index(char_index),
		.char_found(char_found),
		.curr_path(curr_path),
		.track_length(track_length),
		.state_3(state_3),
		.left(left),
		.num_lefts(num_lefts),
		.header(header),
		.enable(writeEn_HS),
		.bit1(writeBit_HS),
		.write_finish(write_finish)
	);
	t05_translation translation(
		.clk(hwclk),
		.rst(reset),
		.totChar(totChar),
		.charIn({1'd0, read_out}),
		.path(path),
		.writeBin(writeBit_TL),
		.writeEn(writeEn_TL),
		.nextCharEn(nextCharEn),
		.en_state(en_state),
		.fin_state(fin_state_TL),
		.pulse(pulse_TRN),
		.sram_complete(TRN_sram_complete),
		.char_index(TRN_char_index),
		.word_cnt(word_cnt)
	);
	initial _sv2v_0 = 0;
endmodule
