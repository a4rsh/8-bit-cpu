typedef enum {FETCH, DECODE, EXECUTE, HALT} state_t;

module cpu(
    input logic clk, rst,
    input logic [7:0] mem_data_out,
    output logic mem_wen,
    output logic [7:0] mem_address, mem_data_in,
    output logic halt
);

// Misc
state_t state, next_state;
logic [7:0] ins, next_ins;

// Input
logic pc_en, pc_load;
logic [7:0] pc_next;
// Ouptut
logic [7:0] pc_out;
pc pc(.clk, .rst, .en(pc_en), .load(pc_load), .next(pc_next), .out(pc_out));

// Input
logic reg_wen;
logic [1:0] reg_in_1, reg_in_2;
logic [7:0] reg_data;
// Output
logic [7:0] reg_out_1, reg_out_2;
register register(.clk, .rst, .wen(reg_wen), .in_1(reg_in_1), .in_2(reg_in_2), .data(reg_data), .out_1(reg_out_1), .out_2(reg_out_2));

// Input
logic signed [7:0] alu_a, alu_b;
logic [1:0] alu_op;
// Output
logic signed [7:0] alu_result;
logic alu_zero, alu_neg;
alu alu(.a(alu_a), .b(alu_b), .op(alu_op), .result(alu_result), .zero(alu_zero), .neg(alu_neg));

always_ff @ (posedge clk, posedge rst)
    if (rst) begin
        state <= FETCH;
    end else begin
        state <= next_state;
        if (next_state != HALT)
            ins <= next_ins;
    end

always_comb begin
    // Don't update states by default
    next_state = state;
    next_ins = ins;

    // Turn off writes by default
    mem_wen = 1'b0;
    pc_en = 1'b0;
    reg_wen = 1'b0;

    // Other defaults
    mem_address = 8'b0;
    mem_data_in = 8'b0;

    pc_load = 1'b0;
    pc_next = 8'b0;

    reg_in_1 = 2'b0;
    reg_in_2 = 2'b0;
    reg_data = 8'b0;

    alu_a = 8'b0;
    alu_b = 8'b0;
    alu_op = 2'b0;

    halt = 1'b0;

    if (state == FETCH) begin
        next_state = DECODE;
        mem_address = pc_out;
        next_ins = mem_data_out;
    end else if (state == DECODE) begin
        next_state = EXECUTE;
        pc_en = 1'b1;

        casez(ins[7:5])
        3'b000: begin // Write Lower
            reg_wen = 1'b1;
            reg_in_1 = {1'b0, ins[4]};
            reg_data = {reg_out_1[7:4], ins[3:0]};
        end
        3'b001: begin // Write Upper
            reg_wen = 1'b1;
            reg_in_1 = {1'b0, ins[4]};
            reg_data = {ins[3:0], reg_out_1[3:0]}; 
        end
        3'b010: begin // Move
            reg_wen = 1'b1;     
            reg_in_1 = ins[3:2];
            reg_in_2 = ins[1:0];
            reg_data = reg_out_2;
        end
        3'b011: begin
            if (ins[4] == 1'b0) begin // Load
                reg_wen = 1'b1;
                reg_in_1 = ins[3:2];
                reg_in_2 = ins[1:0];
                mem_address = reg_out_2;
                reg_data = mem_data_out;
            end else begin // Save
                mem_wen = 1'b1;
                reg_in_1 = ins[3:2];
                reg_in_2 = ins[1:0];
                mem_address = reg_out_2;
                mem_data_in = reg_out_1;
            end
        end
        3'b10?: begin // Arithmetic & Bitwise
            reg_wen = 1'b1;
            alu_op = ins[5:4];
            reg_in_1 = ins[3:2];
            reg_in_2 = ins[1:0];
            alu_a = reg_out_1;
            alu_b = reg_out_2;
            reg_data = alu_result;
        end
        3'b110: begin // Jumping
            reg_in_1 = ins[3:2];
            reg_in_2 = ins[1:0];
            if (ins[4] == 1'b0 | reg_out_2 == 8'b0) begin
                pc_load = 1'b1;
                pc_next = reg_out_1;
            end
        end
        3'b111: begin // Halting
            next_state = HALT;
            halt = 1'b1;
            pc_en = 1'b0;
        end
        endcase
    end else if (state == EXECUTE) begin
        next_state = FETCH;
    end else begin // State is halt
        next_state = HALT;
        halt = 1'b1;
    end

end

endmodule