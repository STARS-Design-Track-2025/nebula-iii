module t08_alu(

    input logic [31:0] reg1, reg2, immediate, program_counter, //Inputs that operations may be done on (from two registers, an immediate value, or the program counter)

    input logic [5:0] alu_control, //For determining which operation to perform

    output logic [31:0] data_out, //Result outputted from an operation

    output logic branch //Whether the branch condition has been met
    
);

    logic [31:0] in1, in2; //Which inputs the operation will ultimately be done on 

    typedef enum logic [5:0] {
        ADD =   6'd1, //R type
        SUB =   6'd2,
        SLL =   6'd3,
        SLT =   6'd4,
        SLTU =  6'd5,
        XOR =   6'd6,
        SRL =   6'd7,
        SRA =   6'd8,
        OR =    6'd9,
        AND =   6'd10,
        
        ADDI =   6'd11, //I type
        SLTI =   6'd12,
        SLTIU =  6'd13,
        XORI =   6'd14,
        ORI =    6'd15,
        ANDI =   6'd16,
        SLLI =   6'd17,
        SRLI =   6'd18,
        SRAI =   6'd19,

        LB =     6'd20, //I type continued
        LH =     6'd21,
        LW =     6'd22,
        LBU =    6'd23,
        LHU =    6'd24,

        SB = 6'd25, //S type
        SH = 6'd26,
        SW = 6'd27,

        BEQ = 6'd28, //B type
        BNE = 6'd29,
        BLT = 6'd30,
        BGE = 6'd31,
        BLTU = 6'd32,
        BGEU = 6'd33,

        AUIPC = 6'd35, // U type

        JALR = 6'd37

    } alu_operations;

    alu_operations alu_operation;
    assign alu_operation = alu_operations'(alu_control);

    always_comb begin : input_multiplexer

        case (alu_operation)

            ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI, LB, LBU, LH, LHU, LW, SB, SH, SW, JALR: begin
                in1 = reg1;
                in2 = immediate;
            end
            AUIPC: begin
                in1 = program_counter;
                in2 = immediate;
            end
            default: begin
                in1 = reg1;
                in2 = reg2;
            end            

        endcase

    end

    always_comb begin : operation_select

        data_out = 32'b0; //Default value
        branch = 1'b0; //Default value

        case (alu_operation)

            ADD, ADDI, LB, 
            LBU, LH, LHU, 
            LW, SB, SH, 
            SW, AUIPC, JALR:  data_out =    in1 + in2;
            SUB:              data_out =    in1 - in2;
            SLL, SLLI:        data_out =    in1 << (in2[4:0]);
            SLT, SLTI:        data_out =    {31'b0, $signed(in1) < $signed(in2)};
            SLTU, SLTIU:      data_out =    {31'b0, in1 < in2};
            XOR, XORI:        data_out =    in1 ^ in2;
            SRL, SRLI:        data_out =    in1 >> (in2[4:0]);
            SRA, SRAI:        data_out =    $signed(in1) >>> (in2[4:0]);
            OR, ORI:          data_out =    in1 | in2;
            AND, ANDI:        data_out =    in1 & in2;

            BEQ:    branch =     (in1 == in2);
            BGE:    branch =     ($signed(in1) >= $signed(in2));
            BGEU:   branch =     (reg1 >= reg2);
            BLT:    branch =     ($signed(in1) < $signed(in2));
            BLTU:   branch =     (in1 < in2);
            BNE:    branch =     (in1 != in2);

            default: begin
                data_out = 32'b0;
                branch = 1'b0;
            end

        endcase

    end

endmodule