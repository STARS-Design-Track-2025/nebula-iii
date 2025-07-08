module fa32 (
  input logic [31:0] A, B,
  input logic Cin,
  output logic Cout,
  output logic [31:0] S
);
  assign {Cout, S} = A + B + {31'b0, Cin};
endmodule
