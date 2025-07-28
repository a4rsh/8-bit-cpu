module register (
    input logic clk, rst, wen,
    input logic [1:0] in_1, in_2,
    input logic [7:0] data,
    output logic [7:0] out_1, out_2
);

logic [7:0] regs [3:0];

assign out_1 = regs[in_1];
assign out_2 = regs[in_2];

always_ff @ (posedge clk, posedge rst)
    if (rst) begin
        regs[2'b00] <= 8'b0;
        regs[2'b01] <= 8'b0;
        regs[2'b10] <= 8'b0;
        regs[2'b11] <= 8'b0;
    end else
        if (wen) begin
            regs[in_1] <= data;
            $display("\n"); 
        end

endmodule