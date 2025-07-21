//produces program counter and return address for jump opertion
module t08_fetch(
    input logic [31:0] imm_address,
    input logic clk, nrst, jump, branch, freeze,
    output logic [31:0] program_counter, ret_address
);
logic [31:0] next_pc, next_ra, current_ra;

always_ff@(posedge clk, negedge nrst) begin
    if (!nrst) begin
        program_counter <= '0;
        //program_counter <= -4;
        current_ra <= '0;
    end

    else if(!freeze) begin
        program_counter <= next_pc;
        current_ra <= next_ra;
    end
end

always_comb begin
    if (!freeze) begin
        next_pc = program_counter +4; //normal incrementing
        next_ra = current_ra;
        if (program_counter >= {32{1'b1}}) begin next_pc = 0; end // restart at 0
        if (jump|branch) begin
            next_pc = $signed(program_counter) + $signed(imm_address); //adding signed value
            //next_ra = program_counter + 4;
        end
        if (jump) begin
            next_ra = program_counter + 4;
        end
    end

    else begin 
        next_pc = program_counter; 
        next_ra = current_ra;
     end
end

// assign program_counter = current_pc[31:0];//assigning to output
assign ret_address = current_ra[31:0];
endmodule
