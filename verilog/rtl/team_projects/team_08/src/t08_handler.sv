//memory handler: does few things: for write mode (store type operations),
//passes data from register to the memory. 3 types of operations: SB(first 8 bits), SH(half data),SW(full data))
//for read operations: passes data from memory to register. 5 types of operations: 
//3 signed: lb(load byte), lh(half data), lw(whole data), and unsigned: lbu(byte), lhu(hald), lui


module t08_handler(
    input logic [31:0] rs1, mem, mem_address, counter,
    input logic write, read, clk, nrst, busy,done,
    input logic [2:0] func3,
    output logic [31:0] data_reg,  data_mem, addressnew, instruction,
    output logic writeout, readout
);
logic [31:0] regs = 0, mems = 0, address, nextregs, nextmem, nextinst, nextnewadd; //tempo var
logic state,  nextstate; //0 wait, 1 send

//assign addressnew = mem_address; 
assign data_mem = mems;
assign data_reg = regs;
//assign writeout = write;
//assign readout = read;

always_ff@(posedge clk, negedge nrst) begin
    if(!nrst) begin
        regs <= '0;
        mems <= '0;
        state <= 0; //wait
    end
    else begin
        regs <= nextregs;
        mems <= nextmem;
        state <= nextstate;
        instruction <= nextinst ;
        //newad

    end
end

always_comb begin
    nextstate = state;
    addressnew = 0;
    
    case(state)
    0: if (!busy) begin
        if ((write) | (read & done ) begin 
                nextstate = 1; //data
            end
        end
        else if (write|read) begin
            nextstate = 0;
        end
        else begin
            nextstate = 2; 
        end
    end

    1: begin //data
        addressnew = mem_address; 
        nextmem = mems;
        nextregs = regs;
        nextstate = 0;


        readout = read;
        writeout = write;
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
            if (done) begin 
            case(func3)
            0: begin //signed
                nextregs = {{24{mem[31]}},mem[7:0]}; end //LB
            1: begin
                nextregs = {{16{mem[31]}},mem[15:0]}; end //LH


            4: begin //unsigned
                nextregs = {24'b0, mem[7:0]}; end //LBU
            
            5: begin 
                nextregs = {16'b0, mem[15:0]}; end //LHU

            default:  begin  nextregs = mem; end //lw or lui;
            endcase

           end 
            end
    end

    2: begin //instruction fetching
        addressnew = counter;
        if(!busy) begin
            writeout = 1;
            nextstate = 3;
        end
    end

    3: begin //instruction sending to cu
        nextinst = mem;
        nextstate = 0;
        readout = 1;
    end
    default: begin readout = 0; writeout = 0; end
    endcase
end



endmodule




