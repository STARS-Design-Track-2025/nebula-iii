module t04_button_decoder_edge_detector (
    input logic clk, rst,
    input logic alpha,
    input logic [3:0] row, column,
    output logic [4:0] button,
    output logic rising,
    output logic debounced //this is for testing purposes only
);

//determines if a button has been pressed
logic strobe;

// debounce portion
logic [14:0] debounce;

always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
        debounce <= 0;
    end else begin
        debounce <= {strobe, debounce[14:1]}; // push is if button is reading a value
            
    end
end

always_comb begin
    if (&debounce) begin
        debounced = 1'b1;
    end else begin
        debounced = 0;
    end
    // strobe for detecting that a button has been pressed
    if (|row) begin
        strobe = 1'b1;
    end else begin
        strobe = 0;
    end
end

// edge detector portion
logic q2, d1, d2;

always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
        q2 <= 0;
        d2 <= 0;
    end else begin
        d2 <= d1;
        q2 <= d2; 
    end
end

always_comb begin
    d1 = debounced; // d1 = |row;
    if (d2 & ~q2) begin
        rising = 1'b1;
    end else begin
        rising = 1'b0;
    end

end

always_comb begin
    button = 5'd0;
    //remaining buttons section
    if (alpha) begin
        if (column == 4'b1000) begin
            if (row == 4'b1000) begin
                button = 5'd16;
            end else if (row == 4'b0100) begin
                button = 5'd20;
            end else if (row == 4'b0010) begin
                button = 5'd24;
            end else if (row == 4'b0001) begin
                button = 5'd10;
            end
        end else if (column == 4'b0100) begin 
            if (row == 4'b1000) begin
                button = 5'd17;
            end else if (row == 4'b0100) begin
                button = 5'd21;
            end else if (row == 4'b0010) begin
                button = 5'd25;
            end else if (row == 4'b0001) begin
                button = 5'd29;
            end
        end else if (column == 4'b0010) begin
            if (row == 4'b1000) begin
                button = 5'd18;
            end else if (row == 4'b0100) begin
                button = 5'd22;
            end else if (row == 4'b0010) begin
                button = 5'd26;
            end else if (row == 4'b0001) begin
                button = 5'd30;
            end
        end else if (column == 4'b0001) begin
            if (row == 4'b1000) begin
                button = 5'd19;
            end else if (row == 4'b0100) begin
                button = 5'd23;
            end else if (row == 4'b0010) begin
                button = 5'd27;
            end else if (row == 4'b0001) begin
                button = 5'd31;
            end
        end
    end else begin
        if (column == 4'b1000) begin
            if (row == 4'b1000) begin
                button = 5'd7;
            end else if (row == 4'b0100) begin
                button = 5'd4;
            end else if (row == 4'b0010) begin
                button = 5'd1;
            end else if (row == 4'b0001) begin
                button = 5'd10;
            end
        end else if (column == 4'b0100) begin 
            if (row == 4'b1000) begin
                button = 5'd8;
            end else if (row == 4'b0100) begin
                button = 5'd5;
            end else if (row == 4'b0010) begin
                button = 5'd2;
            end else if (row == 4'b0001) begin
                button = 5'd0;
            end
        end else if (column == 4'b0010) begin
            if (row == 4'b1000) begin
                button = 5'd9;
            end else if (row == 4'b0100) begin
                button = 5'd6;
            end else if (row == 4'b0010) begin
                button = 5'd3;
            end else if (row == 4'b0001) begin
                button = 5'd11;
            end
        end else if (column == 4'b0001) begin
            if (row == 4'b1000) begin
                button = 5'd12;
            end else if (row == 4'b0100) begin
                button = 5'd13;
            end else if (row == 4'b0010) begin
                button = 5'd14;
            end else if (row == 4'b0001) begin
                button = 5'd15;
            end
        end
    end
end

endmodule

