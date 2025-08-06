module t07_decoder (
    input logic [31:0] instruction, //from memory handler
    output logic [6:0] Op, funct7, //to control unit
    output logic [2:0] funct3, //to control unit
    output logic [4:0] rs1, rs2, rd //to internal register
);

assign Op = instruction[6:0];
assign funct3 = instruction[14:12];
assign rs1 = instruction[19:15];
assign rs2 = instruction[24:20];
assign rd = instruction[11:7];
assign funct7 = instruction[31:25];

endmodule