`default_nettype none

/* CPU Memory Handler for Team 07

-This module handles memory operations for the CPU, including read and write operations.
-It interfaces with the memory and manages the data flow based on control signals.
-Takes in Data from the control unit and ALU, and outputs the read data and memory address.

*/

 typedef enum logic [3:0] {  
        FETCH = 0,
        F_WAIT = 1,
        DATA = 2,
        D_WAIT = 3
    } state_t;


module t07_cpu_memoryHandler (

    // Inputs
    input logic clk, nrst, busy, // Busy signal to indicate if the memory handler is currently processing
    input logic [3:0] memOp,
    input logic memWrite, memRead,
    input logic memSource,          //if we are writing from the FPU or ALU
    input logic [31:0] ALU_address, // Address for memory operations that comes from the ALU
    input logic [31:0] FPU_data,    // Data from the FPU register to store in memory
    input logic [31:0] Register_dataToMem, // Data from the internal register file to store in memory
    input logic [31:0] ExtData,     // Data from external memory to read/write
    
    //outputs
    output logic [31:0] write_data, // Data to write to external memory
    output logic [31:0] ExtAddress, // Address to write to external memory   
    output logic [31:0] dataToCPU,  // Data to the register
    output logic freeze,            // Freeze signal to pause CPU operations during memory access
    output logic [1:0] rwi,          // Read/Write/Idle control signal for external memory operations
    output logic fetchRead,
    output state_t state,
    output logic addrControl // control for address mux, 0 when fetch, 1 when l/s

);
    //edge detector
    logic load_ct;
    logic prev_busy_o;
    logic busy_o_edge;
    state_t state_n;

    always_ff @(negedge nrst, posedge clk) begin
        if(~nrst) begin
            prev_busy_o <= '0;
        end else begin
            prev_busy_o <= busy;
        end
    end

    assign busy_o_edge = (~busy && prev_busy_o); //detects falling edge

    //fsm
    always_ff @(negedge nrst, posedge clk) begin
        if (~nrst) begin
            state <= FETCH;
        end else begin
            state <= state_n;
        end
    end

    always_comb begin
        case(state) 
            FETCH: begin addrControl = '0; fetchRead = '1; 
                if(busy_o_edge == 'b1) begin state_n = FETCH; end 
                else begin state_n = F_WAIT; end end
            F_WAIT: begin addrControl = 0; fetchRead = '0; 
                if(busy_o_edge == 'b1) begin state_n = F_WAIT; end 
                else begin state_n = DATA; end end
            DATA: begin load_ct = '0; addrControl = 1; fetchRead = '0; 
                if(busy_o_edge == 'b1 & memWrite == 1) /*store*/ begin state_n = D_WAIT; end //load ct = 0 
                else if (busy_o_edge == 1 & memRead == 1) /*load*/ begin state_n = D_WAIT; load_ct = load_ct + 1; end end
            D_WAIT: begin fetchRead = '0; addrControl = 1;
                if(load_ct == 0) begin state_n = FETCH; end
                else if (load_ct == 1) begin state_n = DATA; end
                else state_n = FETCH; end
        endcase
    end

always_comb begin
    if (busy) begin
        freeze = 1;
        write_data = 32'b0; // No data to write when busy
        ExtAddress = 32'b0; // No address to write to when busy
        dataToCPU = 32'b0; // No data to return to CPU when busy
        rwi = 2'b00; // Idle state when busy
    end else begin
        freeze = 0;
    if(memWrite) begin 
        dataToCPU = 32'b0; // No data to return to CPU on write operation
        rwi = 2'b01; // Write operation
        if(memSource) begin
            // If memSource is set, we are writing from the FPU register
            ExtAddress = ALU_address; // Use ALU address for memory operations
            if (memOp == 4'd6) begin // store byte
                write_data = {24'b0, FPU_data[7:0]}; // Store byte from FPU data
            end else if (memOp == 4'd7) begin // store half-word
                write_data = {16'b0, FPU_data[15:0]}; // Store half-word from FPU data
            end else if (memOp == 4'd8) begin // store word
                write_data = FPU_data; // Store full word from FPU data
            end else begin
                write_data = 32'b0; // Default case, no valid operation
            end
        end else begin
            // Otherwise, we are writing from the Register file
            ExtAddress = ALU_address; // Use ALU address for memory operations
            if (memOp == 4'd6) begin // store byte
                write_data = {24'b0, Register_dataToMem[7:0]}; // Store byte from FPU data
            end else if (memOp == 4'd7) begin // store half-word
                write_data = {16'b0, Register_dataToMem[15:0]}; // Store half-word from FPU data
            end else if (memOp == 4'd8) begin // store word
                write_data = Register_dataToMem; // Store full word from FPU data
            end else begin
                write_data = 32'b0; // Default case, no valid operation
            end 
        end 
    end else if(memRead) begin
        rwi = 2'b10; //Read operation
        ExtAddress = ALU_address; // Use ALU address for memory operations
        write_data = 32'b0; // No data to write in read operation
        if (memOp == 4'd1) begin //
            dataToCPU = {{24{ExtData[7]}}, ExtData[7:0]}; // Read data from external memory
        end else if (memOp == 4'd2) begin
            dataToCPU = {{16{ExtData[15]}}, ExtData[15:0]}; // Read half-word from external memory
        end else if (memOp == 4'd3) begin // Read full word from external memory
            dataToCPU = ExtData; 
        end else if (memOp == 4'd4) begin // Read byte unsigned
            dataToCPU = {24'b0, ExtData[7:0]}; 
        end else if (memOp == 4'd5) begin // Read half-word unsigned
            dataToCPU = {16'b0, ExtData[15:0]};
        end else begin
            dataToCPU = 32'b0; // Default case, no valid operation
        end
    end else begin
        rwi = 2'b00; // Idle state
        write_data = 32'b0; // No data to write
        ExtAddress = 32'b0; // No address to write to
        dataToCPU = 32'b0; // No data to return to CPU
    end
    end
end
endmodule
