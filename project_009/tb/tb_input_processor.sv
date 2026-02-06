`timescale 1ns / 1ps

module tb_input_processor;

  localparam DATA_WIDTH = 8;

  logic                   clk;
  logic                   rst_n;
  logic [DATA_WIDTH -1:0] rx_data_in;
  logic                   rx_empty_in;
  logic                   rx_ren_o;
  logic [           15:0] num1_o;
  logic [           15:0] num2_o;
  logic [            1:0] operator_o;
  logic                   start_calc_o;

  input_processor #(.DATA_WIDTH(DATA_WIDTH)) dut (.*);
  initial clk = 0;
  always #10 clk = ~clk;

  int test_count = 0;

  task check_case(input string cmd, input logic [15:0] exp_n1, input logic [1:0] exp_op, input logic [15:0] exp_n2);
    test_count++;
    for (int i = 0; i < cmd.len(); ++i) begin
      @(posedge clk);
      rx_data_in  <= cmd[i];
      rx_empty_in <= 1'b0;

      wait (rx_ren_o == 1'b1);

      @(posedge clk);
      rx_empty_in <= 1'b1;
      rx_data_in  <= 8'h00;
      if (i < cmd.len() - 1) begin
        repeat (2) @(posedge clk);
      end
    end

    wait (start_calc_o == 1'b1);
    repeat (2) @(posedge clk);

    if (num1_o === exp_n1 && operator_o === exp_op && num2_o === exp_n2) begin
      $info("INFO: Case %0d: %s -> N1:%d, Op:%b, N2:%d", test_count, cmd, num1_o, operator_o, num2_o);
    end else begin
      $display("[FAIL] Case %0d: %s -> Beklenen: N1:%d Op:%b N2:%d | Gelen: N1:%d Op:%b N2:%d", test_count, cmd, exp_n1, exp_op, exp_n2, num1_o, operator_o, num2_o);
    end

  endtask

  initial begin
    rst_n = 1'b0;
    rx_empty_in = 1'b1;
    rx_data_in = '0;

    #100;
    rst_n = 1'b1;
    #100;

    check_case("15+5=", 16'd15, 2'b00, 16'd5);
    check_case("20-8=", 16'd20, 2'b01, 16'd8);
    check_case("135/7=", 16'd135, 2'b11, 16'd7);
    check_case("12*155=", 16'd12, 2'b10, 16'd155);

    $display("Simulation is completed succesfully");

    $finish;
  end



endmodule

/*
# ** Info: INFO: Case 1: 15+5= -> N1:   15, Op:00, N2:    5
#    Time: 590 ns  Scope: tb_input_processor.check_case File: tb/tb_input_processor.sv Line: 44
# ** Info: INFO: Case 2: 20-8= -> N1:   20, Op:01, N2:    8
#    Time: 990 ns  Scope: tb_input_processor.check_case File: tb/tb_input_processor.sv Line: 44
# ** Info: INFO: Case 3: 135/7= -> N1:  135, Op:11, N2:    7
#    Time: 1470 ns  Scope: tb_input_processor.check_case File: tb/tb_input_processor.sv Line: 44
# ** Info: INFO: Case 4: 12*155= -> N1:   12, Op:10, N2:  155
#    Time: 2030 ns  Scope: tb_input_processor.check_case File: tb/tb_input_processor.sv Line: 44
# Simulation is completed succesfully
*/
