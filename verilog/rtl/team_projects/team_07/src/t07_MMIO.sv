module t07_MMIO (
//inputs
    // inputs from internal memory
    input logic [31:0] memData_in,  // data from internal memory
    input logic [1:0] rwi_in, //read write or idle from internal memory

    //inputs from instruction/Data memory
    input logic [31:0] ExtData_in, // data from instruction/Data memory
    input logic busy_o, // busy signal from wishbone

    //inputs from external register
    input logic [31:0] regData_in, //data from external register
    input logic ack_REG, //acknowledge signal from external register

    //inputs from SPI TFT
    input logic ack_TFT, //acknowledge signal from SPI TFT

    // input from CPU top
    input logic [31:0] addr_in, // Program Counter address or Internal Memory address 
    input logic fetchRead_in, addrControl_in,



//outputs
    // outputs to external register
    output logic ri_out, //read or idle signal to external register
    output logic [4:0] addr_outREG, // address to external register

    // outputs to internal memory
    output logic [31:0] ExtData_out, //ExtData to internal memory
    output logic busy, //to CPU internal memory handler

    // outputs to fetch
    output logic [31:0] writeInstruction_out, // ext instruction to write to fetch module in CPU

    //output to SPI TFT
    output logic [31:0] writeData_outTFT, // data to write to SPT TFT
    output logic [31:0] addr_outTFT, // address to write to SPI TFT]
    output logic wi_out, // write or idle to SPI FTF

    //output to instruction/Data memory
    output logic [1:0] rwi_out, // read/write/idle to instruction/Data memory (00- read from instruction, 01- write to instruction/Data memory, 10- read from Data memory, 11- idle)
    output logic [31:0] addr_out, // address to instruction/Data memory
    output logic [31:0] writeData_out, // data to write to instruction/Data memory
    output logic fetchRead_out, addrControl_out
);

always_comb begin
    busy = 1'b0; // default busy signal to not busy
    ri_out = 1'b0; // idle external register
    wi_out = 1'b0; // idle TFT
    rwi_out = 2'b11; // idle instruction/Data memory
    addr_outREG = 5'b0; // no address for external register
    addr_out = 32'b0; // no address for instruction/Data memory
    addr_outTFT = 32'b0; // no address for SPI TFT`
    writeData_out = 32'b0; // no data to instruction/Data memory
    writeData_outTFT = 32'b0; // no data to SPI TFT
    ExtData_out = 32'b0; // no data to internal memory
    writeInstruction_out = 32'b0; // no instruction to fetch module
    fetchRead_out = fetchRead_in; //fetch read signal
    addrControl_out = addrControl_in; 

    if (addr_in > 32'd1024) begin
        if (rwi_in == 2'b01) begin //write from internal memory of the CPU
            if (addr_in > 32'd1792 && addr_in < 32'd2048) begin //change address number later              // write to SPI TFT
                busy = ack_TFT; //set busy signal to indicate memory handler is processing
                wi_out = 1'b1; //write to SPI TFT
                addr_outTFT = addr_in; // address to write to SPI TFT
                writeData_outTFT = memData_in; // data to write to SPI TFT
            end else if (addr_in > 32'd1056 && addr_in <= 32'd1792) begin //change address number later     // write to Data memory
                busy = busy_o; //set busy signal to indicate memory handler is processing
                rwi_out = 2'b01; //write to instruction/Data memory
                addr_out = {8'h33, addr_in[23:0]}; // address to instruction/Data memory
                writeData_out = memData_in; // data from instruction/Data memory
            end
        end else if (rwi_in == 2'b10) begin //read from internal memory of the CPU
            if(addr_in > 32'd1024 && addr_in <= 32'd1056) begin //change address number later          // read from external register
                busy = ack_REG; //set busy signal to indicate memory handler is processing
                ri_out = 1'b1; //read from external register
                addr_outREG = addr_in[4:0]; // address to read from external register
                ExtData_out = regData_in; // data from external register to internal memory
            end else if (addr_in > 32'd1056 && addr_in <= 32'd1792) begin //change address number later     // read from data memory
                busy = busy_o; //set busy signal to indicate memory handler is processing
                rwi_out = 2'b10; //read from Data memory
                addr_out = {8'h33, addr_in[23:0]}; // address to read from instruction/Data memory
                ExtData_out = ExtData_in; // data from instruction/Data memory to internal memory
            end 
        end
    end else if (rwi_in == 2'b10)  begin
        if (addr_in <= 32'd1024) begin //change address number later                           // write instruction to fetch module
                busy = busy_o; //set busy signal to indicate memory handler is processing
                //if(fetchRead_in == 0) begin 
                //rwi_out = 2'b11; end else begin
                        rwi_out = 2'b10; //end //read from instruction
                addr_out = {8'h33, addr_in[23:0]}; // address for instruction/Data memory from cpu top mux
                ExtData_out = 32'b0; // no data to internal memory
                writeInstruction_out = ExtData_in; // next instruction to write to fetch module in CPU
        end
<<<<<<< HEAD
   end else if (rwi_in == 2'b00)
        rwi_out = 2'b0;

=======
    end else begin //idle
        rwi_out = 2'b0;
    end
>>>>>>> 77e0343ae0cd68aa06b08ea52c987a9032f33a52
end



endmodule