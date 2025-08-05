//memory handler: does few things: for write mode (store type operations),
//passes data from register to the memory. 3 types of operations: SB(first 8 bits), SH(half data),SW(full data))
//for read operations: passes data from memory to register. 5 types of operations: 
//3 signed: lb(load byte), lh(half data), lw(whole data), and unsigned: lbu(byte), lhu(hald), lui


module t08_handler(
    input logic [31:0] fromregister, frommem, mem_address, counter,
    input logic write, read, clk, nrst, busy,done, gdone, branch,
    input logic [2:0] func3,

    output logic [31:0] toreg,  tomem, addressnew, instruction,
    output logic wb_write, writeout, wb_read, readout, counter_on
);

typedef enum logic[2:0] {
    INC, FETCH, LORS,REGOP, FWAIT, LWAIT, WAIT
} states;

localparam [31:0] I2C_ADDRESS = 32'd923923;
localparam [31:0] SPI_ADDRESS_C = 32'd121212;

assign wb_read = readout&(~gdone);
assign wb_write = writeout&(~gdone);
logic nextfreeze, nextwriteout, nextreadout, next_counter_on;
logic [31:0] address, nextregs, nextmem, nextinst, nextnewadd; //tempo var
states state, nextstate;

always_ff@(posedge clk, negedge nrst) begin
    if(!nrst) begin
        toreg <= '0;
        tomem <= '0;
        addressnew <= 0;
        state <= FETCH;
        writeout <= 0;
        readout <=0;
        instruction <= 0;
        counter_on <= 0;

    end
    else begin
        toreg <= nextregs;
        tomem <= nextmem;
        state <= nextstate;
        instruction <= nextinst ;
        addressnew <= nextnewadd;
        counter_on <= next_counter_on;
        writeout <= nextwriteout;
        readout <= nextreadout;

    end
end


always_comb begin
    next_counter_on = 0;
    nextreadout = readout;
    nextwriteout = writeout;
    nextinst  = instruction;
    nextregs = toreg;
    nextmem = tomem;
    nextnewadd = addressnew;
    nextstate = state;


    case(state)
    INC: begin //increments program counter
        next_counter_on = 1;
        nextstate = WAIT;

    end

    WAIT: begin //wait for incrementation
        if(!busy) begin
        nextstate = FETCH;
        end
        else begin
            nextstate = WAIT;
        end
    end

    FETCH: begin //fetching instruction 
        if(!done) begin
            nextstate = WAIT;
        end
        else begin
        nextreadout = 1;
        nextnewadd = counter;
        nextstate = FWAIT;
        end
    end

    FWAIT: begin //waiting until instruction is fetched
        if (done) begin
        if (gdone) begin
            nextinst = frommem;
            nextstate = LORS;
            nextreadout = 0;
        end
        else begin
            nextstate = FWAIT;
        end
        end
        else begin
            nextstate = WAIT;
        end
    end

    LORS: begin //check if instruction need extra ime - for load/store/ branch
        if (read|write) begin
            nextnewadd = mem_address;
            nextstate = LWAIT;
            if (write) begin
                nextwriteout = 1;

                 case(func3)
                    0: begin  //SB
                        nextmem = {{24{fromregister[31]}},fromregister[7:0]}; 
                    end 
                    1: begin //SH
                        nextmem = {{16{fromregister[31]}},fromregister[15:0]}; 
                    end     
                    2: begin //SW
                        nextmem = fromregister; 
                    end
                    default:;
                endcase
            end

            else if (read) begin
                nextreadout = 1;
            end
        end

  

        else begin      
            if (branch) begin
                nextnewadd = addressnew;
                nextstate = LWAIT;
            end
            else begin
            nextstate = INC;
            end
        end
        end

    LWAIT: begin //waits for load instruction

            if (gdone) begin
                if (read) begin 
                    nextstate = REGOP; 
                    nextreadout = 0; 

                    if ((done& mem_address == I2C_ADDRESS)| (mem_address < 32'd2048)) begin 
                    case(func3)
                        0: begin //LB, signed
                            nextregs = {{24{frommem[31]}},frommem[7:0]}; 
                        end
                        1: begin //LH
                            nextregs = {{16{frommem[31]}},frommem[15:0]}; 
                        end
                        4: begin //LBU, unsigned
                            nextregs = {24'b0, frommem[7:0]}; 
                        end
                        5: begin //LHU
                            nextregs = {16'b0, frommem[15:0]}; 
                        end
                        default: begin  //LW ;
                            nextregs = frommem; 
                        end
                    endcase
                    nextstate = REGOP;
                    end
                    else if (mem_address == I2C_ADDRESS) begin nextstate = LWAIT; end
                    end
                else if (write) begin 
                    nextstate = INC;
                    nextwriteout = 0; 
                    end
            end

            else if (branch) begin
                nextnewadd = addressnew; 
                nextstate = INC;

            end
            

            else begin nextstate = LWAIT; end
    end

    REGOP: begin //extra time for registers to get data
        nextstate = INC;
    end

    endcase
end

endmodule