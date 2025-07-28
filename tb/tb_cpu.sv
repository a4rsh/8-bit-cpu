module tb_cpu;
    localparam PERIOD = 10;
    localparam DELAY = 1;

    logic tb_clk, tb_rst, tb_mem_wen, tb_halt;
    logic [7:0] tb_mem_data_in, tb_mem_data_out, tb_mem_address;
    
    cpu cpu(
        .clk(tb_clk),
        .rst(tb_rst),
        .mem_data_out(tb_mem_data_out),
        .mem_wen(tb_mem_wen),
        .mem_address(tb_mem_address),
        .mem_data_in(tb_mem_data_in),
        .halt(tb_halt)
    );

    memory memory (
        .clk(tb_clk),
        .wen(tb_mem_wen),
        .address(tb_mem_address),
        .data_in(tb_mem_data_in),
        .data_out(tb_mem_data_out)
    );

    always begin
        tb_clk = 1'b0;
        #(PERIOD / 2);
        tb_clk = 1'b1;
        #(PERIOD / 2);
    end

    task reset();
        tb_rst = 1'b1;
        repeat (2) @(negedge tb_clk);
        tb_rst = 1'b0;
    endtask

    initial begin
        $dumpfile("waveform.fst");
        $dumpvars;
        tb_rst = 1'b0;
        reset();
        @(posedge tb_halt);
        $finish();
    end
endmodule