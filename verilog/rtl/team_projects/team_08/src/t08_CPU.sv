/*
The top level module for the CPU (brings the parts of the CPU together)
*/

module t08_CPU (
    input logic clk, nRst,                  //Clock and active-low reset. 
    input logic [31:0] data_in,             //memory to memory handler: data in
    input logic done, busy, gdone,                //from mmio, if its busy, if data from i2c is done
    output logic [31:0] data_out,           //memory handler to mmio: data outputted 
    output logic [31:0] addressnew,        //memory handler to mmio: address in memory
    output logic read_out, write_out, getinst, wb_read        //memory handler to mmio: read and write enable
);

    logic [31:0] program_counter;                               //Program counter
    logic [31:0] return_address;                                //fetch to registers: return address to be stored 
    logic [31:0] instruction;                                   //instruction to cu

    logic [2:0] func3;                                          //CU to memory handler: function 3. 
    logic mem_en_read, mem_en_write;                            //CU to memory handler: Read and write enable signals 
    logic reg_en_read_1, reg_en_read_2, reg_en_write;           //CU to registers: enable signals 
    logic [4:0] reg1, reg2, regd;                               //CU to registers: address inputs 
    logic [1:0] data_in_control;                                //CU to registers: select line for the input mux                   
    logic [31:0] immediate;                                     //CU to ALU: immediate value  
    logic [5:0] alu_control;                                    //CU to ALU: operation select    
    logic jump;                                                 //CU to fetch: jump signal
    
    logic [31:0] mem_to_reg;                                    //memory hander to registers: data 

    logic [31:0] reg_out_1;                                     //registers to ALU and memory hander 
    logic [31:0] reg_out_2;                                     //registers to ALU 
    
    logic [31:0] alu_data_out;                                  //ALU to registers and memory handler: ALU output
    logic branch;                                               //ALU to fetch: branch signal

    logic counter_on;
   

    t08_fetch fetch(
        .imm_address(immediate), 
        .clk(clk), .nrst(nRst), 
        .jump(jump), .branch(branch), 
        .program_counter(program_counter), 
        .ret_address(return_address),
        .counter_on(counter_on)
    );

    t08_control_unit control_unit(
        .instruction(instruction), 
        .read(mem_en_read), .write(mem_en_write), 
        .funct3(func3), 
        .data_in_control(data_in_control), 
        .reg1(reg1), .reg2(reg2), .regd(regd), 
        .en_read_1(reg_en_read_1), .en_read_2(reg_en_read_2), .en_write(reg_en_write), 
        .immediate(immediate), 
        .alu_control(alu_control), 
        .jump(jump)
    );

    t08_alu alu(
        .reg1(reg_out_1), .reg2(reg_out_2), .immediate(immediate), .program_counter(program_counter), //Inputs
        .alu_control(alu_control), //Operation control input
        .data_out(alu_data_out), .branch(branch) //Outputs
    );

    t08_registers registers(
        .clk(clk), .nRst(nRst), //clock and reset
        .address_r1(reg1), .address_r2(reg2), .address_rd(regd), //register addresses
        .data_in_frommemory(mem_to_reg), .data_in_frominstructionfetch(return_address), .data_in_fromalu(alu_data_out), //multiplexer inputs
        .data_in_control(data_in_control), //multiplexer select line
        .en_read_1(reg_en_read_1), .en_read_2(reg_en_read_2), .en_write(reg_en_write), //enable signals
        .busy(0), //busy signal
        .data_out_r1(reg_out_1), .data_out_r2(reg_out_2) //outputs
    );

    t08_handler handler(
        .fromregister(reg_out_2), .frommem(data_in), 
        .mem_address(alu_data_out), 
        .counter(program_counter),
        .write(mem_en_write), .read(mem_en_read), 
        .clk(clk), .nrst(nRst), 
        .busy(busy), .gdone(gdone), .counter_on(counter_on),
        .func3(func3), 
        .toreg(mem_to_reg), .tomem(data_out), 
        .addressnew(addressnew), 
        .instruction(instruction),
        .writeout(write_out), .readout(read_out), .getinst(getinst), .wb_read(wb_read)
    );

endmodule
