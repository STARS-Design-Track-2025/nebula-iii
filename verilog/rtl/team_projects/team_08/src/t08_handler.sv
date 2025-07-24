//memory handler: does few things: for write mode (store type operations),
//passes data from register to the memory. 3 types of operations: SB(first 8 bits), SH(half data),SW(full data))
//for read operations: passes data from memory to register. 5 types of operations: 
//3 signed: lb(load byte), lh(half data), lw(whole data), and unsigned: lbu(byte), lhu(hald), lui


module t08_handler(
    input logic [31:0] fromregister, frommem, mem_address, counter,
    input logic write, read, clk, nrst, busy,done, gdone,
    input logic [2:0] func3,
    output logic [31:0] toreg,  tomem, addressnew, instruction,
    output logic wb_write, writeout, wb_read, readout,  getinst, counter_on
);
typedef enum logic[2:0] {
    INC, FETCH, LORS,REGOP, FWAIT, LWAIT
} states;

localparam [31:0] I2C_ADDRESS = 32'd923923;
localparam [31:0] SPI_ADDRESS_C = 32'd121212;

// logic readout;
assign wb_read = readout&(~gdone);
assign wb_write = writeout&(~gdone);
logic nextfreeze, nextwriteout, nextreadout, next_counter_on;
logic [31:0] address, nextregs, nextmem, nextinst, nextnewadd; //tempo var
//logic [2:0]  state,nextstate; 
states state, nextstate;

always_ff@(posedge clk, negedge nrst) begin
    if(!nrst) begin
        toreg <= '0;
        tomem <= '0;
        addressnew <= 0;
        state <= INC;
    //    freeze <= 1;
        writeout <= 0;
        readout <=0;
        instruction <= 0;
        counter_on <= 1;
    end
    else begin
        toreg <= nextregs;
        tomem <= nextmem;
        state <= nextstate;
        instruction <= nextinst ;
        addressnew <= nextnewadd;
        //freeze <= nextfreeze|busy;
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
    INC: begin
        next_counter_on = 1;
        nextstate = FETCH;
    end

    FETCH: begin
        nextreadout = 1;
        nextnewadd = counter;
        nextstate = FWAIT;

    end

    FWAIT: begin
        if (gdone) begin
            nextinst = frommem;
            nextstate = LORS;
            nextreadout = 0;
        end
        else begin
            nextstate = FWAIT;
        end
    end

    LORS: begin
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
            nextstate = INC;
        end
        end

    LWAIT: begin
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
                        default: begin  //LW or LUI;
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
            else begin nextstate = LWAIT; end
    end

    REGOP: begin
        // if ((done& mem_address == I2C_ADDRESS)| (mem_address < 32'd2048)) begin 
        //     case(func3)
        //         0: begin //LB, signed
        //             nextregs = {{24{frommem[31]}},frommem[7:0]}; 
        //         end
        //         1: begin //LH
        //             nextregs = {{16{frommem[31]}},frommem[15:0]}; 
        //         end
        //         4: begin //LBU, unsigned
        //             nextregs = {24'b0, frommem[7:0]}; 
        //         end
        //         5: begin //LHU
        //             nextregs = {16'b0, frommem[15:0]}; 
        //         end
        //         default: begin  //LW or LUI;
        //             nextregs = frommem; 
        //         end
        //     endcase
        nextstate = INC;
        // end
        // else if (mem_address == I2C_ADDRESS) begin nextstate = REGOP; end

    end
    endcase
end

endmodule

























// logic nextfreeze, nextwriteout, nextreadout;
// logic [31:0] address, nextregs, nextmem, nextinst, nextnewadd; //tempo var
// logic [1:0] state,  nextstate; //0 wait, 1 send

// always_ff@(posedge clk, negedge nrst) begin
//     if(!nrst) begin
//         toreg <= '0;
//         tomem <= '0;
//         addressnew <= 0;
//         state <= 0; //wait
//         freeze <= 1;
//         writeout <= 0;
//         readout <=0;
//         instruction <= 0;
//     end
//     else begin
//         toreg <= nextregs;
//         tomem <= nextmem;
//         state <= nextstate;
//         instruction <= nextinst ;
//         addressnew <= nextnewadd;
//         freeze <= nextfreeze|busy;
//         writeout <= nextwriteout;
//         readout <= nextreadout;

//     end
// end

// always_comb begin
//     nextfreeze = freeze;
//     nextstate = state;
//     nextnewadd = addressnew;
//     nextregs = toreg;
//     nextmem = tomem;
//     nextinst = instruction;
//     nextreadout = readout;
//     nextwriteout = writeout;
//     getinst = 0;

//     case(state)
//     0: begin //data
//         nextnewadd = addressnew; 
//         nextmem = tomem;
//         nextregs = toreg;
//         nextreadout = 0;
//         nextwriteout = 0;

//         if (!busy) begin
//             nextstate = 1;
//             nextreadout = 1;
//             nextwriteout = 0;
//             if (gdone )begin
//             nextfreeze = 0;
//             end

//             if (write) begin //store type, signed
//                 nextwriteout = 1;
//                 nextreadout = 0;
//                 nextnewadd = mem_address;
//                 nextfreeze = 1;
//                 nextstate = 2;
                
//                 case(func3)
//                     0: begin  //SB
//                         nextmem = {{24{fromregister[31]}},fromregister[7:0]}; 
//                     end 
//                     1: begin //SH
//                         nextmem = {{16{fromregister[31]}},fromregister[15:0]}; 
//                     end     
//                     2: begin //SW
//                         nextmem = fromregister; 
//                     end
//                     default:;
//                 endcase
//             end

//             else if (read) begin
//                 nextfreeze = 1;
//                 nextreadout = 1;
//                 nextnewadd = mem_address;
//                 nextstate = 2;
//                 //  nextstate = 0;

//                 if ((done& mem_address == I2C_ADDRESS)| (mem_address < 32'd2048)) begin 
//                     case(func3)
//                         0: begin //LB, signed
//                             nextregs = {{24{frommem[31]}},frommem[7:0]}; 
//                         end
//                         1: begin //LH
//                             nextregs = {{16{frommem[31]}},frommem[15:0]}; 
//                         end


//                         4: begin //LBU, unsigned
//                             nextregs = {24'b0, frommem[7:0]}; 
//                         end

//                         5: begin //LHU
//                             nextregs = {16'b0, frommem[15:0]}; 
//                         end 

//                         default: begin  //LW or LUI;
//                             nextregs = frommem; 
//                         end
//                     endcase
//                 end
//             end
//         end

//         else begin 
//             nextstate = 0; 
//             nextfreeze = 1;
//         end
//     end

//     1: begin //instruction fetching
//         nextfreeze = 1;
//         // readout = 1;
//         // getinst = 1;
//         nextnewadd = counter;  
//         nextinst = frommem;
        
//         if(!busy) begin
//             // getinst = 1;      
//             nextstate = 0;
//             nextfreeze = 1;       
//         end

//     end

//     2: begin
//         if (write) begin 
//             nextwriteout = 1;
//             nextreadout = 0; 

//                 // case(func3)
//                 // 0: begin
//                 //     nextmem = {{24{fromregister[31]}},fromregister[7:0]}; end //SB
//                 // 1: begin
//                 //     nextmem = {{16{fromregister[31]}},fromregister[15:0]}; end //SH     
//                 // 2: begin
//                 //     nextmem = fromregister; end  //sw
//                 // default:;
//                 // endcase

//             end

//         else if (read)  begin
//              nextwriteout = 0;
//              nextreadout = 1; 
//                 // if ((done& mem_address == I2C_ADDRESS)| (mem_address < 32'd2048)) begin 
                
//                 // case(func3)
//                 // 0: begin //signed
//                 //     nextregs = {{24{frommem[31]}},frommem[7:0]}; end //LB
//                 // 1: begin
//                 //     nextregs = {{16{frommem[31]}},frommem[15:0]}; end //LH


//                 // 4: begin //unsigned
//                 //     nextregs = {24'b0, frommem[7:0]}; end //LBU
                
//                 // 5: begin 
//                 //     nextregs = {16'b0, frommem[15:0]}; end //LHU

//                 // default:  begin  nextregs = frommem; end //lw or lui;
//                 // endcase
//                 // end 
//                  end 
                
   
//       nextnewadd = counter;
//         nextfreeze = 1;
        
//         if (gdone) begin
//             nextstate = 1;
    

//         end
//         else 
//             nextstate = 2;

//         end

//     default: begin readout = 0; writeout = 0; end
  

//   endcase
// end

// endmodule 
