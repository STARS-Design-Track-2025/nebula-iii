`timescale 1ns / 1ps
module t07_control_unit_tb ();
    //control unit inputs
    logic [6:0] Op, funct7;
    logic [2:0] funct3;
    logic [4:0] rs2;
    //control unit outputs
    logic ALUSrc, regWrite, branch, jump, memWrite, memRead, memToReg, FPUSrc, regEnable;
    logic [2:0] regWriteSrc, FPURnd;
    logic [4:0] FPUOp, rs3;
    logic [1:0] FPUWrite;
    logic [3:0] memOp;

    task Opcodes; begin
        Op = 'b0110111; //U-type, lui
        #6
        Op = 'b0010111; //U-type, auipc
        #6
        Op = 'b1101111; //J-type, jal
        #6
        Op = 'b1100111; //I-type, jalr
        #6
        Op = 'b1100011; //B-type
        #6
        Op = 'b0000011; //I-type (load)
        #6
        Op = 'b0100011; //S-type
        #6
        Op = 'b0010011; //I-type (immediate)
        #6
        Op = 'b0110011; //R-type
    end
    endtask

    task funct3_task; begin
        funct3 = 'b000;
        #1
        funct3 = 'b001;
        #1
        funct3 = 'b010;
        #1
        funct3 = 'b011;
        #1
        funct3 = 'b100;
        #1
        funct3 = 'b101;
        #1
        funct3 = 'b110;
        #1
        funct3 = 'b111;
    end
    endtask

    task funct7_task; begin
        funct7 = '0;
        #0.5
        funct7 = 'b0100000;
    end
    endtask

    task rs2_task; begin
        rs2 = '0;
        #1 
        rs2 = 5'b00001;
    end
    endtask

    //signal dump
    initial begin
        $dumpfile("t07_control_unit.vcd");
        $dumpvars(0, t07_controlUnit_tb);

    Opcodes();
    funct3_task();
    funct7_task();

    end




endmodule