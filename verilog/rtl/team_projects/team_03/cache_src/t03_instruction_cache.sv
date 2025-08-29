`timescale 1ps/1ps
module t03_instruction_cache
#(
    parameter SET_SIZE = 15
)(
    input logic clk,
    input logic rst,
    output logic [31:0] cache_out,
    output logic hit,
    output logic next_hit,
    input logic [31:0] input_instruction, //this is the instruction that comes from the block RAM
    input logic [31:0] next_address, //this is the address from the PC
    input logic [31:0] current_address,
    input logic cache_read

);
    logic [SET_SIZE:0] valid_bit, n_valid_bit;
    logic [SET_SIZE:0][25:0] address_tags, n_address_tags;
    logic [SET_SIZE:0][31:0] instructions, n_instructions;


    always_ff @(posedge clk, posedge rst) begin
        if(rst) begin
            valid_bit <= 0;
            address_tags <= 0;
            instructions <= 0;
        end
        else if (|input_instruction) begin
            valid_bit <= n_valid_bit;
            address_tags <= n_address_tags;
            instructions <= n_instructions;

        end
    end

    always @ (*) begin
        n_valid_bit = valid_bit;
        n_address_tags = address_tags;
        n_instructions = instructions;
        cache_out = 0;
        hit = 0;
        if(valid_bit[current_address[5:2]] && (address_tags[current_address[5:2]] == current_address[31:6])) begin //cache hit
            hit = 1;
            cache_out = instructions[current_address[5:2]]; //this is the data that was stored in cache
        end
        if(cache_read) begin //cache miss but new data is loaded
            n_instructions[current_address[5:2]] = input_instruction;
            n_address_tags[current_address[5:2]] = current_address[31:6];
            n_valid_bit[current_address[5:2]] = 1;
        end
    end

    always @ (*) begin
        next_hit = 0;
        if(valid_bit[next_address[5:2]] && (address_tags[next_address[5:2]] == next_address[31:6])) begin
            next_hit = 1;
        end
    end


endmodule