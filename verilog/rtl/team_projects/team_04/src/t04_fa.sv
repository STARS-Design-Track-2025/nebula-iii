`default_nettype none
module t04_fa (
  input Cin, A, B,
  output Cout, S
);

assign Cout = (A & B) | (Cin & A) | (Cin & B);
assign S = A ^ B ^ Cin;
endmodule