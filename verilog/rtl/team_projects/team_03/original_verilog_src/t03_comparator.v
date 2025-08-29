`default_nettype none
module t03_comparator (
	Hcnt,
	Vcnt,
	hsync,
	vsync,
	at_display
);
	reg _sv2v_0;
	input wire [10:0] Hcnt;
	input wire [10:0] Vcnt;
	output wire hsync;
	output wire vsync;
	output wire at_display;
	reg hsync_output;
	reg vsync_output;
	reg at_display_output;
	wire [10:0] hsync_value;
	wire [10:0] vsync_value;
	wire [10:0] min_x;
	wire [10:0] max_x;
	wire [10:0] min_y;
	wire [10:0] max_y;
	assign hsync = hsync_output;
	assign vsync = vsync_output;
	assign at_display = at_display_output;
	assign hsync_value = 24;
	assign vsync_value = 6;
	assign min_x = 37;
	assign max_x = 197;
	assign min_y = 29;
	assign max_y = 629;
	always @(*) begin
		if (_sv2v_0)
			;
		if (($signed(Hcnt) >= 0) && (Hcnt <= hsync_value))
			hsync_output = 0;
		else
			hsync_output = 1;
		if (($signed(Vcnt) >= 0) && (Vcnt <= vsync_value))
			vsync_output = 0;
		else
			vsync_output = 1;
		if (((Hcnt >= min_x) && (Hcnt <= max_x)) && ((Vcnt >= min_y) && (Vcnt <= max_y)))
			at_display_output = 1;
		else
			at_display_output = 0;
	end
	initial _sv2v_0 = 0;
endmodule
