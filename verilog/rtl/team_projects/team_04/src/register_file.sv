module register_file(
<<<<<<< HEAD
  input logic clk, rst, reg_write,
  input logic [4:0] reg1, reg2, regd,
  input logic [31:0] write_data,
  output logic [31:0] read_data1, read_data2
);
  reg [31:0] registers [31:0];
=======
  input  logic clk, rst, reg_write,
  input  logic [4:0] reg1, reg2, regd,
  input  logic [31:0] write_data,
  output logic [31:0] read_data1, read_data2
);
  logic [31:0] registers [31:0];
>>>>>>> a71e555e5c7f0c655ef566e9ea7adba670e17709

  always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
      for (int i = 0; i < 32; i++) begin
        registers[i] <= 32'd0;
      end
    end
    else begin
<<<<<<< HEAD
      if (reg_write) begin
=======
      if (reg_write && regd != 5'd0) begin
>>>>>>> a71e555e5c7f0c655ef566e9ea7adba670e17709
        registers[regd] <= write_data;
      end
    end
  end

  assign read_data1 = registers[reg1];
  assign read_data2 = registers[reg2];
<<<<<<< HEAD
endmodule
=======
endmodule
>>>>>>> a71e555e5c7f0c655ef566e9ea7adba670e17709
