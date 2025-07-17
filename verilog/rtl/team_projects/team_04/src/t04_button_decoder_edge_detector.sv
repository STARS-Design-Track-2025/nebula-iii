module t04_button_decoder_edge_detector (
    input logic clk, rst,
    input logic alpha,
    input logic pulse,
    input logic [3:0] row, column, //this is the debounced rows
    output logic [4:0] button,
    output logic rising
);

logic q2, d1, d2;
logic [4:0] sticky, sticky_n;
logic push, push_n;

always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
        sticky <= 0; //determines if button is being held down or not
        push <= 0; //basically a D-flip flop for the push register
        q2 <= 0; //part of the edge detector
        d2 <= 0;
    end else begin
        sticky <= sticky_n;
        push <= push_n;
        d2 <= d1;
        q2 <= d2;
    end
end

always_comb begin
    //sticky next state logic
    sticky_n = sticky;
    if (pulse) begin
        sticky_n = {push, sticky[4:1]};
    end

    //push next state logic (edge detector)
    d1 = |row;
    if (d2 & ~q2) begin
        push_n = 1'b1;
    end else if (pulse) begin
        push_n = 0;
    end else begin
        push_n = push;
    end

    if (sticky_n == 5'b10000 & pulse) begin
        rising = 1'b1;
    end else begin
        rising = 0;
    end
end

logic [4:0] button_n;

always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
        button <= 0; // button_c is the current button and button is the next button
    end else begin
        button <= button_n;
    end

end

always_comb begin
    button_n = button;
    if (rising) begin
        button_n = 5'd0;
    end
    //remaining buttons section
    if (alpha) begin
        if (column == 4'b1000) begin
            if (row == 4'b1000) begin button_n = 5'd19; end
            else if (row == 4'b0100) begin button_n = 5'd23; end 
            else if (row == 4'b0010) begin button_n = 5'd27; end
            else if (row == 4'b0001) begin button_n = 5'd31; end
        end else if (column == 4'b0100) begin 
            if (row == 4'b1000) begin button_n = 5'd18; end
            else if (row == 4'b0100) begin button_n = 5'd22; end 
            else if (row == 4'b0010) begin button_n = 5'd26; end 
            else if (row == 4'b0001) begin button_n = 5'd30; end
        end else if (column == 4'b0010) begin
            if (row == 4'b1000) begin button_n = 5'd17; end
            else if (row == 4'b0100) begin button_n = 5'd21; end
            else if (row == 4'b0010) begin button_n = 5'd25; end
            else if (row == 4'b0001) begin button_n = 5'd10; end
        end else if (column == 4'b0001) begin
            if (row == 4'b1000) begin button_n = 5'd16; end
            else if (row == 4'b0100) begin button_n = 5'd20; end
            else if (row == 4'b0010) begin button_n = 5'd24; end
            else if (row == 4'b0001) begin button_n = 5'd29; end
        end
    end else begin
        if (column == 4'b1000) begin
            if (row == 4'b1000) begin button_n = 5'd12; end
            else if (row == 4'b0100) begin button_n = 5'd13; end
            else if (row == 4'b0010) begin button_n = 5'd14; end
            else if (row == 4'b0001) begin button_n = 5'd15; end
        end else if (column == 4'b0100) begin
            if (row == 4'b1000) begin button_n = 5'd9; end
            else if (row == 4'b0100) begin button_n = 5'd6; end
            else if (row == 4'b0010) begin button_n = 5'd3; end
            else if (row == 4'b0001) begin button_n = 5'd11; end
        end else if (column == 4'b0010) begin
            if (row == 4'b1000) begin button_n = 5'd8; end
            else if (row == 4'b0100) begin button_n = 5'd5; end
            else if (row == 4'b0010) begin button_n = 5'd2; end
            else if (row == 4'b0001) begin button_n = 5'd10; end
        end else if (column == 4'b0001) begin
            if (row == 4'b1000) begin button_n = 5'd7; end
            else if (row == 4'b0100) begin button_n = 5'd4; end
            else if (row == 4'b0010) begin button_n = 5'd1; end
            else if (row == 4'b0001) begin button_n = 5'd0; end
        end
    end
end

endmodule
