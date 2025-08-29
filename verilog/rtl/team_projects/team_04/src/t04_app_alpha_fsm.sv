module t04_app_alpha_fsm (
    input logic clk, rst,
    input logic rising,
    input logic [4:0] button,
    output logic alpha,
    output logic [1:0] app
);

typedef enum logic [1:0] { 
    EQUATION = 2'd0,
    GRAPH = 2'd1,
    CARD_READER = 2'd2
} app_t;



// alpha_fsm
logic alpha_n;

always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
        alpha <= 0;
    end else begin
        alpha <= alpha_n;
    end
end

always_comb begin
    alpha_n = alpha;
    if (button == 5'd10 & rising) begin
        alpha_n = ~alpha;
    end else begin
        alpha_n = alpha;
    end
end


// app_fsm
app_t app_n, app_c;

always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
        app_c <= EQUATION;
    end else begin
        app_c <= app_n;
    end
end

always_comb begin
    app = app_c;
    if (rising) begin
        case (app_c)
        EQUATION: begin
            if (button == 5'd18) begin
                app_n = GRAPH;
            end else begin
                app_n = app_c;
            end
        end
        GRAPH: begin
            if (button == 5'd18) begin
                app_n = CARD_READER;
            end else begin
                app_n = app_c;
            end
        end
        CARD_READER: begin
            if (button == 5'd18) begin
                app_n = EQUATION;
            end else begin
                app_n = app_c;
            end
        end
        default app_n = app_c;
        endcase
    end else begin
        app_n = app_c;
    end
end



endmodule
