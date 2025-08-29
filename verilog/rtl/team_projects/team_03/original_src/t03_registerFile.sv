// the purpose of this module is to be able to store elements to perform fast operations in registers
`default_nettype none
`timescale 1ps/1ps

module t03_registerFile(
    input logic clk, regwrite, reset, memToReg, jal,
    input logic [31:0] instruction, result_ALU, data_out, pc,
    output logic [31:0] read_data1, read_data2
);

    logic [31:0][31:0] regfile; //32 registers, each with 32 bits
    logic [4:0] rs1, rs2, rd;
    logic [31:0] write_data;
    
    //hardcodes the values of rs1, rs2, and rd together, which the control unit will later pick through signals in muxes
    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20]; //in the cases that we don't need rs2, the control unit can take care of this and use rs2 accordingly
    assign rd = instruction[11:7]; //this is the destination register which will be written to

    //assigns the specific registers to the input values to output the read_data1 and read_data2
    assign read_data1 = regfile[rs1];
    assign read_data2 = regfile[rs2];
    
    always_ff @( posedge clk, posedge reset) begin
        if (reset) begin // in the reset case, all flip flops are set with 0
            regfile <= '0;
        end else if (regwrite && rd != 0) begin
            regfile[rd] <= write_data;
        end
    end

    always_comb begin //This is the combinational logic that decides what is fed to write_data
        if(jal) begin
            write_data = pc;
        end else if (memToReg) begin
            write_data = data_out;
        end else begin
            write_data = result_ALU;
        end
    end


endmodule