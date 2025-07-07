module tb;
  logic [31:0] src_A, src_B, instruction;
  logic [1:0]  ALU_control;
  logic [31:0] ALU_result;
  logic BranchConditionFlag;

  ALU dut (.*);

  initial begin
    src_A = 32'b0; src_B = 32'b0; instruction = 32'b0;
    ALU_control = 2'b0;

    $dumpfile("waves/ALU.vcd");
    $dumpvars(0, tb);

    src_A = 32'd10; src_B = 32'd15;
    instruction = {7'b0000000, 5'd2, 5'd1, 3'b000, 5'd3, 7'b0110011};
    ALU_control = 2'b00;
    #1 $display("ADD 10 + 15 = %0d", ALU_result);
    #1;

    src_A = 32'd15; src_B = 32'd10;
    instruction = {7'b0100000, 5'd2, 5'd1, 3'b000, 5'd3, 7'b0110011};
    #1 $display("Subtract 15 - 10 = %0d", ALU_result);
    #1;

    src_A = 32'hFFFF00FF; src_B = 32'hFF00FFFF;
    instruction = {7'b0, 5'd2, 5'd1, 3'b111, 5'd3, 7'b0110011};
    #1 $display("AND src_A & src_B = %h", ALU_result);
    #1;

    src_A = 32'hFFFF0000; src_B = 32'h0000FFFF;
    instruction = {7'b0, 5'd2, 5'd1, 3'd6, 5'd3, 7'b0110011};
    #1 $display("OR src_A | src_B = %h", ALU_result);
    #1;

    src_A = 32'hF0000000; src_B = 32'd4;
    instruction = {7'b0, 5'd2, 5'd1, 3'd5, 5'd3, 7'b0110011};
    #1 $display("SRL src_A >> src_B = %h", ALU_result);
    #1;

    src_A = 32'hF0000000; src_B = 32'd4;
    instruction = {7'b0100000, 5'd2, 5'd1, 3'b101, 5'd3, 7'b0110011};
    #1 $display("SRA src_A >>> src_B = %h", ALU_result);
    #1;

    src_A = 32'hAAAA5555; src_B = 32'h5555AAAA;
    instruction = {7'b0000000, 5'd2, 5'd1, 3'b100, 5'd3, 7'b0110011};
    #1 $display("XOR src_A ^ src_B = %h", ALU_result);
    #1;

    src_A = 32'h00000001; src_B = 32'd8;
    instruction = {7'b0000000, 5'd2, 5'd1, 3'b001, 5'd3, 7'b0110011};
    #1 $display("SLL src_A << src_B = %h", ALU_result);
    #1;

    src_A = -32'sd1; src_B = 32'sd1;
    instruction = {7'b0000000, 5'd2, 5'd1, 3'b010, 5'd3, 7'b0110011};
    #1 $display("SLT src_A < src_B (signed) = %0d", ALU_result);
    #1;

    src_A = 32'h00000001; src_B = 32'hFFFFFFFF;
    instruction = {7'b0000000, 5'd2, 5'd1, 3'b011, 5'd3, 7'b0110011};
    #1 $display("SLTU src_A < src_B (unsigned) = %0d", ALU_result);
    #1;

    src_A = 32'd42; src_B = 32'd42;
    ALU_control = 2'd1;
    instruction = {7'b0000000, 5'd2, 5'd1, 3'b000, 5'd0, 7'b1100011};
    #1 $display("BEQ (src_A == src_B) -> BranchFlag = %0d", BranchConditionFlag);
    #1;

    src_A = 32'd42; src_B = 32'd24;
    instruction = {7'b0000000, 5'd2, 5'd1, 3'b001, 5'd0, 7'b1100011};
    #1 $display("BNE (src_A != src_B) -> BranchFlag = %0d", BranchConditionFlag);
    #1;

    src_A = -32'sd5; src_B = 32'sd2;
    instruction = {7'b0000000, 5'd2, 5'd1, 3'b100, 5'd0, 7'b1100011};
    #1 $display("BLT (src_A < src_B signed) -> BranchFlag = %0d", BranchConditionFlag);
    #1;

    src_A = 32'sd5; src_B = 32'sd2;
    instruction = {7'b0000000, 5'd2, 5'd1, 3'b101, 5'd0, 7'b1100011};
    #1 $display("BGE (src_A >= src_B signed) -> BranchFlag = %0d", BranchConditionFlag);
    #1;

    src_A = 32'h00000001; src_B = 32'hFFFFFFFF;
    instruction = {7'b0000000, 5'd2, 5'd1, 3'b110, 5'd0, 7'b1100011};
    #1 $display("BLTU (src_A < src_B unsigned) -> BranchFlag = %0d", BranchConditionFlag);
    #1;

    src_A = 32'hFFFFFFFF; src_B = 32'h00000001;
    instruction = {7'b0000000, 5'd2, 5'd1, 3'b111, 5'd0, 7'b1100011};
    #1 $display("BGEU (src_A >= src_B unsigned) -> BranchFlag = %0d", BranchConditionFlag);
    #1;

    $finish;
  end

endmodule