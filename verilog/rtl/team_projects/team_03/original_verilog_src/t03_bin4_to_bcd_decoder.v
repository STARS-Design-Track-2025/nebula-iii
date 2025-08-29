`default_nettype none
module t03_bin4_to_bcd_decoder (
	health,
	phealth
);
	input wire [3:0] health;
	output reg [11:0] phealth;
	reg [7:0] temp_bcd;
	reg [3:0] bcd_select;
	reg [5:0] number;
	always @(*) begin
		temp_bcd = 8'd0;
		begin : sv2v_autoblock_1
			integer i;
			for (i = 3; i >= 0; i = i - 1)
				begin
					if (temp_bcd[7:4] >= 5)
						temp_bcd[7:4] = temp_bcd[7:4] + 3;
					if (temp_bcd[3:0] >= 5)
						temp_bcd[3:0] = temp_bcd[3:0] + 3;
					temp_bcd = temp_bcd << 1;
					temp_bcd[0] = health[i];
				end
		end
		begin : sv2v_autoblock_2
			reg signed [31:0] i;
			for (i = 0; i < 2; i = i + 1)
				begin
					if (i == 0)
						bcd_select = temp_bcd[3:0];
					else if (i == 1)
						bcd_select = temp_bcd[7:4];
					case (bcd_select)
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
						default: number = 6'd3;
					endcase
					if (i == 0)
						phealth[5:0] = number;
					else if (i == 1)
						phealth[11:6] = number;
				end
		end
	end
endmodule
