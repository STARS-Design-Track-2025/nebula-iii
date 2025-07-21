//memory handler: does few things: for write mode (store type operations),
//passes data from register to the memory. 3 types of operations: SB(first 8 bits), SH(half data),SW(full data))
//for read operations: passes data from memory to register. 5 types of operations: 
//3 signed: lb(load byte), lh(half data), lw(whole data), and unsigned: lbu(byte), lhu(hald), lui


module t08_handler(
    input logic [31:0] fromregister, frommem, mem_address, counter,
    input logic write, read, clk, nrst, busy,done,
    input logic [2:0] func3,
    output logic [31:0] toreg,  tomem, addressnew, instruction,
    output logic writeout, readout, freeze
);

localparam [31:0] I2C_ADDRESS = 32'd923923;



logic [31:0] regs = 0, mems = 0, address, nextregs, nextmem, nextinst, nextnewadd; //tempo var
logic [1:0] state,  nextstate; //0 wait, 1 send

//assign addressnew = mem_address; 
assign tomem = mems;
assign toreg = regs;
//assign writeout = write;
//assign readout = read;
assign freeze = busy;
//|readout|writeout;



always_ff@(posedge clk, negedge nrst) begin
    if(!nrst) begin
        regs <= '0;
        mems <= '0;
        addressnew <= 0;
        state <= 0; //wait
    end
    else begin
        regs <= nextregs;
        mems <= nextmem;
        state <= nextstate;
        instruction <= nextinst ;
        addressnew <= nextnewadd;

    end
end

always_comb begin
    nextstate = state;
    nextnewadd = addressnew;
    nextregs = regs;
    nextmem = mems;
    nextinst = instruction;
    readout = 0;
    writeout = 0;

    case(state)
    // 0: begin
    //      if (!busy) begin

    //         if ((write) | (read & done)) begin 
    //                 nextstate = 1; //data
    //             end
    //         else if (!write&!read) begin
    //             nextstate = 2;
    //         end
    //         else begin
    //             nextstate = 0;
    //         end

    // end
    // end

    0: begin //data
        nextnewadd = counter; 

        nextmem = mems;
        nextregs = regs;
        nextstate = 1;

        readout = 0;
        writeout = 0;
        if (busy) begin nextstate = 0; end

        else if (write&!busy) begin //store type, signed
            writeout = write;
            nextnewadd = mem_address;

            case(func3)
            0: begin
                nextmem = {{24{fromregister[31]}},fromregister[7:0]}; end //SB
            1: begin
                nextmem = {{16{fromregister[31]}},fromregister[15:0]}; end //SH     
            2: begin
                nextmem = fromregister; end  //sw
            default:;
            endcase

            //nextstate = 0;
        end

        else if (read& !busy) begin
            readout = read;
            nextnewadd = mem_address;
          //  nextstate = 0;

            if ((done& mem_address == I2C_ADDRESS)| (mem_address < 32'd2048)) begin 
            case(func3)
            0: begin //signed
                nextregs = {{24{frommem[31]}},frommem[7:0]}; end //LB
            1: begin
                nextregs = {{16{frommem[31]}},frommem[15:0]}; end //LH


            4: begin //unsigned
                nextregs = {24'b0, frommem[7:0]}; end //LBU
            
            5: begin 
                nextregs = {16'b0, frommem[15:0]}; end //LHU

            default:  begin  nextregs = frommem; end //lw or lui;
            endcase

           end 
            end

        // else begin
        //     //nextstate = 1;
        // end
    end

    1: begin //instruction fetching
        nextnewadd = counter;                  
        nextinst = frommem;
        if(!busy) begin
            readout = 1;        

            nextstate = 0;
        end

    end

    // 2: begin //instruction sending to cu
 

    //     //readout = 1;
    // end
    default: begin readout = 0; writeout = 0; end
    endcase
end



endmodule 
