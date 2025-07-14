//memory handler: does few things: for write mode (store type operations),
//passes data from register to the memory. 3 types of operations: SB(first 8 bits), SH(half data),SW(full data))
//for read operations: passes data from memory to register. 5 types of operations: 
//3 signed: lb(load byte), lh(half data), lw(whole data), and unsigned: lbu(byte), lhu(hald)

module t08_handler(
    input logic [31:0] rs1, mem, mem_address, 
    input logic write, read, clk, nrst,
    input logic [2:0] func3,
    output logic [31:0] data_reg,  data_mem, addressnew,
    output logic writeout, readout
);
logic [31:0] regs = 0, mems = 0, address, nextregs, nextmem; //tempo var

assign addressnew = mem_address; 
assign data_mem = mems;
assign data_reg = regs;
assign writeout = write;
assign readout = read;

always_ff@(posedge clk, negedge nrst) begin
    if(!nrst) begin
        regs <= '0;
        mems <= '0;
    end
    else begin
        regs <= nextregs;
        mems <= nextmem;

    end
end

always_comb begin
    nextmem = mems;
    nextregs = regs;
    if (write) begin //store type, signed
        case(func3)
        0: begin
            nextmem = {{24{rs1[31]}},rs1[7:0]}; end //SB
        1: begin
            nextmem = {{16{rs1[31]}},rs1[15:0]}; end //SH     
        2: begin
            nextmem = rs1; end  //sw
        default:;
        endcase
    end
    else if (read) begin
        case(func3)
        0: begin //signed
            nextregs = {{24{mem[31]}},mem[7:0]}; end //LB
        1: begin
            nextregs = {{16{mem[31]}},mem[15:0]}; end //LH
        2: begin
            nextregs = mem; end //LW

        4: begin //unsigned
            nextregs = {24'b0, mem[7:0]}; end //LBU
        
        5: begin 
            nextregs = {16'b0, mem[15:0]}; end //LHU
        default:;
        endcase
    end
end
endmodule




