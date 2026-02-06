`timescale 1ns / 1ps

module tb_alu;

  logic        clk;
  logic        rst_n;
  logic [15:0] num1;
  logic [15:0] num2;
  logic [ 1:0] op_code;
  logic        start;
  logic [31:0] result;
  logic        is_division;
  logic        done;

  alu dut (.*);

  initial clk = 0;
  always #10 clk = ~clk;

  task check_alu(input [15:0] a, input [15:0] b, input [1:0] op, input [31:0] expected_res);
    @(posedge clk);
    num1    <= a;
    num2    <= b;
    op_code <= op;
    start   <= 1'b1;

    @(posedge clk);
    start <= 1'b0;

    wait (done == 1'b1);

    if (result === expected_res) begin
      $display("[PASS] Op:%b | A:%d B:%d | Result:%d", op, a, b, result);
    end else begin
      $display("[FAIL] Op:%b | A:%d B:%d | Beklenen:%d Gelen:%d", op, a, b, expected_res, result);
    end

    @(posedge clk);
  endtask

  initial begin
    rst_n = 0;
    num1 = 0;
    num2 = 0;
    op_code = 0;
    start = 0;
    #100;
    rst_n = 1;
    #20;

    $display("\n--- Simulation is started ---\n");

    // 1.(15 + 5 = 30)
    check_alu(16'd15, 16'd15, 2'b00, 32'd30);

    // 2.(20 - 8 = 12)
    check_alu(16'd20, 16'd8, 2'b01, 32'd12);

    // 3.  (12 * 120 = 1440)
    check_alu(16'd12, 16'd120, 2'b10, 32'd1440);

    // 4.  (15 / 2 = 7.5 -> 75 bekleniyor)
    // num1*10 
    check_alu(16'd15, 16'd2, 2'b11, 32'd75);

    // 5.  (135 / 7 = 19.28... -> 192 
    check_alu(16'd135, 16'd7, 2'b11, 32'd192);

    $display("\n--- Tests are completed ---\n");
    $finish;
  end

endmodule

/*
# --- Simulation is started ---
# 
# [PASS] Op:00 | A:   15 B:    5 | Result:        20
# [PASS] Op:01 | A:   20 B:    8 | Result:        12
# [PASS] Op:10 | A:   12 B:   10 | Result:       120
# [PASS] Op:11 | A:   15 B:    2 | Result:        75
# [PASS] Op:11 | A:  135 B:    7 | Result:       192
# 
# --- Tests are completed ---
*/
