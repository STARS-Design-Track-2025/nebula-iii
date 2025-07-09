module t04_ALU(
  input  logic [31:0] src_A, src_B, instruction,
  input  logic  ALU_control,
  output logic [31:0] ALU_result,
  output logic        BranchConditionFlag
);

  logic [31:0] sub_result;
  logic [2:0]  funct3;
  logic [6:0]  funct7;

  assign funct3 = instruction[14:12];
  assign funct7 = instruction[31:25];

  // Subtract B from A using fa32 (A - B)
  t04_fa32 subtractor (
    .A(src_A),
    .B(~src_B),            // A + (~B + 1) = A - B
    .Cin(1'b1),
    .Cout(),
    .S(sub_result)
  );

  always_comb begin
    BranchConditionFlag = 1'b0;
    ALU_result = 32'b0;

    if (ALU_control == 1) begin
      ALU_result = sub_result;

      unique case (funct3)
          3'b000: BranchConditionFlag = (sub_result == 0);                                // BEQ
          3'b001: BranchConditionFlag = (sub_result != 0);                                // BNE
          3'b100: BranchConditionFlag = sub_result[31];                                   // BLT (signed)
          3'b101: BranchConditionFlag = ~sub_result[31] && (sub_result != 0);             // BGE (signed)
          3'b110: BranchConditionFlag = ($unsigned(src_A) < $unsigned(src_B));            // BLTU
          3'b111: BranchConditionFlag = ($unsigned(src_A) >= $unsigned(src_B));           // BGEU
          default: BranchConditionFlag = 1'b0;
      endcase
    end

    else begin
      case (funct3)
          3'b000: begin
            // add or sub
            if (funct7 == 7'b0100000)
              ALU_result = sub_result; // SUB
            else
              ALU_result = src_A + src_B; // ADD
          end
          3'b111: ALU_result = src_A & src_B; // AND
          3'b110: ALU_result = src_A | src_B; // OR
          3'b100: ALU_result = src_A ^ src_B; // XOR
          3'b001: ALU_result = src_A << src_B[4:0]; // SLL
          3'b101: begin
            if (funct7 == 7'b0100000)
              ALU_result = $signed(src_A) >>> src_B[4:0]; // SRA
            else
              ALU_result = src_A >> src_B[4:0];           // SRL
          end
          3'b010: ALU_result = ($signed(src_A) < $signed(src_B)) ? 32'd1 : 32'd0; // SLT
          3'b011: ALU_result = ($unsigned(src_A) < $unsigned(src_B)) ? 32'd1 : 32'd0; // SLTU
          default: ALU_result = 32'd0;
      endcase
    end
  end

endmodule