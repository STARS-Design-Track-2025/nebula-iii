module request_unit(
    input  logic clk,
    input  logic rst,
    input  logic i_ack,
    input  logic d_ack,
    input  logic [31:0] PC,
    input  logic [31:0] mem_address,
    input  logic [31:0] stored_data,
    input  logic MemRead,
    input  logic MemWrite,
    output logic [31:0] i_address,
    output logic [31:0] d_address,
    output logic [31:0] mem_store,
    output logic freeze
);

    always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        i_address <= 32'b0;
        d_address <= 32'b0;
        mem_store <= 32'b0;
        freeze    <= 1;
    end else begin
        i_address <= PC;
        d_address <= (MemRead || MemWrite) ? mem_address : 32'b0;
        mem_store <= (MemWrite) ? stored_data : 32'b0;
        freeze    <= ~(i_ack || d_ack);
    end
end

endmodule
