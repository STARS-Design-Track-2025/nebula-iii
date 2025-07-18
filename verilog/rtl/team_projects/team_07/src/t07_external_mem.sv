module t07_external_mem (
//inputs
    // inputs from internal memory
    input logic [31:0] addr_in, //address from the internal memory
    input logic [31:0] memData_in,  // data from internal memory
    input logic [1:0] rwi_in, //read write or idle from internal memory

    //inputs from instruction/Data memory
    input logic [31:0] inst, // instruction to write to fetch (writeInstruction_out)

    //inputs from external register
    input logic [31:0] regData_in, //data from external register

    // input from fetch module
    input logic [31:0] PC_address, // Program Counter address to write to instruction module

    // inputs from IDK where?????? (instruction/ data memory????)
    input logic clk, nrst,

//outputs
    // outputs to external register
    output logic [1:0] rwi_out, //2 - read, 1 - write, 0 -idle (sent to external regester)
    output logic [31:0] addr_outREG, // address to external register

    // outputs to internal memory
    output logic [31:0] ExtData_out, //ExtData to internal memory
    output logic busy, //to CPU internal memory handler

    // outputs to fetch
    output logic [31:0] writeInstruction_out, // ext instruction to write to fetch module in CPU

    //output to SPI TFT
    output logic [31:0] addr_outTFT, // address to SPI TFT
    output logic [31:0] writeData_outTFT, // data to write to SPT TFT

    //output to instruction/Data memory
    output logic [31:0] addr_out, // address to instruction/Data memory

);

wishbone_manager()






// always_ff @(posedge clk, negedge nrst) begin //check that pos rst is correct
//     if (rwi_in == 2'b10) begin //read from memory from cpu
        
        
//         rwi_out <= 2'b10; // when do we know if we are also reading from the register?
//         addr_outREG <= addr_in; // address to read from external register


//         ExtData_out <= memData_in; // data from internal memory to external memory

//         if (addr_in < 32'd1024) begin //access wishbone
//             //wishbone
//         end else begin //access register
//             //register
//         end
//     end
//     if (rwi_in == 2'b01) begin //write to memory
        
//         rwi_out <= 2'd1; // when do we know if we are also writing to the register?

//         addr_out <= PC_address; // address to write to instruction module
//         writeData_out <= regData_in;
//     end else begin
//         rwi_out <= '0;
//         addr_out <= addr_in;
//         writeData_out <= 0;
//     end
// end


endmodule