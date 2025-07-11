/*
The top level module for the CPU (brings the parts of the CPU together)
*/

module t08_CPU (
    input logic clk, nRst, //Clock and active-low reset. 
    input logic [31:0] data_in, //Data in from memory to memory handler.
    input logic [31:0] instruction, //Instruction that the CPU receives, given to control unit decoder. 
    output logic [31:0] data_out, //Data outputted to memory from memory handler. (Outputted to MMIO)
    output logic [31:0] mem_address, //Indicates an address in memory (Outputted to MMIO)
    output logic read_out, write_out //Read and write enable outputs (Outputted to MMIO)
);

    logic [31:0] program_counter; //Program counter.
    logic jump, branch; //Jump and branch signals.

    logic [31:0] immediate; //Immediate value outputted from control unit. 
    logic [2:0] func3; //Function 3. 

    logic [31:0] return_address; //Return address to be stored in registers. 

    logic mem_en_read, mem_en_write; //Read and write enable signals for memory handler. 
    logic [31:0] mem_to_reg; //Data output from memory handler to registers. 

    logic reg_en_read_1, reg_en_read_2, reg_en_write; //Enable signals for the registers. 
    logic [4:0] reg_address_r1, reg_address_r2, reg_address_rd; //Address inputs for the registers. 
    logic [1:0] reg_data_in_control; //Select line for the input multiplexer for the registers
    logic [31:0] reg_out_1, reg_out_2; //Outputs from the registers. 

    logic [5:0] alu_control; //Operation select for the alu. 
    logic [31:0] alu_data_out; //Result outputted from the alu. 

    t08_fetch fetch(.imm_address(immediate), .clk(clk), .nrst(nRst), .jump(jump), .branch(branch), .program_counter(program_counter), 
        .ret_address(return_address));

    t08_handler handler(.rs1(reg_out_1), .mem(data_in), .mem_address(mem_address), .write(mem_en_write), .read(mem_en_read), 
        .clk(clk), .nrst(nRst), .func3(func3), .data_reg(mem_to_reg), .data_mem(data_out), .addressnew(), 
        .writeout(write_out), .readout(read_out));

    t08_control_unit control_unit(.reset(nRst), .instruction(instruction), .read(mem_en_read), .write(mem_en_write), .funct3(func3), 
        .data_in_control(reg_data_in_control), .reg1(reg_address_r1), .reg2(reg_address_r2), .regd(reg_address_rd), 
        .en_read_1(reg_en_read_1), .en_read_2(reg_en_read_2), .en_write(reg_en_write), .immediate(immediate), .alu_control(alu_control), .jump(jump));

    t08_alu alu(.clk(clk), .nRst(nRst), .reg1(reg_out_1), .reg2(reg_out_2), .immediate(immediate), .program_counter(program_counter), 
        .alu_control(alu_control), .data_out(alu_data_out), .branch(branch));

    t08_registers registers(.clk(clk), .nRst(nRst), .address_r1(reg_address_r1), .address_r2(reg_address_r2), .address_rd(reg_address_rd), 
        .data_in_frommemory(mem_to_reg), .data_in_frominstructionfetch(return_address), .data_in_fromalu(alu_data_out), 
        .data_in_control(reg_data_in_control), .en_read_1(reg_en_read_1), .en_read_2(reg_en_read_2), .en_write(reg_en_write), 
        .data_out_r1(reg_out_1), .data_out_r2(reg_out_2));

endmodule