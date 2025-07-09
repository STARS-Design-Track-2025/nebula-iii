module t08_alu(
    input logic clk, nRst, //Clock and active-low reset

    input logic [31:0] reg1, reg2, immediate, program_counter, //Inputs that operations may be done on (from two registers, an immediate value, or the program counter)

    input logic [5:0] alu_control, //For determining which operation to perform

    output logic [31:0] data_out, //Result outputted from an operation

    output logic branch //Whether the branch condition has been met
);

    logic [31:0] data_out_n;
    logic branch_n;

    logic [31:0] in1, in2; //Which inputs the operation will ultimately be done on 

    always_ff @ (posedge clk, negedge nRst) begin
        if (!nRst) begin
            data_out <= 0;
            branch <= 0;
        end else begin
            data_out <= data_out_n;
            branch <= branch_n;
        end
    end

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

        ADDI =  6'd11, //I type
        SLTI =  6'd12, 
        SLTIU = 6'd13, 
        XORI =  6'd14,
        ORI =   6'd15,
        ANDI =  6'd16, 

        LB =    6'd17, //I type continued
        LBU =   6'd18,
        LH =    6'd19,
        LHU =   6'd20,
        LW =    6'd21,

        SB = 6'd22, //S type
        SH = 6'd23,
        SW = 6'd24,

        BEQ = 6'd25, //B type
        BGE = 6'd26,
        BGEU = 6'd27,
        BLT = 6'd28,
        BLTU = 6'd29,
        BNE = 6'd30,    

        AUIPC = 6'd31 //U type

    } alu_operations;

    always_comb begin : input_multiplexer

        case (alu_operations'(alu_control))

            ADDI, SLTI, SLTIU, XORI, ORI, ANDI, LB, LBU, LH, LHU, LW, SB, SH, SW: begin
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

        data_out_n = 32'b0; //Default value
        branch_n = 1'b0; //Default value

        case (alu_operations'(alu_control))

            ADD, ADDI, LB, 
            LBU, LH, LHU, 
            LW, SB, SH, 
            SW, AUIPC:        data_out_n =    in1 + in2;
            SUB:              data_out_n =    in1 - in2;
            SLL:              data_out_n =    in1 << (in2[4:0]);
            SLT, SLTI:        data_out_n =    {31'b0, $signed(in1) < $signed(in2)};
            SLTU, SLTIU:      data_out_n =    {31'b0, in1 < in2};
            XOR, XORI:        data_out_n =    in1 ^ in2;
            SRL:              data_out_n =    in1 >> (in2[4:0]);
            SRA:              data_out_n =    in1 >>> (in2[4:0]);
            OR, ORI:          data_out_n =    in1 | in2;
            AND, ANDI:        data_out_n =    in1 & in2;

            BEQ:    branch_n =     (in1 == in2);
            BGE:    branch_n =     ($signed(in1) >= $signed(in2));
            BGEU:   branch_n =     (reg1 >= reg2);
            BLT:    branch_n =     ($signed(in1) < $signed(in2));
            BLTU:   branch_n =     (in1 < in2);
            BNE:    branch_n =     (in1 != in2);

            default: begin
                data_out_n = 32'b0;
                branch_n = 1'b0;
            end

        endcase

    end

endmodule