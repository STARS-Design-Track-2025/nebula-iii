`default_nettype none
`timescale 1ms/10ps

module t03_requestUnitCached (
    input logic clk,
    input logic rst,
    input logic ack,
    input logic next_hit,
    input logic memRead,
    input logic memWrite,
    input logic [31:0] pcMemory, //Location of program counter in memory
    input logic [31:0] resultALU, //Output of ALU
    output logic read,
    output logic write,
    output logic freezePC,
    output logic freezeInstr,
    output logic addressSrc,
    output logic [31:0] address, //For interfacing with wishbone manager / MMIO
    output logic cache_read
);

typedef enum logic [1:0] {
    INSTRUCTION_DONE = 2'b00,
    WAIT_INSTRUCTION = 2'b01,
    READ_MEMORY = 2'b10,
    WRITE_MEMORY = 2'b11
} memory_state;

memory_state state, next_state;
memory_state previous_state;

assign address = addressSrc ? resultALU : pcMemory;

always_ff @ (posedge clk, posedge rst) begin
    if(rst) begin
        state <= INSTRUCTION_DONE;
        previous_state <= INSTRUCTION_DONE;
    end 
    else begin
        state <= next_state;
        previous_state <= state;
    end
end

always_comb begin //NEXT_STATE LOGIC
    next_state = state; //DEFAULT
    case(state)
        INSTRUCTION_DONE: begin
            if (memRead) begin
                //next_previous_state = INSTRUCTION_DONE;
                next_state = READ_MEMORY;
            end else if (memWrite) begin
               // next_previous_state = INSTRUCTION_DONE;
                next_state = WRITE_MEMORY;
            end else if (~next_hit && ~(memRead | memWrite)) begin
                // next_previous_state = INSTRUCTION_DONE;
                next_state = WAIT_INSTRUCTION;
            end else begin
                next_state = INSTRUCTION_DONE;
            end
        end
        WAIT_INSTRUCTION: begin
            if(ack) begin
                next_state = INSTRUCTION_DONE;
            end
        end
        READ_MEMORY: begin
            if(!next_hit && ack) begin
                next_state = WAIT_INSTRUCTION;
            end else if (next_hit && ack) begin
                next_state = INSTRUCTION_DONE;
            end
        end
        WRITE_MEMORY: begin
            if(!next_hit && ack) begin
                next_state = WAIT_INSTRUCTION;
            end else if (next_hit && ack) begin
                next_state = INSTRUCTION_DONE;
            end
        end
    endcase
end

always_comb begin //OUTPUT LOGIC
    cache_read = 0;
    case(state)
        INSTRUCTION_DONE: begin
            freezePC = (next_state != INSTRUCTION_DONE) ? 1 : 0; 
            freezeInstr = 1'b0;
            read = ~(memWrite) && ~next_hit;
            write = memWrite;
            addressSrc = (memWrite | memRead);
            cache_read = (previous_state == WAIT_INSTRUCTION);
        end
        WAIT_INSTRUCTION: begin
            freezePC = ~ack;
            freezeInstr = 1'b1;
            read = 1'b1;
            write = 1'b0;
            addressSrc = 1'b0;
        end
        READ_MEMORY: begin
            freezePC = ~next_hit;
            freezeInstr = 1'b1;
            read = 1'b1;
            write = 1'b0;
            addressSrc = 1'b1;
        end
        WRITE_MEMORY: begin
            freezePC = ~next_hit;
            freezeInstr = 1'b1;
            read = 1'b0;
            write = 1'b1;
            addressSrc = 1'b1;
        end
    endcase
end

endmodule