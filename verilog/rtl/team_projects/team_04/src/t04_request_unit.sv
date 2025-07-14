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
    output logic freeze
);

    logic [31:0] latched_instruction;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            latched_instruction <= 32'd0;
        end 
        else begin
            if ((MemRead || MemWrite)) begin
                latched_instruction <= instruction_in;
            end
            else begin
                latched_instruction <= 32'd0;
            end
        end
    end

    always_comb begin
        instruction_out = (freeze && (MemRead || MemWrite)) ? latched_instruction : instruction_in;
        if (rst) begin
            final_address = PC;
        end
        else begin
            final_address = (MemRead || MemWrite) ? mem_address : PC;
        end
        mem_store = stored_data;
        if (i_ack || d_ack) begin
            freeze = 0;
        end
        else begin
            freeze = (MemRead || MemWrite);
        end
    end

endmodule
