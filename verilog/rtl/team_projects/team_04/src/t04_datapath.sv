module t04_datapath(
    input  logic clk,
    input  logic rst,
    input  logic i_ack,
    input  logic d_ack,
    input  logic [31:0] instruction,
    input  logic [31:0] memload,
    output logic [31:0] final_address,
    output logic [31:0] mem_store,
    output logic MemRead_O,
    output logic MemWrite_O
);

logic [4:0] Reg1;
logic [4:0] Reg2;
logic [4:0] RegD;
logic [31:0] Imm;
logic Jal;
logic Jalr;
logic MemToReg;
logic RegWrite;
logic ALUSrc;
logic Branch;
logic MemRead;
logic MemWrite;
logic ALU_control;
logic Freeze;
logic [31:0] PC;
logic [31:0] PC_plus4;
logic [31:0] PC_Jalr;
logic [31:0] src_A, src_B;
logic [31:0] ALU_result;
logic [31:0] write_back_data;
logic [31:0] instruction_out;
logic BranchConditionFlag;

assign PC_plus4 = PC + 32'd4;

t04_register_file rf(
    .clk(clk),
    .rst(rst),
    .reg_write(RegWrite),
    .reg1(Reg1),
    .reg2(Reg2),
    .regd(RegD),
    .write_data(write_back_data),
    .read_data1(src_A),
    .read_data2(src_B)
);

t04_control_unit cu(
    .BranchConditionFlag(BranchConditionFlag),
    .instruction(instruction_out),
    .ALU_result(ALU_result),
    .RegWrite(RegWrite),
    .ALUSrc(ALUSrc),
    .Branch(Branch),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .MemToReg(MemToReg),
    .Jal(Jal),
    .Jalr(Jalr),
    .Imm(Imm),
    .ALU_control(ALU_control),
    .RegD(RegD),
    .Reg2(Reg2),
    .Reg1(Reg1)
);

logic [31:0] ALU_input_B;
assign ALU_input_B = (ALUSrc || Jalr) ? Imm : src_B;

t04_ALU alu(
    .src_A(src_A),
    .src_B(ALU_input_B),
    .instruction(instruction_out),
    .ALU_control(ALU_control),
    .ALU_result(ALU_result),
    .BranchConditionFlag(BranchConditionFlag)
);

assign PC_Jalr = ALU_result;

logic [31:0] result_or_pc4;
assign result_or_pc4 = (Jal || Jalr) ? PC_plus4 : ALU_result;

assign write_back_data = (MemToReg) ? memload : result_or_pc4;

t04_PC pc_module(
    .clk(clk),
    .rst(rst),
    .PC_Jalr(PC_Jalr),
    .Jalr(Jalr),
    .Jal(Jal),
    .Branch(Branch),
    .Freeze(Freeze),
    .imm(Imm),
    .PC(PC)
);

t04_request_unit ru(
    .clk(clk), .rst(rst),
    .i_ack(i_ack), .d_ack(d_ack),
    .instruction_in(instruction),
    .PC(PC),
    .mem_address(ALU_result),
    .stored_data(src_B),
    .MemRead(MemRead), .MemWrite(MemWrite),
    .final_address(final_address),
    .instruction_out(instruction_out),
    .mem_store(mem_store),
    .freeze(Freeze)
);

assign MemRead_O = MemRead;
assign MemWrite_O = MemWrite;

endmodule
