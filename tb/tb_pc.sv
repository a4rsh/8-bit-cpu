module tb_pc;

    localparam PERIOD = 10;
    localparam DELAY = 1;

    logic tb_clk, tb_rst, tb_en, tb_load;
    logic [7:0] tb_next, tb_out;

    int num_tests;
    int num_passed;

    pc DUT(
        .clk(tb_clk),
        .rst(tb_rst),
        .en(tb_en),
        .load(tb_load),
        .next(tb_next),
        .out(tb_out)
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

    task increment_pc(input logic[7:0] expected, input logic en);
        num_tests += 1;
        tb_load = 1'b0;
        tb_en = en;
        @(posedge tb_clk);
        #(DELAY)
        if (expected != tb_out)
            $display("[Time %0t] FAILED: expected %0d, got %0d\n", $time, expected, tb_out);
        else
            num_passed += 1;
    endtask

    task set_pc(input logic[7:0] next, input logic en);
        num_tests += 1;
        tb_load = 1'b1;
        tb_next = next;
        tb_en = en;
        @(posedge tb_clk);
        #(DELAY)
        if (next != tb_out)
            $display("[Time %0t] FAILED: expected %0d, got %0d\n", $time, next, tb_out);
        else
            num_passed += 1;
    endtask

    initial begin
        $dumpfile("waveform.fst");
        $dumpvars;
        tb_rst = 1'b0;
        num_tests = 0;
        num_passed = 0;

        reset();
        for (int i = 1; i < 256; i++) begin
            increment_pc(i[7:0], 1'b1);
        end

            increment_pc(8'b0, 1'b1);
            increment_pc(8'b0, 1'b0);
        reset();

        set_pc(8'b10101010, 1'b1);
        set_pc(8'b00000000, 1'b1);
        set_pc(8'b11111111, 1'b1);
        set_pc(8'b11101010, 1'b1);

        $display("Passed %0d/%0d tests.", num_passed, num_tests);
        $finish();
    end
endmodule