// mux module
// This module implements a simple 2-to-1 multiplexer for 32-bit inputs.
// It selects between two inputs based on a select signal.
// If sel is high, output b; if sel is low, output a.
module t07_muxes(
    input logic [31:0] a, b, // Inputs to the mux
    input logic sel,          // Select signal
    output logic [31:0] out   // Output of the mux
);
    always_comb begin
        if (sel) begin
            out = b; // If sel is high, output b
        end else begin
            out = a; // If sel is low, output a
        end
    end
endmodule