`default_nettype none
`timescale 1ms/10ps

module t03_requestUnit (
    input logic clk,
    input logic rst,
    input logic ack,
    input logic memRead,
    input logic memWrite,
    input logic [31:0] pcMemory, //Location of program counter in memory
    input logic [31:0] resultALU, //Output of ALU
    output logic read,
    output logic write,
    output logic freezePC,
    output logic freezeInstr,
    output logic addressSrc,
    output logic [31:0] address //For interfacing with wishbone manager / MMIO
);

typedef enum logic [1:0] {
    INSTRUCTION_DONE = 2'b00,
    WAIT_INSTRUCTION = 2'b01,
    READ_MEMORY = 2'b10,
    WRITE_MEMORY = 2'b11
} memory_state;

memory_state state;
memory_state next_state;

assign address = addressSrc ? resultALU : pcMemory;


always_ff @ (posedge clk, posedge rst) begin
    if(rst) begin
        state = INSTRUCTION_DONE;
    end else begin
        state = next_state;
    end
end

always_comb begin //NEXT_STATE LOGIC
    next_state = state; //DEFAULT
    case(state)
        INSTRUCTION_DONE: begin
            if (memRead) begin
                next_state = READ_MEMORY;
            end else if (memWrite) begin
                next_state = WRITE_MEMORY;
            end else begin
                next_state = WAIT_INSTRUCTION;
            end
        end
        WAIT_INSTRUCTION: begin
            if(ack) begin
                next_state = INSTRUCTION_DONE;
            end
        end
        READ_MEMORY: begin
            if(ack) begin
                next_state = WAIT_INSTRUCTION;
            end
        end
        WRITE_MEMORY: begin
            if(ack) begin
                next_state = WAIT_INSTRUCTION;
            end
        end
    endcase
end

always_comb begin //OUTPUT LOGIC
    case(state)
        INSTRUCTION_DONE: begin
            freezePC = 1'b1;
            freezeInstr = 1'b0;
            read = ~(memWrite);
            write = memWrite;
            addressSrc = (memWrite | memRead);
        end
        WAIT_INSTRUCTION: begin
            freezePC = ~ack;
            freezeInstr = 1'b1;
            read = 1'b1;
            write = 1'b0;
            addressSrc = 1'b0;
        end
        READ_MEMORY: begin
            freezePC = 1'b1;
            freezeInstr = 1'b1;
            read = 1'b1;
            write = 1'b0;
            addressSrc = 1'b1;
        end
        WRITE_MEMORY: begin
            freezePC = 1'b1;
            freezeInstr = 1'b1;
            read = 1'b0;
            write = 1'b1;
            addressSrc = 1'b1;
        end
    endcase
end

endmodule