`default_nettype none
module t03_cputop (
	clk,
	rst,
	ack,
	dataOut,
	data,
	address,
	write,
	read,
	ALUsrc,
	freezePc
);
	input wire clk;
	input wire rst;
	input wire ack;
	input wire [31:0] dataOut;
	output wire [31:0] data;
	output wire [31:0] address;
	output wire write;
	output wire read;
	output wire ALUsrc;
	output wire freezePc;
	wire memRead;
	wire memWrite;
	wire freezeInstr;
	wire addressSrc;
	wire memToReg;
	wire auipc;
	wire regWrite;
	wire zero;
	wire negative;
	wire overflow;
	wire lui;
	wire hit;
	wire next_hit;
	wire cache_read;
	wire [31:0] offset;
	wire [31:0] ALUResult;
	wire [31:0] currentPc;
	wire [31:0] toMemory;
	wire [31:0] instruction;
	wire [31:0] read_data1;
	wire [31:0] read_data2;
	wire [31:0] immediate;
	wire [31:0] cache_out;
	wire [31:0] currentPc_base_address;
	wire [1:0] pcControl;
	wire [1:0] jump;
	wire [2:0] branch;
	wire [2:0] dataWidth;
	wire [3:0] ALUOp;
	assign data = read_data2;
	wire [31:0] instruction_in;
	assign instruction_in = (hit ? cache_out : dataOut);
	t03_pc pc(
		.clk(clk),
		.rst(rst),
		.freezePc(freezePc),
		.offset(immediate),
		.ALUResult(ALUResult),
		.control(pcControl),
		.currentPc(currentPc),
		.currentPc_base_address(currentPc_base_address),
		.toMemory(toMemory)
	);
	t03_requestUnitCached requestUnit(
		.clk(clk),
		.rst(rst),
		.ack(ack),
		.next_hit(next_hit),
		.memRead(memRead),
		.memWrite(memWrite),
		.pcMemory(toMemory),
		.resultALU(ALUResult),
		.read(read),
		.write(write),
		.freezePC(freezePc),
		.freezeInstr(freezeInstr),
		.addressSrc(addressSrc),
		.address(address),
		.cache_read(cache_read)
	);
	t03_instrHolder instrHolder(
		.clk(clk),
		.rst(rst),
		.instruction_in(instruction_in),
		.freezeInstr(freezeInstr),
		.instruction(instruction)
	);
	t03_control control(
		.opcode(instruction[6:0]),
		.funct3(instruction[14:12]),
		.funct7bit6(instruction[30]),
		.branch(branch),
		.jump(jump),
		.memRead(memRead),
		.memToReg(memToReg),
		.ALUOp(ALUOp),
		.auipc(auipc),
		.memWrite(memWrite),
		.dataWidth(dataWidth),
		.ALUsrc(ALUsrc),
		.regWrite(regWrite),
		.lui(lui)
	);
	t03_registerFile registerFile(
		.clk(clk),
		.regwrite(regWrite & ~freezePc),
		.reset(rst),
		.memToReg(memToReg),
		.jal(|jump),
		.instruction(instruction),
		.result_ALU(ALUResult),
		.data_out(dataOut),
		.pc(currentPc),
		.read_data1(read_data1),
		.read_data2(read_data2)
	);
	t03_instruction_cache instruction_cache(
		.clk(clk),
		.rst(rst),
		.input_instruction(dataOut),
		.next_address(toMemory),
		.current_address(currentPc_base_address),
		.hit(hit),
		.cache_out(cache_out),
		.next_hit(next_hit),
		.cache_read(cache_read)
	);
	t03_imm_gen imm_gen(
		.instruction(instruction),
		.immediate(immediate)
	);
	t03_alu alu(
		.control(ALUOp),
		.pc(currentPc),
		.immediate(immediate),
		.rd1(read_data1),
		.rd2(read_data2),
		.ALUSrc(ALUsrc),
		.Auipc(auipc),
		.result(ALUResult),
		.zero(zero),
		.negative(negative),
		.overflow(overflow),
		.lui(lui)
	);
	t03_branchControl branchControl(
		.branch(branch),
		.jump(jump),
		.zero(zero),
		.negative(negative),
		.overflow(overflow),
		.control(pcControl)
	);
endmodule
