// //memory handler: does few things: for write mode (store type operations),
// //passes data from register to the memory. 3 types of operations: SB(first 8 bits), SH(half data),SW(full data))
// //for read operations: passes data from memory to register. 5 types of operations: 
// //3 signed: lb(load byte), lh(half data), lw(whole data), and unsigned: lbu(byte), lhu(hald), lui


// module t08_handler(
//     input logic, clk, nrst,

//     //from register
//     input logic [31:0] reg_data_i,

//     //from mmio
//     input logic [31:0] mmio_data_i,
//     input logic mmio_busy_i,
    
//     //from alu??
//     input logic [31:0] address_i,
    
//     //from pc /fetch
//     input logic [31:0] counter,

//     //from CU
//     input write_i, read_i, 
//     input [2:0] funct3,

//     //to register
//     output [31:0] reg_data_o,

//     //to mmio
//     output [31:0] mmio_data_o,
//     output mmio_read_o, mmio_write_o, mmio_getinst_o,

//     //to ????
//     output [31:0] address_o,

//     //to CPU
//     output [31:0] instruction_o,

//     //to pc/ fetch
//     output fetch_inc

//     // input logic [31:0] fromregister,        //data to write from register
//     //                    frommem,             //data read from memory
//     //                    mem_address,         //memory address to read from or write to
//     //                    counter,             //instruction location
//     // input logic write, read,                //command from CU to write or read 
//     //             clk, nrst,                  //command from 
//     //             busy, done,                 //WHAT IS DONE
//     // input logic [2:0] func3,
//     // output logic [31:0] toreg,  tomem, addressnew, instruction,
//     // output logic writeout, readout,  getinst, freeze
// );

// typedef enum logic[1:0] {
//     READINST,
//     LOADING,
//     STORING,
// } state;

// state curr_state, next_state;
// logic [31:0] reg_data_o_next, mmio_data_o_next, address_o_next, instruction_o_next; 

// always_ff@(posedge clk, negedge nrst) begin
//     if (!nrst) begin
//         curr_state = READINST;
//         reg_data_o = 0;
//         mmio_data_o = 0;
//         address_o = 0;
//         instruction_o = 0;
//     end else begin
//         curr_state = next_state;
//         reg_data_o = reg_data_o_next;
//         mmio_data_o = mmio_data_next;
//         address_o = address_o_next;
//         instruction_o = instruction_o_next;
//     end
// end

// always_comb begin
//     case (state)
//         reg_data_o_next = 0;
//         mmio_data_o_next = 0;
//         address_o_next = 0;
//         instruction_o_next = 0;

//         READINST:
//             mmio_read_o = 1;

//         LOADING:
//             if (busy) begin
//                 next_state = LOADING;
//             end else begin
//                 next_state = READINST;
//             end
//         STORING:
//             if (busy) begin
//                 next_state = STORING;
//             end else begin
//                 next_state = READINST;
//             end
//     endcase
// end

// /*
// localparam [31:0] I2C_ADDRESS = 32'd923923;

// logic [31:0] regs = 0, mems = 0, address, nextregs, nextmem, nextinst, nextnewadd; //tempo var
// logic [1:0] state,  nextstate; //0 wait, 1 send

// //assign addressnew = mem_address; 
// assign tomem = mems;
// assign toreg = regs;
// //assign writeout = write;
// //assign readout = read;
// assign freeze = busy|readout|writeout;

// always_ff@(posedge clk, negedge nrst) begin
//     if(!nrst) begin
//         regs <= '0;
//         mems <= '0;
//         addressnew <= 0;
//         state <= 0; //wait
//     end
//     else begin
//         regs <= nextregs;
//         mems <= nextmem;
//         state <= nextstate;
//         instruction <= nextinst ;
//         addressnew <= nextnewadd;

//     end
// end

// always_comb begin
//     nextstate = state;
//     nextnewadd = addressnew;
//     nextregs = regs;
//     nextmem = mems;
//     nextinst = instruction;
//     readout = 0;
//     writeout = 0;

//     case(state)
//     // 0: begin
//     //      if (!busy) begin

//     //         if ((write) | (read & done)) begin 
//     //                 nextstate = 1; //data
//     //             end
//     //         else if (!write&!read) begin
//     //             nextstate = 2;
//     //         end
//     //         else begin
//     //             nextstate = 0;
//     //         end

//     // end
//     // end

//     0: begin //data
//         nextnewadd = counter; 

//         nextmem = mems;
//         nextregs = regs;
//         nextstate = 1;

//         readout = 0;
//         writeout = 0;
//         if (busy) begin nextstate = 0; end

//         else if (write&!busy) begin //store type, signed
//             writeout = write;
//             nextnewadd = mem_address;

//             case(func3)
//             0: begin
//                 nextmem = {{24{fromregister[31]}},fromregister[7:0]}; end //SB
//             1: begin
//                 nextmem = {{16{fromregister[31]}},fromregister[15:0]}; end //SH     
//             2: begin
//                 nextmem = fromregister; end  //sw
//             default:;
//             endcase

//             //nextstate = 0;
//         end

//         else if (read& !busy) begin
//             readout = read;
//             nextnewadd = mem_address;
//           //  nextstate = 0;

//             if ((done& mem_address == I2C_ADDRESS)| (mem_address < 32'd2048)) begin 
//             case(func3)
//             0: begin //signed
//                 nextregs = {{24{frommem[31]}},frommem[7:0]}; end //LB
//             1: begin
//                 nextregs = {{16{frommem[31]}},frommem[15:0]}; end //LH


//             4: begin //unsigned
//                 nextregs = {24'b0, frommem[7:0]}; end //LBU
            
//             5: begin 
//                 nextregs = {16'b0, frommem[15:0]}; end //LHU

//             default:  begin  nextregs = frommem; end //lw or lui;
//             endcase

//            end 
//             end

//         // else begin
//         //     //nextstate = 1;
//         // end
//     end

//     1: begin //instruction fetching
//         nextnewadd = counter;                  
//         nextinst = frommem;
//         if(!busy) begin
//             getinst = 1;        

//             nextstate = 0;
//         end

//     end

//     // 2: begin //instruction sending to cu
 

//     //     //readout = 1;
//     // end
//     default: begin readout = 0; writeout = 0; end
//     endcase
// end

// */

// endmodule 
