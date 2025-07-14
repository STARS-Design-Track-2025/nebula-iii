module t04_counter_column (
    input logic clk, rst,
    output logic [3:0] column
);

logic [10:0] count, count_n;
logic [1:0] column_count, column_count_n;
logic [3:0] column_n;
logic pulse;

//the following section is to create a pulse, 

always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
        count <= 0;
    end else begin
        count <= count_n;
    end
end

always_comb begin
    if (count < 11'd1) begin
        count_n = count + 1;
        pulse = 1'b0;
    end else if (count == 11'd1) begin
        count_n = count + 1;
        pulse = 1'b1;
        count_n = 0;
    end else begin
        count_n = count;
        pulse = 1'b0;
    end
end


//fsm section
// change the posedge clk to posedge pulse when wanting to implement

always_ff @(posedge pulse, posedge rst) begin
    if (rst) begin
        column_count <= 0;
        column <= 0;
    end else begin
        column_count <= column_count_n;
        column <= column_n;
    end
end

always_comb begin
    case (column_count)
        2'd0: begin
            column_n = 4'b0001;
            column_count_n = 2'd1;
        end
        2'd1: begin
            column_n = 4'b0010;
            column_count_n = 2'd2;
        end
        2'd2: begin
            column_n = 4'b0100;
            column_count_n = 2'd3;
        end
        2'd3: begin
            column_n = 4'b1000;
            column_count_n = 2'd0;
        end
    endcase


end




endmodule
