`default_nettype none
`timescale 1ps/1ps
module t03_comparator
(
    input logic [10:0] Hcnt,
    input logic [10:0] Vcnt,
    output hsync,
    output vsync,
    output at_display
);
    logic hsync_output;
    logic vsync_output;
    logic at_display_output;
    
    logic [10:0] hsync_value;
    logic [10:0] vsync_value;
    
    logic [10:0] min_x;
    logic [10:0] max_x;

    logic [10:0] min_y;
    logic [10:0]max_y;


    assign hsync = hsync_output;
    assign vsync = vsync_output;
    assign at_display = at_display_output;

    //Use these values to adjust the displaying
    assign hsync_value = 24;
    assign vsync_value = 6;

    assign min_x = 37;
    assign max_x = 197;

    assign min_y = 29; 
    assign max_y = 629;
    

    always_comb begin
    //$signed() because there is a type mismatch as Hcnt was unsigned. 
    
    if(($signed(Hcnt) >= 0 && Hcnt <= hsync_value)) begin
        hsync_output= 0;
    end
    else begin
        hsync_output= 1;
    end
    
    if(($signed(Vcnt) >= 0 && Vcnt <= vsync_value)) begin
        vsync_output = 0;
    end
    else begin
        vsync_output = 1;
    end

    if((Hcnt >= min_x && Hcnt <= max_x) && ( Vcnt >= min_y && Vcnt <= max_y)) begin //not necessary for vga and for debugging purposes only
        at_display_output = 1;
    end
    else begin
        at_display_output = 0;
    end

    
    end



endmodule