module tb_register;

    localparam PERIOD = 10;
    localparam DELAY = 1;

    logic tb_clk, tb_rst, tb_wen;
    logic [1:0] tb_in_1, tb_in_2;
    logic [7:0] tb_data, tb_out_1, tb_out_2;

    int num_tests;
    int num_passed; 

    register DUT (
        .clk(tb_clk),
        .rst(tb_rst),
        .wen(tb_wen),
        .in_1(tb_in_1),
        .in_2(tb_in_2),
        .data(tb_data),
        .out_1(tb_out_1),
        .out_2(tb_out_2)
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

    task test(input logic [1:0] in_1, in_2, input logic wen, input logic[7:0] data, exp1, exp2);
        num_tests += 1;
        tb_in_1 = in_1;
        tb_in_2 = in_2;
        tb_wen = wen;
        tb_data = data;
        @ (posedge tb_clk);
        #(DELAY)
        if ({tb_out_1, tb_out_2} != {exp1, exp2})
            $display("[Time %0t] FAILED: expected %0d, got %0d\n", $time, {exp1, exp2}, {tb_out_1, tb_out_2});
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

        test(.in_1(2'b11), .in_2(2'b01), .wen(1'b1), .data(8'd23), .exp1(8'd23), .exp2(8'd0));
        test(.in_1(2'b10), .in_2(2'b11), .wen(1'b0), .data(8'd0), .exp1(8'd0), .exp2(8'd23));
        test(.in_1(2'b00), .in_2(2'b11), .wen(1'b1), .data(8'd15), .exp1(8'd15), .exp2(8'd23));

        $display("Passed %0d/%0d tests.", num_passed, num_tests);
        $finish();
    end

endmodule