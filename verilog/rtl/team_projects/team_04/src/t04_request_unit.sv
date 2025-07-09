module t04_request_unit(
    input  logic clk,
    input  logic rst,
    input  logic i_ack,
    input  logic d_ack,
    input  logic [31:0] PC,
    input  logic [31:0] mem_address,
    input  logic [31:0] stored_data,
    input  logic MemRead,
    input  logic MemWrite,
    output logic [31:0] final_address,
    output logic [31:0] mem_store,
    output logic freeze
);

    logic [31:0] n_final_address;

    always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
        final_address <= 32'b0;
        mem_store <= 32'b0;
        freeze <= 1;
    end else begin
        mem_store <= stored_data;
        freeze <= ~(i_ack || d_ack);
        final_address <= n_final_address;
    end
    end

    always_comb begin
        if (MemWrite || MemRead) begin
            n_final_address = mem_address;
        end
        else begin
            n_final_address = PC;
        end
    end

endmodule
