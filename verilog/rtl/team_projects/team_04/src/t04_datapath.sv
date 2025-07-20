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
logic [31:0] n_PC;
logic MUL_EN;
logic [31:0] mulitply_result;
logic ack_mul;
logic mul_freeze;
logic main_freeze;
logic zero_multi;

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
    .instruction(instruction_out),
    .ALU_result(ALU_result),
    .RegWrite(RegWrite),
    .ALUSrc(ALUSrc),
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
    .BranchConditionFlag(BranchConditionFlag),
    .MUL_EN(MUL_EN)
);

t04_multiplication multiplication_module(
.clk(clk),
.rst(rst),
.mul(MUL_EN),
.multiplicand(src_A),
.multiplier(src_B),
.product(mulitply_result),
.ack_mul(ack_mul),
.zero_multi(zero_multi)
);

assign PC_Jalr = ALU_result;

logic [31:0] result_or_pc4;

always_comb begin 
    if (MUL_EN) begin
        result_or_pc4 = mulitply_result;
    end
    else begin
        result_or_pc4 = (Jal || Jalr) ? PC_plus4 : ALU_result;
    end
    if (zero_multi) begin
        main_freeze = 0;
    end
    else if (~(MUL_EN && ack_mul)) begin
        main_freeze = Freeze || mul_freeze;
    end
    else begin
        main_freeze = 0;
    end
end

assign mul_freeze = (MUL_EN) ? (~ack_mul) : 0;
assign write_back_data = (MemToReg) ? memload : result_or_pc4;


t04_PC pc_module(
    .clk(clk),
    .rst(rst),
    .PC_Jalr(PC_Jalr),
    .Jalr(Jalr),
    .Jal(Jal),
    .Branch(BranchConditionFlag),
    .Freeze(main_freeze),
    .imm(Imm),
    .PC(PC),
    .n_PC(n_PC)
);

t04_request_unit_old ru(
    .clk(clk), .rst(rst),
    .i_ack(i_ack), .d_ack(d_ack),
    .instruction_in(instruction),
    .PC(PC),
    .n_PC(n_PC),
    .BranchCondition(BranchConditionFlag),
    .mem_address(ALU_result),
    .stored_data(src_B),
    .MUL_EN(MUL_EN),
    .ack_mul(ack_mul),
    .zero_multi(zero_multi),
    .MemRead(MemRead), .MemWrite(MemWrite),
    .final_address(final_address),
    .instruction_out(instruction_out),
    .mem_store(mem_store),
    .freeze(Freeze),
    .MemRead_request(MemRead_O),
    .MemWrite_request(MemWrite_O)
);


endmodule
