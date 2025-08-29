`default_nettype none
`timescale 1ms/10ps


module t03_branchControl (
  input logic [2:0] branch,
  input logic [1:0] jump,
  input logic zero,
  input logic negative,
  input logic overflow,
  output logic [1:0] control
);

    typedef enum logic [2:0] { //NONE = 3'b011
    BEQ = 3'b000,
    BNE = 3'b001,
    BLT = 3'b100,
    BGE = 3'b101,
    BLTU = 3'b110,
    BGEU = 3'b111
    } BRANCHTYPE;

    typedef enum logic [1:0] {  //NONE = 2'b00
    JAL = 2'b01,
    JALR = 2'b10
    } JUMPTYPE;

    always_comb begin
        control[0] = (jump == JALR);

        if(jump == JAL) begin
            control[1] = 1'b1;
        end else begin
            case(branch)
                BEQ: control[1] = zero;
                BNE: control[1] = ~zero;
                BLT: control[1] = negative;
                BGE: control[1] = ~negative;
                BLTU: control[1] = overflow;
                BGEU: control[1] = ~overflow;
                default: control[1] = 1'b0;
            endcase
        end
    end

endmodule