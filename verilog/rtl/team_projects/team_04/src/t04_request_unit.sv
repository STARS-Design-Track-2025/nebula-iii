module t04_request_unit(
    input  logic clk,
    input  logic rst,
    input  logic i_ack,
    input  logic d_ack,
    input  logic [31:0] instruction_in,
    input  logic [31:0] PC,
    input  logic [31:0] mem_address,
    input  logic [31:0] stored_data,
    input  logic MemRead,
    input  logic MemWrite,
    output logic [31:0] final_address,
    output logic [31:0] instruction_out,
    output logic [31:0] mem_store,
    output logic freeze,
    output logic MemRead_request,
    output logic MemWrite_request
);

    logic [31:0] latched_instruction;
    logic n_freeze;
    logic last_freeze;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            latched_instruction <= 0;
            freeze <= 1;
            last_freeze <= 0;
            MemRead_request <= 0;
            MemWrite_request <= 0;
        end 
        else begin
            if ((!freeze)) begin
                latched_instruction <= instruction_in;
            end
            freeze <= n_freeze;
            last_freeze <= freeze;
            MemRead_request <= MemRead;
            MemWrite_request <= MemWrite;
        end
    end

    always_comb begin
        instruction_out = (freeze || last_freeze)? latched_instruction : instruction_in;
        if (rst) begin
            final_address = PC;
        end
        else begin
            final_address = (freeze) ? mem_address : PC;
        end
        mem_store = stored_data;
        if (freeze == 0) begin
            if (i_ack || d_ack) begin
                n_freeze = 0;
            end
            else begin
                n_freeze = (MemRead || MemWrite);
            end 
        end
        else begin
            if (i_ack || d_ack) begin
                n_freeze = 0;
            end
            else begin
                n_freeze = 1;
            end 
        end
    end

endmodule
