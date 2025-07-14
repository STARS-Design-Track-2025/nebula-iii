module external_mem (
    input logic [31:0] addr_in, inst, memData_in, regData_in, //inst - instruction, addr_in - address in from CPU,
    input logic [1:0] rwi_in, //read write or idle
    input logic clk, rst,
    output logic [1:0] rwi_out, //2 - read, 1 - write, 0 -idle (sent to both external reg and internal mem)
    output logic [31:0] CPUData_out, writeData_out, addr_out
);

always_ff @(posedge clk, posedge rst) begin //check that pos rst is correct
    if (rwi_in == 000) begin //read to memory
        rwi_out <= 2'd2;
        addr_out <= addr_in;
        //CPUData_out <= memData_in[addr_in];
    end
    if (rwi_in == 001) begin //write to memory
        rwi_out <= 2'd1;
        addr_out <= addr_in;
        writeData_out <= regData_in;
    end else begin
        rwi_out = '0;
        addr_out <= addr_in;
        writeData_out <= 0;
    end
end

endmodule