module t03_cache_routing
(
    input logic memWrite, memRead, 
    input logic [31:0] data_out, 
    input logic [31:0] cache_out,
    input logic hit, 
    output logic [31:0] data_into_cache,
    output logic [31:0] data_into_DFF 
);

always_comb begin
    data_into_cache = 0;
    data_into_DFF = 0;
    if(hit) begin
        data_into_DFF = cache_out; 
    end
    else if ((memRead || memWrite) && !hit) begin
        data_into_DFF = data_out;
    end
    else if (!(memRead || memWrite) && !hit) begin
        data_into_DFF = data_out;
        data_into_cache = data_out;
    end
end


endmodule