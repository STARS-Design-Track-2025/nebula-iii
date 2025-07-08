module request_unit(
    input logic clk,
    input logic rst,
    input logic i_ack,
    input logic d_ack,
    input logic [31:0] PC,
    input logic [31:0] memload,
    input logic [31:0] stored_data,
    output logic [31:0] i_address,
    output logic [31:0] d_address,
    output logic [31:0] mem_store,
    output logic freeze
);

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            i_address <= 32'b0;
            d_address <= 32'b0;
            mem_store <= 32'b0;
            freeze <= 1;
        end else begin
            i_address <= PC;
            d_address <= memload;
            mem_store <= stored_data;
            freeze <= ~(i_ack || d_ack);
        end
    end
endmodule
