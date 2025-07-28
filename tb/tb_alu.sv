module tb_alu;
    localparam DELAY = 10;

    logic signed [7:0] tb_a, tb_b, tb_result;
    logic [1:0] tb_op;
    logic tb_zero, tb_neg;

    int num_tests;
    int num_passed;

    alu DUT(
        .a(tb_a),
        .b(tb_b),
        .op(tb_op),
        .result(tb_result),
        .zero(tb_zero),
        .neg(tb_neg)
    );

    task test_alu(input logic signed [7:0] a, b, input logic[1:0] op, input logic signed [7:0] result, input logic zero, neg);
        num_tests += 1;
        tb_a = a;
        tb_b = b;
        tb_op = op;
        #(DELAY)
        if (result == tb_result && zero == tb_zero && neg == tb_neg)
            num_passed += 1;
        else
            if (result != tb_result) begin
                $display("[Time %0t] FAILED: expected %0d, got %0d\n", $time, result, tb_result);
            end if (zero != tb_zero) begin
                $display("[Time %0t] FAILED: expected %0d, got %0d\n", $time, zero, tb_zero);
            end if (neg != tb_neg) begin
                $display("[Time %0t] FAILED: expected %0d, got %0d\n", $time, neg, tb_neg);
            end

    endtask

    initial begin
        $dumpfile("waveform.fst");
        $dumpvars;
        num_tests = 0;
        num_passed = 0;

        test_alu(8'd1, 8'd3, 2'b00, 8'd4, 1'b0, 1'b0);
        test_alu(8'd100, 8'd100, 2'b00, 8'd200, 1'b0, 1'b1);

        test_alu(8'd100, 8'd50, 2'b01, 8'd50, 1'b0, 1'b0);
        test_alu(8'd50, 8'd50, 2'b01, 8'd0, 1'b1, 1'b0);
        test_alu(8'd50, 8'd200, 2'b01, 8'd106, 1'b0, 1'b0);

        test_alu(8'b00000000, 8'b11111111, 2'b10, 8'b00000000, 1'b1, 1'b0);
        test_alu(8'b00010010, 8'b11111111, 2'b10, 8'b00010010, 1'b0, 1'b0);
        
        test_alu(8'b00010010, 8'b11111111, 2'b11, 8'b11101101, 1'b0, 1'b1);
        test_alu(8'b11111111, 8'b11111111, 2'b11, 8'b00000000, 1'b1, 1'b0);

        $display("Passed %0d/%0d tests.", num_passed, num_tests);
        $finish();
    end
endmodule