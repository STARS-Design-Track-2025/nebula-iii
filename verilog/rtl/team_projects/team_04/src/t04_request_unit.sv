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

    logic in_data_phase;
    logic [31:0] latched_instruction;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            in_data_phase <= 0;
            latched_instruction <= 32'd0;
        end else begin
            if ((MemRead || MemWrite) && (i_ack || ~d_ack))
                in_data_phase <= 1;
            else if (d_ack)
                in_data_phase <= 0;

            if (~in_data_phase)
                latched_instruction <= instruction_in;
        end
    end

    always_comb begin
        instruction_out = (in_data_phase) ? latched_instruction : instruction_in;
        final_address = (MemRead || MemWrite) ? mem_address : PC;
        mem_store = stored_data;
        freeze = (MemRead || MemWrite) || ~(i_ack || d_ack);
    end

endmodule
