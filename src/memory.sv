module memory (
    input logic clk, wen,
    input logic [7:0] address,
    input logic [7:0] data_in,
    output logic [7:0] data_out
);

logic [7:0] mem [255:0];

assign data_out = mem[address];

always_ff @ (posedge clk) begin
    if (wen)
        mem[address] <= data_in;
end
        

initial begin
    $readmemb("program.bin", mem);
end

final begin
    $writememb("memory.bin", mem);
end

endmodule

