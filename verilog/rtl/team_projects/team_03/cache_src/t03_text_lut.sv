`default_nettype none
`timescale 1ps/1ps
//This is not an official lut just to test
//output logic [71:0] text //Dimensions are up for grabs end index equals with * length - 1
module t03_text_lut #(parameter int number_of_chars = 12, parameter int character_bits = 72, parameter int char_size = 6)
(   
    //[0:11] Means you have 12 characters. Alaphabet input is 5 bits and gives you acces to 2^6 characters!!
    input logic [char_size*(number_of_chars)-1:0] alphabet,
    output logic [((number_of_chars*character_bits) - 1):0] characters	
);
    logic [5:0] bit_select;
    logic [4:0] row_indexing;
    parameter y_length = 8; //8 Bits Tall
    parameter x_length = 9; //Different on the LUT vs Display, this is for each individual character
    parameter width = x_length * y_length;
    logic [(character_bits-1):0] text;  
    always_comb begin
    for(int i = 1; i <= number_of_chars; i++) begin
    
        for(int j = 0; j <=(char_size-1); j++) begin
            bit_select[(char_size-1)-j] = alphabet[char_size*(number_of_chars)-1 - j - char_size*(i-1)];
        end

        case(bit_select) 
        
    //shout out to chat for removing the art portion of this project
    //"Generative AI" being generative
    //37 is empty space
            // A
    6'd0: begin
        text[71:63] = 9'b001110000;
        text[62:54] = 9'b010001000;
        text[53:45] = 9'b100000100;
        text[44:36] = 9'b100000100;
        text[35:27] = 9'b111111100;
        text[26:18] = 9'b100000100;
        text[17:9]  = 9'b100000100;
        text[8:0]   = 9'b100000100;
    end

    // B
    6'd1: begin
        text[71:63] = 9'b111111000;
        text[62:54] = 9'b100000100;
        text[53:45] = 9'b100000100;
        text[44:36] = 9'b111111000;
        text[35:27] = 9'b100000100;
        text[26:18] = 9'b100000100;
        text[17:9]  = 9'b100000100;
        text[8:0]   = 9'b111111000;
    end

    // C
    6'd2: begin
        text[71:63] = 9'b001111100;
        text[62:54] = 9'b010000000;
        text[53:45] = 9'b100000000;
        text[44:36] = 9'b100000000;
        text[35:27] = 9'b100000000;
        text[26:18] = 9'b100000000;
        text[17:9]  = 9'b010000000;
        text[8:0]   = 9'b001111100;
    end

    // D
    6'd3: begin
        text[71:63] = 9'b111111000;
        text[62:54] = 9'b100000100;
        text[53:45] = 9'b100000100;
        text[44:36] = 9'b100000100;
        text[35:27] = 9'b100000100;
        text[26:18] = 9'b100000100;
        text[17:9]  = 9'b100000100;
        text[8:0]   = 9'b111111000;
    end

    // E
    6'd4: begin
        text[71:63] = 9'b111111100;
        text[62:54] = 9'b100000000;
        text[53:45] = 9'b100000000;
        text[44:36] = 9'b111111000;
        text[35:27] = 9'b100000000;
        text[26:18] = 9'b100000000;
        text[17:9]  = 9'b100000000;
        text[8:0]   = 9'b111111100;
    end

    // F
    6'd5: begin
        text[71:63] = 9'b111111100;
        text[62:54] = 9'b100000000;
        text[53:45] = 9'b100000000;
        text[44:36] = 9'b111111000;
        text[35:27] = 9'b100000000;
        text[26:18] = 9'b100000000;
        text[17:9]  = 9'b100000000;
        text[8:0]   = 9'b100000000;
    end

    // G
    6'd6: begin
        text[71:63] = 9'b001111100;
        text[62:54] = 9'b010000000;
        text[53:45] = 9'b100000000;
        text[44:36] = 9'b100011100;
        text[35:27] = 9'b100000100;
        text[26:18] = 9'b100000100;
        text[17:9]  = 9'b010000100;
        text[8:0]   = 9'b001111100;
    end

    // H
    6'd7: begin
        text[71:63] = 9'b100000100;
        text[62:54] = 9'b100000100;
        text[53:45] = 9'b100000100;
        text[44:36] = 9'b111111100;
        text[35:27] = 9'b100000100;
        text[26:18] = 9'b100000100;
        text[17:9]  = 9'b100000100;
        text[8:0]   = 9'b100000100;
    end

    // I
    6'd8: begin
        text[71:63] = 9'b011111110;
        text[62:54] = 9'b000110000;
        text[53:45] = 9'b000110000;
        text[44:36] = 9'b000110000;
        text[35:27] = 9'b000110000;
        text[26:18] = 9'b000110000;
        text[17:9]  = 9'b000110000;
        text[8:0]   = 9'b011111110;
    end

    // J
    6'd9: begin
        text[71:63] = 9'b000111110;
        text[62:54] = 9'b000001100;
        text[53:45] = 9'b000001100;
        text[44:36] = 9'b000001100;
        text[35:27] = 9'b000001100;
        text[26:18] = 9'b000001100;
        text[17:9]  = 9'b100001100;
        text[8:0]   = 9'b011111000;
    end

    // K
    6'd10: begin
        text[71:63] = 9'b100000100;
        text[62:54] = 9'b100001000;
        text[53:45] = 9'b100010000;
        text[44:36] = 9'b111100000;
        text[35:27] = 9'b100010000;
        text[26:18] = 9'b100001000;
        text[17:9]  = 9'b100000100;
        text[8:0]   = 9'b100000010;
    end

    // L
    6'd11: begin
        text[71:63] = 9'b100000000;
        text[62:54] = 9'b100000000;
        text[53:45] = 9'b100000000;
        text[44:36] = 9'b100000000;
        text[35:27] = 9'b100000000;
        text[26:18] = 9'b100000000;
        text[17:9]  = 9'b100000000;
        text[8:0]   = 9'b111111100;
    end

    // M
    6'd12: begin
        text[71:63] = 9'b100000100;
        text[62:54] = 9'b110001100;
        text[53:45] = 9'b101010100;
        text[44:36] = 9'b100100100;
        text[35:27] = 9'b100000100;
        text[26:18] = 9'b100000100;
        text[17:9]  = 9'b100000100;
        text[8:0]   = 9'b100000100;
    end

    // N
    6'd13: begin
        text[71:63] = 9'b100000100;
        text[62:54] = 9'b110000100;
        text[53:45] = 9'b101000100;
        text[44:36] = 9'b100100100;
        text[35:27] = 9'b100010100;
        text[26:18] = 9'b100001100;
        text[17:9]  = 9'b100000100;
        text[8:0]   = 9'b100000100;
    end

    // O
    6'd14: begin
        text[71:63] = 9'b001111000;
        text[62:54] = 9'b010000100;
        text[53:45] = 9'b100000010;
        text[44:36] = 9'b100000010;
        text[35:27] = 9'b100000010;
        text[26:18] = 9'b100000010;
        text[17:9]  = 9'b010000100;
        text[8:0]   = 9'b001111000;
    end

    // P
    6'd15: begin
        text[71:63] = 9'b111111000;
        text[62:54] = 9'b100000100;
        text[53:45] = 9'b100000100;
        text[44:36] = 9'b111111000;
        text[35:27] = 9'b100000000;
        text[26:18] = 9'b100000000;
        text[17:9]  = 9'b100000000;
        text[8:0]   = 9'b100000000;
    end

    // Q
    6'd16: begin
        text[71:63] = 9'b001111000;
        text[62:54] = 9'b010000100;
        text[53:45] = 9'b100000010;
        text[44:36] = 9'b100000010;
        text[35:27] = 9'b100000010;
        text[26:18] = 9'b100010010;
        text[17:9]  = 9'b010000100;
        text[8:0]   = 9'b001111010;
    end

    // R
    6'd17: begin
        text[71:63] = 9'b111111000;
        text[62:54] = 9'b100000100;
        text[53:45] = 9'b100000100;
        text[44:36] = 9'b111111000;
        text[35:27] = 9'b100010000;
        text[26:18] = 9'b100001000;
        text[17:9]  = 9'b100000100;
        text[8:0]   = 9'b100000010;
    end

    // S
    6'd18: begin
        text[71:63] = 9'b011111100;
        text[62:54] = 9'b100000000;
        text[53:45] = 9'b100000000;
        text[44:36] = 9'b011111000;
        text[35:27] = 9'b000000100;
        text[26:18] = 9'b000000100;
        text[17:9]  = 9'b000000100;
        text[8:0]   = 9'b111111000;
    end

    // T
    6'd19: begin
        text[71:63] = 9'b111111110;
        text[62:54] = 9'b000110000;
        text[53:45] = 9'b000110000;
        text[44:36] = 9'b000110000;
        text[35:27] = 9'b000110000;
        text[26:18] = 9'b000110000;
        text[17:9]  = 9'b000110000;
        text[8:0]   = 9'b000110000;
    end

    // U
    6'd20: begin
        text[71:63] = 9'b100000100;
        text[62:54] = 9'b100000100;
        text[53:45] = 9'b100000100;
        text[44:36] = 9'b100000100;
        text[35:27] = 9'b100000100;
        text[26:18] = 9'b100000100;
        text[17:9]  = 9'b010001000;
        text[8:0]   = 9'b001110000;
    end

    // V
    6'd21: begin
        text[71:63] = 9'b100000100;
        text[62:54] = 9'b100000100;
        text[53:45] = 9'b100000100;
        text[44:36] = 9'b100000100;
        text[35:27] = 9'b100000100;
        text[26:18] = 9'b010001000;
        text[17:9]  = 9'b001110000;
        text[8:0]   = 9'b000100000;
    end

    // W
    6'd22: begin
        text[71:63] = 9'b100000100;
        text[62:54] = 9'b100000100;
        text[53:45] = 9'b100000100;
        text[44:36] = 9'b100100100;
        text[35:27] = 9'b100100100;
        text[26:18] = 9'b101010100;
        text[17:9]  = 9'b110001100;
        text[8:0]   = 9'b100000100;
    end

    // X
    6'd23: begin
        text[71:63] = 9'b100000100;
        text[62:54] = 9'b010001000;
        text[53:45] = 9'b001110000;
        text[44:36] = 9'b000100000;
        text[35:27] = 9'b001110000;
        text[26:18] = 9'b010001000;
        text[17:9]  = 9'b100000100;
        text[8:0]   = 9'b100000100;
    end

    // Y
    6'd24: begin
        text[71:63] = 9'b100000100;
        text[62:54] = 9'b010001000;
        text[53:45] = 9'b001110000;
        text[44:36] = 9'b000100000;
        text[35:27] = 9'b000100000;
        text[26:18] = 9'b000100000;
        text[17:9]  = 9'b000100000;
        text[8:0]   = 9'b000100000;
    end

    // Z
    6'd25: begin
        text[71:63] = 9'b111111110;
        text[62:54] = 9'b000000100;
        text[53:45] = 9'b000001000;
        text[44:36] = 9'b000010000;
        text[35:27] = 9'b000100000;
        text[26:18] = 9'b001000000;
        text[17:9]  = 9'b010000000;
        text[8:0]   = 9'b111111110;
    end

        6'd26: begin
        text[71:63] = 9'b001111000;
        text[62:54] = 9'b010000100;
        text[53:45] = 9'b100001010;
        text[44:36] = 9'b100010010;
        text[35:27] = 9'b100100010;
        text[26:18] = 9'b101000010;
        text[17:9]  = 9'b010000100;
        text[8:0]   = 9'b001111000;
    end

    // 1
    6'd27: begin
        text[71:63] = 9'b000110000;
        text[62:54] = 9'b001110000;
        text[53:45] = 9'b000110000;
        text[44:36] = 9'b000110000;
        text[35:27] = 9'b000110000;
        text[26:18] = 9'b000110000;
        text[17:9]  = 9'b000110000;
        text[8:0]   = 9'b011111110;
    end

    // 2
    6'd28: begin
        text[71:63] = 9'b001111000;
        text[62:54] = 9'b010000100;
        text[53:45] = 9'b000000100;
        text[44:36] = 9'b000001000;
        text[35:27] = 9'b000110000;
        text[26:18] = 9'b001000000;
        text[17:9]  = 9'b010000000;
        text[8:0]   = 9'b011111110;
    end

    // 3
    6'd29: begin
        text[71:63] = 9'b001111000;
        text[62:54] = 9'b010000100;
        text[53:45] = 9'b000000100;
        text[44:36] = 9'b000111000;
        text[35:27] = 9'b000000100;
        text[26:18] = 9'b000000100;
        text[17:9]  = 9'b010000100;
        text[8:0]   = 9'b001111000;
    end

    // 4
    6'd30: begin
        text[71:63] = 9'b000001000;
        text[62:54] = 9'b000011000;
        text[53:45] = 9'b000101000;
        text[44:36] = 9'b001001000;
        text[35:27] = 9'b010001000;
        text[26:18] = 9'b011111110;
        text[17:9]  = 9'b000001000;
        text[8:0]   = 9'b000001000;
    end

    // 5
    6'd31: begin
        text[71:63] = 9'b011111110;
        text[62:54] = 9'b010000000;
        text[53:45] = 9'b010000000;
        text[44:36] = 9'b011111000;
        text[35:27] = 9'b000000100;
        text[26:18] = 9'b000000100;
        text[17:9]  = 9'b010000100;
        text[8:0]   = 9'b001111000;
    end

    // 6
    6'd32: begin
        text[71:63] = 9'b001111000;
        text[62:54] = 9'b010000100;
        text[53:45] = 9'b100000000;
        text[44:36] = 9'b111111000;
        text[35:27] = 9'b100000100;
        text[26:18] = 9'b100000100;
        text[17:9]  = 9'b010000100;
        text[8:0]   = 9'b001111000;
    end

    // 7
    6'd33: begin
        text[71:63] = 9'b011111110;
        text[62:54] = 9'b000000100;
        text[53:45] = 9'b000001000;
        text[44:36] = 9'b000010000;
        text[35:27] = 9'b000100000;
        text[26:18] = 9'b001000000;
        text[17:9]  = 9'b010000000;
        text[8:0]   = 9'b100000000;
    end

    // 8
    6'd34: begin
        text[71:63] = 9'b001111000;
        text[62:54] = 9'b010000100;
        text[53:45] = 9'b010000100;
        text[44:36] = 9'b001111000;
        text[35:27] = 9'b010000100;
        text[26:18] = 9'b010000100;
        text[17:9]  = 9'b010000100;
        text[8:0]   = 9'b001111000;
    end

    // 9
    6'd35: begin
        text[71:63] = 9'b001111000;
        text[62:54] = 9'b010000100;
        text[53:45] = 9'b010000100;
        text[44:36] = 9'b001111100;
        text[35:27] = 9'b000000100;
        text[26:18] = 9'b000000100;
        text[17:9]  = 9'b010000100;
        text[8:0]   = 9'b001111000;
    end

        
        default: text[71:0] = 72'd0;
        endcase

        for(integer j = 0; j < y_length; j ++) begin
            for(int k = 0; k < x_length; k++) begin
                     characters[(number_of_chars*character_bits - 1) - (number_of_chars * x_length) * j - x_length * (i - 1) - k] = text[(character_bits - 1) - (x_length * j) - k];
                end
            end
        end
    end
endmodule
    //characters[k + character_bits*(i-1)] = text[k];
        // for(integer i = 0 ; i < 6; i++) begin //6 is length
        //      for(integer j = 0; j < 6; j++) begin //6 is width
             
        // end
        // end
    
    // logic  [35:0][35:0] text [1:0];
    // readmemh("text.mem", text);

    