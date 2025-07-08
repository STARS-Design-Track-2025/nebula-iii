module datapath(
<<<<<<< HEAD
    input  logic clk,
    input  logic rst,
    input  logic ALUSrc,
    input  logic Branch,
    input  logic MemRead,
    input  logic MemWrite,
    input  logic [1:0] ALU_control,

    input  logic [31:0] instruction,
    input  logic [31:0] read_data,

    output logic [31:0] PC,
    output logic [31:0] mem_address,
    output logic [31:0] write_data
);
    logic [4:0] Reg1,
    logic [4:0] Reg2,
    logic [4:0] RegD,
    logic [31:0] Imm,
    logic Jal,
    logic Jalr,
    logic MemToReg,
    logic RegWrite,
    logic Freeze
    logic [31:0] PC_plus4;
    logic [31:0] PC_Jalr;
    logic [31:0] src_A, src_B;
    logic [31:0] ALU_result;
    logic [31:0] write_back_data;
    logic BranchConditionFlag;

    assign PC_plus4 = PC + 32'd4;

    register_file rf (
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

    control_unit cu (
        // inputs
        .BranchConditionFlag(BranchConditionFlag),
        .instruction(instruction),
        .ALU_result(ALU_result),
        // outputs
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
    // multiplexer
    assign ALU_input_B = (ALUSrc || Jalr) ? Imm : src_B;

    ALU alu (
        .src_A(src_A),
        .src_B(ALU_input_B),
        .instruction(instruction),
        .ALU_control(ALU_control),
        .ALU_result(ALU_result),
        .BranchConditionFlag(BranchConditionFlag)
    );

    assign PC_Jalr = ALU_result;
    assign mem_address = ALU_result;
    assign write_data  = src_B;

    logic [31:0] result_or_pc4;
    assign result_or_pc4 = (Jal | Jalr) ? PC_plus4 : ALU_result;

    assign write_back_data = (MemToReg) ? read_data : result_or_pc4;

    // === Instantiate PC module ===
    PC pc_module (
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

endmodule

=======
input  logic clk,
input  logic rst,
input  logic i_ack,
input  logic d_ack,
input  logic [31:0] instruction,
input  logic [31:0] memload,
output logic [31:0] i_address,
output logic [31:0] d_address,
output logic [31:0] mem_store
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
logic [1:0] ALU_control;
logic Freeze;
logic [31:0] PC;
logic [31:0] PC_plus4;
logic [31:0] PC_Jalr;
logic [31:0] src_A, src_B;
logic [31:0] ALU_result;
logic [31:0] write_back_data;
logic BranchConditionFlag;

assign PC_plus4 = PC + 32'd4;

register_file rf(
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

control_unit cu(
.BranchConditionFlag(BranchConditionFlag),
.instruction(instruction),
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

ALU alu(
.src_A(src_A),
.src_B(ALU_input_B),
.instruction(instruction),
.ALU_control(ALU_control),
.ALU_result(ALU_result),
.BranchConditionFlag(BranchConditionFlag)
);

assign PC_Jalr = ALU_result;

logic [31:0] result_or_pc4;
assign result_or_pc4 = (Jal || Jalr) ? PC_plus4 : ALU_result;

assign write_back_data = (MemToReg) ? memload : result_or_pc4;

PC pc_module(
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

request_unit ru(
    .clk(clk),
    .rst(rst),
    .i_ack(i_ack),
    .d_ack(d_ack),
    .PC(PC),
    .mem_address(ALU_result),
    .stored_data(src_B),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .i_address(i_address),
    .d_address(d_address),
    .mem_store(mem_store),
    .freeze(Freeze)
);

endmodule
>>>>>>> a71e555e5c7f0c655ef566e9ea7adba670e17709
