`timescale 1ns / 1ps

module tb_gray_code;


  localparam DATA_WIDTH = 4;

  logic                  clk;
  logic                  rst_n;
  logic                  gray_en;
  logic [DATA_WIDTH-1:0] binary_out;
  logic [DATA_WIDTH-1:0] gray_out;

  logic [DATA_WIDTH-1:0] check_binary;

  gray_code #(.DATA_WIDTH(DATA_WIDTH)) dut (.*);

  initial begin
    clk = 0;
  end
  always #10 clk = ~clk;

  function [DATA_WIDTH-1:0] gray_to_bin(input [DATA_WIDTH-1:0] gray);
    logic [DATA_WIDTH-1:0] bin;
    bin[DATA_WIDTH-1] = gray[DATA_WIDTH-1];
    for (int i = DATA_WIDTH - 2; i >= 0; --i) begin
      bin[i] = bin[i+1] ^ gray[i];
    end
    return bin;
  endfunction


  initial begin
    rst_n   = 0;
    gray_en = 0;
    #25 rst_n = 1;

    $info("\n--- TEST STARTED ---");
    $info(" INFO: Time\tBin\tGray\tCheck");
    $info("---------------------------------------");

    repeat (20) begin
      @(posedge clk);
      gray_en = 1;
      #2;
      check_binary = gray_to_bin(gray_out);

      $info("INFO: Time:%0t\t Binary_out:%0d\t Gray_out:%b\t Check_binary:%0d", $time, binary_out, gray_out, check_binary);

      if (binary_out !== check_binary) $error("ERROR! Gray converter wrong! Binary_out:%d, Check_binary:%d", binary_out, check_binary);
    end

    $info("---------------------------------------");
    $info("INFO: TEST COMPLETED! EXAMINE RESULTS.");
    $finish;
  end



endmodule
