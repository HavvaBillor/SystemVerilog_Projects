`timescale 1ns / 1ps

module tb_uart_tx #(
    parameter CLK_FREQ = 50_000_000,
    parameter BAUD_RATE = 115_200,
    parameter DATA_WIDTH = 8,
    parameter FIFO_DEPTH = 16,  // adrr 4, 2^4 =16 fifo_depth
    parameter CLK_PERIOD = 10
);

  localparam BAUD_DIV = CLK_FREQ / BAUD_RATE;
  localparam BAUD_CLK_PERIOD = BAUD_DIV * CLK_PERIOD;


  logic       clk_i;
  logic       rst_ni;
  logic       tx_en_i;
  logic       tx_wen_i;
  logic [7:0] din_i;
  logic       empty_o;
  logic       full_o;
  logic       tx_bit_o;


  uart_tx #(
      .CLK_FREQ  (CLK_FREQ),
      .BAUD_RATE (BAUD_RATE),
      .DATA_WIDTH(DATA_WIDTH),
      .FIFO_DEPTH(FIFO_DEPTH)
  ) tx_dut (
      .*
  );

  logic [7:0] test_data_array[] = {'h1, 'h9, 'h0, 'h7};
  logic [3:0] bit_counter;
  logic [9:0] expected_frame;

  initial clk_i = '0;
  always #(CLK_PERIOD / 2) clk_i = ~clk_i;

  task write_fifo(input logic [7:0] data);
    $strobe("Writing data %0h to FIFO", data);
    tx_wen_i = 1;  // tx write enable 1
    din_i = data;  // send data to uart tx data input
    @(posedge clk_i);
    tx_wen_i = 0;
    @(posedge clk_i);
  endtask

  task verifying_tx_bit(input logic expected_bit, input int bit_index);
    @(negedge clk_i);
    if (expected_bit !== tx_bit_o) begin
      $error("ERROR! TX bit verification failed! At bit %0d, expected bit %0b but got: %0b", bit_index, expected_bit, tx_bit_o);
    end else begin
      $info("INFO: TX bit verification successful. Bit %0d is %0b", bit_index, tx_bit_o);
    end
  endtask

  initial begin
    tx_en_i  <= 0;
    tx_wen_i <= 0;
    din_i    <= 0;
    rst_ni   <= 0;
    repeat (2) @(posedge clk_i);
    rst_ni <= 1;

    $display("INFO: Writing data to FIFO ");
    for (int i = 0; i < test_data_array.size(); ++i) begin
      write_fifo(test_data_array[i]);
    end

    $display("INFO: TX enabling and starting transmission ");
    tx_en_i <= 1;

    for (int i = 0; i < test_data_array.size(); ++i) begin
      @(posedge clk_i);
      expected_frame = {1'b1, test_data_array[i], 1'b0};  // stop_bit,test_data,start_bit

      $display("INFO: Testing start bit");
      verifying_tx_bit(expected_frame[0], 0);

      for (bit_counter = 1; bit_counter < 9; bit_counter++) begin
        #BAUD_CLK_PERIOD;
        verifying_tx_bit(expected_frame[bit_counter], bit_counter);
      end

      #BAUD_CLK_PERIOD;
      $display("INFO: Testing stop bit");
      verifying_tx_bit(expected_frame[9], 9);
      #BAUD_CLK_PERIOD;

    end

    wait (empty_o && bit_counter == 9);
    #100ns;
    $display("INFO: All data transmitted! Verification is completed successfully!");
    $finish;

  end



endmodule
