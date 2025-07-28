module tb_memory;
    localparam PERIOD = 10;
    localparam DELAY = 1;

    logic tb_clk, tb_wen;
    logic [7:0] tb_address, tb_data_in, tb_data_out;

    int num_tests;
    int num_passed; 

    memory DUT (
        .clk(tb_clk),
        .wen(tb_wen),
        .address(tb_address),
        .data_in(tb_data_in),
        .data_out(tb_data_out)
    );

    always begin
        tb_clk = 1'b0;
        #(PERIOD / 2);
        tb_clk = 1'b1;
        #(PERIOD / 2);
    end

    task test(input wen, input logic[7:0] address, data_in, expected);
        num_tests += 1;
        tb_wen = wen;
        tb_address = address;
        tb_data_in = data_in;
        @ (posedge tb_clk);
        #(DELAY)
        if (tb_data_out != expected)
            $display("[Time %0t] FAILED: expected %0d, got %0d\n", $time, expected, tb_data_out);
        else
            num_passed += 1;
    endtask

    initial begin
        $dumpfile("waveform.fst");
        $dumpvars;
        num_tests = 0;
        num_passed = 0;

        test(1'b1, 8'd184, 8'd12, 8'd12);
        test(1'b1, 8'd0, 8'd34, 8'd34);
        test(1'b0, 8'd184, 8'd58, 8'd12);
        test(1'b0, 8'd0, 8'd73, 8'd34);

        $display("Passed %0d/%0d tests.", num_passed, num_tests);
        $finish();
    end

endmodule