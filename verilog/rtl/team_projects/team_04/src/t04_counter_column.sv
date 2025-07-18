module t04_counter_column (
    input logic clk, rst,
    output logic [3:0] column,
    output logic pulse_e // the pulse to send to the decoder (the end pulse)
);

logic [10:0] count, count_n;
logic [3:0] column_n;
logic pulse_s; // the pulse to start each change in column

//the following section is to create a pulse, it is also present in the button decoder

always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
        count <= 0;
    end else begin
        count <= count_n;
    end
end

always_comb begin
    if (count < 11'd99) begin
        count_n = count + 1;
        pulse_s = 0;
        if (count == 11'd98) begin
            pulse_e = 1'b1;
        end else begin
            pulse_e = 0;
        end
    end else if (count == 11'd99) begin
        pulse_e = 0;
        pulse_s = 1'b1;
        count_n = 0;
    end else begin
        count_n = count;
        pulse_s = 0;
        pulse_e = 0;
    end
end


//fsm section
// change the posedge clk to posedge pulse when wanting to implement

always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
        column <= 0;
    end else begin
        column <= column_n;
    end
end

always_comb begin
    if (pulse_s) begin
        case (column)
            4'b1000: begin
                column_n = 4'b0001;
            end
            4'b0001: begin
                column_n = 4'b0010;
            end
            4'b0010: begin
                column_n = 4'b0100;
            end
            4'b0100: begin
                column_n = 4'b1000;
            end
            default: begin
                column_n = 4'b0001;
            end
        endcase
    end else begin
        column_n = column;
    end

end

endmodule
