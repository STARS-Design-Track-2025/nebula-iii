//produces program counter and return address for jump opertion
module t08_fetch(
    input logic signed [31:0] imm_address,
    input logic clk, nrst, jump, branch,
    output logic [31:0] program_counter, ret_address
);
logic [32:0] next_pc, next_ra, current_pc = 0, current_ra = 0, prev_pc = 0;
always_ff@(posedge clk, negedge nrst) begin
    if (nrst) begin
        current_pc <= '0;
        current_ra <= '0;
    end
    else begin
        current_pc <= next_pc;
        current_ra <= next_ra;
    end
end

always_comb begin
    next_pc = current_pc +4; //normal incrementing
    next_ra = current_ra;
    if (current_pc >= {32{1'b1}}) begin next_pc = 0; end // restart at 0
    if (jump) begin
        next_pc = current_pc + $signed(imm_address); //adding signed value
        next_ra = current_pc + 4;
    end
    else if (branch) begin
        next_pc = current_pc + $signed(imm_address);
    end
end

assign program_counter = current_pc[31:0];//assigning to output
assign ret_address = current_ra[31:0];
endmodule