module t07_MMIO(
    input clk, nrst, 
    //internal memory
    input logic [31:0] memData_in, //data from internal memory
    input logic [1:0] rwi_in, //read write or idle
    output logic [31:0] CPUData_out, //ExtData to internal memory
    output logic busy, //to CPU internal memory handler

    //inputs from wishbone manager
    input logic [31:0] WBData_in, // data from instruction/Data memory (for load word)
    input logic busy_o, 
    output logic read, write, //rw for wishbone manager
    output logic [31:0] addr_out, //address send to instr or data mem
    output logic [31:0] WBData_out, //data sent to WB during store instr

    //external register
    input logic [31:0] regData_in, 
    input logic ack_REG,
    input logic ChipSelReg, // chip select from external register to indicate we can read
    output logic regRead, //read or idle signal to external register
    output logic [4:0] addr_outREG, // address to external register

    //inputs from SPI TFT
    input logic ack_TFT, 

    //CPU
    input logic [31:0] addr_in, //addr for instruction fetch
    output logic [31:0] instr_out, //instr sent to fetch

    //SPI for TFT
    output logic [31:0] writeData_outTFT, // data to write to SPT TFT
    output logic [31:0] addr_outTFT, // address to write to SPI TFT]
    output logic wi_out, // write or idle to SPI FTF



);

//edge detector
logic prev_busy_o, busy_o_edge;

always_ff @(negedge nrst, posedge clk) begin
    if(~nrst) begin
        prev_busy_o <= '0;
    end else begin
        prev_busy_o <= busy;
    end
end

assign busy_o_edge = (~busy && prev_busy_o); //detects falling edge

always_comb begin

    //busy signal logic -- busy sent to CPU
    if (ack_TFT || busy_o) begin busy = '1; end
    else if ((addr_in > 32'd1024 && addr_in <= 32'd1056) & rwi_in == 2'b10 & ChipSelReg) begin busy = ack_REG; end
    else if ((addr_in > 32'd1024 && addr_in <= 32'd1056) & ChipSelReg == '0 & rwi_in == 2'b10) begin busy = '1; end 
    else begin busy = 0; end

    //read & write for wishbone manager
    if(busy_o_edge) begin
        read = 0;
        write = 0;
    end else if(rwi_in == 'b11) begin //fetch
        read = 1;
        write = 0;
    end else if(rwi_in == 'b10) begin //read
        read = 1;
        write = 0;
        //idle = 0;
    end else if(rwi_in == 'b01) begin //write
        read = 0;
        write = 1;
        //idle = 0;
    end else begin 
        read = 0;
        write = 0;
        //idle = 1;
    end

    if(addr_in <= 32'd1024) begin //fetch instruction
        addr_out = {8'h33, addr_in[23:0]}; //address for instruction (from PC)
        CPUData_out = 32'b0; //sending instruction to fetch, not internal mem
        instr_out = WBData_in; //next instruction to write to fetch module in CPU
    end else begin
        if(addr_in > 32'd1024 & addr_in <= 32'd1056) begin //read from external registers
            addr_outREG = addr_in[4:0]; // address to external register (to get correct ESP32 data)
            if(ChipSelReg == 1) begin
                regRead = 1'b1; //read from external register
                CPUData_out = regData_in; // data from external register to internal memory
            end
        end
        else if (addr_in > 32'd1056 & addr_in <= 32'd1792) begin //access data memory
            if(read) begin //load
                addr_out = {8'h33, addr_in[23:0]}; //addr - read from data mem
                CPUData_out = WBData_in; 
            end
            if(write) begin //store
                addr_out = {8'h33, addr_in[23:0]}; //addr - write to data mem
                WBData_out = memData_in;
            end
        end



end
endmodule
