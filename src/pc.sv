module pc (
    input logic clk, rst, en, load,
    input logic [7:0] next,
    output logic [7:0] out
);

logic [7:0] next_out;

always_ff @ (posedge clk, posedge rst)
    if (rst)
        out <= 8'b0;
    else
        out <= en ? next_out : out;

always_comb
    if (load)
        next_out = next;
    else
        if (out == 8'b11111111)
            next_out = 8'b0; 
        else 
            next_out = out + 1;    
            
endmodule