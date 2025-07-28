module alu (
    input logic signed [7:0] a, b, 
    input logic [1:0] op,
    output logic signed [7:0] result,
    output logic zero, neg // For future use (currently not used)
);

always_comb
    case (op)
        2'b00: result = a + b; 
        2'b01: result = a - b;
        2'b10: result = a & b;
        2'b11: result = a ^ b;
        default: result = a;
    endcase

assign zero = (result == 8'b0);
assign neg = result[7];

endmodule