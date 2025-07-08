module datapath(
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

