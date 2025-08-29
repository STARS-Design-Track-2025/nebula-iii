`default_nettype none
module t03_control (
	opcode,
	funct3,
	funct7bit6,
	branch,
	jump,
	memRead,
	memToReg,
	ALUOp,
	auipc,
	lui,
	memWrite,
	dataWidth,
	ALUsrc,
	regWrite
);
	reg _sv2v_0;
	input wire [6:0] opcode;
	input wire [2:0] funct3;
	input wire funct7bit6;
	output reg [2:0] branch;
	output reg [1:0] jump;
	output reg memRead;
	output reg memToReg;
	output reg [3:0] ALUOp;
	output reg auipc;
	output reg lui;
	output reg memWrite;
	output reg [2:0] dataWidth;
	output reg ALUsrc;
	output reg regWrite;
	always @(*) begin
		if (_sv2v_0)
			;
		dataWidth = funct3;
		case (opcode)
			7'b0110011: begin
				branch = 3'b011;
				jump = 2'b00;
				memRead = 1'b0;
				memToReg = 1'b0;
				ALUOp = {funct7bit6, funct3};
				memWrite = 1'b0;
				ALUsrc = 1'b0;
				regWrite = 1'b1;
				auipc = 1'b0;
				lui = 0;
			end
			7'b0010011: begin
				branch = 3'b011;
				jump = 2'b00;
				memRead = 1'b0;
				memToReg = 1'b0;
				if (funct3 == 3'h5)
					ALUOp = {funct7bit6, funct3};
				else
					ALUOp = {1'b0, funct3};
				memWrite = 1'b0;
				ALUsrc = 1'b1;
				regWrite = 1'b1;
				auipc = 1'b0;
				lui = 0;
			end
			7'b0000011: begin
				branch = 3'b011;
				jump = 2'b00;
				memRead = 1'b1;
				memToReg = 1'b1;
				ALUOp = 4'b0000;
				memWrite = 1'b0;
				ALUsrc = 1'b1;
				regWrite = 1'b1;
				auipc = 1'b0;
				lui = 0;
			end
			7'b0100011: begin
				branch = 3'b011;
				jump = 2'b00;
				memRead = 1'b0;
				memToReg = 1'b0;
				ALUOp = 4'b0000;
				memWrite = 1'b1;
				ALUsrc = 1'b1;
				regWrite = 1'b0;
				auipc = 1'b0;
				lui = 0;
			end
			7'b1100011: begin
				branch = funct3;
				jump = 2'b00;
				memRead = 1'b0;
				memToReg = 1'b0;
				ALUOp = 4'b1000;
				memWrite = 1'b0;
				ALUsrc = 1'b0;
				regWrite = 1'b0;
				auipc = 1'b0;
				lui = 0;
			end
			7'b1101111: begin
				branch = 3'b011;
				jump = 2'b01;
				memRead = 1'b0;
				memToReg = 1'b0;
				ALUOp = 4'b0000;
				memWrite = 1'b0;
				ALUsrc = 1'b0;
				regWrite = 1'b1;
				auipc = 1'b0;
				lui = 0;
			end
			7'b1100111: begin
				branch = 3'b011;
				jump = 2'b10;
				memRead = 1'b0;
				memToReg = 1'b0;
				ALUOp = 4'b0000;
				memWrite = 1'b0;
				ALUsrc = 1'b1;
				regWrite = 1'b1;
				auipc = 1'b0;
				lui = 0;
			end
			7'b0110111: begin
				branch = 3'b011;
				jump = 2'b00;
				memRead = 1'b0;
				memToReg = 1'b0;
				ALUOp = 4'b0000;
				memWrite = 1'b0;
				ALUsrc = 1'b1;
				regWrite = 1'b1;
				auipc = 1'b0;
				lui = 1;
			end
			7'b0010111: begin
				branch = 3'b011;
				jump = 2'b00;
				memRead = 1'b0;
				memToReg = 1'b0;
				ALUOp = 4'b0000;
				memWrite = 1'b0;
				ALUsrc = 1'b1;
				regWrite = 1'b1;
				auipc = 1'b1;
				lui = 0;
			end
			7'b0000000: begin
				branch = 3'b011;
				jump = 2'b00;
				memRead = 1'b0;
				memToReg = 1'b0;
				ALUOp = 4'b0000;
				memWrite = 1'b0;
				ALUsrc = 1'b0;
				regWrite = 1'b0;
				auipc = 1'b0;
				lui = 0;
			end
			default: begin
				branch = 3'b011;
				jump = 2'b00;
				memRead = 1'b0;
				memToReg = 1'b0;
				ALUOp = 4'b0000;
				memWrite = 1'b0;
				ALUsrc = 1'b0;
				regWrite = 1'b0;
				auipc = 1'b0;
				lui = 0;
			end
		endcase
	end
	initial _sv2v_0 = 0;
endmodule
