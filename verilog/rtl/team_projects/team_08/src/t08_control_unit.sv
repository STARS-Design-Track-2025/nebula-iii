`default_nettype none
//control unit: [description]

module t08_control_unit(  
    input logic [31:0] instruction,       //32 bit instruction   
    output logic read,                    //to memory handler
    output logic write,                   //to memory handler
    output logic [2:0] funct3,            //funct3 field and enabler passed to memory handler

    output logic [4:0] reg1,              //register 1
    output logic [4:0] reg2,              //register 2
    output logic [4:0] regd,              //destination register
    output logic en_read_1,               //to registers: register 1 reading enabler
    output logic en_read_2,               //to registers: register 2 reading enabler
    output logic en_write,                //to registers: register writing enabler
    output logic [1:0] data_in_control,   //to registers

    output logic [31:0] immediate,        //to ALU: 32 bit immediate
    output logic [5:0] alu_control,       //to ALU: 6-bit command for controlling the alu module
    
    output logic jump                   //to program counter: control signal enabling jump operation
);

logic [6:0] opcode;                //opcode field               
logic [6:0] funct7;                //function 7 field 

//Logic for analyzing the type of the instruction 
always_comb begin
    opcode = instruction[6:0];

    read = 0;                   //to memory handler
    write = 0;                  //to memory handler
    funct3 = 0;                 //to memory handler

    reg1 = 0;                   //register 1
    reg2 = 0;                   //register 2
    regd = 0;                   //destination register
    en_read_1 = 0;              //to registers
    en_read_2 = 0;              //to registers
    en_write = 0;               //to registers
    data_in_control = 0;        //to registers
    if (instruction[31] == 0) begin
        immediate = 0;              //to ALU
    end else begin
        immediate = {32{1'b1}};
    end
    
    alu_control = 0;            //to ALU: for controlling the alu module

    jump = 0;                   //to instruction fetch/ program counter

    //R-TYPE INSTRUCTIONS  
    if (opcode == 7'b0110011) begin  
        funct7 = instruction[31:25];

        funct3 = instruction[14:12];
        
        reg1 = instruction[19:15];
        reg2 = instruction[24:20];
        regd = instruction[11:7];
        en_read_1 = 1;
        en_read_2 = 1;
        en_write = 1;
        data_in_control = 2'd3;

        case(funct3)
            3'b000: begin                                      
                if (funct7 == 0) begin              // ADDITION
                    alu_control = 6'd1; 
                end                    
                else if(funct7 == 32) begin            //SUBTRACTION
                    alu_control = 6'd2; 
                end
            end
            3'b001: begin
                if (funct7 == 0) begin              // SLL: SHIFT LEFT LOGICAL
                    alu_control = 6'd3;
                end                           
            end

            3'b010: begin
                if (funct7 == 0) begin              // SLT: SET LESS THAN
                    alu_control = 6'd4;
                end 
            end

            3'b011: begin
                if (funct7 == 0) begin              // SLTU: SET LESS THAN UNSIGNED
                    alu_control = 6'd5;
                end 
            end
                        
            3'b100: begin
                if (funct7 == 0) begin              // XOR
                    alu_control = 6'd6; 
                end
            end
            
            3'b101: begin
                if (funct7 == 0) begin              // SRL: SHIFT RIGHT LOGICAL 
                    alu_control = 6'd7;
                end else if (funct7 == 32) begin 
                        alu_control = 6'd8;         // SRA: SHIFT RIGHT ARITHMETIC
                end
            end
                        
            3'b110: begin
                if (funct7 == 0) begin              // OR 
                    alu_control = 6'd9;
                end 
            end
                        
            3'b111: begin
                if (funct7 == 0) begin              // AND
                    alu_control = 6'd10;
                end
            end
            endcase
    end

    // I-TYPE              
    else if (opcode == 7'b0010011) begin
        funct3 = instruction[14:12];

        reg1 = instruction[19:15];
        regd = instruction[11:7];
        en_read_1 = 1;
        en_write = 1;
        data_in_control = 2'd3;
        immediate[11:0] = instruction[31:20];

        case (funct3)
            3'b000: begin
                alu_control = 6'd11;                // ADDI: ADD IMMEDIATE
            end

            3'b010 : begin
                alu_control = 6'd12;                // SLTI: SET LESS THAN IMMEDIATE
            end
                                
            3'b011: begin
                alu_control = 6'd13;                // SLTIU: SET LESS THAN IMMEDIATE UNSIGNED
            end
            
            3'b100: begin
                alu_control = 6'd14;                // XORI: XOR IMMEDIATE
            end                

            3'b110: begin
                alu_control = 6'd15;                // ORI: OR IMMEDIATE
            end
            
            3'b111: begin
                alu_control = 6'd16;                // ANDI: AND IMMEDIATE
            end

            3'b001: begin
                funct7 = instruction[31:25];
                alu_control = 6'd17;                //SLLI: SHIFT LEFT LOGICAL IMMEDIATE
            end

            3'b101: begin
                funct7 = instruction[31:25];

                if (funct7 == 0) begin
                    alu_control = 6'd18;            // SRLI: SHIFT RIGHT LOGICAL IMMEDIATE
                end 
                else if (funct7 == 32) begin
                    alu_control = 6'd19;            // SRAI: SHIFT RIGHT ARITHMETIC IMMEDIATE
                end
            end
        endcase
    end

    // I-TYPE (LOAD INSTRUCTIONS)  
    else if(opcode == 7'b0000011) begin
        read = 1;   
        funct3 = instruction[14:12];
    
        reg1 = instruction[19:15];
        regd = instruction[11:7];
        en_read_1 = 1;
        en_write = 1;
        data_in_control = 1; //plex to datareg from memory handler

        immediate[11:0] = instruction[31:20];

        case(funct3)
            3'b000: begin             
                alu_control = 6'd20;                // LB: LOAD BYTE
            end

            3'b001: begin
                alu_control = 6'd21;                // LH: LOAD HALF          
            end

            3'b010: begin
                alu_control = 6'd22;                // LW: LOAD WORD
            end 
            
            3'b100: begin              
                alu_control = 6'd23;                // LBU: LOAD BYTE UNSIGNED
            end
                                                         
            
            3'b101: begin
                alu_control = 6'd24;                // LHU: LOAD HALF UNSIGNED
            end  

        endcase
    end

    //S-TYPE  
    else if (opcode == 7'b0100011) begin 
        write = 1;
        funct3 = instruction[14:12];

        reg1 = instruction[19:15];
        reg2 = instruction[24:20];
        regd = instruction[11:7];    
        en_read_1 = 1;
        data_in_control = 2'd3;

        immediate[6:0] = instruction[31:25];

        case(funct3)
            3'b000: begin
                alu_control = 6'd25;                // SB: STORE BYTE
            end        
            
            3'b001: begin
                alu_control = 6'd26;                // SH: STORE HALF
            end
            
            3'b010: begin
                alu_control = 6'd27;                // SW: STORE WORD
            end

        endcase
    end

    //BRANCHING INSTRUCTION
    else if(opcode == 7'b1100011) begin
        funct3 = instruction[14:12];

        reg1 = instruction[19:15];
        reg2 = instruction[24:20];
        en_read_1 = 1;
        en_read_2 = 1;

        immediate[12] = instruction[31];
        immediate[10:5] = instruction[30:25];
        immediate[4:1] = instruction[11:8];
        immediate[11] = instruction[7];
        immediate[0] = 0;
        
        case(funct3)
            3'b000: begin                           //BEQ: BRANCH EQUAL
                alu_control = 6'd28; 
            end

            3'b001: begin                           //BNE: BRANCH NOTE EQUAL
                alu_control = 6'd29; 
            end
                
            3'b100: begin
                alu_control = 6'd30;                //BLT: BRANCH LESS THAN
            end    
            
            3'b101: begin
                alu_control = 6'd31;                // BGE: BRANCH IF GREATER THAN OR EQUAL TO 
            end
            
            3'b110: begin
                alu_control = 6'd32;                //BLTU: BRANCH LESS THAN UNISIGNED
            end
                
            3'b111: begin
                alu_control = 6'd33;                // BGEU: BRANCH GREATER THAN OR EQUAL UNSIGNED 
            end
        
        endcase
    end

    //U-TYPE: LUI
    else if (opcode == 7'b0110111) begin 
        funct3 = 1; //to enable memory handler

        regd = instruction[11:7];
        en_write = 1;
        data_in_control = 2'd1;

        immediate[31:12] = instruction[31:12];
        immediate[0] = 0;
        alu_control = 6'd34;
    end
    
    //U-TYPE: AUIPC: ADD UPPER IMMEDIATE TO COUNTER
    else if (opcode == 7'b0010111) begin
        regd = instruction[11:7];
        en_write = 1;
        data_in_control = 2'd3;

        immediate[31:12] = instruction[31:12];
        immediate[0] = 0;
        alu_control = 6'd35;
    end
    
    //J-TYPE: JAL: JUMP AND LINK OPERATION
    else if (opcode == 7'b1101111) begin
        regd = instruction[11:7];
        en_write = 1;
        data_in_control = 2'd2;

        immediate[20] = instruction[31];
        immediate[10:1] = instruction[30:21];
        immediate[11] = instruction[20];
        immediate[19:12] = instruction[19:12];
        immediate[0] = 0;
        alu_control = 6'd36;

        jump = 1;
    end
    
    //I-TYPE: JALR: JUMP AND LINK REGISTER
    else if (opcode == 7'b1100111) begin
        funct3 = instruction[14:12];
        
        reg1 = instruction[19:15];
        regd = instruction[11:7];
        en_read_1 = 1;
        en_write = 1;
        data_in_control =2'd2;

        immediate[11:0] = instruction[31:20];
        alu_control = 6'd37;
        
        jump = 1;
    end                    
end 
                
        
endmodule
