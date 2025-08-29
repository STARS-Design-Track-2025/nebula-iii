`default_nettype none
`timescale 1ps/1ps
module t03_bin4_to_bcd_decoder (
    input  logic [3:0] health,
    output logic [11:0] phealth
);
    logic [7:0] temp_bcd;
    logic [3:0] bcd_select;
    
    logic [5:0] number;
    always @ (*) begin
        temp_bcd = 8'd0;

        for (integer i = 3; i >= 0; i = i - 1) begin
         
            if (temp_bcd[7:4] >= 5)
                temp_bcd[7:4] = temp_bcd[7:4] + 3;
            if (temp_bcd[3:0] >= 5)
                temp_bcd[3:0] = temp_bcd[3:0] + 3;

           
            temp_bcd = temp_bcd << 1;

            
            temp_bcd[0] = health[i];
        end


        for(int i = 0; i < 2; i ++) begin
        if(i == 0) begin
            bcd_select = temp_bcd[3:0];
        end
        else if(i == 1) begin
            bcd_select = temp_bcd[7:4];
        end
        case(bcd_select)

        4'd0: number = 6'd26;

        4'd1: number = 6'd27;

        4'd2: number = 6'd28;

        4'd3: number = 6'd29;

        4'd4: number = 6'd30;

        4'd5: number = 6'd31;

        4'd6: number = 6'd32; 

        4'd7: number = 6'd33;

        4'd8: number = 6'd34; 

        4'd9: number = 6'd35; 
        
        default: number = 6'd3; //clear error
        endcase

        if(i == 0) begin
            phealth[5:0] = number;
        end
        else if(i == 1) begin
            phealth[11:6] = number;
        end
        end

    end

endmodule