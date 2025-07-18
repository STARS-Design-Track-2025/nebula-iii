module t04_request_unit_old(
    input  logic clk,
    input  logic rst,
    input  logic i_ack,
    input  logic d_ack,
    input  logic [31:0] n_PC,
    input  logic BranchCondition,
    input  logic [31:0] instruction_in,
    input  logic [31:0] PC,
    input  logic [31:0] mem_address,
    input  logic [31:0] stored_data,
    input  logic MemRead,
    input  logic MemWrite,
    input  logic MUL_EN,
    input  logic ack_mul,
    output logic [31:0] final_address,
    output logic [31:0] instruction_out,
    output logic [31:0] mem_store,
    output logic freeze,
    output logic MemRead_request,
    output logic MemWrite_request
);

    logic [31:0] latched_instruction;
    logic [31:0] n_latched_instruction;
    logic n_memread;
    logic n_memread2;
    logic n_memwrite;
    logic n_memwrite2;
    logic ack_mul_reg;
    logic ack_mul_reg2;
    logic MUL_EN1;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            latched_instruction <= 32'd0;
            n_memread <= 0;
            n_memwrite <= 0;
            n_memread2 <= 0;
            n_memwrite2 <= 0;
            ack_mul_reg <= 0;
            ack_mul_reg2 <= 0;
            MUL_EN1 <= 0;
        end 
        else begin
            latched_instruction <= n_latched_instruction;
            n_memread <= MemRead;
            n_memwrite <= MemWrite;
            n_memread2 <= n_memread;
            n_memwrite2 <= n_memwrite;
            ack_mul_reg <= ack_mul;
            ack_mul_reg2 <= ack_mul_reg;
            MUL_EN1 <= MUL_EN;
        end
    end

    always_comb begin
        MemRead_request = MemRead;
        MemWrite_request = MemWrite;
        if ((n_memread == 1 || n_memwrite == 1) || (MUL_EN1)) begin
            instruction_out = latched_instruction;
        end
        else if ((latched_instruction == instruction_in && (!(MemRead || MemWrite))) || (latched_instruction != 32'b0 && instruction_in == 32'hBAD1BAD1 && !(MemRead || MemWrite))) begin
            instruction_out = 32'b0;
        end
        else begin
            instruction_out = (instruction_in == 32'hBAD1BAD1) ? latched_instruction : instruction_in;
        end
        if (rst) begin
            final_address = PC;
        end
        else begin
            if (BranchCondition) begin
                final_address = n_PC - 32'd4; //subtracting 4 to stop it from incrementing too far
            end
            else begin
                final_address = (((MemRead || MemWrite)) && (!(n_memread2 || n_memwrite2))) ? mem_address : PC;
            end
        end
        mem_store = stored_data;
        if (i_ack || d_ack) begin
            if ((MemRead || MemWrite) && (!(n_memread2 || n_memwrite2))) begin
                freeze = 1;
            end
            else begin
                freeze = 0;
            end
        end
        else begin
            freeze = 1;
        end
        if (MUL_EN && !ack_mul && !ack_mul_reg) begin
            n_latched_instruction = latched_instruction;
        end
        else if (((n_memread == 1 && MemRead == 1) || (n_memwrite == 1 && MemWrite == 1))) begin
            if ((n_memread2 == 1 || n_memwrite2 == 1) && !freeze) begin
                n_latched_instruction = 32'd0; 
            end
            else begin                   
                n_latched_instruction = latched_instruction;
            end
        end
        else if (instruction_in != 32'hBAD1BAD1) begin
            n_latched_instruction = instruction_in;
        end
        else begin
            n_latched_instruction = 32'd0;
        end
    end


endmodule
