/*
The top level module for the CPU (brings the parts of the CPU together)
*/

module t08_CPU (
    input logic clk, nRst,                  //Clock and active-low reset. 
    input logic [31:0] data_in,             //memory to memory handler: data in
    input logic [31:0] instruction,         //memory to CPU: instruction 
    output logic [31:0] data_out,           //memory handler to mmio: data outputted 
    output logic [31:0] mem_address,        //memory handler to mmio: address in memory
    output logic read_out, write_out        //memory handler to mmio: read and write enable
);

    logic [31:0] program_counter;                               //Program counter
    logic [31:0] return_address;                                //fetch to registers: return address to be stored 

    logic [2:0] func3;                                          //CU to memory handler: function 3. 
    logic mem_en_read, mem_en_write;                            //CU to memory handler: Read and write enable signals 
    logic reg_en_read_1, reg_en_read_2, reg_en_write;           //CU to registers: enable signals 
    logic [4:0] reg1, reg2, regd; //CU to registers: address inputs 
    logic [1:0] data_in_control;                                //CU to registers: select line for the input mux                            //CU to fetch
    logic [31:0] immediate;                                     //CU to ALU: immediate value  
    logic [5:0] alu_control;                                    //CU to ALU: operation select    
    logic jump;                                                 //CU to fetch: jump signal
    
    logic [31:0] mem_to_reg;                                    //memory hander to registers: data 

    logic [31:0] reg_out_1;                                     //registers to ALU and memory hander 
    logic [31:0] reg_out_2;                                        //registers to ALU 
    
    logic [31:0] alu_data_out;                                  //ALU to registers and memory handler: ALU output
    logic branch;                                               //ALU to fetch: branch signal

    t08_fetch fetch(.imm_address(immediate), .clk(clk), .nrst(nRst), .jump(jump), .branch(branch), 
    .program_counter(program_counter), .ret_address(return_address));

    t08_handler handler(.rs1(reg_out_1), .mem(data_in), .mem_address(mem_address), .write(mem_en_write), 
        .read(mem_en_read), .clk(clk), .nrst(nRst), .func3(func3), .data_reg(mem_to_reg), .data_mem(data_out), 
        .addressnew(), .writeout(write_out), .readout(read_out));

    t08_control_unit control_unit(.reset(nRst), .instruction(instruction), .read(mem_en_read), .write(mem_en_write), 
        .funct3(func3), .data_in_control(data_in_control), .reg1(reg1), .reg2(reg2), .regd(regd), .en_read_1(reg_en_read_1), 
        .en_read_2(reg_en_read_2), .en_write(reg_en_write), .immediate(immediate), .alu_control(alu_control), .jump(jump));

    t08_alu alu(.clk(clk), .nRst(nRst), .reg1(reg_out_1), .reg2(reg_out_2), .immediate(immediate), 
        .program_counter(program_counter), .alu_control(alu_control), .data_out(alu_data_out), .branch(branch));

    t08_registers registers(.clk(clk), .nRst(nRst), .address_r1(reg1), .address_r2(reg2), .address_rd(regd), 
        .data_in_frommemory(mem_to_reg), .data_in_frominstructionfetch(return_address), 
        .data_in_fromalu(alu_data_out), .data_in_control(data_in_control), .en_read_1(reg_en_read_1), 
        .en_read_2(reg_en_read_2), .en_write(reg_en_write), .data_out_r1(reg_out_1), .data_out_r2(reg_out_2));

endmodule