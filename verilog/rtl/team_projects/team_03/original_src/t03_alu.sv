`default_nettype none
module t03_alu (
input logic [3:0] control, // control signal from control unit
input logic [31:0] pc, immediate, rd1,rd2,
input logic ALUSrc, Auipc, lui,
output logic [31:0] result, //assuming 32 bit cpu
output logic zero, negative, overflow //zero output
);

typedef enum logic [3:0] {
ADD = 4'b0000,
SUB = 4'b1000,
XOR = 4'b0100,
OR = 4'b0110,
AND = 4'b0111,
SLL = 4'b0001,
SRL = 4'b0101,
SRA = 4'b1101,
SLT = 4'b0010,
SLTU = 4'b0011
} ALUOPERATION;

logic [31:0] num1, num2;
logic num1_sign, num2_sign;
assign num1_sign = num1[31];
assign num2_sign = num2[31];
logic cout, borrow_out; 

logic [3:0] operation;
assign operation = control; //What does this line do? Nah I think ur good I just never saw that syntax before

//alu muxes
always_comb begin
num1 = rd1;
num2 = rd2;

if(Auipc) begin
num1 = pc;
end else if (lui) begin
num1 = 32'd0;
end

if(ALUSrc) begin
num2 = immediate;
end
end


//alu comb block
always_comb begin
cout = 0;
borrow_out = 0;
case (operation)
AND: begin
result = num1 & num2;
end
OR: begin
result = num1 | num2;
end
ADD: begin
{cout, result} = num1 + num2;
end
SUB: begin
{borrow_out, result} = {1'b0, num1} - {1'b0, num2};
end
XOR: begin
result = num1^num2;
end
SLL: begin
result = num1 << num2;
end
SRL: begin
result = num1 >> num2;
end
SRA: begin
result = num1 >>> num2;
end
SLT: begin
if (num1_sign == 1 && num2_sign == 1) begin // check if num1 is negative for twos complement
result = num1<num2 ? 0:1;
end else if (num1_sign == 1) begin
result = 1;
end else if (num2_sign == 1) begin
result = 0;
end else begin
result = num1<num2 ? 1:0;
end
end
SLTU: begin
result = num1<num2 ? 1:0; //unsigned so twos complement doesn't matter.
end
default: result = '0;

endcase
zero = (result == 0) ? 1 : 0; //check for 0.
negative = result[31];
overflow = cout || borrow_out;
end


endmodule

